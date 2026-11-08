CREATE TYPE "GeometryType" AS ENUM ('Point');

CREATE TABLE "Extensions" (
	id SERIAL NOT NULL,
	PRIMARY KEY (id)
);
CREATE INDEX "ix_Extensions_id" ON "Extensions" (id);
COMMENT ON TABLE "Extensions" IS 'The extensions object. Each member is named after the ISO 3166-1 or ISO 3166-2 code of one jurisdiction, in lowerCamelCase, such as ca or caQc. Its value is an object that the profile of that jurisdiction defines. The core model accepts any member, so that a system can keep extensions it does not know. DMO-053, DMO-056.';

CREATE TABLE "Money" (
	id SERIAL NOT NULL,
	amount TEXT NOT NULL,
	currency TEXT NOT NULL,
	PRIMARY KEY (id)
);
CREATE INDEX "ix_Money_id" ON "Money" (id);
COMMENT ON TABLE "Money" IS 'An amount of money. DAT-050 to DAT-053.';

CREATE TABLE "MultilingualText" (
	id SERIAL NOT NULL,
	en TEXT NOT NULL,
	fr TEXT NOT NULL,
	PRIMARY KEY (id)
);
CREATE INDEX "ix_MultilingualText_id" ON "MultilingualText" (id);
COMMENT ON TABLE "MultilingualText" IS 'Text in English and French, keyed by language tag. Other language tags are allowed as extra members. DAT-004 to DAT-006.';

CREATE TABLE "ZonedLocalDateTime" (
	id SERIAL NOT NULL,
	"localDateTime" TEXT NOT NULL,
	"timeZone" TEXT NOT NULL,
	PRIMARY KEY (id)
);
CREATE INDEX "ix_ZonedLocalDateTime_id" ON "ZonedLocalDateTime" (id);
COMMENT ON TABLE "ZonedLocalDateTime" IS 'A wall-clock date and time with the time zone it belongs to. DAT-015.';

CREATE TABLE "InstantInterval" (
	id SERIAL NOT NULL,
	start TEXT NOT NULL,
	"end" TEXT,
	PRIMARY KEY (id)
);
CREATE INDEX "ix_InstantInterval_id" ON "InstantInterval" (id);
COMMENT ON TABLE "InstantInterval" IS 'A span between two instants. The end is excluded and may be absent. DAT-023.';

CREATE TABLE "DateInterval" (
	id SERIAL NOT NULL,
	start TEXT NOT NULL,
	"end" TEXT,
	PRIMARY KEY (id)
);
CREATE INDEX "ix_DateInterval_id" ON "DateInterval" (id);
COMMENT ON TABLE "DateInterval" IS 'A span between two dates. The end is excluded and may be absent. DAT-023.';

CREATE TABLE "Point" (
	id SERIAL NOT NULL,
	type "GeometryType" NOT NULL,
	PRIMARY KEY (id)
);
CREATE INDEX "ix_Point_id" ON "Point" (id);
COMMENT ON TABLE "Point" IS 'A GeoJSON point: longitude, then latitude, in WGS 84 decimal degrees. DAT-080, DAT-081.';

CREATE TABLE "Entity" (
	id TEXT NOT NULL,
	"createdAt" TEXT NOT NULL,
	"updatedAt" TEXT NOT NULL,
	extensions_id INTEGER,
	PRIMARY KEY (id),
	FOREIGN KEY(extensions_id) REFERENCES "Extensions" (id)
);
CREATE INDEX "ix_Entity_id" ON "Entity" (id);
COMMENT ON TABLE "Entity" IS 'Fields that every entity of the model has: an identifier, audit instants and the extensions object. Departs from Apache OFBiz (DMO-006): each entity has its own UUID key, never a key of several fields. DMO-021, DMO-022, DMO-050, DMO-053.';
COMMENT ON COLUMN "Entity".id IS 'The identifier of the entity. New ones should be version 7 UUIDs (DAT-063). DMO-021.';
COMMENT ON COLUMN "Entity"."createdAt" IS 'When the system of record first stored the entity. DMO-050.';
COMMENT ON COLUMN "Entity"."updatedAt" IS 'When the system of record last changed the entity. DMO-050.';
COMMENT ON COLUMN "Entity".extensions_id IS 'Fields that one jurisdiction adds, keyed by jurisdiction code. DMO-053 to DMO-056.';

