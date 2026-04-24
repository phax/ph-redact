<?xml version="1.0" encoding="UTF-8"?>
<!--

    Copyright (C) 2015-2026 Philip Helger (www.helger.com)
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
  XSLT 1.0 stylesheet to anonymize sensitive data in UN/CEFACT CII D16B
  CrossIndustryInvoice documents.
-->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:rsm="urn:un:unece:uncefact:data:standard:CrossIndustryInvoice:100"
  xmlns:ram="urn:un:unece:uncefact:data:standard:ReusableAggregateBusinessInformationEntity:100"
  xmlns:qdt="urn:un:unece:uncefact:data:standard:QualifiedDataType:100"
  xmlns:udt="urn:un:unece:uncefact:data:standard:UnqualifiedDataType:100">

  <xsl:output method="xml" encoding="UTF-8" indent="yes" />
  <xsl:strip-space elements="*" />

  <!-- ==================== Identity transform ==================== -->
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

  <!-- ==================== Document-level identifiers ==================== -->

  <!-- ExchangedDocument/ID (invoice number) -->
  <xsl:template match="rsm:ExchangedDocument/ram:ID">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>ANONYMIZED-DOC-ID</xsl:text></xsl:copy>
  </xsl:template>

  <!-- ExchangedDocumentContext transaction ID -->
  <xsl:template match="ram:SpecifiedTransactionID">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>ANONYMIZED-TX-ID</xsl:text></xsl:copy>
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
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>ANONYMIZED-PARTY-ID</xsl:text></xsl:copy>
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
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>ANONYMIZED-GLOBAL-ID</xsl:text></xsl:copy>
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
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>Anonymous Party</xsl:text></xsl:copy>
  </xsl:template>

  <!-- ==================== Legal organization ==================== -->

  <xsl:template match="ram:SpecifiedLegalOrganization/ram:ID">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>ANONYMIZED-LEGAL-ID</xsl:text></xsl:copy>
  </xsl:template>

  <xsl:template match="ram:SpecifiedLegalOrganization/ram:Name">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>Anonymous Legal Entity</xsl:text></xsl:copy>
  </xsl:template>

  <xsl:template match="ram:SpecifiedLegalOrganization/ram:TradingBusinessName">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>Anonymous Trading Name</xsl:text></xsl:copy>
  </xsl:template>

  <!-- ==================== Tax registration ==================== -->

  <xsl:template match="ram:SpecifiedTaxRegistration/ram:ID">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>ANONYMIZED-TAX-ID</xsl:text></xsl:copy>
  </xsl:template>

  <!-- ==================== Contact information ==================== -->

  <xsl:template match="ram:DefinedTradeContact/ram:PersonName">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>Anonymous Contact</xsl:text></xsl:copy>
  </xsl:template>

  <xsl:template match="ram:DefinedTradeContact/ram:DepartmentName">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>Anonymous Department</xsl:text></xsl:copy>
  </xsl:template>

  <xsl:template match="ram:DefinedTradeContact/ram:ID">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>ANONYMIZED-CONTACT-ID</xsl:text></xsl:copy>
  </xsl:template>

  <xsl:template match="ram:DefinedTradeContact/ram:JobTitle">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>Employee</xsl:text></xsl:copy>
  </xsl:template>

  <xsl:template match="ram:DefinedTradeContact/ram:Responsibility">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>Anonymous Responsibility</xsl:text></xsl:copy>
  </xsl:template>

  <xsl:template match="ram:DefinedTradeContact/ram:PersonID">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>ANONYMIZED-PERSON-ID</xsl:text></xsl:copy>
  </xsl:template>

  <!-- Contact person details -->
  <xsl:template match="ram:SpecifiedContactPerson/ram:GivenName">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>Anonymous</xsl:text></xsl:copy>
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
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>anonymous@example.com</xsl:text></xsl:copy>
  </xsl:template>

  <!-- IM -->
  <xsl:template match="ram:InstantMessagingUniversalCommunication/ram:URIID">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>anonymous@example.com</xsl:text></xsl:copy>
  </xsl:template>

  <!-- URI-based communication (endpoint, website, etc.) -->
  <xsl:template match="ram:URIUniversalCommunication/ram:URIID">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>ANONYMIZED-URI</xsl:text></xsl:copy>
  </xsl:template>

  <xsl:template match="ram:EndPointURIUniversalCommunication/ram:URIID">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>ANONYMIZED-ENDPOINT</xsl:text></xsl:copy>
  </xsl:template>

  <!-- ==================== Address information ==================== -->

  <xsl:template match="ram:PostalTradeAddress/ram:PostcodeCode">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>00000</xsl:text></xsl:copy>
  </xsl:template>

  <xsl:template match="ram:PostalTradeAddress/ram:LineOne">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>Anonymous Street 1</xsl:text></xsl:copy>
  </xsl:template>

  <xsl:template match="ram:PostalTradeAddress/ram:LineTwo">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>Anonymous Address Line 2</xsl:text></xsl:copy>
  </xsl:template>

  <xsl:template match="ram:PostalTradeAddress/ram:LineThree">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>Anonymous Address Line 3</xsl:text></xsl:copy>
  </xsl:template>

  <xsl:template match="ram:PostalTradeAddress/ram:LineFour">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>Anonymous Address Line 4</xsl:text></xsl:copy>
  </xsl:template>

  <xsl:template match="ram:PostalTradeAddress/ram:LineFive">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>Anonymous Address Line 5</xsl:text></xsl:copy>
  </xsl:template>

  <xsl:template match="ram:PostalTradeAddress/ram:StreetName">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>Anonymous Street</xsl:text></xsl:copy>
  </xsl:template>

  <xsl:template match="ram:PostalTradeAddress/ram:CityName">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>Anonymous City</xsl:text></xsl:copy>
  </xsl:template>

  <xsl:template match="ram:PostalTradeAddress/ram:CitySubDivisionName">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>Anonymous District</xsl:text></xsl:copy>
  </xsl:template>

  <xsl:template match="ram:PostalTradeAddress/ram:CountrySubDivisionName">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>Anonymous Region</xsl:text></xsl:copy>
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
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>Anonymous Department</xsl:text></xsl:copy>
  </xsl:template>

  <xsl:template match="ram:PostalTradeAddress/ram:AdditionalStreetName">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>Anonymous Additional Street</xsl:text></xsl:copy>
  </xsl:template>

  <xsl:template match="ram:PostalTradeAddress/ram:AttentionOf">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>Anonymous Person</xsl:text></xsl:copy>
  </xsl:template>

  <xsl:template match="ram:PostalTradeAddress/ram:CareOf">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>Anonymous Person</xsl:text></xsl:copy>
  </xsl:template>

  <xsl:template match="ram:PostalTradeAddress/ram:ID">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>ANONYMIZED-ADDR-ID</xsl:text></xsl:copy>
  </xsl:template>

  <xsl:template match="ram:PostalTradeAddress/ram:CountryName">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>Anonymous Country</xsl:text></xsl:copy>
  </xsl:template>

  <xsl:template match="ram:PostalTradeAddress/ram:CountrySubDivisionID">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>XX</xsl:text></xsl:copy>
  </xsl:template>

  <!-- ==================== Financial account information ==================== -->

  <!-- Creditor financial account -->
  <xsl:template match="ram:PayeePartyCreditorFinancialAccount/ram:IBANID">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>ANONYMIZED-IBAN</xsl:text></xsl:copy>
  </xsl:template>

  <xsl:template match="ram:PayeePartyCreditorFinancialAccount/ram:AccountName">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>Anonymous Account</xsl:text></xsl:copy>
  </xsl:template>

  <xsl:template match="ram:PayeePartyCreditorFinancialAccount/ram:ProprietaryID">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>ANONYMIZED-ACCOUNT-ID</xsl:text></xsl:copy>
  </xsl:template>

  <!-- Debtor financial account -->
  <xsl:template match="ram:PayerPartyDebtorFinancialAccount/ram:IBANID">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>ANONYMIZED-IBAN</xsl:text></xsl:copy>
  </xsl:template>

  <xsl:template match="ram:PayerPartyDebtorFinancialAccount/ram:AccountName">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>Anonymous Account</xsl:text></xsl:copy>
  </xsl:template>

  <xsl:template match="ram:PayerPartyDebtorFinancialAccount/ram:ProprietaryID">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>ANONYMIZED-ACCOUNT-ID</xsl:text></xsl:copy>
  </xsl:template>

  <!-- ==================== Financial institution ==================== -->

  <xsl:template match="ram:PayeeSpecifiedCreditorFinancialInstitution/ram:BICID |
                        ram:PayerSpecifiedDebtorFinancialInstitution/ram:BICID">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>ANONYMIZED-BIC</xsl:text></xsl:copy>
  </xsl:template>

  <xsl:template match="ram:PayeeSpecifiedCreditorFinancialInstitution/ram:Name |
                        ram:PayerSpecifiedDebtorFinancialInstitution/ram:Name">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>Anonymous Bank</xsl:text></xsl:copy>
  </xsl:template>

  <!-- ==================== Payment card information ==================== -->

  <xsl:template match="ram:ApplicableTradeSettlementFinancialCard/ram:ID">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>0000000000000000</xsl:text></xsl:copy>
  </xsl:template>

  <xsl:template match="ram:ApplicableTradeSettlementFinancialCard/ram:CardholderName">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>ANONYMOUS CARDHOLDER</xsl:text></xsl:copy>
  </xsl:template>

  <xsl:template match="ram:ApplicableTradeSettlementFinancialCard/ram:VerificationNumeric">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>000</xsl:text></xsl:copy>
  </xsl:template>

  <xsl:template match="ram:ApplicableTradeSettlementFinancialCard/ram:IssuingCompanyName">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>Anonymous Card Issuer</xsl:text></xsl:copy>
  </xsl:template>

  <!-- ==================== Payment means ==================== -->

  <xsl:template match="ram:SpecifiedTradeSettlementPaymentMeans/ram:ID">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>ANONYMIZED-PAYMENT-ID</xsl:text></xsl:copy>
  </xsl:template>

  <xsl:template match="ram:SpecifiedTradeSettlementPaymentMeans/ram:Information">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>Anonymized payment information</xsl:text></xsl:copy>
  </xsl:template>

  <!-- ==================== Document references ==================== -->

  <xsl:template match="ram:SellerOrderReferencedDocument/ram:IssuerAssignedID |
                       ram:BuyerOrderReferencedDocument/ram:IssuerAssignedID |
                       ram:ContractReferencedDocument/ram:IssuerAssignedID |
                       ram:DespatchAdviceReferencedDocument/ram:IssuerAssignedID |
                       ram:ReceivingAdviceReferencedDocument/ram:IssuerAssignedID |
                       ram:AdditionalReferencedDocument/ram:IssuerAssignedID |
                       ram:InvoiceReferencedDocument/ram:IssuerAssignedID">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>ANONYMIZED-REF</xsl:text></xsl:copy>
  </xsl:template>

  <!-- ==================== Notes (may contain sensitive free text) ==================== -->

  <xsl:template match="ram:IncludedNote/ram:Content">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>Anonymized note</xsl:text></xsl:copy>
  </xsl:template>

  <!-- ==================== Payment reference ==================== -->

  <xsl:template match="ram:PaymentReference">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>ANONYMIZED-PAYMENT-REF</xsl:text></xsl:copy>
  </xsl:template>

  <!-- ==================== Buyer reference ==================== -->

  <xsl:template match="ram:BuyerReference">
    <xsl:copy><xsl:apply-templates select="@*" /><xsl:text>ANONYMIZED-BUYER-REF</xsl:text></xsl:copy>
  </xsl:template>

  <!-- ==================== Attached binary objects ==================== -->

  <xsl:template match="ram:AttachmentBinaryObject">
    <xsl:copy>
      <xsl:apply-templates select="@*" />
      <xsl:text>QU5PTllNSVpFRA==</xsl:text>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
