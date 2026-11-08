# Terms needed

Entries to add to `termbase/terms.yaml` of `fpsot-spec-writing`, in its format.
The GDT search gave no record for SQL, XML, OWL or SHACL, and TERMIUM Plus returned HTTP 403.
Like the RDF and SKOS entries, these keep the English full form in French, from the standard that defines each one.

```yaml
  - id: owl
    kind: abbreviation
    en: {short: "OWL", full: "Web Ontology Language", definition: "The W3C language for describing the classes and properties of a domain, and the relations between them."}
    fr: {short: "OWL", full: "Web Ontology Language", definition: "Langage du W3C qui sert à décrire les classes et les propriétés d'un domaine, et les relations entre elles."}
    source: {name: "W3C, OWL 2 Web Ontology Language Document Overview (no GDT record found; TERMIUM Plus could not be read)", url: "https://www.w3.org/TR/owl2-overview/", checked: "2026-11-07"}
  - id: shacl
    kind: abbreviation
    en: {short: "SHACL", full: "Shapes Constraint Language", definition: "The W3C language for describing the conditions that RDF data must meet, so that a tool can check it."}
    fr: {short: "SHACL", full: "Shapes Constraint Language", definition: "Langage du W3C qui sert à décrire les conditions que des données RDF doivent remplir, pour qu'un outil puisse les vérifier."}
    source: {name: "W3C, Shapes Constraint Language (SHACL) (no GDT record found; TERMIUM Plus could not be read)", url: "https://www.w3.org/TR/shacl/", checked: "2026-11-07"}
  - id: sql
    kind: abbreviation
    en: {short: "SQL", full: "Structured Query Language", definition: "The standard language for defining, querying and changing the data of a relational database."}
    fr: {short: "SQL", full: "Structured Query Language", definition: "Langage normalisé qui sert à définir, à interroger et à modifier les données d'une base de données relationnelle."}
    source: {name: "ISO/IEC 9075-1, Information technology, Database languages SQL, Part 1: Framework (no GDT record found; TERMIUM Plus could not be read)", url: "https://www.iso.org/standard/76583.html", checked: "2026-11-07"}
  - id: xml
    kind: abbreviation
    en: {short: "XML", full: "Extensible Markup Language", definition: "The W3C text format that marks up structured data with nested, named elements."}
    fr: {short: "XML", full: "Extensible Markup Language", definition: "Format texte du W3C qui balise des données structurées au moyen d'éléments nommés et imbriqués."}
    source: {name: "W3C, Extensible Markup Language (XML) 1.0 (Fifth Edition) (no GDT record found; TERMIUM Plus could not be read)", url: "https://www.w3.org/TR/xml/", checked: "2026-11-07"}
```

## Change to an existing entry (for the project lead)

The entry `party` defines a party as "a person or organization that holds rights or duties recorded in a registry".
The data models specification uses the term for every person or organization that a system records, as DMO-040 explains.
A wider definition would fit both uses, for example:

```yaml
    en: {full: "party", definition: "A person or an organization that a system records, such as one that holds rights or duties in a registry."}
    fr: {full: "partie", definition: "Personne ou organisation qu'un système enregistre, comme celle qui détient des droits ou des obligations inscrits dans un registre."}
```