CREATE TABLE "Party" (
	"partyType" TEXT NOT NULL,
	id TEXT NOT NULL,
	"createdAt" TEXT NOT NULL,
	"updatedAt" TEXT NOT NULL,
	extensions_id INTEGER,
	PRIMARY KEY (id),
	FOREIGN KEY(extensions_id) REFERENCES "Extensions" (id)
);
CREATE INDEX "ix_Party_id" ON "Party" (id);
COMMENT ON TABLE "Party" IS 'A person or an organization. Each party is exactly one of the two. DMO-040.';
COMMENT ON COLUMN "Party"."partyType" IS 'Whether the party is a person or an organization: a code of the PartyType enumeration, which each subclass fixes. DMO-040.';
COMMENT ON COLUMN "Party".id IS 'The identifier of the entity. New ones should be version 7 UUIDs (DAT-063). DMO-021.';
COMMENT ON COLUMN "Party"."createdAt" IS 'When the system of record first stored the entity. DMO-050.';
COMMENT ON COLUMN "Party"."updatedAt" IS 'When the system of record last changed the entity. DMO-050.';
COMMENT ON COLUMN "Party".extensions_id IS 'Fields that one jurisdiction adds, keyed by jurisdiction code. DMO-053 to DMO-056.';

CREATE TABLE "Person" (
	"birthDate" TEXT,
	"partyType" TEXT NOT NULL,
	id TEXT NOT NULL,
	"createdAt" TEXT NOT NULL,
	"updatedAt" TEXT NOT NULL,
	extensions_id INTEGER,
	PRIMARY KEY (id),
	FOREIGN KEY(extensions_id) REFERENCES "Extensions" (id)
);
CREATE INDEX "ix_Person_id" ON "Person" (id);
COMMENT ON TABLE "Person" IS 'A human being. DMO-041.';
COMMENT ON COLUMN "Person"."birthDate" IS 'The date of birth, when a process needs it. DMO-041.';
COMMENT ON COLUMN "Person"."partyType" IS 'Whether the party is a person or an organization: a code of the PartyType enumeration, which each subclass fixes. DMO-040.';
COMMENT ON COLUMN "Person".id IS 'The identifier of the entity. New ones should be version 7 UUIDs (DAT-063). DMO-021.';
COMMENT ON COLUMN "Person"."createdAt" IS 'When the system of record first stored the entity. DMO-050.';
COMMENT ON COLUMN "Person"."updatedAt" IS 'When the system of record last changed the entity. DMO-050.';
COMMENT ON COLUMN "Person".extensions_id IS 'Fields that one jurisdiction adds, keyed by jurisdiction code. DMO-053 to DMO-056.';

CREATE TABLE "Organization" (
	"partyType" TEXT NOT NULL,
	id TEXT NOT NULL,
	"createdAt" TEXT NOT NULL,
	"updatedAt" TEXT NOT NULL,
	extensions_id INTEGER,
	PRIMARY KEY (id),
	FOREIGN KEY(extensions_id) REFERENCES "Extensions" (id)
);
CREATE INDEX "ix_Organization_id" ON "Organization" (id);
COMMENT ON TABLE "Organization" IS 'A group of people with a shared purpose, such as a business, a public body or an association. Apache OFBiz calls it PartyGroup. DMO-042.';
COMMENT ON COLUMN "Organization"."partyType" IS 'Whether the party is a person or an organization: a code of the PartyType enumeration, which each subclass fixes. DMO-040.';
COMMENT ON COLUMN "Organization".id IS 'The identifier of the entity. New ones should be version 7 UUIDs (DAT-063). DMO-021.';
COMMENT ON COLUMN "Organization"."createdAt" IS 'When the system of record first stored the entity. DMO-050.';
COMMENT ON COLUMN "Organization"."updatedAt" IS 'When the system of record last changed the entity. DMO-050.';
COMMENT ON COLUMN "Organization".extensions_id IS 'Fields that one jurisdiction adds, keyed by jurisdiction code. DMO-053 to DMO-056.';

