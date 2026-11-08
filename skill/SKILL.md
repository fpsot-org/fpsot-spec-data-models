---
name: fpsot-data-models
description: Data model rules for FPSOT projects. Use when designing or changing a LinkML model, an entity, a party, person or organization record, a contact mechanism, a jurisdiction extension, or a storage mapping such as SQL tables or OFBiz entity definitions.
---

# FPSOT data models

Summary of the FPSOT data models specification. It adds no rules of its own.
The spec text in `spec/` wins on any difference. Each line cites its requirement ID.
The Party model is in `model/party.yaml`.

Each line keeps the strength of its rule: "must" and "must not" are MUST and MUST NOT, "should" and "should not" are SHOULD and SHOULD NOT, "may" is MAY.

## Principles

- A model must describe exchanged and kept data: entities, fields, types, references, constraints. It must not describe behavior (DMO-001).
- Every part of a model is optional. A system may implement any part, or take it from another system, such as its own Party, Apache OFBiz or a remote service (DMO-002).
- A model must not say how data is stored: no tables, indexes or database products (DMO-003).
- A system must exchange the data of each part it implements or replaces in the model form. It may convert at its boundary (DMO-004).
- A model must not require a product, framework, application module or deployment style (DMO-005).
- A model should follow the universal data model patterns as Apache OFBiz implements them. A departure must be stated, with its reason, in the element description (DMO-006).

## LinkML source and generated files

- One LinkML schema must be the source, under `model/`; one subject area per file should be the norm (DMO-010).
- The schema must declare `id` (https URI), `name`, `title`, `description`, `version`, `license` and a `default_prefix` (DMO-011).
- It must import the data types model and must not redefine its types. A copy may be kept, unchanged, with its release named (DMO-012).
- Every class, slot, type and enum must have a description, which should cite requirement IDs (DMO-013).
- JSON Schema, SQL, OWL and SHACL files must be generated into `model/generated/`, never edited by hand (DMO-014).
- A check must regenerate them and fail on any difference, and CI must run it (DMO-015). The LinkML release must be fixed, and the check must fail under another one (DMO-016).
- Valid and invalid examples must exist and be checked (DMO-017). Run `model/test-model.sh`; after a model change, run it with `UPDATE=true` and commit the generated files.

## Names, keys and types

- Classes must be singular UpperCamelCase nouns; slots and enum values must follow the naming spec; use term base terms, no shortened words: `ContactMechanism`, not `ContactMech` (DMO-020).
- Each entity must have `id` with type `Uuid`; new ones should be UUID v7, and must be v4 when DAT-064 applies. An identifier from another body must not be the `id`. Value classes inlined in an entity, such as `PersonName`, have no `id` (DMO-021).
- A reference must be a slot holding the other entity's `id`, such as `partyId`. Composite keys must not be identifiers or reference targets; link entities must have their own `id`. Natural uniqueness may use LinkML `unique_keys` (DMO-022).
- A period must be a `validity` interval, never two date fields. It should be `DateInterval` or `InstantInterval`, as the fact needs. OFBiz `fromDate` maps to `start` and `thruDate` to `end`, with no shift into an `InstantInterval`. Into a `DateInterval`, the source time zone must be known, a `thruDate` after midnight ends on the next day, and a record with no `fromDate` must be flagged (DMO-023).
- Slots must use data types: `Instant`, `CalendarDate`, `Money`, `MultilingualText` for published text. Text a person enters must be a plain string as written (DMO-024).

## Codes, names and contact data

- Kinds, roles, purposes and statuses must be codes from a controlled vocabulary, never type entities (DMO-030).
- When codes vary by institution, the slot may be `CodeValue`; its description must name the kind of scheme, and the deployment must name the scheme (DMO-031).
- A person name must have a required `fullName`; `givenNames` and `familyName` must be optional; no title required; no restrictive pattern (DMO-032).
- A postal address must have separate slots; only `country` (ISO 3166-1 alpha-2) is required; region and postal code keep the issuer form; nothing is translated (DMO-033).
- Telephone numbers must be exchanged in E.164 form, such as `+14185550123`, with the extension separate; a short code such as 211 must be a `TelephoneShortCode`. Email addresses must be exchanged as written, without changing the case of the local part (DMO-034).
- Organization names must be plain strings as registered, one entry per language with its tag (DMO-035).
- A slot about a person must not be required unless every use needs it (DMO-036).

## Party subject area

- `Party` must be abstract; each party must be one `Person` or one `Organization`, with `partyType` `person` or `organization` (DMO-040).
- A `Person` may hold names and a `birthDate` (DMO-041). An `Organization` may hold names (DMO-042).
- Roles must be `PartyRole` entities with a code and a period, never subclasses or flags (DMO-043).
- Relationships must be `PartyRelationship` entities with both parties, both roles, a type and a period; they read from the first party to the second, such as employer to employee, as in OFBiz (DMO-044).
- Addresses, telephone numbers, telephone short codes and email addresses must be `ContactMechanism` entities, linked through `PartyContactMechanism` with purposes and a period; they may be shared (DMO-045).
- Identifiers issued by other bodies must be `PartyIdentification` entities: scheme code and value in the issuer form (DMO-046).
- Categories must be `PartyClassification` entities: scheme URI, code and period (DMO-047).

## Audit, history and extensions

- Every entity must have `createdAt` and `updatedAt` instant slots. A record that a system of record emits must hold both; a record sent in to be created may omit them. They must never serve as validity. Who changed what should go in a separate audit log (DMO-050).
- Past facts must stay retrievable as ended records in the model form; when a fact changes, the old record must end where the new one starts; a correction may replace the record (DMO-051). A record must not be deleted only because its period ended (DMO-052).
- Jurisdiction fields go in the one `extensions` object; each member must be named after the ISO 3166 code in lowerCamelCase, such as `caQc`, and its value must be an object. A jurisdiction with no code must nest under the nearest coded one, such as `caQc.montreal`; a body that is not a jurisdiction, such as the EU, must use its registered name (DMO-053).
- Jurisdiction fields must not sit beside core fields or carry a prefix or namespace (DMO-054).
- Each member must be defined by a jurisdiction profile in its own LinkML schema, citing its legal source; the core must not change (DMO-055).
- Systems must keep unknown extension members and must not reject them; a member must not redefine a core field (DMO-056). A field that several jurisdictions share should move into the core (DMO-057).

## Versions and deprecation

- Each release must have a Semantic Versioning number; the model version follows the repository tag, and a text-only release is a patch release (DMO-060).
- Within a major version, a release must not remove, rename or retype anything, make a slot required or narrow a pattern; it may add optional items (DMO-061).
- Retire an element with LinkML `deprecated` (reason and release), and `deprecated_element_has_exact_replacement` when one element replaces it; it must stay until the next major version (DMO-062).
- The schema `id` must not change; each release's files must stay available under its tag (DMO-063).
- Validate incoming data with the latest minor release of its major version (DMO-064, should).

## Persistence and tooling

- A persistence mapping must be a separate generated file; any store may be used (DMO-070).
- A mapping may add storage-only items, which must not change meaning or appear in exchanged data (DMO-071).
- An Entity Engine XML file may be published, and must then be generated and checked (DMO-072).
- A mapping from an existing model, such as OFBiz, must give every target, apply DMO-023 and DMO-050, and list fields with no target (DMO-073).
