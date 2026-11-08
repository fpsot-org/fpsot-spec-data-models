#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
#
# Tests the Party model:
#   - the LinkML release matches the one that generated the files (DMO-016);
#   - every file in generated/ matches a fresh generation from party.yaml (DMO-015);
#   - every example in examples/valid/ passes LinkML validation, and every one
#     in examples/invalid/ fails (DMO-017);
#   - when DATA_TYPES names a copy of the data types model, imports/data-types.yaml
#     is the same file (DMO-012).
#
# Run with the LinkML tools on the PATH, such as PATH=<venv>/bin:$PATH.
# Environment: PYTHON (default python3, the Python of the LinkML install),
# DATA_TYPES (optional), UPDATE=true to rewrite generated/ instead of checking it.
set -u
here="$(cd "$(dirname "$0")" && pwd)"
python=${PYTHON:-python3}
model="$here/party.yaml"
tests="$here/examples/test-schema.yaml"
want_linkml=1.12.1
fail=0

have=$($python -I -c 'import importlib.metadata as m; print(m.version("linkml"))' 2>/dev/null)
if [ "$have" != "$want_linkml" ]; then
  echo "FAIL: LinkML $want_linkml is required, found ${have:-none}"; exit 1
fi

# One line per generated file: file name, then the generator command.
generate() {
  case "$1" in
    party.json) gen-json-schema "$model" ;;
    party.sql) gen-sqltables --dialect postgresql "$model" ;;
    party-owl.ttl) gen-owl "$model" ;;
    party-shacl.ttl) gen-shacl "$model" ;;
  esac
}
for f in party.json party.sql party-owl.ttl party-shacl.ttl; do
  if [ "${UPDATE:-false}" = true ]; then
    generate "$f" 2>/dev/null > "$here/generated/$f" || { echo "FAIL: cannot generate $f"; fail=1; }
  elif ! generate "$f" 2>/dev/null | cmp -s - "$here/generated/$f"; then
    echo "FAIL: generated/$f does not match party.yaml; run with UPDATE=true and commit the result"; fail=1
  fi
done

if [ -n "${DATA_TYPES:-}" ] && ! cmp -s "$DATA_TYPES" "$here/imports/data-types.yaml"; then
  echo "FAIL: imports/data-types.yaml differs from $DATA_TYPES"; fail=1
fi

while IFS= read -r f; do
  if ! linkml-validate -s "$tests" -C Examples "$f" >/dev/null 2>&1; then
    echo "FAIL: valid example rejected: $f"; linkml-validate -s "$tests" -C Examples "$f" 2>&1 | tail -3; fail=1
  fi
done < <(find "$here/examples/valid" -name '*.yaml' | sort)
while IFS= read -r f; do
  if linkml-validate -s "$tests" -C Examples "$f" >/dev/null 2>&1; then
    echo "FAIL: invalid example accepted: $f"; fail=1
  fi
done < <(find "$here/examples/invalid" -name '*.yaml' | sort)
[ $fail -eq 0 ] && echo "PASS"
exit $fail
