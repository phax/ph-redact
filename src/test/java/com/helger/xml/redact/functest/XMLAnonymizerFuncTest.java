/*
 * Copyright (C) 2015-2026 Philip Helger (www.helger.com)
 * philip[at]helger[dot]com
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *         http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.helger.xml.redact.functest;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;

import javax.xml.transform.TransformerException;

import org.jspecify.annotations.NonNull;
import org.junit.Test;
import org.w3c.dom.Document;

import com.helger.io.resource.ClassPathResource;
import com.helger.xml.redact.EAnonymizationFormat;
import com.helger.xml.redact.XMLAnonymizer;
import com.helger.xml.serialize.read.DOMReader;

/**
 * Functional test for {@link XMLAnonymizer}.
 *
 * @author Philip Helger
 */
public final class XMLAnonymizerFuncTest
{
  @NonNull
  private static Document _readTestFile (@NonNull final String sPath)
  {
    final Document aDoc = DOMReader.readXMLDOM (new ClassPathResource (sPath));
    assertNotNull ("Failed to read test file: " + sPath, aDoc);
    return aDoc;
  }

  @Test
  public void testDetectFormatUBL21 ()
  {
    final Document aDoc = _readTestFile ("external/ubl21/invoice-sample.xml");
    assertEquals (EAnonymizationFormat.UBL_21, XMLAnonymizer.detectFormat (aDoc));
  }

  @Test
  public void testDetectFormatCIID16B ()
  {
    final Document aDoc = _readTestFile ("external/cii-d16b/invoice-sample.xml");
    assertEquals (EAnonymizationFormat.CII_D16B, XMLAnonymizer.detectFormat (aDoc));
  }

  @Test
  public void testAnonymizeUBL21Invoice () throws TransformerException
  {
    final Document aDoc = _readTestFile ("external/ubl21/invoice-sample.xml");
    final XMLAnonymizer aAnonymizer = new XMLAnonymizer (EAnonymizationFormat.UBL_21);
    final Document aResult = aAnonymizer.anonymize (aDoc);
    assertNotNull (aResult);

    final String sXml = com.helger.xml.serialize.write.XMLWriter.getNodeAsString (aResult);
    assertNotNull (sXml);

    // Verify sensitive data was anonymized
    _assertNotContains (sXml, "Acme Corporation");
    _assertNotContains (sXml, "Beta Industries");
    _assertNotContains (sXml, "Hans Mueller");
    _assertNotContains (sXml, "Marie Jensen");
    _assertNotContains (sXml, "Hauptstrasse");
    _assertNotContains (sXml, "Vesterbrogade");
    _assertNotContains (sXml, "Munich");
    _assertNotContains (sXml, "Copenhagen");
    _assertNotContains (sXml, "80331");
    _assertNotContains (sXml, "hans.mueller@acme-corp.de");
    _assertNotContains (sXml, "marie.jensen@beta-ind.dk");
    _assertNotContains (sXml, "+49 89 12345678");
    _assertNotContains (sXml, "+45 33 123456");
    _assertNotContains (sXml, "DE123456789");
    _assertNotContains (sXml, "DK12345678");
    _assertNotContains (sXml, "DE89370400440532013000");
    _assertNotContains (sXml, "COBADEFFXXX");
    _assertNotContains (sXml, "4000001987658");
    _assertNotContains (sXml, "5790002221134");
    _assertNotContains (sXml, "INV-2024-001234");
    _assertNotContains (sXml, "HRB 12345");
    _assertNotContains (sXml, "PO-2024-5678");

    // Verify non-sensitive data was preserved
    _assertContains (sXml, "2.1");
    _assertContains (sXml, "380");
    _assertContains (sXml, "EUR");
    _assertContains (sXml, "1000.00");
    _assertContains (sXml, "190.00");
    _assertContains (sXml, "Widget Premium XL");
    _assertContains (sXml, "DE");
    _assertContains (sXml, "DK");
    _assertContains (sXml, "VAT");
  }

  @Test
  public void testAnonymizeCIID16BInvoice () throws TransformerException
  {
    final Document aDoc = _readTestFile ("external/cii-d16b/invoice-sample.xml");
    final XMLAnonymizer aAnonymizer = new XMLAnonymizer (EAnonymizationFormat.CII_D16B);
    final Document aResult = aAnonymizer.anonymize (aDoc);
    assertNotNull (aResult);

    final String sXml = com.helger.xml.serialize.write.XMLWriter.getNodeAsString (aResult);
    assertNotNull (sXml);

    // Verify sensitive data was anonymized
    _assertNotContains (sXml, "Gamma Solutions");
    _assertNotContains (sXml, "Delta Manufacturing");
    _assertNotContains (sXml, "Thomas Weber");
    _assertNotContains (sXml, "Lucia Rossi");
    _assertNotContains (sXml, "Friedrichstrasse");
    _assertNotContains (sXml, "Via Roma");
    _assertNotContains (sXml, "Berlin");
    _assertNotContains (sXml, "Rome");
    _assertNotContains (sXml, "10115");
    _assertNotContains (sXml, "thomas.weber@gamma-solutions.de");
    _assertNotContains (sXml, "lucia.rossi@delta-mfg.it");
    _assertNotContains (sXml, "+49 30 98765432");
    _assertNotContains (sXml, "+39 06 12345678");
    _assertNotContains (sXml, "DE987654321");
    _assertNotContains (sXml, "IT01234567890");
    _assertNotContains (sXml, "DE89370400440532013000");
    _assertNotContains (sXml, "COBADEFFXXX");
    _assertNotContains (sXml, "Commerzbank");
    _assertNotContains (sXml, "4000001987658");
    _assertNotContains (sXml, "5790002221134");
    _assertNotContains (sXml, "CII-2024-001234");
    _assertNotContains (sXml, "PO-2024-5678");
    _assertNotContains (sXml, "info@gamma-solutions.de");

    // Verify non-sensitive data was preserved
    _assertContains (sXml, "380");
    _assertContains (sXml, "EUR");
    _assertContains (sXml, "1000.00");
    _assertContains (sXml, "190.00");
    _assertContains (sXml, "Widget Premium XL");
    _assertContains (sXml, "DE");
    _assertContains (sXml, "IT");
    _assertContains (sXml, "VAT");
  }

  @Test
  public void testEnumValues ()
  {
    assertEquals (2, EAnonymizationFormat.values ().length);
    assertEquals (EAnonymizationFormat.UBL_21, EAnonymizationFormat.getFromIDOrNull ("ubl21"));
    assertEquals (EAnonymizationFormat.CII_D16B, EAnonymizationFormat.getFromIDOrNull ("cii-d16b"));
    assertNull (EAnonymizationFormat.getFromIDOrNull ("unknown"));
    assertNull (EAnonymizationFormat.getFromIDOrNull (null));
  }

  private static void _assertContains (final String sXml, final String sExpected)
  {
    if (!sXml.contains (sExpected))
      throw new AssertionError ("Expected XML to contain '" + sExpected + "' but it did not");
  }

  private static void _assertNotContains (final String sXml, final String sNotExpected)
  {
    if (sXml.contains (sNotExpected))
      throw new AssertionError ("Expected XML NOT to contain '" + sNotExpected + "' but it did");
  }
}
