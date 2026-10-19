/**
 * pi instance reporter -- feeds the Noctalia "linus/pi-instances" plugin.
 *
 * Every running pi process writes one small JSON report to
 *
 *   ${PI_INSTANCES_STATE_DIR:-${XDG_CACHE_HOME:-~/.cache}/pi-instances}/<uuid>.json
 *
 * and removes it on shutdown. The Noctalia plugin (home/config/noctalia/
 * pi-instances/) reads that directory and renders the status light:
 * green = done, yellow = working, red = waiting for input.
 *
 * ~/.cache is used rather than ~/.local/state on purpose: the bwrap jail
 * (lib/jailed-pi.nix) bind-mounts ~/.cache (and ~/.pi) read-write while the
 * jail's ~/.local is an ephemeral tmpfs, so a jailed pi's reports would
 * otherwise be invisible to the host.
 *
 * Identity and liveness: jailed pi processes run in an unshared PID
 * namespace (their process.pid is a namespace pid, e.g. 2, and /proc/1 is
 * bwrap), so pids cannot be used for identification or liveness checks
 * across the jail boundary. Each instance therefore gets a random id
 * (crypto.randomUUID) for its file name and keeps its report fresh with a
 * 20 s heartbeat; readers treat a report as live while its updatedAtEpoch
 * is within a TTL (the plugin uses 120 s) and garbage-collect stale ones
 * (SIGKILLed instances disappear within the TTL).
 *
 * States reported:
 *   working        agent loop is running (before_agent_start .. agent_settled)
 *   done           agent finished its run and nothing is pending
 *   waiting_input  a blocking extension UI prompt is up, or the finished
 *                  run ended with a question (heuristic on the last
 *                  assistant message), or the session has just started and
 *                  is waiting for its first prompt
 *
 * This file is installed by home-manager as
 * ~/.pi/agent/extensions/instance-report.ts, pi's global auto-discovery
 * location, so every pi process (TUI, RPC, pi.nvim) loads it. Editing it
 * is picked up by new pi processes; /reload hot-reloads running ones.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { randomUUID } from "node:crypto";
import * as fs from "node:fs";
import { homedir } from "node:os";
import * as path from "node:path";

/** Optional override for tests / unusual setups. */
const stateDir: string =
  process.env.PI_INSTANCES_STATE_DIR ??
  path.join(
    process.env.XDG_CACHE_HOME ?? path.join(homedir(), ".cache"),
    "pi-instances",
  );

const HEARTBEAT_MS = 20_000;

type State = "working" | "done" | "waiting_input";

interface Report {
  /** Random per-process id; also the report file name. */
  id: string;
  /** Informational: the *namespace* pid -- a host pid outside the bwrap
   *  jail, but a jail-namespace pid inside it. Not usable for liveness. */
  pid: number;
  /** True when /proc/1 is bwrap, i.e. the process runs in the jail. */
  sandboxed: boolean;
  startedAt: string;
  startedAtEpoch: number;
  state: State;
  stateSince: string;
  stateSinceEpoch: number;
  turns: number;
  runs: number;
  /** session name (from /name) or the cwd basename -- what the bar shows. */
  label?: string;
  sessionId?: string;
  sessionFile?: string;
  cwd?: string;
  model?: string;
  thinkingLevel?: string;
  lastTool?: string;
  /** One-line "what is it doing right now" (thinking / tool). */
  activity?: string;
  /** Start of the last user prompt, truncated with an ellipsis. Shown in
   *  the foldout; kept after the run settles (not session-scoped state). */
  lastPrompt?: string;
  uiPromptKind?: string;
  uiPromptTitle?: string;
  lastActivityEpoch: number;
  updatedAt: string;
  updatedAtEpoch: number;
}

/** A finished assistant message that ends in a question (or an obvious
 *  "your call" phrasing) means the agent is waiting on the user. */
const QUESTION_RE =
  /\?\s*$|\b(should i|shall i|do you want|would you like|want me to|which (?:one|option|approach)|let me know|your call|your preference|thoughts)\b/i;

/** Compact one-line summary of what a tool call is doing, from its
 *  arguments -- e.g. "bash $ cargo test", "edit src/main.ts". */