CREATE TABLE "ContactMechanism" (
	"contactMechanismType" TEXT NOT NULL,
	id TEXT NOT NULL,
	"createdAt" TEXT NOT NULL,
	"updatedAt" TEXT NOT NULL,
	extensions_id INTEGER,
	PRIMARY KEY (id),
	FOREIGN KEY(extensions_id) REFERENCES "Extensions" (id)
);
CREATE INDEX "ix_ContactMechanism_id" ON "ContactMechanism" (id);
COMMENT ON TABLE "ContactMechanism" IS 'A way to reach a party: a postal address, a telephone number or an email address. Apache OFBiz calls it ContactMech. DMO-045.';
COMMENT ON COLUMN "ContactMechanism"."contactMechanismType" IS 'The kind of contact mechanism: a code of the ContactMechanismType enumeration, which each subclass fixes. DMO-045.';
COMMENT ON COLUMN "ContactMechanism".id IS 'The identifier of the entity. New ones should be version 7 UUIDs (DAT-063). DMO-021.';
COMMENT ON COLUMN "ContactMechanism"."createdAt" IS 'When the system of record first stored the entity. DMO-050.';
COMMENT ON COLUMN "ContactMechanism"."updatedAt" IS 'When the system of record last changed the entity. DMO-050.';
COMMENT ON COLUMN "ContactMechanism".extensions_id IS 'Fields that one jurisdiction adds, keyed by jurisdiction code. DMO-053 to DMO-056.';

CREATE TABLE "PostalAddress" (
	language TEXT,
	"civicNumber" TEXT,
	unit TEXT,
	street TEXT,
	locality TEXT,
	region TEXT,
	"postalCode" TEXT,
	country TEXT NOT NULL,
	"contactMechanismType" TEXT NOT NULL,
	id TEXT NOT NULL,
	"createdAt" TEXT NOT NULL,
	"updatedAt" TEXT NOT NULL,
	extensions_id INTEGER,
	PRIMARY KEY (id),
	FOREIGN KEY(extensions_id) REFERENCES "Extensions" (id)
);
CREATE INDEX "ix_PostalAddress_id" ON "PostalAddress" (id);
COMMENT ON TABLE "PostalAddress" IS 'A postal address in separate fields, kept as written. Only the country is required. DMO-033, LOC-053, LOC-055.';
COMMENT ON COLUMN "PostalAddress".language IS 'The language in which the text is written, when known. LOC-055.';
COMMENT ON COLUMN "PostalAddress"."civicNumber" IS 'The civic number, with its suffix, such as 1200 or 12A.';
COMMENT ON COLUMN "PostalAddress".unit IS 'The apartment, suite or unit, as written.';
COMMENT ON COLUMN "PostalAddress".street IS 'The street name with its type and direction, as written, such as rue Principale Ouest.';
COMMENT ON COLUMN "PostalAddress".locality IS 'The municipality or locality, never translated.';
COMMENT ON COLUMN "PostalAddress".region IS 'The province, state or other region, in the form of its issuer, such as QC.';
COMMENT ON COLUMN "PostalAddress"."postalCode" IS 'The postal code in the form of its issuer, such as H2X 1Y4. Some countries have none.';
COMMENT ON COLUMN "PostalAddress".country IS 'The country, as an ISO 3166-1 alpha-2 code.';
COMMENT ON COLUMN "PostalAddress"."contactMechanismType" IS 'The kind of contact mechanism: a code of the ContactMechanismType enumeration, which each subclass fixes. DMO-045.';
COMMENT ON COLUMN "PostalAddress".id IS 'The identifier of the entity. New ones should be version 7 UUIDs (DAT-063). DMO-021.';
COMMENT ON COLUMN "PostalAddress"."createdAt" IS 'When the system of record first stored the entity. DMO-050.';
COMMENT ON COLUMN "PostalAddress"."updatedAt" IS 'When the system of record last changed the entity. DMO-050.';
COMMENT ON COLUMN "PostalAddress".extensions_id IS 'Fields that one jurisdiction adds, keyed by jurisdiction code. DMO-053 to DMO-056.';

