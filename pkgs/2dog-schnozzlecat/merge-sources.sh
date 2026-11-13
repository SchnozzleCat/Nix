# File-level 3-way merge: apply the changes from $base -> $fork onto $target
# (the 2dog libgodot tree), like `git merge`, failing loudly on conflicts.
# usage: merge-sources.sh <base> <fork> <target(writable)>
#
# Verified to produce the same tree as `git merge` for 2dog-4.7 (7606ec3)
# + SchnozzleCat 7da4fae over 4.7-stable.
set -euo pipefail
base=$(realpath "$1") fork=$(realpath "$2") target=$(realpath "$3")
conflicts=0

# Copy a fork file into the target: content + executable bit (sources may be
# read-only store paths, so never copy their mode verbatim).
take() {
  mkdir -p "$(dirname "$2")"
  rm -f "$2"
  if [[ -L $1 ]]; then
    ln -s "$(readlink "$1")" "$2"
  else
    cp "$1" "$2"
    chmod u+w "$2"
    if [[ -x $1 ]]; then chmod +x "$2"; else chmod -x "$2"; fi
  fi
}

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
    take "$f" "$t"; continue
  fi
  if cmp -s "$f" "$t"; then continue; fi                         # same change on both sides
  if [[ -e $b ]] && cmp -s "$b" "$t"; then take "$f" "$t"; continue; fi  # only the fork changed it
  # both sides changed (or both added): textual 3-way merge
  if [[ -e $b ]]; then bb=$b; else bb=$(mktemp); fi
  if ! git merge-file -q -L 2dog -L base -L fork "$t" "$bb" "$f"; then
    echo "CONFLICT (content): $rel" >&2; conflicts=$((conflicts + 1))
  fi
  if [[ -x $f ]]; then chmod +x "$t"; fi
done < <(
  cd "$fork" && find . \( -type f -o -type l \) -printf '%P\0'
  cd "$base" && find . \( -type f -o -type l \) -printf '%P\0' |
    while IFS= read -r -d '' p; do [[ -e "$fork/$p" || -L "$fork/$p" ]] || printf '%s\0' "$p"; done
)

if ((conflicts > 0)); then
  echo "$conflicts merge conflict(s) between the fork and the 2dog libgodot branch;" \
    "resolve them in a merged fork branch and point the fork rev at it." >&2
  exit 1
fi
