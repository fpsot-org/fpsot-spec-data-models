#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
#
# Tests the Party model:
#   - the LinkML and linkml-runtime releases match the ones that generated the
#     files (DMO-016);
#   - every file in generated/ matches a fresh generation from party.yaml (DMO-015);
#   - every example in examples/valid/ passes LinkML validation, the generated
#     JSON Schema and the generated SHACL shapes, and every one in
#     examples/invalid/ fails each of them for the reason that its comments
#     name (DMO-017);
#   - every example in examples/profile/ passes the core checks, and the
#     example Québec profile accepts the valid ones and rejects the invalid
#     ones (DMO-055, DMO-056);
#   - when DATA_TYPES names a copy of the data types model, imports/data-types.yaml
#     is the same file (DMO-012).
#
# Generation takes three recorded steps around the LinkML generators:
#   1. The generators read a temporary copy of the model whose data types
#      import keeps only the classes, enumerations and types that the Party
#      model uses. The test container and the unused classes of the data types
#      model, such as Money and Point, then stay out of every generated file.
#      The committed copy in imports/ stays unchanged (DMO-012).
#   2. The JSON Schema takes PartyContainer as its root class.
#   3. The SHACL shape of Extensions loses its "sh:closed true" and
#      "sh:ignoredProperties" lines, so that it accepts any member (DMO-056);
#      the SQL file gets a header comment (DMO-070).
#
# Run with the LinkML tools and the packages of requirements.txt on the PATH,
# such as PATH=<venv>/bin:$PATH. Environment: PYTHON (default python3, the Python
# of that install), DATA_TYPES (optional), UPDATE=true to rewrite generated/
# instead of checking it.
set -u
here="$(cd "$(dirname "$0")" && pwd)"
python=${PYTHON:-python3}
model="$here/party.yaml"
profile="$here/examples/ca-qc-profile.yaml"
fail=0

for pkg in linkml linkml-runtime; do
  want=$(sed -n "s/^$pkg==//p" "$here/requirements.txt")
  have=$($python -I -c "import importlib.metadata as m; print(m.version('$pkg'))" 2>/dev/null)
  if [ -z "$want" ] || [ "$have" != "$want" ]; then
    echo "FAIL: $pkg ${want:-(no pin in requirements.txt)} is required, found ${have:-none}"; exit 1
  fi
done

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

# Step 1: the temporary copy of the model, with a pruned data types import.
mkdir -p "$work/imports"
cp "$model" "$work/party.yaml"
$python -I - "$model" "$here/imports/data-types.yaml" > "$work/imports/data-types.yaml" <<'EOF' || { echo "FAIL: cannot prune the data types import"; exit 1; }
import sys
import yaml
from linkml_runtime.utils.schemaview import SchemaView

sv = SchemaView(sys.argv[1])
own = set(sv.all_classes(imports=False))
seen, enums, types = set(), set(), set()
todo = list(own)
while todo:
    c = todo.pop()
    if c in seen:
        continue
    seen.add(c)
    todo.extend(sv.class_ancestors(c))
    for s in sv.class_induced_slots(c):
        for r in [s.range] + [x.range for x in (s.any_of or [])]:
            if r in sv.all_classes():
                todo.append(r)
            elif r in sv.all_enums():
                enums.add(r)
            elif r in sv.all_types():
                types.update(sv.type_ancestors(r))
with open(sys.argv[2], encoding="utf-8") as f:
    dt = yaml.safe_load(f)
for key, used in (("classes", seen), ("enums", enums), ("types", types)):
    for name in list(dt.get(key) or {}):
        if name not in used:
            del dt[key][name]
    if key in dt and not dt[key]:
        del dt[key]
yaml.safe_dump(dt, sys.stdout, sort_keys=False, allow_unicode=True)
EOF

