#!/usr/bin/env bash
# Prints the Apex tests to run for the current delta (space separated), or nothing.
#  - a changed class/trigger that is itself a test (@isTest)  -> run it
#  - a changed class/trigger "Foo"                            -> run FooTest or Foo_Test if one exists
set -euo pipefail
DELTA=changed-sources/force-app
declare -A tests=()


while IFS= read -r f; do
  name=$(basename "$f"); name=${name%.cls}; name=${name%.trigger}
  if [[ "$f" == *.cls ]] && grep -qi '@istest' "$f"; then
    tests["$name"]=1
  else
    for cand in "${name}Test" "${name}_Test"; do
      if [ -n "$(find force-app -name "$cand.cls" -print -quit)" ]; then tests["$cand"]=1; fi
    done
  fi
done < <(find "$DELTA" \( -name '*.cls' -o -name '*.trigger' \) 2>/dev/null)


if [ ${#tests[@]} -gt 0 ]; then printf '%s\n' "${!tests[@]}" | sort | paste -sd' ' -; fi
