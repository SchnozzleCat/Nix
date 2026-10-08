{
  lib,
  python3,
  raspberrypifw,
  runCommand,
}:
# raspberrypifw, with the Pi 5 family DTBs patched so U-Boot's pl01x driver
# can bind the debug UART (uart10). Without this, U-Boot hangs at its splash
# logo before reading extlinux.conf. See patch-dtbs.py for details.
runCommand "raspberrypifw-uart10-fixed"
{
  nativeBuildInputs = [python3];
  meta = {
    inherit (raspberrypifw.meta) description homepage license;
  };
}
''
  cp -r ${raspberrypifw} "$out"
  chmod -R u+w "$out"
  python3 ${./patch-dtbs.py} patch "$out/share/raspberrypi/boot"
''