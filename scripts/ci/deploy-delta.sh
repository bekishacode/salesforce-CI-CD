#!/usr/bin/env bash
# Usage: deploy-delta.sh <from-ref> <validate|deploy>
# Deploys (or dry-run validates) ONLY what changed between <from-ref> and HEAD,
# running ONLY the tests found in that change. Needs an org logged in with alias "target".
set -euo pipefail
FROM="$1"; MODE="$2"
OUT=changed-sources


rm -rf "$OUT"; mkdir -p "$OUT"
sf sgd:source:delta --from "$FROM" --to HEAD --source-dir force-app/ --output-dir "$OUT/" --generate-delta


PKG="$OUT/package/package.xml"
DESTRUCTIVE="$OUT/destructiveChanges/destructiveChanges.xml"
HAS_ADD=false; HAS_DEL=false
grep -q '<members>' "$PKG" && HAS_ADD=true
{ [ -f "$DESTRUCTIVE" ] && grep -q '<members>' "$DESTRUCTIVE"; } && HAS_DEL=true


if [ "$HAS_ADD" = false ] && [ "$HAS_DEL" = false ]; then
  echo "No deployable metadata changes. Nothing to do."
  exit 0
fi
echo "Components to deploy:"; cat "$PKG"; echo


ARGS=(--manifest "$PKG" --target-org target --wait 60)


if [ "$HAS_DEL" = true ]; then
  echo "Components deleted in git will be removed from the org after the deploy:"; cat "$DESTRUCTIVE"; echo
  ARGS+=(--post-destructive-changes "$DESTRUCTIVE" --ignore-warnings)
fi


TESTS=$(bash scripts/ci/select-tests.sh)
APEX_CHANGED=$(find "$OUT/force-app" \( -name '*.cls' -o -name '*.trigger' \) -print -quit 2>/dev/null || true)
if [ -n "$TESTS" ]; then
  echo "Tests to run: $TESTS"
  read -ra T <<< "$TESTS"
  ARGS+=(--test-level RunSpecifiedTests --tests "${T[@]}")
elif [ -n "$APEX_CHANGED" ]; then
  echo "WARNING: Apex changed but no matching test class (<Name>Test) was found."
  echo "The org default applies (all local tests in a production-type org)."
else
  echo "No Apex in this change; no tests required."
fi


[ "$MODE" = "validate" ] && ARGS+=(--dry-run)
sf project deploy start "${ARGS[@]}"