function clipText(s: unknown, n = 64): string {
  const t = String(s ?? "").replace(/\s+/g, " ").trim();
  return t.length > n ? `${t.slice(0, n - 1)}…` : t;
}

function describeTool(name: string, input: any): string {
  const base = (s: unknown): string =>
    s ? `${name} ${clipText(path.basename(String(s)), 48)}` : name;
  switch (name) {
    case "bash":
      return input?.command
        ? `bash $ ${clipText(String(input.command).split("\n")[0])}`
        : "bash";
    case "read":
    case "write":
    case "edit":
      return base(input?.path);
    case "grep":
    case "find":
    case "ls":
      return base(input?.path ?? input?.pattern);
    case "web_search":
    case "fetch":
    case "web_fetch":
      return base(input?.query ?? input?.url);
    default: {
      // Extension/custom tools: fall back to the first short string arg.
      for (const value of Object.values(input ?? {})) {
        if (typeof value === "string" && value.trim()) {
          return `${name} ${clipText(value, 48)}`;
        }
      }
      return name;
    }
  }
}

function assistantText(message: any): string {
  const content = message?.content;
  if (typeof content === "string") return content;
  if (Array.isArray(content)) {
    return content
      .filter((part: any) => part?.type === "text")
      .map((part: any) => part.text ?? "")
      .join("\n");
  }
  return "";
}

/** The bwrap jail runs the sandbox in its own PID namespace, so /proc/1
 *  is bwrap inside it (and the real init outside). */
function isSandboxed(): boolean {
  try {
    return fs.readFileSync("/proc/1/comm", "utf8").trim() === "bwrap";
  } catch {
    return false;
  }
}

