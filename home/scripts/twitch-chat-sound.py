#!/usr/bin/env python3
"""Play an OS sound whenever a message is posted in a Twitch channel's chat.

Connects anonymously (read-only) to Twitch IRC, so no account or OAuth token
is required. Reconnects automatically on disconnect.

Usage:   twitch-chat-sound <channel> [cooldown_seconds]
Env:     TWITCH_SOUND           path to the sound file to play (optional)
         TWITCH_PLAYER          player command, default "paplay"
         TWITCH_PLAY_SOUND      whether or not to play the sound
         TWITCH_NOTIFY          if set, also show each message via notify-send
         TWITCH_NOTIFY_TIMEOUT  if set, also sets a timeout for notify-send
"""
import os
import random
import socket
import ssl
import subprocess
import sys
import time

HOST = "irc.chat.twitch.tv"
PORT = 6697


def play(player, sound):
    cmd = [player] + ([sound] if sound else [])
    try:
        subprocess.Popen(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    except FileNotFoundError:
        print(f"[twitch-chat-sound] player not found: {player}", file=sys.stderr)


def notify(user, msg, timeout):
    try:
        subprocess.Popen(
            ["notify-send", "-a", "twitch-chat", user, msg, "-t", str(timeout)],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
    except FileNotFoundError:
        print("[twitch-chat-sound] notify-send not found", file=sys.stderr)


def main():
    if len(sys.argv) < 2:
        print("usage: twitch-chat-sound <channel> [cooldown_seconds]", file=sys.stderr)
        sys.exit(1)

    channel = sys.argv[1].lstrip("#").lower()
    cooldown = float(sys.argv[2]) if len(sys.argv) > 2 else 0.0
    sound = os.environ.get("TWITCH_SOUND", "")
    player = os.environ.get("TWITCH_PLAYER", "paplay")
    do_notify = bool(os.environ.get("TWITCH_NOTIFY"))
    timeout = os.environ.get("TWITCH_NOTIFY_TIMEOUT") or 1000000
    should_play = bool(os.environ.get("TWITCH_PLAY_SOUND"))
    nick = f"justinfan{random.randint(10000, 99999)}"
    last = -1.0

    while True:
        try:
            raw = socket.create_connection((HOST, PORT), timeout=30)
            ctx = ssl.create_default_context()
            sock = ctx.wrap_socket(raw, server_hostname=HOST)
            sock.sendall(f"NICK {nick}\r\n".encode())
            sock.sendall(f"JOIN #{channel}\r\n".encode())
            sock.settimeout(360)
            print(f"[twitch-chat-sound] listening to #{channel}", file=sys.stderr)

            buf = ""
            while True:
                data = sock.recv(4096)
                if not data:
                    raise OSError("connection closed by server")
                buf += data.decode("utf-8", "replace")
                while "\r\n" in buf:
                    line, buf = buf.split("\r\n", 1)
                    if line.startswith("PING"):
                        sock.sendall(line.replace("PING", "PONG", 1).encode() + b"\r\n")
                    elif "PRIVMSG" in line:
                        try:
                            prefix, rest = line.split(" PRIVMSG ", 1)
                            user = prefix.split("!", 1)[0].lstrip(":")
                            msg = rest.split(" :", 1)[1]
                        except (IndexError, ValueError):
                            user, msg = "?", ""
                        print(f"<{user}> {msg}", file=sys.stderr)
                        if user == "schnozzlecat":
                            continue
                        if do_notify:
                            notify(user, msg, timeout)
                        now = time.monotonic()
                        if should_play and (last < 0 or now - last >= cooldown):
                            last = now
                            play(player, sound)
        except (OSError, ssl.SSLError) as exc:
            print(
                f"[twitch-chat-sound] {exc}; reconnecting in 5s",
                file=sys.stderr,
            )
            time.sleep(5)
        except KeyboardInterrupt:
            sys.exit(0)


if __name__ == "__main__":
    main()
