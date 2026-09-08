# ph-redact

<!-- ph-badge-start -->
[![Sonatype Central](https://maven-badges.sml.io/sonatype-central/com.helger/ph-redact-parent-pom/badge.svg)](https://maven-badges.sml.io/sonatype-central/com.helger/ph-redact-parent-pom/)
[![javadoc](https://javadoc.io/badge2/com.helger/ph-redact/javadoc.svg)](https://javadoc.io/doc/com.helger/ph-redact)

> If this project saved you some time or made your day a little easier, a star would mean a lot — it helps others find it too.
<!-- ph-badge-end -->

XSLT-based XML document anonymizer for e-invoicing formats. Replaces all sensitive and personally identifiable data while preserving document structure, monetary values, tax information, and other non-sensitive business data.

Format detection uses the [DDD (Document Details Determinator)](https://github.com/phax/ddd) library, which also handles unwrapping of SBDH and XHE envelopes.

The creation of this repository was inspired by https://github.com/valitoolorg/zebra

## Supported Formats

- **UBL** - OASIS Universal Business Language (Invoice, CreditNote, Order, DespatchAdvice, and all other UBL document types)
- **CII** - UN/CEFACT Cross Industry Invoice

Both editions of EN 16931 are covered by the same stylesheet per syntax, because the namespaces did not
change between the editions and the 2026 elements are purely additive:

| Edition | UBL | CII |
|---------|-----|-----|
| EN 16931:2017 | 2.1 | D16B |
| EN 16931:2026 | 2.5 | D25A |

## What Gets Anonymized

| Category | Examples | Replaced With |
|----------|----------|---------------|
| Party names | Company names, registration names, trading names | `Anonymized Party` |
| Contact details | Phone, fax, email | `+00 000 0000000`, `anonymized@example.com` |
| Person information | First/family/middle name, job title, birth date | `Anonymized Person`, `1900-01-01` |
| Postal addresses | Street, city, postal code, region, PO box | `Anonymized Street`, `Anonymized City`, `00000` |
| Party identifiers | Endpoint IDs, GLN, party IDs | `ANONYMIZED-PARTY-ID`, `ANONYMIZED-ENDPOINT` |
| Tax identifiers | VAT numbers, company registration IDs | `ANONYMIZED-TAX-ID`, `ANONYMIZED-COMPANY-ID` |
| Financial accounts | IBAN, BIC, account names | `ANONYMIZED-IBAN`, `ANONYMIZED-BIC` |
| Payment cards | Card number, cardholder name, CVV | `0000000000000000`, `000` |
| Document IDs | Invoice number, UUID, order/contract references | `ANONYMIZED-DOC-ID`, `ANONYMIZED-REF` |
| Payment references | Payment IDs, mandate IDs, buyer references | `ANONYMIZED-PAYMENT-ID`, `ANONYMIZED-BUYER-REF` |
| Notes | Free-text notes (may contain any sensitive data) | `Anonymized note` |
| URIs | Website URLs, communication URIs | `https://www.example.com`, `ANONYMIZED-URI` |
| Binary attachments | Embedded document content and filename | Replaced with placeholder, `anonymized.bin` |
| Document descriptions | Supporting document description, external document location | `Anonymized document description`, `https://www.example.com/anonymized` |
| Accounting references | Buyer accounting reference (document and line level) | `ANONYMIZED-ACCOUNTING-REF` |

All of these replacement values are built from a single configurable prefix - see
[Custom replacement prefix](#custom-replacement-prefix).

## What Is Preserved

- Monetary amounts (line totals, tax amounts, grand totals)
- Tax rates and category codes
- Currency codes
- Country identification codes (ISO 3166)
- Document type codes
- Item/product names and descriptions
- Quantities and unit codes
- Dates (issue date, due date, delivery date)
- UBL version and customization IDs
- Profile and process identifiers
- Tax scheme identifiers (e.g. `VAT`, `S`)
- Additional legal information (`cbc:CompanyLegalForm` / trade party `ram:Description`)
- Allowance and charge reasons, VAT exemption reason texts

## Usage

### Command Line

Build the standalone jar and run it:

```bash
mvn clean package
java -jar ph-redact-cli/target/ph-redact-cli-full.jar [options] <files...>
```

**Options:**

| Option | Description | Default |
|--------|-------------|---------|
| `-t`, `--target` | Output directory | Current directory |
| `-s`, `--suffix` | Output filename suffix | `-anonymized` |
| `-f`, `--format` | Force format (`ubl` or `cii`) | Auto-detect |
| `-p`, `--prefix` | Prefix for the replaced identifier values | `ANONYMIZED` |
| `--verbose` | Enable verbose output | Off |
| `-h`, `--help` | Show help | |
| `-V`, `--version` | Show version | |

**Examples:**

```bash
# Anonymize a single file (format auto-detected)
java -jar ph-redact-cli-full.jar invoice.xml

# Anonymize multiple files into a specific directory
java -jar ph-redact-cli-full.jar -t /output/dir invoice1.xml invoice2.xml cii-invoice.xml

# Force CII format and use custom suffix
java -jar ph-redact-cli-full.jar -f cii -s -redacted invoice.xml

# Use a custom prefix for the replaced identifier values
java -jar ph-redact-cli-full.jar -p REDACTED invoice.xml

# Verbose output
java -jar ph-redact-cli-full.jar --verbose *.xml
```

The output file is written to the target directory with the suffix appended before the file extension.
For example, `invoice.xml` becomes `invoice-anonymized.xml`.

### Java API

```java
// Explicit format
XMLAnonymizer aAnonymizer = new XMLAnonymizer (EAnonymizationFormat.UBL);
aAnonymizer.anonymize (new File ("invoice.xml"), new File ("invoice-anonymized.xml"));

// Auto-detect format (uses DDD)
XMLAnonymizer.anonymizeAutoDetect (new File ("input.xml"), new File ("output.xml"));

// DOM-based
Document aDoc = DOMReader.readXMLDOM (new File ("invoice.xml"));
XMLAnonymizer aAnonymizer = new XMLAnonymizer (EAnonymizationFormat.CII);
Document aResult = aAnonymizer.anonymize (aDoc);
```

### Custom replacement prefix

All replacement values are built from a single configurable prefix plus a context specific remainder.
If no prefix is provided, `ANONYMIZED` is used:

```java
// Results in REDACTED-DOC-ID, Redacted Party, redacted@example.com, ...
XMLAnonymizer aAnonymizer = new XMLAnonymizer (EAnonymizationFormat.UBL, "REDACTED");

// Same for the auto-detecting convenience method
XMLAnonymizer.anonymizeAutoDetect (new File ("input.xml"), new File ("output.xml"), "REDACTED");
```

The case of the prefix is normalized per context, so the output looks the same no matter how the
prefix itself is written:

| Context | Case | Example with prefix `ANONYMIZED` | Example with prefix `REDACTED` |
|---------|------|----------------------------------|--------------------------------|
| Identifiers | upper | `ANONYMIZED-DOC-ID` | `REDACTED-DOC-ID` |
| Human readable texts | mixed | `Anonymized Party` | `Redacted Party` |
| Mail addresses, URLs, filenames | lower | `anonymized@example.com` | `redacted@example.com` |

Values that carry no wording (`+00 000 0000000`, `00000`, `1900-01-01`, `0000000000000000`, the
base64 content of embedded attachments, ...) are independent of the prefix.

### Standalone XSLT

The XSLT stylesheets can be used independently with any XSLT 1.0 processor:

```bash
# UBL
xsltproc ph-redact/src/main/resources/xslt/ubl-anonymize.xslt invoice.xml > invoice-anonymized.xml

# CII
xsltproc ph-redact/src/main/resources/xslt/cii-anonymize.xslt cii-invoice.xml > cii-invoice-anonymized.xml

# With a custom replacement prefix
xsltproc --stringparam anonymization-prefix REDACTED \
         ph-redact/src/main/resources/xslt/ubl-anonymize.xslt invoice.xml > invoice-anonymized.xml
```

## Project Layout

This is a multi-module Maven project:

- `ph-redact` - The library: format enum, XSLT-based anonymizer, format auto-detection, and the XSLT stylesheets.
- `ph-redact-cli` - The command-line client (picocli) and standalone fat jar build.

## Building

Requires Java 17+ and Maven.

```bash
mvn clean package
```

The build produces (replacing x.y.z with the actual version number):
- `ph-redact/target/ph-redact-x.y.z-SNAPSHOT.jar` - Library jar
- `ph-redact-cli/target/ph-redact-cli-x.y.z-SNAPSHOT.jar` - CLI jar (lib only)
- `ph-redact-cli/target/ph-redact-cli-full.jar` - Standalone executable jar with all dependencies

## Maven Coordinates

To use the library in Maven (replacing `x.y.z` with the effective version number):

```xml
<dependency>
  <groupId>com.helger</groupId>
  <artifactId>ph-redact</artifactId>
  <version>x.y.z</version>
</dependency>
```

## License

Apache License, Version 2.0

## News and Noteworthy

v1.1.0 - work in progress
* Added the elements introduced by the EN 16931:2026 syntax bindings (UBL 2.5 and CII D25A) to both stylesheets. UBL: `cac:Annotation/cbc:AnnotationContent`, `cac:DeliveryNoteDocumentReference/cbc:ID`, `cac:DocumentReference/cbc:ID`, `cac:OrderReference/cbc:SalesOrderID`. CII: `ram:BuyerReferenceID` (renamed from `ram:BuyerReference` in D25A) and `ram:DeliveryNoteReferencedDocument/ram:IssuerAssignedID`.
* Closed further gaps that existed in both editions. UBL: `cbc:AccountingCost`, `cbc:AccountingCostCode`, `cbc:DocumentDescription`, `cac:ExternalReference/cbc:URI` and the `@filename` of the embedded binary object. CII: `ram:CreditorReferenceID`, `ram:DirectDebitMandateID`, `ram:SpecifiedProcuringProject`, `ram:ReceivableSpecifiedTradeAccountingAccount/ram:ID`, `ram:PayableSpecifiedTradeAccountingAccount/ram:ID`, `ram:SpecifiedTradePaymentTerms/ram:Description`, `ram:AdditionalReferencedDocument/ram:Name`, `ram:AdditionalReferencedDocument/ram:URIID` and the `@filename` of the attachment.
* The prefix of all replacement values is now configurable via the XSLT parameter `anonymization-prefix`, the new `XMLAnonymizer` constructor parameter and the new CLI option `-p` / `--prefix`. The default value `ANONYMIZED` is unchanged. Its case is normalized per context: upper case for identifiers (`ANONYMIZED-DOC-ID`), mixed case for human readable texts (`Anonymized Party`) and lower case for mail addresses, URLs and filenames (`anonymized@example.com`).
* Harmonized the textual replacement values: the ones that previously read `Anonymous ...` now read `Anonymized ...` (`Anonymous Party` became `Anonymized Party`, `anonymous@example.com` became `anonymized@example.com`, and so on).
* Renamed the enum constant `EAnonymizationFormat.UBL_21` to `EAnonymizationFormat.UBL`, its format ID from `ubl21` to `ubl` and the XSLT stylesheet `xslt/ubl21-anonymize.xslt` to `xslt/ubl-anonymize.xslt`, because they all cover UBL 2.1 as well as UBL 2.5. The renaming of the enum constant and of the stylesheet are backwards incompatible changes. The legacy format ID `ubl21` is still accepted by `EAnonymizationFormat.getFromIDOrNull` and by the CLI option `-f` / `--format`.
* The `TransformerFactory` for the XSLT stylesheets is now created via `XMLFactory.createDefaultTransformerFactory ()` of ph-xml, which disallows DOCTYPE declarations as well as the loading of external entities and DTDs.

v1.0.1 - 2026-05-11
* Restructured the codebase into a multi-module Maven project: `ph-redact` (library) and `ph-redact-cli` (command-line client). The library Maven coordinate `com.helger:ph-redact` is unchanged.
* The standalone executable jar was renamed from `ph-redact-full.jar` to `ph-redact-cli-full.jar` and is now produced under `ph-redact-cli/target/`.

v1.0.0 - 2026-04-24
* Initial version

---

My personal [Coding Styleguide](https://github.com/phax/meta/blob/master/CodingStyleguide.md) |
It is appreciated if you star the GitHub project if you like it.