# Steps 2 and 3: one case per generated file.
generate() {
  case "$1" in
    party.json) gen-json-schema --top-class PartyContainer "$work/party.yaml" ;;
    party.sql)
      printf '%s\n' \
        '-- Raw output of the LinkML SQL generator (gen-sqltables) for PostgreSQL.' \
        '-- It shows the shape of a persistence mapping only, and is not a working mapping:' \
        '-- foreign keys to abstract classes, the extensions object and intervals do not' \
        '-- map to useful tables or columns. The model stays storage-independent (DMO-003, DMO-070).'
      gen-sqltables --dialect postgresql "$work/party.yaml" ;;
    party-owl.ttl) gen-owl "$work/party.yaml" ;;
    party-shacl.ttl)
      gen-shacl "$work/party.yaml" | awk '
        $0 == "party:Extensions a sh:NodeShape ;" { block = 1 }
        block && $0 ~ /^[[:space:]]*sh:closed true ;$/ { patched = 1; next }
        block && $0 ~ /^[[:space:]]*sh:ignoredProperties [^ ]+ ;$/ { next }
        block && / \.$/ { block = 0 }
        { print }
        END { if (!patched) exit 1 }' ;;
  esac
}
for f in party.json party.sql party-owl.ttl party-shacl.ttl; do
  if ! generate "$f" > "$work/$f" 2>"$work/$f.log"; then
    echo "FAIL: cannot generate $f"; tail -3 "$work/$f.log"; fail=1
  elif [ "${UPDATE:-false}" = true ]; then
    cp "$work/$f" "$here/generated/$f"
  elif ! cmp -s "$work/$f" "$here/generated/$f"; then
    echo "FAIL: generated/$f does not match party.yaml; run with UPDATE=true and commit the result"; diff -u "$here/generated/$f" "$work/$f" | head -40; fail=1
  fi
done
if grep -q 'Examples\|Money\|"Point"' "$here/generated/"*; then
  echo "FAIL: a generated file holds a class that the Party model does not use"; fail=1
fi

if [ -n "${DATA_TYPES:-}" ] && ! cmp -s "$DATA_TYPES" "$here/imports/data-types.yaml"; then
  echo "FAIL: imports/data-types.yaml differs from $DATA_TYPES"; fail=1
fi

# LinkML validation, with the expected text of each invalid example.
linkml_check() { # schema class mode file
  local out want
  out=$(linkml-validate -s "$1" -C "$2" "$4" 2>&1)
  local status=$?
  if [ "$3" = valid ]; then
    [ $status -eq 0 ] || { echo "FAIL: LinkML rejected valid example $4"; echo "$out" | tail -3; fail=1; }
  else
    want=$(sed -n 's/^# *expect-json: *//p' "$4")
    if [ $status -eq 0 ]; then
      echo "FAIL: LinkML accepted invalid example $4"; fail=1
    elif [ -z "$want" ] || ! grep -qE -- "$want" <<<"$out"; then
      echo "FAIL: LinkML rejected $4 for another reason:"; echo "$out" | tail -3; fail=1
    fi
  fi
}
examples() { find "$here/examples/$1" -maxdepth 1 -name '*.yaml' | sort; }
mapfile -t valid < <(examples valid)
mapfile -t invalid < <(examples invalid)
mapfile -t profile_valid < <(examples profile/valid)
mapfile -t profile_invalid < <(examples profile/invalid)

for f in "${valid[@]}"; do linkml_check "$model" PartyContainer valid "$f"; done
for f in "${invalid[@]}"; do linkml_check "$model" PartyContainer invalid "$f"; done
for f in "${profile_valid[@]}"; do linkml_check "$profile" QuebecPartyContainer valid "$f"; done
for f in "${profile_invalid[@]}"; do linkml_check "$profile" QuebecPartyContainer invalid "$f"; done

# JSON Schema and SHACL checks of the generated files.
check() { $python -I "$here/check-examples.py" "$model" PartyContainer \
  "$here/generated/party.json" "$here/generated/party-shacl.ttl" "$@" || fail=1; }
check valid "${valid[@]}"
check invalid "${invalid[@]}"
check valid "${profile_valid[@]}"
check accepted "${profile_invalid[@]}"

[ $fail -eq 0 ] && echo "PASS"
exit $fail
