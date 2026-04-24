# xml-anonymizer

XSLT-based XML document anonymizer for e-invoicing formats. Replaces all sensitive and personally identifiable data while preserving document structure, monetary values, tax information, and other non-sensitive business data.

Format detection uses the [DDD (Document Details Determinator)](https://github.com/phax/ddd) library, which also handles unwrapping of SBDH and XHE envelopes.

The creation of this repository was inspired by https://github.com/valitoolorg/zebra

## Supported Formats

- **UBL 2.1** - OASIS Universal Business Language (Invoice, CreditNote, Order, DespatchAdvice, and all other UBL 2.1 document types)
- **CII D16B** - UN/CEFACT Cross Industry Invoice

## What Gets Anonymized

| Category | Examples | Replaced With |
|----------|----------|---------------|
| Party names | Company names, registration names, trading names | `Anonymous Party` |
| Contact details | Phone, fax, email | `+00 000 0000000`, `anonymous@example.com` |
| Person information | First/family/middle name, job title, birth date | `Anonymous Person`, `1900-01-01` |
| Postal addresses | Street, city, postal code, region, PO box | `Anonymous Street`, `Anonymous City`, `00000` |
| Party identifiers | Endpoint IDs, GLN, party IDs | `ANONYMIZED-PARTY-ID`, `ANONYMIZED-ENDPOINT` |
| Tax identifiers | VAT numbers, company registration IDs | `ANONYMIZED-TAX-ID`, `ANONYMIZED-COMPANY-ID` |
| Financial accounts | IBAN, BIC, account names | `ANONYMIZED-IBAN`, `ANONYMIZED-BIC` |
| Payment cards | Card number, cardholder name, CVV | `0000000000000000`, `000` |
| Document IDs | Invoice number, UUID, order/contract references | `ANONYMIZED-DOC-ID`, `ANONYMIZED-REF` |
| Payment references | Payment IDs, mandate IDs, buyer references | `ANONYMIZED-PAYMENT-ID`, `ANONYMIZED-BUYER-REF` |
| Notes | Free-text notes (may contain any sensitive data) | `Anonymized note` |
| URIs | Website URLs, communication URIs | `https://www.example.com`, `ANONYMIZED-URI` |
| Binary attachments | Embedded document content | Replaced with placeholder |

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

## Usage

### Command Line

Build the standalone jar and run it:

```bash
mvn clean package
java -jar target/xml-anonymizer-full.jar [options] <files...>
```

**Options:**

| Option | Description | Default |
|--------|-------------|---------|
| `-t`, `--target` | Output directory | Current directory |
| `-s`, `--suffix` | Output filename suffix | `-anonymized` |
| `-f`, `--format` | Force format (`ubl21` or `cii-d16b`) | Auto-detect |
| `--verbose` | Enable verbose output | Off |
| `-h`, `--help` | Show help | |
| `-V`, `--version` | Show version | |

**Examples:**

```bash
# Anonymize a single file (format auto-detected)
java -jar xml-anonymizer-full.jar invoice.xml

# Anonymize multiple files into a specific directory
java -jar xml-anonymizer-full.jar -t /output/dir invoice1.xml invoice2.xml cii-invoice.xml

# Force CII format and use custom suffix
java -jar xml-anonymizer-full.jar -f cii-d16b -s -redacted invoice.xml

# Verbose output
java -jar xml-anonymizer-full.jar --verbose *.xml
```

The output file is written to the target directory with the suffix appended before the file extension.
For example, `invoice.xml` becomes `invoice-anonymized.xml`.

### Java API

```java
// Explicit format
XMLAnonymizer aAnonymizer = new XMLAnonymizer (EAnonymizationFormat.UBL_21);
aAnonymizer.anonymize (new File ("invoice.xml"), new File ("invoice-anonymized.xml"));

// Auto-detect format (uses DDD)
XMLAnonymizer.anonymizeAutoDetect (new File ("input.xml"), new File ("output.xml"));

// DOM-based
Document aDoc = DOMReader.readXMLDOM (new File ("invoice.xml"));
XMLAnonymizer aAnonymizer = new XMLAnonymizer (EAnonymizationFormat.CII_D16B);
Document aResult = aAnonymizer.anonymize (aDoc);
```

### Standalone XSLT

The XSLT stylesheets can be used independently with any XSLT 1.0 processor:

```bash
# UBL 2.1
xsltproc src/main/resources/xslt/ubl21-anonymize.xslt invoice.xml > invoice-anonymized.xml

# CII D16B
xsltproc src/main/resources/xslt/cii-d16b-anonymize.xslt cii-invoice.xml > cii-invoice-anonymized.xml
```

## Building

Requires Java 17+ and Maven.

```bash
mvn clean package
```

The build produces two artifacts (replacing x.y.z with the actual version number):
- `target/xml-anonymizer-x.y.z-SNAPSHOT.jar` - Library jar
- `target/xml-anonymizer-full.jar` - Standalone executable jar with all dependencies

## Maven Coordinates

```xml
<dependency>
  <groupId>com.helger</groupId>
  <artifactId>xml-anonymizer</artifactId>
  <version>1.0.0-SNAPSHOT</version>
</dependency>
```

## License

Apache License, Version 2.0

## News and Noteworthy

v1.0.0 - 2026-04-24
* Initial version