CREATE TABLE "TelephoneNumber" (
	number TEXT NOT NULL,
	"extensionNumber" TEXT,
	"contactMechanismType" TEXT NOT NULL,
	id TEXT NOT NULL,
	"createdAt" TEXT NOT NULL,
	"updatedAt" TEXT NOT NULL,
	extensions_id INTEGER,
	PRIMARY KEY (id),
	FOREIGN KEY(extensions_id) REFERENCES "Extensions" (id)
);
CREATE INDEX "ix_TelephoneNumber_id" ON "TelephoneNumber" (id);
COMMENT ON TABLE "TelephoneNumber" IS 'A telephone number. DMO-034.';
COMMENT ON COLUMN "TelephoneNumber".number IS 'The number in E.164 form.';
COMMENT ON COLUMN "TelephoneNumber"."extensionNumber" IS 'The internal extension, digits only.';
COMMENT ON COLUMN "TelephoneNumber"."contactMechanismType" IS 'The kind of contact mechanism: a code of the ContactMechanismType enumeration, which each subclass fixes. DMO-045.';
COMMENT ON COLUMN "TelephoneNumber".id IS 'The identifier of the entity. New ones should be version 7 UUIDs (DAT-063). DMO-021.';
COMMENT ON COLUMN "TelephoneNumber"."createdAt" IS 'When the system of record first stored the entity. DMO-050.';
COMMENT ON COLUMN "TelephoneNumber"."updatedAt" IS 'When the system of record last changed the entity. DMO-050.';
COMMENT ON COLUMN "TelephoneNumber".extensions_id IS 'Fields that one jurisdiction adds, keyed by jurisdiction code. DMO-053 to DMO-056.';

CREATE TABLE "EmailAddress" (
	address TEXT NOT NULL,
	"contactMechanismType" TEXT NOT NULL,
	id TEXT NOT NULL,
	"createdAt" TEXT NOT NULL,
	"updatedAt" TEXT NOT NULL,
	extensions_id INTEGER,
	PRIMARY KEY (id),
	FOREIGN KEY(extensions_id) REFERENCES "Extensions" (id)
);
CREATE INDEX "ix_EmailAddress_id" ON "EmailAddress" (id);
COMMENT ON TABLE "EmailAddress" IS 'An email address. DMO-034.';
COMMENT ON COLUMN "EmailAddress".address IS 'The address, kept as the person wrote it.';
COMMENT ON COLUMN "EmailAddress"."contactMechanismType" IS 'The kind of contact mechanism: a code of the ContactMechanismType enumeration, which each subclass fixes. DMO-045.';
COMMENT ON COLUMN "EmailAddress".id IS 'The identifier of the entity. New ones should be version 7 UUIDs (DAT-063). DMO-021.';
COMMENT ON COLUMN "EmailAddress"."createdAt" IS 'When the system of record first stored the entity. DMO-050.';
COMMENT ON COLUMN "EmailAddress"."updatedAt" IS 'When the system of record last changed the entity. DMO-050.';
COMMENT ON COLUMN "EmailAddress".extensions_id IS 'Fields that one jurisdiction adds, keyed by jurisdiction code. DMO-053 to DMO-056.';

CREATE TABLE "Examples" (
	id TEXT NOT NULL,
	"createdAt" TEXT,
	"birthDate" TEXT,
	"openingTime" TEXT,
	"processingTime" TEXT,
	status TEXT,
	active BOOLEAN,
	appointment_id INTEGER,
	fee_id INTEGER,
	name_id INTEGER,
	validity_id INTEGER,
	location_id INTEGER,
	PRIMARY KEY (id),
	FOREIGN KEY(appointment_id) REFERENCES "ZonedLocalDateTime" (id),
	FOREIGN KEY(fee_id) REFERENCES "Money" (id),
	FOREIGN KEY(name_id) REFERENCES "MultilingualText" (id),
	FOREIGN KEY(validity_id) REFERENCES "DateInterval" (id),
	FOREIGN KEY(location_id) REFERENCES "Point" (id)
);
CREATE INDEX "ix_Examples_id" ON "Examples" (id);
COMMENT ON TABLE "Examples" IS 'Container used only to test the examples of this schema.';