export default function instanceReporter(pi: ExtensionAPI) {
  const id = randomUUID();
  const file = path.join(stateDir, `${id}.json`);
  const sandboxed = isSandboxed();
  const nowIso = () => new Date().toISOString();
  const nowEpoch = () => Math.floor(Date.now() / 1000);

  const report: Report = {
    id,
    pid: process.pid,
    sandboxed,
    startedAt: nowIso(),
    startedAtEpoch: nowEpoch(),
    // A fresh session has done nothing yet: it waits for its first prompt.
    state: "waiting_input",
    stateSince: nowIso(),
    stateSinceEpoch: nowEpoch(),
    turns: 0,
    runs: 0,
    lastActivityEpoch: nowEpoch(),
    updatedAt: nowIso(),
    updatedAtEpoch: nowEpoch(),
  };

  let agentActive = false;
  let uiPrompt = false;
  let lastSettled: State | undefined;
  let lastAssistantText = "";

  function persist(patch: Partial<Report> = {}) {
    Object.assign(report, patch, {
      lastActivityEpoch: nowEpoch(),
      updatedAt: nowIso(),
      updatedAtEpoch: nowEpoch(),
    });
    try {
      fs.mkdirSync(stateDir, { recursive: true });
      const tmp = `${file}.tmp`;
      fs.writeFileSync(tmp, `${JSON.stringify(report, null, 2)}\n`);
      fs.renameSync(tmp, file); // atomic: readers never see a partial file
    } catch {
      // Reporting must never take the agent down (read-only fs, full disk, ..)
    }
  }

  // Heartbeat: keeps updatedAtEpoch fresh while the instance idles for
  // hours between turns, so the reader's TTL liveness check works. The
  // timer is unref'd so it never keeps the process alive on its own.
  const heartbeat: ReturnType<typeof setInterval> | undefined = setInterval(
    () => persist(),
    HEARTBEAT_MS,
  );
  heartbeat?.unref?.();

  function setState(state: State, patch: Partial<Report> = {}) {
    report.state = state;
    report.stateSince = nowIso();
    report.stateSinceEpoch = nowEpoch();
    persist(patch);
  }

  function removeReport() {
    if (heartbeat) clearInterval(heartbeat);
    try {
      fs.rmSync(file, { force: true });
      fs.rmSync(`${file}.tmp`, { force: true });
    } catch {
      /* best effort */
    }
  }

  function labelFor(ctx: any): string {
    const name = pi.getSessionName?.();
    if (name) return name;
    try {
      return path.basename(ctx.cwd ?? "") || "pi";
    } catch {
      return "pi";
    }
  }

  function modelFor(ctx: any): string | undefined {
    const model = ctx.model;
    return model ? `${model.provider}/${model.id}` : undefined;
  }

  pi.on("session_start", async (_event, ctx) => {
    report.sessionId = ctx.sessionManager?.getSessionId?.();
    report.sessionFile = ctx.sessionManager?.getSessionFile?.() ?? undefined;
    report.cwd = ctx.cwd;
    report.label = labelFor(ctx);
    report.model = modelFor(ctx);
    report.thinkingLevel = ctx.thinkingLevel;
    agentActive = false;
    uiPrompt = false;
    lastSettled = undefined;
    lastAssistantText = "";
    setState("waiting_input");
  });

  // Fires the moment the user submits a prompt, slightly before agent_start.
  pi.on("before_agent_start", async (event, ctx) => {
    report.cwd = ctx.cwd;
    agentActive = true;
    lastAssistantText = "";
    setState("working", {
      lastPrompt: event.prompt ? clipText(event.prompt, 80) : undefined,
      // The prompt itself is now shown via lastPrompt; the next assistant
      // message_start sets "thinking…" within moments.
      activity: undefined,
    });
  });

  pi.on("agent_start", async (_event, ctx) => {
    agentActive = true;
    report.cwd = ctx.cwd;
    if (!report.model) report.model = modelFor(ctx);
    setState("working");
  });

  // Each LLM call in the run: the model is thinking/composing.
  pi.on("message_start", async (event) => {
    if (event.message?.role === "assistant") {
      persist({ activity: "thinking…" });
    }
  });

  pi.on("turn_start", async (event) => {
    report.turns = event.turnIndex + 1;
    persist(); // keeps "lastActivity" fresh while long turns run
  });

  pi.on("tool_execution_start", async (event) => {
    // NOTE: this event carries the arguments as `args` (the `tool_call`
    // event uses `input`).
    report.lastTool = event.toolName;
    persist({ activity: describeTool(event.toolName, event.args) });
  });

  pi.on("message_end", async (event) => {
    if (event.message?.role === "assistant") {
      lastAssistantText = assistantText(event.message);
    }
    persist();
  });

  // Blocking extension UI prompts (ctx.ui.select/confirm/input/editor/custom):
  // the agent is alive but cannot continue until the user answers.
  pi.on("ui_prompt_start", async (event) => {
    uiPrompt = true;
    setState("waiting_input", {
      activity: `prompt: ${event.title ?? event.kind}`,
      uiPromptKind: event.kind,
      uiPromptTitle: event.title,
    });
  });

  pi.on("ui_prompt_end", async () => {
    uiPrompt = false;
    if (agentActive) {
      setState("working", { uiPromptKind: undefined, uiPromptTitle: undefined });
    } else {
      setState(lastSettled ?? "waiting_input", {
        uiPromptKind: undefined,
        uiPromptTitle: undefined,
      });
    }
  });

  // agent_end alone can be followed by an auto-retry, auto-compaction retry
  // or a queued follow-up, so the state only settles on agent_settled.
  pi.on("agent_settled", async (_event, ctx) => {
    agentActive = false;
    const asks =
      lastAssistantText.trim().length > 0 &&
      QUESTION_RE.test(lastAssistantText.trim());
    lastSettled = asks ? "waiting_input" : "done";
    report.runs += 1;
    report.cwd = ctx.cwd;
    setState(lastSettled, { activity: undefined });
  });

  pi.on("session_info_changed", async (event) => {
    report.label = event.name ?? report.label;
    persist();
  });

  pi.on("model_select", async (event) => {
    report.model = `${event.model.provider}/${event.model.id}`;
    persist();
  });

  pi.on("session_shutdown", async () => {
    // Covers quit AND session replacement (/new, /resume, /fork, /reload);
    // session_start of the replacement rewrites the report immediately.
    removeReport();
  });

  // Anything short of SIGKILL (normal exit, Ctrl-C, signal-triggered
  // shutdown) lands here. A SIGKILLed instance lingers until the reader's
  // TTL garbage-collects its report.
  process.on("exit", removeReport);

  // Cover modes that emit no session_start event of their own.
  persist();
}
