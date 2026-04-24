# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

XSLT-based XML document anonymizer for e-invoicing formats (UBL 2.1 and CII D16B). Replaces sensitive/PII data while preserving document structure, monetary values, tax information, and non-sensitive business data. Format detection uses the [DDD](https://github.com/phax/ddd) library, which also handles SBDH and XHE envelope unwrapping.

## Build & Test Commands

```bash
mvn clean package              # Build library jar + standalone fat jar
mvn test                       # Run all tests
mvn -Dtest=XMLAnonymizerFuncTest test   # Run a single test class
```

Requires Java 17+ and Maven. The build produces:
- `target/ph-redact-<version>.jar` — library jar
- `target/ph-redact-full.jar` — standalone executable (via maven-shade-plugin)

## Architecture

The codebase is a single-module Maven project with three Java classes and two XSLT stylesheets:

- **`EAnonymizationFormat`** — Enum mapping format IDs (`ubl21`, `cii-d16b`) to their XSLT classpath resources. Also maps DDD syntax IDs to formats via `getFromDDDSyntaxIDOrNull`.
- **`XMLAnonymizer`** — Core class. Compiles and caches the XSLT `Templates` for a given format, then applies the transformation. Provides `detectFormat(Document)` for auto-detection via DDD, and a convenience `anonymizeAutoDetect` static method.
- **`XMLAnonymizerMain`** — CLI entry point using picocli. Supports batch processing of multiple files with format auto-detection or forced format.

The actual anonymization logic lives entirely in the XSLT stylesheets under `src/main/resources/xslt/`. Java code only handles XSLT compilation, format detection, and CLI orchestration.

## Adding a New Format

1. Create a new XSLT stylesheet in `src/main/resources/xslt/`.
2. Add a new constant to `EAnonymizationFormat` with the format ID and XSLT path.
3. Update `getFromDDDSyntaxIDOrNull` if the format has a DDD syntax mapping.
4. Add test data under `src/test/resources/external/<format>/` and corresponding tests in `XMLAnonymizerFuncTest`.

## Key Dependencies

- **ph-commons / ph-xml** — XML DOM reading/writing (`DOMReader`, `XMLWriter`)
- **DDD** — Document Details Determinator for format auto-detection and envelope unwrapping
- **picocli** — CLI argument parsing
- **JUnit 4** — Test framework (not JUnit 5)