CREATE TABLE "Point_coordinates" (
	"Point_id" INTEGER,
	coordinates FLOAT NOT NULL,
	PRIMARY KEY ("Point_id", coordinates),
	FOREIGN KEY("Point_id") REFERENCES "Point" (id)
);
CREATE INDEX "ix_Point_coordinates_Point_id" ON "Point_coordinates" ("Point_id");
CREATE INDEX "ix_Point_coordinates_coordinates" ON "Point_coordinates" (coordinates);
COMMENT ON TABLE "Point_coordinates" IS 'None';
COMMENT ON COLUMN "Point_coordinates"."Point_id" IS 'Autocreated FK slot';

CREATE TABLE "PersonName" (
	id SERIAL NOT NULL,
	"nameType" TEXT,
	language TEXT,
	"fullName" TEXT NOT NULL,
	"givenNames" TEXT,
	"familyName" TEXT,
	"Person_id" TEXT,
	validity_id INTEGER,
	PRIMARY KEY (id),
	FOREIGN KEY("Person_id") REFERENCES "Person" (id),
	FOREIGN KEY(validity_id) REFERENCES "DateInterval" (id)
);
CREATE INDEX "ix_PersonName_id" ON "PersonName" (id);
COMMENT ON TABLE "PersonName" IS 'One name of a person. Only the full name is required. DMO-032, LOC-050.';
COMMENT ON COLUMN "PersonName"."nameType" IS 'The kind of name, such as legal or preferred, from a scheme that the deployment names. DMO-030, DMO-031.';
COMMENT ON COLUMN "PersonName".language IS 'The language in which the text is written, when known. LOC-055.';
COMMENT ON COLUMN "PersonName"."fullName" IS 'The whole name, as the person writes it.';
COMMENT ON COLUMN "PersonName"."givenNames" IS 'The given names, only when a process needs the parts.';
COMMENT ON COLUMN "PersonName"."familyName" IS 'The family name, only when a process needs the parts.';
COMMENT ON COLUMN "PersonName"."Person_id" IS 'Autocreated FK slot';
COMMENT ON COLUMN "PersonName".validity_id IS 'When the fact holds: the start is included and the end is not. Replaces the fromDate and thruDate pair of Apache OFBiz (DMO-006). DMO-023, DAT-023.';

CREATE TABLE "OrganizationName" (
	id SERIAL NOT NULL,
	"nameType" TEXT,
	language TEXT,
	name TEXT NOT NULL,
	"Organization_id" TEXT,
	validity_id INTEGER,
	PRIMARY KEY (id),
	FOREIGN KEY("Organization_id") REFERENCES "Organization" (id),
	FOREIGN KEY(validity_id) REFERENCES "DateInterval" (id)
);
CREATE INDEX "ix_OrganizationName_id" ON "OrganizationName" (id);
COMMENT ON TABLE "OrganizationName" IS 'One name of an organization, as registered or used. DMO-035, DMO-042.';
COMMENT ON COLUMN "OrganizationName"."nameType" IS 'The kind of name, such as legal or preferred, from a scheme that the deployment names. DMO-030, DMO-031.';
COMMENT ON COLUMN "OrganizationName".language IS 'The language in which the text is written, when known. LOC-055.';
COMMENT ON COLUMN "OrganizationName".name IS 'The name as the organization writes it, never translated by the system.';
COMMENT ON COLUMN "OrganizationName"."Organization_id" IS 'Autocreated FK slot';
COMMENT ON COLUMN "OrganizationName".validity_id IS 'When the fact holds: the start is included and the end is not. Replaces the fromDate and thruDate pair of Apache OFBiz (DMO-006). DMO-023, DAT-023.';

