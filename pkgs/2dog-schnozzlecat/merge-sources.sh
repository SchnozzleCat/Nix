# File-level 3-way merge: apply the changes from $base -> $fork onto $target
# (the 2dog libgodot tree), like `git merge`, failing loudly on conflicts.
# usage: merge-sources.sh <base> <fork> <target(writable)>
set -euo pipefail
base=$(realpath "$1") fork=$(realpath "$2") target=$(realpath "$3")
conflicts=0
while IFS= read -r -d '' rel; do
  b="$base/$rel" f="$fork/$rel" t="$target/$rel"
  # unchanged by the fork -> keep target's version
  if [[ -e $b && -e $f ]] && cmp -s "$b" "$f"; then continue; fi
  if [[ ! -e $f ]]; then
    # deleted by the fork
    if [[ ! -e $t ]]; then continue; fi
    if [[ -e $b ]] && cmp -s "$b" "$t"; then rm -f "$t"; continue; fi
    echo "CONFLICT (modify/delete): $rel" >&2; conflicts=$((conflicts + 1)); continue
  fi
  if [[ ! -e $t ]]; then
    if [[ -e $b ]]; then
      echo "CONFLICT (delete/modify): $rel" >&2; conflicts=$((conflicts + 1)); continue
    fi
    mkdir -p "$(dirname "$t")"; cp -p "$f" "$t"; continue
  fi
  if cmp -s "$f" "$t"; then continue; fi                      # same change on both sides
  if [[ -e $b ]] && cmp -s "$b" "$t"; then cp -p "$f" "$t"; continue; fi  # only the fork changed it
  # both sides changed (or both added): textual 3-way merge
  if [[ -e $b ]]; then bb=$b; else bb=$(mktemp); fi
  if ! git merge-file -q -L 2dog -L base -L fork "$t" "$bb" "$f"; then
    echo "CONFLICT (content): $rel" >&2; conflicts=$((conflicts + 1))
  fi
  # carry over the executable bit set by the fork
  [[ -x $f ]] && chmod +x "$t"
done < <(cd "$fork" && find . \( -type f -o -type l \) -printf '%P\0'; cd "$base" && find . \( -type f -o -type l \) -printf '%P\0' | while IFS= read -r -d '' p; do [[ -e "$fork/$p" ]] || printf '%s\0' "$p"; done)
if (( conflicts > 0 )); then
  echo "$conflicts merge conflict(s) between the fork and the 2dog libgodot branch; resolve them in a merged fork branch and point forkRev at it." >&2
  exit 1
fi
