"""Restore the unix permissions recorded in an extracted .NET pack.

NuGet zips do not carry permissions; packs with executables (emscripten,
node, mono-aot-cross, ...) list them in data/UnixFilePermissions.xml, which
`dotnet workload install` applies on extraction.
usage: fix-nupkg-permissions.py <extracted pack dir>
"""

import os
import re
import sys

root = sys.argv[1]
manifest = os.path.join(root, "data", "UnixFilePermissions.xml")
if os.path.isfile(manifest):
    with open(manifest, encoding="utf-8") as f:
        entries = re.findall(r'Path="([^"]+)" Permission="(\d+)"', f.read())
    for path, perm in entries:
        target = os.path.join(root, path)
        if os.path.isfile(target) and not os.path.islink(target):
            os.chmod(target, int(perm, 8))