CREATE TABLE "PartyRole" (
	"partyId" TEXT NOT NULL,
	role TEXT NOT NULL,
	id TEXT NOT NULL,
	"createdAt" TEXT NOT NULL,
	"updatedAt" TEXT NOT NULL,
	validity_id INTEGER,
	extensions_id INTEGER,
	PRIMARY KEY (id),
	FOREIGN KEY("partyId") REFERENCES "Party" (id),
	FOREIGN KEY(validity_id) REFERENCES "DateInterval" (id),
	FOREIGN KEY(extensions_id) REFERENCES "Extensions" (id)
);
CREATE INDEX "ix_PartyRole_id" ON "PartyRole" (id);
COMMENT ON TABLE "PartyRole" IS 'A role that a party plays, such as applicant, employer or supplier. Departs from Apache OFBiz (DMO-006): the role has a period, and the role is a code instead of a RoleType record. DMO-043.';
COMMENT ON COLUMN "PartyRole"."partyId" IS 'The party that the entity is about. NAM-040.';
COMMENT ON COLUMN "PartyRole".role IS 'The role, from a scheme of party roles that the deployment names. DMO-030, DMO-031.';
COMMENT ON COLUMN "PartyRole".id IS 'The identifier of the entity. New ones should be version 7 UUIDs (DAT-063). DMO-021.';
COMMENT ON COLUMN "PartyRole"."createdAt" IS 'When the system of record first stored the entity. DMO-050.';
COMMENT ON COLUMN "PartyRole"."updatedAt" IS 'When the system of record last changed the entity. DMO-050.';
COMMENT ON COLUMN "PartyRole".validity_id IS 'When the fact holds: the start is included and the end is not. Replaces the fromDate and thruDate pair of Apache OFBiz (DMO-006). DMO-023, DAT-023.';
COMMENT ON COLUMN "PartyRole".extensions_id IS 'Fields that one jurisdiction adds, keyed by jurisdiction code. DMO-053 to DMO-056.';

CREATE TABLE "PartyRelationship" (
	"partyId" TEXT NOT NULL,
	role TEXT NOT NULL,
	"relatedPartyId" TEXT NOT NULL,
	"relatedRole" TEXT NOT NULL,
	"relationshipType" TEXT NOT NULL,
	id TEXT NOT NULL,
	"createdAt" TEXT NOT NULL,
	"updatedAt" TEXT NOT NULL,
	validity_id INTEGER,
	extensions_id INTEGER,
	PRIMARY KEY (id),
	FOREIGN KEY("partyId") REFERENCES "Party" (id),
	FOREIGN KEY("relatedPartyId") REFERENCES "Party" (id),
	FOREIGN KEY(validity_id) REFERENCES "DateInterval" (id),
	FOREIGN KEY(extensions_id) REFERENCES "Extensions" (id)
);
CREATE INDEX "ix_PartyRelationship_id" ON "PartyRelationship" (id);
COMMENT ON TABLE "PartyRelationship" IS 'A relationship between two parties, each in a role, such as an employee and an employer. DMO-044.';
COMMENT ON COLUMN "PartyRelationship"."partyId" IS 'The party that the entity is about. NAM-040.';
COMMENT ON COLUMN "PartyRelationship".role IS 'The role of the first party in the relationship. DMO-030.';
COMMENT ON COLUMN "PartyRelationship"."relatedPartyId" IS 'The second party of the relationship.';
COMMENT ON COLUMN "PartyRelationship"."relatedRole" IS 'The role of the second party in the relationship. DMO-030.';
COMMENT ON COLUMN "PartyRelationship"."relationshipType" IS 'The kind of relationship, from a scheme that the deployment names. DMO-030, DMO-031.';
COMMENT ON COLUMN "PartyRelationship".id IS 'The identifier of the entity. New ones should be version 7 UUIDs (DAT-063). DMO-021.';
COMMENT ON COLUMN "PartyRelationship"."createdAt" IS 'When the system of record first stored the entity. DMO-050.';
COMMENT ON COLUMN "PartyRelationship"."updatedAt" IS 'When the system of record last changed the entity. DMO-050.';
COMMENT ON COLUMN "PartyRelationship".validity_id IS 'When the fact holds: the start is included and the end is not. Replaces the fromDate and thruDate pair of Apache OFBiz (DMO-006). DMO-023, DAT-023.';
COMMENT ON COLUMN "PartyRelationship".extensions_id IS 'Fields that one jurisdiction adds, keyed by jurisdiction code. DMO-053 to DMO-056.';

