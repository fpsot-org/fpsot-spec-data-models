# Instructions for agents

This repository holds the FPSOT data models specification: how FPSOT projects define and publish entity data models in LinkML, with generated JSON Schema, SQL, OWL and SHACL files, and the Party subject area.

- The normative text is in `spec/en/` and `spec/fr/`. Every rule has an ID such as `DMO-001`.
- Follow `skill/SKILL.md` when you design or change a data model in any FPSOT project. The spec text wins on any difference.
- `model/party.yaml` is the source of the Party model. After you change it, run `UPDATE=true model/test-model.sh` to regenerate `model/generated/`, then `model/test-model.sh`, and commit the source and the generated files together.
- Never edit `model/generated/` or `model/imports/data-types.yaml` by hand.
- Every page exists in English and in French, with the same file name and the same IDs.
- Terms and abbreviations come from the term base of `fpsot-spec-writing`. Add a missing term there first.
- This is a layer 1 specification. It may refer to the layer 0 specifications and to the data types and vocabularies specifications. It refers to API design only by topic, and never to the registry.
- Do not copy text, diagrams or attribute lists from Len Silverston's books. Summarize patterns in your own words, from the public Apache OFBiz model.
- Do not copy text from outside standards. Summarize them in your own words and cite the exact version.
- Commits follow Conventional Commits and are signed. Pull requests are squash-merged.
