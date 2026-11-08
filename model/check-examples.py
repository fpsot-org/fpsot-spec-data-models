# SPDX-License-Identifier: Apache-2.0
"""Checks example files against the generated JSON Schema and SHACL shapes.

Usage: python -I check-examples.py SCHEMA CLASS JSON_SCHEMA SHACL (valid|invalid|accepted) FILE...

- valid: both checks must accept the file.
- invalid: both checks must reject the file, and the errors must match the
  regular expressions of its "# expect-json:" and "# expect-shacl:" comments.
  A JSON error reads like "'country' is a required property", and a SHACL
  error starts with the local name of its path, such as "country: Less than 1".
  "# expect-shacl: accepted" states that SHACL cannot see the broken rule; the
  comment must then give the reason, and the SHACL check must accept the file.
- accepted: both checks must accept the file, which another schema, such as a
  jurisdiction profile, rejects (DMO-056).

The RDF form follows the schema: each object gets the rdf:type of its class
and of every ancestor, a UUID identifier becomes a urn:uuid: IRI, an enumeration
value becomes the IRI of its meaning, a URI becomes an IRI, and a typed value
keeps its lexical form with the XSD datatype of its type. A key that the schema does not define becomes
a property in the namespace of the model, so that a closed shape reports it.
"""
import json
import re
import sys

import jsonschema
import yaml
from linkml_runtime.utils.schemaview import SchemaView
from pyshacl import validate
from rdflib import RDF, SH, XSD, BNode, Graph, Literal, URIRef


def expectations(path):
    found = {}
    with open(path, encoding="utf-8") as f:
        for line in f:
            m = re.match(r"#\s*expect-(json|shacl):\s*(.*\S)", line)
            if m:
                found[m.group(1)] = m.group(2)
    return found


class Converter:
    def __init__(self, sv):
        self.sv = sv
        self.base = sv.schema.default_prefix
        self.ns = sv.namespaces()[self.base]
        self.classes = set(sv.all_classes())
        self.enums = set(sv.all_enums())
        self.types = set(sv.all_types())

    def node(self, g, obj, cls):
        sv = self.sv
        ident = sv.get_identifier_slot(cls)
        if ident is not None and ident.name in obj:
            node = URIRef("urn:uuid:" + str(obj[ident.name]))
        else:
            node = BNode()
        for c in sv.class_ancestors(cls):
            g.add((node, RDF.type, URIRef(sv.get_uri(c, expand=True))))
        slots = {s.name: s for s in sv.class_induced_slots(cls)}
        for key, value in obj.items():
            if ident is not None and key == ident.name:
                continue
            slot = slots.get(key)
            pred = URIRef(sv.get_uri(slot, expand=True)) if slot else URIRef(self.ns + key)
            for item in value if isinstance(value, list) else [value]:
                g.add((node, pred, self.value(g, item, slot)))
        return node

    def value(self, g, item, slot):
        sv = self.sv
        rng = slot.range if slot is not None else None
        if rng in self.classes:
            if isinstance(item, dict):
                return self.node(g, item, rng)
            return URIRef("urn:uuid:" + str(item))
        if rng in self.enums:
            pv = sv.get_enum(rng).permissible_values.get(str(item))
            if pv is not None and pv.meaning:
                return URIRef(sv.expand_curie(pv.meaning))
            return Literal(item)
        if rng in self.types and isinstance(item, str):
            if {"uri", "uriorcurie"} & set(sv.type_ancestors(rng)):
                return URIRef(item)
            uri = sv.induced_type(rng).uri
            # The types of linkml:types use the xsd prefix, which the model itself does not declare.
            datatype = URIRef(XSD + uri[4:]) if uri.startswith("xsd:") else URIRef(sv.expand_curie(uri))
            # normalize=False keeps the lexical form, so that a pattern sees the value as written.
            return Literal(item, datatype=datatype, normalize=False)
        if isinstance(item, dict):
            node = BNode()
            for key, value in item.items():
                for sub in value if isinstance(value, list) else [value]:
                    g.add((node, URIRef(self.ns + key), self.value(g, sub, None)))
            return node
        return Literal(item)


def main():
    schema, cls, json_schema, shacl, mode, *files = sys.argv[1:]
    sv = SchemaView(schema)
    conv = Converter(sv)
    with open(json_schema, encoding="utf-8") as f:
        validator = jsonschema.Draft201909Validator(json.load(f))
    shapes = Graph().parse(shacl, format="turtle")
    fail = 0
    for path in files:
        with open(path, encoding="utf-8") as f:
            data = yaml.safe_load(f)
        json_errors = []
        for e in validator.iter_errors(data):
            json_errors += [e.message] + [sub.message for sub in e.context]
        g = Graph()
        conv.node(g, data, cls)
        conforms, report, _ = validate(g, shacl_graph=shapes, advanced=True)
        shacl_errors = []
        for result in report.objects(None, SH.result):
            local = str(report.value(result, SH.resultPath) or "").rsplit("/", 1)[-1]
            shacl_errors.append(f"{local}: {report.value(result, SH.resultMessage)}")
        exp = expectations(path)
        for check, errors in (("json", json_errors), ("shacl", shacl_errors)):
            want = exp.get(check)
            if mode in ("valid", "accepted") or (check == "shacl" and want and want.startswith("accepted")):
                if errors:
                    print(f"FAIL: {check} check rejected {path}: {errors[0]}")
                    fail = 1
                continue
            if not want:
                print(f"FAIL: {path} has no '# expect-{check}:' comment")
                fail = 1
            elif not errors:
                print(f"FAIL: {check} check accepted invalid example {path}")
                fail = 1
            elif not any(re.search(want, e) for e in errors):
                print(f"FAIL: {check} check rejected {path} for another reason: {errors[0]}")
                fail = 1
    sys.exit(fail)


if __name__ == "__main__":
    main()