CREATE TABLE "PartyContactMechanism" (
	"partyId" TEXT NOT NULL,
	"contactMechanismId" TEXT NOT NULL,
	id TEXT NOT NULL,
	"createdAt" TEXT NOT NULL,
	"updatedAt" TEXT NOT NULL,
	validity_id INTEGER,
	extensions_id INTEGER,
	PRIMARY KEY (id),
	FOREIGN KEY("partyId") REFERENCES "Party" (id),
	FOREIGN KEY("contactMechanismId") REFERENCES "ContactMechanism" (id),
	FOREIGN KEY(validity_id) REFERENCES "DateInterval" (id),
	FOREIGN KEY(extensions_id) REFERENCES "Extensions" (id)
);
CREATE INDEX "ix_PartyContactMechanism_id" ON "PartyContactMechanism" (id);
COMMENT ON TABLE "PartyContactMechanism" IS 'Links a party to a contact mechanism, for some purposes and a period. DMO-045.';
COMMENT ON COLUMN "PartyContactMechanism"."partyId" IS 'The party that the entity is about. NAM-040.';
COMMENT ON COLUMN "PartyContactMechanism".id IS 'The identifier of the entity. New ones should be version 7 UUIDs (DAT-063). DMO-021.';
COMMENT ON COLUMN "PartyContactMechanism"."createdAt" IS 'When the system of record first stored the entity. DMO-050.';
COMMENT ON COLUMN "PartyContactMechanism"."updatedAt" IS 'When the system of record last changed the entity. DMO-050.';
COMMENT ON COLUMN "PartyContactMechanism".validity_id IS 'When the fact holds: the start is included and the end is not. Replaces the fromDate and thruDate pair of Apache OFBiz (DMO-006). DMO-023, DAT-023.';
COMMENT ON COLUMN "PartyContactMechanism".extensions_id IS 'Fields that one jurisdiction adds, keyed by jurisdiction code. DMO-053 to DMO-056.';

CREATE TABLE "PartyIdentification" (
	"partyId" TEXT NOT NULL,
	"identificationScheme" TEXT NOT NULL,
	value TEXT NOT NULL,
	"issuerId" TEXT,
	id TEXT NOT NULL,
	"createdAt" TEXT NOT NULL,
	"updatedAt" TEXT NOT NULL,
	validity_id INTEGER,
	extensions_id INTEGER,
	PRIMARY KEY (id),
	FOREIGN KEY("partyId") REFERENCES "Party" (id),
	FOREIGN KEY("issuerId") REFERENCES "Party" (id),
	FOREIGN KEY(validity_id) REFERENCES "DateInterval" (id),
	FOREIGN KEY(extensions_id) REFERENCES "Extensions" (id)
);
CREATE INDEX "ix_PartyIdentification_id" ON "PartyIdentification" (id);
COMMENT ON TABLE "PartyIdentification" IS 'An identifier that a body issued for a party, such as a business number. DMO-046.';
COMMENT ON COLUMN "PartyIdentification"."partyId" IS 'The party that the entity is about. NAM-040.';
COMMENT ON COLUMN "PartyIdentification"."identificationScheme" IS 'The identification scheme, from a scheme of identification schemes that the deployment names. DMO-031, DMO-046.';
COMMENT ON COLUMN "PartyIdentification".value IS 'The identifier, in the exact form of its issuer. DAT-066.';
COMMENT ON COLUMN "PartyIdentification"."issuerId" IS 'The organization that issued the identifier, when the model holds it.';
COMMENT ON COLUMN "PartyIdentification".id IS 'The identifier of the entity. New ones should be version 7 UUIDs (DAT-063). DMO-021.';
COMMENT ON COLUMN "PartyIdentification"."createdAt" IS 'When the system of record first stored the entity. DMO-050.';
COMMENT ON COLUMN "PartyIdentification"."updatedAt" IS 'When the system of record last changed the entity. DMO-050.';
COMMENT ON COLUMN "PartyIdentification".validity_id IS 'When the fact holds: the start is included and the end is not. Replaces the fromDate and thruDate pair of Apache OFBiz (DMO-006). DMO-023, DAT-023.';
COMMENT ON COLUMN "PartyIdentification".extensions_id IS 'Fields that one jurisdiction adds, keyed by jurisdiction code. DMO-053 to DMO-056.';

