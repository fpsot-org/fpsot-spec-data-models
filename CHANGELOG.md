# Changelog

All notable changes to this specification are listed here.
The format follows [Keep a Changelog 1.1.0](https://keepachangelog.com/en/1.1.0/),
and versions follow [Semantic Versioning 2.0.0](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2026-11-07

### Added

- Principles DMO-001 to DMO-006: models describe data, not behavior; every part is optional and replaceable; no storage, product or module is required; universal data model patterns as Apache OFBiz implements them.
- LinkML rules DMO-010 to DMO-017: one source per model, schema metadata, import of the data types model, descriptions, generated JSON Schema, SQL, OWL and SHACL files, a drift check in the continuous integration, a fixed LinkML release, and examples.
- Name, key and type rules DMO-020 to DMO-024: class names, UUID keys, references, validity intervals with the mapping from OFBiz fromDate and thruDate, and data types.
- Code and contact rules DMO-030 to DMO-036: codes bound to vocabularies, names of persons and organizations, postal addresses, telephone numbers, email addresses and sensitive data.
- Party rules DMO-040 to DMO-047: party, person, organization, party role, party relationship, contact mechanisms, identifications and classifications.
- Audit, history and extension rules DMO-050 to DMO-057, with one extensions object per jurisdiction.
- Version rules DMO-060 to DMO-064, and persistence rules DMO-070 to DMO-073 with the planned tooling.
- LinkML Party model `model/party.yaml`, its generated files, a copy of the data types model, an example Québec profile, examples and the test script `model/test-model.sh`.
- A `model` job in the continuous integration that runs the test script.
- Comparison data for thirteen topics, with Canada and Québec rows.
- How-to guide that builds a small Party example.

[Unreleased]: https://github.com/fpsot-org/fpsot-spec-data-models/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/fpsot-org/fpsot-spec-data-models/releases/tag/v0.1.0
