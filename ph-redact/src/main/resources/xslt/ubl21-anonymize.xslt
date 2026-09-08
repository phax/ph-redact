<?xml version="1.0" encoding="UTF-8"?>
<!--

    Copyright (C) 2026 Philip Helger (www.helger.com)
    philip[at]helger[dot]com

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

            http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

-->
<!--
  XSLT 1.0 stylesheet to anonymize sensitive data in UBL documents.
  Covers all main UBL document types (Invoice, CreditNote, Order, DespatchAdvice, etc.)
  since they all share the same CommonBasicComponents and CommonAggregateComponents namespaces.
  Contains the elements of the EN 16931:2017 binding (UBL 2.1) as well as the elements added by
  the EN 16931:2026 binding (UBL 2.5) - the namespaces of UBL 2.1 and UBL 2.5 are identical.
-->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2"
  xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2">

  <xsl:output method="xml" encoding="UTF-8" indent="yes" />
  <xsl:strip-space elements="*" />

  <!--
    Prefix of all replacement values. The context specific remainder (e.g. "-DOC-ID", " Party",
    "@example.com") is appended to it. The default value is mirrored in
    XMLAnonymizer.DEFAULT_ANONYMIZATION_PREFIX.
  -->
  <xsl:param name="anonymization-prefix" select="'ANONYMIZED'" />

  <!--
    Case variants of the prefix: upper case for identifiers ("ANONYMIZED-DOC-ID"), mixed case for
    human readable texts ("Anonymized Party") and lower case for mail addresses, URLs and filenames
    ("anonymized@example.com").
  -->
  <xsl:variable name="lowercase-chars" select="'abcdefghijklmnopqrstuvwxyz'" />
  <xsl:variable name="uppercase-chars" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />
  <xsl:variable name="prefix-upper" select="translate($anonymization-prefix, $lowercase-chars, $uppercase-chars)" />
  <xsl:variable name="prefix-lower" select="translate($anonymization-prefix, $uppercase-chars, $lowercase-chars)" />
  <xsl:variable name="prefix-text"
                select="concat(translate(substring($anonymization-prefix, 1, 1), $lowercase-chars, $uppercase-chars),
                               substring($prefix-lower, 2))" />

  <!-- ==================== Identity transform ==================== -->
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

  <!-- ==================== Document-level identifiers ==================== -->

  <!-- Root document ID (Invoice/ID, CreditNote/ID, Order/ID, etc.) -->
  <xsl:template match="/*[namespace-uri()!='urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2']/cbc:ID">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-upper, '-DOC-ID')" /></xsl:copy>
  </xsl:template>

  <!-- UUID -->
  <xsl:template match="cbc:UUID">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>00000000-0000-0000-0000-000000000000</xsl:text></xsl:copy>
  </xsl:template>

  <!-- ==================== Document reference identifiers ==================== -->

  <xsl:template match="cac:OrderReference/cbc:ID |
                       cac:ContractDocumentReference/cbc:ID |
                       cac:DespatchDocumentReference/cbc:ID |
                       cac:DeliveryNoteDocumentReference/cbc:ID |
                       cac:ReceiptDocumentReference/cbc:ID |
                       cac:OriginatorDocumentReference/cbc:ID |
                       cac:AdditionalDocumentReference/cbc:ID |
                       cac:ProjectReference/cbc:ID |
                       cac:InvoiceDocumentReference/cbc:ID |
                       cac:CreditNoteDocumentReference/cbc:ID |
                       cac:SelfBilledInvoiceDocumentReference/cbc:ID |
                       cac:SelfBilledCreditNoteDocumentReference/cbc:ID |
                       cac:DebitNoteDocumentReference/cbc:ID |
                       cac:StatementDocumentReference/cbc:ID |
                       cac:DocumentReference/cbc:ID">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-upper, '-REF')" /></xsl:copy>
  </xsl:template>

  <!-- Sales order reference -->
  <xsl:template match="cac:OrderReference/cbc:SalesOrderID">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-upper, '-REF')" /></xsl:copy>
  </xsl:template>

  <!-- Billing reference document IDs -->
  <xsl:template match="cac:BillingReference/cac:InvoiceDocumentReference/cbc:ID |
                       cac:BillingReference/cac:CreditNoteDocumentReference/cbc:ID |
                       cac:BillingReference/cac:DebitNoteDocumentReference/cbc:ID |
                       cac:BillingReference/cac:SelfBilledInvoiceDocumentReference/cbc:ID">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-upper, '-REF')" /></xsl:copy>
  </xsl:template>

  <!-- Line item IDs -->
  <xsl:template match="cac:InvoiceLine/cbc:ID |
                       cac:CreditNoteLine/cbc:ID |
                       cac:DebitNoteLine/cbc:ID |
                       cac:OrderLine/cac:LineItem/cbc:ID |
                       cac:DespatchLine/cbc:ID |
                       cac:ReceiptLine/cbc:ID">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="." /></xsl:copy>
  </xsl:template>

  <!-- ==================== Party identification ==================== -->

  <xsl:template match="cbc:EndpointID">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-upper, '-ENDPOINT')" /></xsl:copy>
  </xsl:template>

  <xsl:template match="cac:PartyIdentification/cbc:ID">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-upper, '-PARTY-ID')" /></xsl:copy>
  </xsl:template>

  <xsl:template match="cac:PartyLegalEntity/cbc:CompanyID">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-upper, '-COMPANY-ID')" /></xsl:copy>
  </xsl:template>

  <xsl:template match="cac:PartyLegalEntity/cbc:RegistrationName">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-text, ' Company')" /></xsl:copy>
  </xsl:template>

  <!-- Tax registration (VAT number) -->
  <xsl:template match="cac:PartyTaxScheme/cbc:CompanyID">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-upper, '-TAX-ID')" /></xsl:copy>
  </xsl:template>

  <xsl:template match="cac:PartyTaxScheme/cbc:RegistrationName">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-text, ' Tax Entity')" /></xsl:copy>
  </xsl:template>

  <!-- ==================== Party names ==================== -->

  <xsl:template match="cac:PartyName/cbc:Name">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-text, ' Party')" /></xsl:copy>
  </xsl:template>

  <!-- ==================== Contact information ==================== -->

  <xsl:template match="cac:Contact/cbc:ID">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-upper, '-CONTACT-ID')" /></xsl:copy>
  </xsl:template>

  <xsl:template match="cac:Contact/cbc:Name">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-text, ' Contact')" /></xsl:copy>
  </xsl:template>

  <xsl:template match="cbc:Telephone">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>+00 000 0000000</xsl:text></xsl:copy>
  </xsl:template>

  <xsl:template match="cbc:Telefax">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>+00 000 0000000</xsl:text></xsl:copy>
  </xsl:template>

  <xsl:template match="cbc:ElectronicMail">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-lower, '@example.com')" /></xsl:copy>
  </xsl:template>

  <!-- ==================== Person information ==================== -->

  <xsl:template match="cac:Person/cbc:FirstName">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="$prefix-text" /></xsl:copy>
  </xsl:template>

  <xsl:template match="cac:Person/cbc:FamilyName">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>Person</xsl:text></xsl:copy>
  </xsl:template>

  <xsl:template match="cac:Person/cbc:MiddleName">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>A.</xsl:text></xsl:copy>
  </xsl:template>

  <xsl:template match="cac:Person/cbc:OtherName">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="$prefix-text" /></xsl:copy>
  </xsl:template>

  <xsl:template match="cac:Person/cbc:Title">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>Mx</xsl:text></xsl:copy>
  </xsl:template>

  <xsl:template match="cac:Person/cbc:NameSuffix">
    <xsl:copy><xsl:apply-templates select="@*" /></xsl:copy>
  </xsl:template>

  <xsl:template match="cac:Person/cbc:JobTitle">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>Employee</xsl:text></xsl:copy>
  </xsl:template>

  <xsl:template match="cac:Person/cbc:ID">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-upper, '-PERSON-ID')" /></xsl:copy>
  </xsl:template>

  <xsl:template match="cac:Person/cbc:NationalityID">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>XX</xsl:text></xsl:copy>
  </xsl:template>

  <xsl:template match="cac:Person/cbc:BirthDate">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>1900-01-01</xsl:text></xsl:copy>
  </xsl:template>

  <xsl:template match="cac:Person/cbc:BirthplaceName">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-text, ' City')" /></xsl:copy>
  </xsl:template>

  <xsl:template match="cac:Person/cbc:GenderCode">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>0</xsl:text></xsl:copy>
  </xsl:template>

  <!-- ==================== Address information ==================== -->

  <xsl:template match="cbc:StreetName">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-text, ' Street')" /></xsl:copy>
  </xsl:template>

  <xsl:template match="cbc:AdditionalStreetName">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-text, ' Additional Street')" /></xsl:copy>
  </xsl:template>

  <xsl:template match="cbc:BuildingName">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>Building A</xsl:text></xsl:copy>
  </xsl:template>

  <xsl:template match="cbc:BuildingNumber">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>1</xsl:text></xsl:copy>
  </xsl:template>

  <xsl:template match="cbc:CityName">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-text, ' City')" /></xsl:copy>
  </xsl:template>

  <xsl:template match="cbc:PostalZone">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>00000</xsl:text></xsl:copy>
  </xsl:template>

  <xsl:template match="cbc:CitySubdivisionName">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-text, ' District')" /></xsl:copy>
  </xsl:template>

  <xsl:template match="cbc:CountrySubentity">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-text, ' Region')" /></xsl:copy>
  </xsl:template>

  <xsl:template match="cbc:CountrySubentityCode">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>XX</xsl:text></xsl:copy>
  </xsl:template>

  <xsl:template match="cbc:Region">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-text, ' Region')" /></xsl:copy>
  </xsl:template>

  <xsl:template match="cbc:District">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-text, ' District')" /></xsl:copy>
  </xsl:template>

  <xsl:template match="cbc:BlockName">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>Block A</xsl:text></xsl:copy>
  </xsl:template>

  <xsl:template match="cbc:Postbox">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>0000</xsl:text></xsl:copy>
  </xsl:template>

  <xsl:template match="cbc:Floor">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>0</xsl:text></xsl:copy>
  </xsl:template>

  <xsl:template match="cbc:Room">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>0</xsl:text></xsl:copy>
  </xsl:template>

  <xsl:template match="cbc:Department">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-text, ' Department')" /></xsl:copy>
  </xsl:template>

  <xsl:template match="cbc:MarkAttention">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-text, ' Person')" /></xsl:copy>
  </xsl:template>

  <xsl:template match="cbc:MarkCare">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-text, ' Person')" /></xsl:copy>
  </xsl:template>

  <xsl:template match="cbc:PlotIdentification">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>0</xsl:text></xsl:copy>
  </xsl:template>

  <xsl:template match="cbc:InhouseMail">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="$prefix-lower" /></xsl:copy>
  </xsl:template>

  <xsl:template match="cac:AddressLine/cbc:Line">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-text, ' Address Line')" /></xsl:copy>
  </xsl:template>

  <!-- ==================== Financial account information ==================== -->

  <xsl:template match="cac:FinancialAccount/cbc:ID |
                       cac:PayeeFinancialAccount/cbc:ID |
                       cac:PayerFinancialAccount/cbc:ID |
                       cac:CreditAccount/cbc:ID">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-upper, '-IBAN')" /></xsl:copy>
  </xsl:template>

  <xsl:template match="cac:FinancialAccount/cbc:Name |
                        cac:PayeeFinancialAccount/cbc:Name |
                        cac:PayerFinancialAccount/cbc:Name">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-text, ' Account')" /></xsl:copy>
  </xsl:template>

  <xsl:template match="cac:FinancialAccount/cbc:AliasName |
                        cac:PayeeFinancialAccount/cbc:AliasName |
                        cac:PayerFinancialAccount/cbc:AliasName">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-text, ' Account Alias')" /></xsl:copy>
  </xsl:template>

  <xsl:template match="cac:FinancialInstitutionBranch/cbc:ID">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-upper, '-BIC')" /></xsl:copy>
  </xsl:template>

  <xsl:template match="cac:FinancialInstitutionBranch/cbc:Name">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-text, ' Bank')" /></xsl:copy>
  </xsl:template>

  <xsl:template match="cac:FinancialInstitution/cbc:ID">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-upper, '-BIC')" /></xsl:copy>
  </xsl:template>

  <xsl:template match="cac:FinancialInstitution/cbc:Name">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-text, ' Bank')" /></xsl:copy>
  </xsl:template>

  <!-- ==================== Payment card information ==================== -->

  <xsl:template match="cac:CardAccount/cbc:PrimaryAccountNumberID">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>0000000000000000</xsl:text></xsl:copy>
  </xsl:template>

  <xsl:template match="cac:CardAccount/cbc:HolderName">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-upper, ' CARDHOLDER')" /></xsl:copy>
  </xsl:template>

  <xsl:template match="cac:CardAccount/cbc:CV2ID">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>000</xsl:text></xsl:copy>
  </xsl:template>

  <xsl:template match="cac:CardAccount/cbc:IssuerID">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="$prefix-upper" /></xsl:copy>
  </xsl:template>

  <xsl:template match="cac:CardAccount/cbc:IssueNumberID">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>000</xsl:text></xsl:copy>
  </xsl:template>

  <!-- ==================== Payment means ==================== -->

  <xsl:template match="cac:PaymentMeans/cbc:PaymentID">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-upper, '-PAYMENT-ID')" /></xsl:copy>
  </xsl:template>

  <xsl:template match="cac:PaymentMeans/cbc:InstructionID">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-upper, '-INSTRUCTION-ID')" /></xsl:copy>
  </xsl:template>

  <xsl:template match="cac:PaymentMeans/cbc:InstructionNote">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-text, ' payment instruction')" /></xsl:copy>
  </xsl:template>

  <!-- ==================== Payment mandate ==================== -->

  <xsl:template match="cac:PaymentMandate/cbc:ID">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-upper, '-MANDATE-ID')" /></xsl:copy>
  </xsl:template>

  <!-- ==================== URIs ==================== -->

  <xsl:template match="cbc:WebsiteURI">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>https://www.example.com</xsl:text></xsl:copy>
  </xsl:template>

  <!-- External document location -->
  <xsl:template match="cac:ExternalReference/cbc:URI">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat('https://www.example.com/', $prefix-lower)" /></xsl:copy>
  </xsl:template>

  <!-- ==================== Notes (may contain sensitive free text) ==================== -->

  <xsl:template match="cbc:Note">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-text, ' note')" /></xsl:copy>
  </xsl:template>

  <!-- Invoice note of UBL 2.5 (replaces the document level cbc:Note) -->
  <xsl:template match="cac:Annotation/cbc:AnnotationContent">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-text, ' note')" /></xsl:copy>
  </xsl:template>

  <!-- ==================== Delivery location ==================== -->

  <xsl:template match="cac:DeliveryLocation/cbc:ID">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-upper, '-LOCATION-ID')" /></xsl:copy>
  </xsl:template>

  <xsl:template match="cac:DeliveryLocation/cbc:Description">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-text, ' location')" /></xsl:copy>
  </xsl:template>

  <!-- ==================== Buyer/Customer reference ==================== -->

  <xsl:template match="cbc:BuyerReference">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-upper, '-BUYER-REF')" /></xsl:copy>
  </xsl:template>

  <xsl:template match="cbc:CustomerAssignedAccountID">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-upper, '-ACCOUNT-ID')" /></xsl:copy>
  </xsl:template>

  <xsl:template match="cbc:SupplierAssignedAccountID">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-upper, '-ACCOUNT-ID')" /></xsl:copy>
  </xsl:template>

  <xsl:template match="cbc:AdditionalAccountID">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-upper, '-ACCOUNT-ID')" /></xsl:copy>
  </xsl:template>

  <!-- Buyer accounting reference (document and line level) -->
  <xsl:template match="cbc:AccountingCost">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-upper, '-ACCOUNTING-REF')" /></xsl:copy>
  </xsl:template>

  <xsl:template match="cbc:AccountingCostCode">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-upper, '-ACCOUNTING-REF')" /></xsl:copy>
  </xsl:template>

  <!-- ==================== Attached document content ==================== -->

  <xsl:template match="cac:Attachment/cbc:EmbeddedDocumentBinaryObject">
    <xsl:copy>
      <xsl:apply-templates select="@*" />
      <!-- Replace binary content with empty base64 -->
      <xsl:text>QU5PTllNSVpFRA==</xsl:text>
    </xsl:copy>
  </xsl:template>

  <!-- Attached document filename -->
  <xsl:template match="cac:Attachment/cbc:EmbeddedDocumentBinaryObject/@filename">
    <xsl:attribute name="filename">
      <xsl:value-of select="concat($prefix-lower, '.bin')" />
    </xsl:attribute>
  </xsl:template>

  <!-- Supporting document description -->
  <xsl:template match="cbc:DocumentDescription">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-text, ' document description')" /></xsl:copy>
  </xsl:template>

</xsl:stylesheet>