CREATE TABLE "PartyClassification" (
	"partyId" TEXT NOT NULL,
	"conceptScheme" TEXT NOT NULL,
	code TEXT NOT NULL,
	id TEXT NOT NULL,
	"createdAt" TEXT NOT NULL,
	"updatedAt" TEXT NOT NULL,
	validity_id INTEGER,
	extensions_id INTEGER,
	PRIMARY KEY (id),
	FOREIGN KEY("partyId") REFERENCES "Party" (id),
	FOREIGN KEY(validity_id) REFERENCES "DateInterval" (id),
	FOREIGN KEY(extensions_id) REFERENCES "Extensions" (id)
);
CREATE INDEX "ix_PartyClassification_id" ON "PartyClassification" (id);
COMMENT ON TABLE "PartyClassification" IS 'Places a party in a category of a controlled vocabulary, such as an industry. DMO-047.';
COMMENT ON COLUMN "PartyClassification"."partyId" IS 'The party that the entity is about. NAM-040.';
COMMENT ON COLUMN "PartyClassification"."conceptScheme" IS 'The URI of the concept scheme. DMO-047.';
COMMENT ON COLUMN "PartyClassification".code IS 'The code of the concept in that scheme, in the form of the scheme. VOC-065.';
COMMENT ON COLUMN "PartyClassification".id IS 'The identifier of the entity. New ones should be version 7 UUIDs (DAT-063). DMO-021.';
COMMENT ON COLUMN "PartyClassification"."createdAt" IS 'When the system of record first stored the entity. DMO-050.';
COMMENT ON COLUMN "PartyClassification"."updatedAt" IS 'When the system of record last changed the entity. DMO-050.';
COMMENT ON COLUMN "PartyClassification".validity_id IS 'When the fact holds: the start is included and the end is not. Replaces the fromDate and thruDate pair of Apache OFBiz (DMO-006). DMO-023, DAT-023.';
COMMENT ON COLUMN "PartyClassification".extensions_id IS 'Fields that one jurisdiction adds, keyed by jurisdiction code. DMO-053 to DMO-056.';

CREATE TABLE "PostalAddress_addressLines" (
	"PostalAddress_id" TEXT,
	"addressLines" TEXT,
	PRIMARY KEY ("PostalAddress_id", "addressLines"),
	FOREIGN KEY("PostalAddress_id") REFERENCES "PostalAddress" (id)
);
CREATE INDEX "ix_PostalAddress_addressLines_PostalAddress_id" ON "PostalAddress_addressLines" ("PostalAddress_id");
CREATE INDEX "ix_PostalAddress_addressLines_addressLines" ON "PostalAddress_addressLines" ("addressLines");
COMMENT ON TABLE "PostalAddress_addressLines" IS 'None';
COMMENT ON COLUMN "PostalAddress_addressLines"."PostalAddress_id" IS 'Autocreated FK slot';
COMMENT ON COLUMN "PostalAddress_addressLines"."addressLines" IS 'Other lines of the address, in order, for countries whose parts do not fit the other fields.';

CREATE TABLE "PartyContactMechanism_purposes" (
	"PartyContactMechanism_id" TEXT,
	purposes TEXT,
	PRIMARY KEY ("PartyContactMechanism_id", purposes),
	FOREIGN KEY("PartyContactMechanism_id") REFERENCES "PartyContactMechanism" (id)
);
CREATE INDEX "ix_PartyContactMechanism_purposes_PartyContactMechanism_id" ON "PartyContactMechanism_purposes" ("PartyContactMechanism_id");
CREATE INDEX "ix_PartyContactMechanism_purposes_purposes" ON "PartyContactMechanism_purposes" (purposes);
COMMENT ON TABLE "PartyContactMechanism_purposes" IS 'None';
COMMENT ON COLUMN "PartyContactMechanism_purposes"."PartyContactMechanism_id" IS 'Autocreated FK slot';
COMMENT ON COLUMN "PartyContactMechanism_purposes".purposes IS 'What the party uses the mechanism for, such as billing or mailing, from a scheme that the deployment names. DMO-030, DMO-031.';

