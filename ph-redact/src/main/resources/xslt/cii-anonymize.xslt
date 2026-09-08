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
  XSLT 1.0 stylesheet to anonymize sensitive data in UN/CEFACT CII CrossIndustryInvoice documents.
  Contains the elements of the EN 16931:2017 binding (CII D16B) as well as the elements added by
  the EN 16931:2026 binding (CII D25A) - the namespaces of D16B and D25A are identical.
-->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:rsm="urn:un:unece:uncefact:data:standard:CrossIndustryInvoice:100"
  xmlns:ram="urn:un:unece:uncefact:data:standard:ReusableAggregateBusinessInformationEntity:100"
  xmlns:qdt="urn:un:unece:uncefact:data:standard:QualifiedDataType:100"
  xmlns:udt="urn:un:unece:uncefact:data:standard:UnqualifiedDataType:100">

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

  <!-- ExchangedDocument/ID (invoice number) -->
  <xsl:template match="rsm:ExchangedDocument/ram:ID">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-upper, '-DOC-ID')" /></xsl:copy>
  </xsl:template>

  <!-- ExchangedDocumentContext transaction ID -->
  <xsl:template match="ram:SpecifiedTransactionID">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-upper, '-TX-ID')" /></xsl:copy>
  </xsl:template>

  <!-- ==================== Trade party identification ==================== -->

  <!-- TradeParty ID (all party contexts) -->
  <xsl:template match="ram:SellerTradeParty/ram:ID |
                       ram:BuyerTradeParty/ram:ID |
                       ram:ShipToTradeParty/ram:ID |
                       ram:ShipFromTradeParty/ram:ID |
                       ram:UltimateShipToTradeParty/ram:ID |
                       ram:InvoicerTradeParty/ram:ID |
                       ram:InvoiceeTradeParty/ram:ID |
                       ram:PayeeTradeParty/ram:ID |
                       ram:PayerTradeParty/ram:ID |
                       ram:SalesAgentTradeParty/ram:ID |
                       ram:BuyerTaxRepresentativeTradeParty/ram:ID |
                       ram:SellerTaxRepresentativeTradeParty/ram:ID |
                       ram:BuyerAssignedAccountantTradeParty/ram:ID |
                       ram:SellerAssignedAccountantTradeParty/ram:ID |
                       ram:UltimatePayeeTradeParty/ram:ID |
                       ram:ItemSellerTradeParty/ram:ID |
                       ram:ItemBuyerTradeParty/ram:ID |
                       ram:IssuerTradeParty/ram:ID">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-upper, '-PARTY-ID')" /></xsl:copy>
  </xsl:template>

  <!-- TradeParty GlobalID -->
  <xsl:template match="ram:SellerTradeParty/ram:GlobalID |
                       ram:BuyerTradeParty/ram:GlobalID |
                       ram:ShipToTradeParty/ram:GlobalID |
                       ram:ShipFromTradeParty/ram:GlobalID |
                       ram:UltimateShipToTradeParty/ram:GlobalID |
                       ram:InvoicerTradeParty/ram:GlobalID |
                       ram:InvoiceeTradeParty/ram:GlobalID |
                       ram:PayeeTradeParty/ram:GlobalID |
                       ram:PayerTradeParty/ram:GlobalID |
                       ram:SalesAgentTradeParty/ram:GlobalID |
                       ram:BuyerTaxRepresentativeTradeParty/ram:GlobalID |
                       ram:SellerTaxRepresentativeTradeParty/ram:GlobalID |
                       ram:UltimatePayeeTradeParty/ram:GlobalID |
                       ram:ItemSellerTradeParty/ram:GlobalID |
                       ram:ItemBuyerTradeParty/ram:GlobalID |
                       ram:IssuerTradeParty/ram:GlobalID">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-upper, '-GLOBAL-ID')" /></xsl:copy>
  </xsl:template>

  <!-- ==================== Trade party names ==================== -->

  <xsl:template match="ram:SellerTradeParty/ram:Name |
                       ram:BuyerTradeParty/ram:Name |
                       ram:ShipToTradeParty/ram:Name |
                       ram:ShipFromTradeParty/ram:Name |
                       ram:UltimateShipToTradeParty/ram:Name |
                       ram:InvoicerTradeParty/ram:Name |
                       ram:InvoiceeTradeParty/ram:Name |
                       ram:PayeeTradeParty/ram:Name |
                       ram:PayerTradeParty/ram:Name |
                       ram:SalesAgentTradeParty/ram:Name |
                       ram:BuyerTaxRepresentativeTradeParty/ram:Name |
                       ram:SellerTaxRepresentativeTradeParty/ram:Name |
                       ram:BuyerAssignedAccountantTradeParty/ram:Name |
                       ram:SellerAssignedAccountantTradeParty/ram:Name |
                       ram:UltimatePayeeTradeParty/ram:Name |
                       ram:ItemSellerTradeParty/ram:Name |
                       ram:ItemBuyerTradeParty/ram:Name |
                       ram:IssuerTradeParty/ram:Name">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-text, ' Party')" /></xsl:copy>
  </xsl:template>

  <!-- ==================== Legal organization ==================== -->

  <xsl:template match="ram:SpecifiedLegalOrganization/ram:ID">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-upper, '-LEGAL-ID')" /></xsl:copy>
  </xsl:template>

  <xsl:template match="ram:SpecifiedLegalOrganization/ram:Name">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-text, ' Legal Entity')" /></xsl:copy>
  </xsl:template>

  <xsl:template match="ram:SpecifiedLegalOrganization/ram:TradingBusinessName">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-text, ' Trading Name')" /></xsl:copy>
  </xsl:template>

  <!-- ==================== Tax registration ==================== -->

  <xsl:template match="ram:SpecifiedTaxRegistration/ram:ID">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-upper, '-TAX-ID')" /></xsl:copy>
  </xsl:template>

  <!-- ==================== Contact information ==================== -->

  <xsl:template match="ram:DefinedTradeContact/ram:PersonName">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-text, ' Contact')" /></xsl:copy>
  </xsl:template>

  <xsl:template match="ram:DefinedTradeContact/ram:DepartmentName">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-text, ' Department')" /></xsl:copy>
  </xsl:template>

  <xsl:template match="ram:DefinedTradeContact/ram:ID">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-upper, '-CONTACT-ID')" /></xsl:copy>
  </xsl:template>

  <xsl:template match="ram:DefinedTradeContact/ram:JobTitle">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>Employee</xsl:text></xsl:copy>
  </xsl:template>

  <xsl:template match="ram:DefinedTradeContact/ram:Responsibility">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-text, ' Responsibility')" /></xsl:copy>
  </xsl:template>

  <xsl:template match="ram:DefinedTradeContact/ram:PersonID">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-upper, '-PERSON-ID')" /></xsl:copy>
  </xsl:template>

  <!-- Contact person details -->
  <xsl:template match="ram:SpecifiedContactPerson/ram:GivenName">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="$prefix-text" /></xsl:copy>
  </xsl:template>

  <xsl:template match="ram:SpecifiedContactPerson/ram:MiddleName">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>A.</xsl:text></xsl:copy>
  </xsl:template>

  <xsl:template match="ram:SpecifiedContactPerson/ram:FamilyName">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>Person</xsl:text></xsl:copy>
  </xsl:template>

  <!-- ==================== Communication channels ==================== -->

  <!-- Telephone -->
  <xsl:template match="ram:TelephoneUniversalCommunication/ram:CompleteNumber |
                       ram:DirectTelephoneUniversalCommunication/ram:CompleteNumber |
                       ram:MobileTelephoneUniversalCommunication/ram:CompleteNumber |
                       ram:FaxUniversalCommunication/ram:CompleteNumber |
                       ram:TelexUniversalCommunication/ram:CompleteNumber |
                       ram:VOIPUniversalCommunication/ram:CompleteNumber">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>+00 000 0000000</xsl:text></xsl:copy>
  </xsl:template>

  <!-- Email -->
  <xsl:template match="ram:EmailURIUniversalCommunication/ram:URIID">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-lower, '@example.com')" /></xsl:copy>
  </xsl:template>

  <!-- IM -->
  <xsl:template match="ram:InstantMessagingUniversalCommunication/ram:URIID">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-lower, '@example.com')" /></xsl:copy>
  </xsl:template>

  <!-- URI-based communication (endpoint, website, etc.) -->
  <xsl:template match="ram:URIUniversalCommunication/ram:URIID">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-upper, '-URI')" /></xsl:copy>
  </xsl:template>

  <xsl:template match="ram:EndPointURIUniversalCommunication/ram:URIID">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-upper, '-ENDPOINT')" /></xsl:copy>
  </xsl:template>

  <!-- ==================== Address information ==================== -->

  <xsl:template match="ram:PostalTradeAddress/ram:PostcodeCode">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>00000</xsl:text></xsl:copy>
  </xsl:template>

  <xsl:template match="ram:PostalTradeAddress/ram:LineOne">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-text, ' Street 1')" /></xsl:copy>
  </xsl:template>

  <xsl:template match="ram:PostalTradeAddress/ram:LineTwo">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-text, ' Address Line 2')" /></xsl:copy>
  </xsl:template>

  <xsl:template match="ram:PostalTradeAddress/ram:LineThree">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-text, ' Address Line 3')" /></xsl:copy>
  </xsl:template>

  <xsl:template match="ram:PostalTradeAddress/ram:LineFour">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-text, ' Address Line 4')" /></xsl:copy>
  </xsl:template>

  <xsl:template match="ram:PostalTradeAddress/ram:LineFive">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-text, ' Address Line 5')" /></xsl:copy>
  </xsl:template>

  <xsl:template match="ram:PostalTradeAddress/ram:StreetName">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-text, ' Street')" /></xsl:copy>
  </xsl:template>

  <xsl:template match="ram:PostalTradeAddress/ram:CityName">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-text, ' City')" /></xsl:copy>
  </xsl:template>

  <xsl:template match="ram:PostalTradeAddress/ram:CitySubDivisionName">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-text, ' District')" /></xsl:copy>
  </xsl:template>

  <xsl:template match="ram:PostalTradeAddress/ram:CountrySubDivisionName">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-text, ' Region')" /></xsl:copy>
  </xsl:template>

  <xsl:template match="ram:PostalTradeAddress/ram:BuildingName">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>Building A</xsl:text></xsl:copy>
  </xsl:template>

  <xsl:template match="ram:PostalTradeAddress/ram:BuildingNumber">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>1</xsl:text></xsl:copy>
  </xsl:template>

  <xsl:template match="ram:PostalTradeAddress/ram:PostOfficeBox">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>0000</xsl:text></xsl:copy>
  </xsl:template>

  <xsl:template match="ram:PostalTradeAddress/ram:DepartmentName">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-text, ' Department')" /></xsl:copy>
  </xsl:template>

  <xsl:template match="ram:PostalTradeAddress/ram:AdditionalStreetName">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-text, ' Additional Street')" /></xsl:copy>
  </xsl:template>

  <xsl:template match="ram:PostalTradeAddress/ram:AttentionOf">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-text, ' Person')" /></xsl:copy>
  </xsl:template>

  <xsl:template match="ram:PostalTradeAddress/ram:CareOf">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-text, ' Person')" /></xsl:copy>
  </xsl:template>

  <xsl:template match="ram:PostalTradeAddress/ram:ID">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-upper, '-ADDR-ID')" /></xsl:copy>
  </xsl:template>

  <xsl:template match="ram:PostalTradeAddress/ram:CountryName">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-text, ' Country')" /></xsl:copy>
  </xsl:template>

  <xsl:template match="ram:PostalTradeAddress/ram:CountrySubDivisionID">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>XX</xsl:text></xsl:copy>
  </xsl:template>

  <!-- ==================== Financial account information ==================== -->

  <!-- Creditor financial account -->
  <xsl:template match="ram:PayeePartyCreditorFinancialAccount/ram:IBANID">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-upper, '-IBAN')" /></xsl:copy>
  </xsl:template>

  <xsl:template match="ram:PayeePartyCreditorFinancialAccount/ram:AccountName">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-text, ' Account')" /></xsl:copy>
  </xsl:template>

  <xsl:template match="ram:PayeePartyCreditorFinancialAccount/ram:ProprietaryID">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-upper, '-ACCOUNT-ID')" /></xsl:copy>
  </xsl:template>

  <!-- Debtor financial account -->
  <xsl:template match="ram:PayerPartyDebtorFinancialAccount/ram:IBANID">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-upper, '-IBAN')" /></xsl:copy>
  </xsl:template>

  <xsl:template match="ram:PayerPartyDebtorFinancialAccount/ram:AccountName">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-text, ' Account')" /></xsl:copy>
  </xsl:template>

  <xsl:template match="ram:PayerPartyDebtorFinancialAccount/ram:ProprietaryID">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-upper, '-ACCOUNT-ID')" /></xsl:copy>
  </xsl:template>

  <!-- ==================== Financial institution ==================== -->

  <xsl:template match="ram:PayeeSpecifiedCreditorFinancialInstitution/ram:BICID |
                        ram:PayerSpecifiedDebtorFinancialInstitution/ram:BICID">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-upper, '-BIC')" /></xsl:copy>
  </xsl:template>

  <xsl:template match="ram:PayeeSpecifiedCreditorFinancialInstitution/ram:Name |
                        ram:PayerSpecifiedDebtorFinancialInstitution/ram:Name">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-text, ' Bank')" /></xsl:copy>
  </xsl:template>

  <!-- ==================== Payment card information ==================== -->

  <xsl:template match="ram:ApplicableTradeSettlementFinancialCard/ram:ID">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>0000000000000000</xsl:text></xsl:copy>
  </xsl:template>

  <xsl:template match="ram:ApplicableTradeSettlementFinancialCard/ram:CardholderName">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-upper, ' CARDHOLDER')" /></xsl:copy>
  </xsl:template>

  <xsl:template match="ram:ApplicableTradeSettlementFinancialCard/ram:VerificationNumeric">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>000</xsl:text></xsl:copy>
  </xsl:template>

  <xsl:template match="ram:ApplicableTradeSettlementFinancialCard/ram:IssuingCompanyName">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-text, ' Card Issuer')" /></xsl:copy>
  </xsl:template>

  <!-- ==================== Payment means ==================== -->

  <xsl:template match="ram:SpecifiedTradeSettlementPaymentMeans/ram:ID">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-upper, '-PAYMENT-ID')" /></xsl:copy>
  </xsl:template>

  <xsl:template match="ram:SpecifiedTradeSettlementPaymentMeans/ram:Information">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-text, ' payment information')" /></xsl:copy>
  </xsl:template>

  <!-- ==================== Payment mandate ==================== -->

  <xsl:template match="ram:SpecifiedTradePaymentTerms/ram:DirectDebitMandateID">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-upper, '-MANDATE-ID')" /></xsl:copy>
  </xsl:template>

  <!-- Bank assigned creditor identifier -->
  <xsl:template match="ram:CreditorReferenceID">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-upper, '-CREDITOR-ID')" /></xsl:copy>
  </xsl:template>

  <!-- ==================== Document references ==================== -->

  <xsl:template match="ram:SellerOrderReferencedDocument/ram:IssuerAssignedID |
                       ram:BuyerOrderReferencedDocument/ram:IssuerAssignedID |
                       ram:ContractReferencedDocument/ram:IssuerAssignedID |
                       ram:DespatchAdviceReferencedDocument/ram:IssuerAssignedID |
                       ram:DeliveryNoteReferencedDocument/ram:IssuerAssignedID |
                       ram:ReceivingAdviceReferencedDocument/ram:IssuerAssignedID |
                       ram:AdditionalReferencedDocument/ram:IssuerAssignedID |
                       ram:InvoiceReferencedDocument/ram:IssuerAssignedID">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-upper, '-REF')" /></xsl:copy>
  </xsl:template>

  <!-- Supporting document description -->
  <xsl:template match="ram:AdditionalReferencedDocument/ram:Name">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-text, ' document description')" /></xsl:copy>
  </xsl:template>

  <!-- External document location -->
  <xsl:template match="ram:AdditionalReferencedDocument/ram:URIID">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat('https://www.example.com/', $prefix-lower)" /></xsl:copy>
  </xsl:template>

  <!-- ==================== Project reference ==================== -->

  <!-- The project name must carry the same value as the project reference -->
  <xsl:template match="ram:SpecifiedProcuringProject/ram:ID |
                       ram:SpecifiedProcuringProject/ram:Name">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-upper, '-REF')" /></xsl:copy>
  </xsl:template>

  <!-- ==================== Accounting reference ==================== -->

  <xsl:template match="ram:ReceivableSpecifiedTradeAccountingAccount/ram:ID |
                       ram:PayableSpecifiedTradeAccountingAccount/ram:ID">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-upper, '-ACCOUNTING-REF')" /></xsl:copy>
  </xsl:template>

  <!-- ==================== Notes (may contain sensitive free text) ==================== -->

  <xsl:template match="ram:IncludedNote/ram:Content">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-text, ' note')" /></xsl:copy>
  </xsl:template>

  <!-- Payment terms text -->
  <xsl:template match="ram:SpecifiedTradePaymentTerms/ram:Description">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-text, ' note')" /></xsl:copy>
  </xsl:template>

  <!-- ==================== Payment reference ==================== -->

  <xsl:template match="ram:PaymentReference">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-upper, '-PAYMENT-REF')" /></xsl:copy>
  </xsl:template>

  <!-- ==================== Buyer reference ==================== -->

  <xsl:template match="ram:BuyerReference |
                       ram:BuyerReferenceID">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:value-of select="concat($prefix-upper, '-BUYER-REF')" /></xsl:copy>
  </xsl:template>

  <!-- ==================== Attached binary objects ==================== -->

  <xsl:template match="ram:AttachmentBinaryObject">
    <xsl:copy>
      <xsl:apply-templates select="@*" />
      <xsl:text>QU5PTllNSVpFRA==</xsl:text>
    </xsl:copy>
  </xsl:template>

  <!-- Attached document filename -->
  <xsl:template match="ram:AttachmentBinaryObject/@filename">
    <xsl:attribute name="filename">
      <xsl:value-of select="concat($prefix-lower, '.bin')" />
    </xsl:attribute>
  </xsl:template>

</xsl:stylesheet>
