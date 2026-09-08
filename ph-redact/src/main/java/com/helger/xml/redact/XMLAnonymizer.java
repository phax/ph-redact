/*
 * Copyright (C) 2026 Philip Helger (www.helger.com)
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
package com.helger.xml.redact;

import java.io.File;
import java.io.InputStream;
import java.io.OutputStream;

import javax.xml.transform.Result;
import javax.xml.transform.Source;
import javax.xml.transform.Templates;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMResult;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

import org.jspecify.annotations.NonNull;
import org.jspecify.annotations.Nullable;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.w3c.dom.Document;

import com.helger.annotation.Nonempty;
import com.helger.base.enforce.ValueEnforcer;
import com.helger.base.string.StringHelper;
import com.helger.ddd.DocumentDetails;
import com.helger.ddd.DocumentDetailsDeterminator;
import com.helger.ddd.model.DDDSyntaxList;
import com.helger.ddd.model.DDDValueProviderList;
import com.helger.io.resource.ClassPathResource;
import com.helger.xml.XMLFactory;
import com.helger.xml.serialize.read.DOMReader;
import com.helger.xml.transform.TransformSourceFactory;

/**
 * Main class for anonymizing XML documents using XSLT transformations. Supports UBL (2.1 and 2.5)
 * and CII (D16B and D25A) documents.
 *
 * @author Philip Helger
 */
public class XMLAnonymizer
{
  /** The name of the XSLT parameter that receives the anonymization prefix */
  public static final String XSLT_PARAM_ANONYMIZATION_PREFIX = "anonymization-prefix";
  /** The default prefix of all identifier replacement values */
  public static final String DEFAULT_ANONYMIZATION_PREFIX = "ANONYMIZED";

  private static final Logger LOGGER = LoggerFactory.getLogger (XMLAnonymizer.class);
  private static final DocumentDetailsDeterminator DDD = new DocumentDetailsDeterminator (DDDSyntaxList.getDefaultSyntaxList (),
                                                                                          DDDValueProviderList.getDefaultValueProviderList ());
  static
  {
    // No info logging
    DDD.setInfoHdl (x -> {});
  }

  private final EAnonymizationFormat m_eFormat;
  private final String m_sAnonymizationPrefix;
  private final Templates m_aTemplates;

  @NonNull
  private static Templates _loadTemplates (@NonNull final EAnonymizationFormat eFormat)
  {
    final String sXSLTPath = eFormat.getXSLTPath ();
    LOGGER.info ("Loading XSLT stylesheet '" + sXSLTPath + "' for format " + eFormat.getID ());
    try (final InputStream aIS = new ClassPathResource (sXSLTPath).getInputStream ())
    {
      if (aIS == null)
        throw new IllegalStateException ("Failed to load XSLT resource '" + sXSLTPath + "'");

      // Secure factory
      final TransformerFactory aFactory = XMLFactory.createDefaultTransformerFactory ();
      return aFactory.newTemplates (TransformSourceFactory.create (aIS));
    }
    catch (final Exception ex)
    {
      throw new IllegalStateException ("Failed to compile XSLT stylesheet '" + sXSLTPath + "'", ex);
    }
  }

  /**
   * Constructor using {@link #DEFAULT_ANONYMIZATION_PREFIX}.
   *
   * @param eFormat
   *        The anonymization format to use. May not be <code>null</code>.
   */
  public XMLAnonymizer (@NonNull final EAnonymizationFormat eFormat)
  {
    this (eFormat, DEFAULT_ANONYMIZATION_PREFIX);
  }

  /**
   * Constructor.
   *
   * @param eFormat
   *        The anonymization format to use. May not be <code>null</code>.
   * @param sAnonymizationPrefix
   *        The prefix to be used for all identifier replacement values. The field specific suffix
   *        (e.g. "-DOC-ID") is appended to it. If <code>null</code> or empty,
   *        {@link #DEFAULT_ANONYMIZATION_PREFIX} is used.
   */
  public XMLAnonymizer (@NonNull final EAnonymizationFormat eFormat, @Nullable final String sAnonymizationPrefix)
  {
    ValueEnforcer.notNull (eFormat, "Format");
    m_eFormat = eFormat;
    m_sAnonymizationPrefix = StringHelper.isEmpty (sAnonymizationPrefix) ? DEFAULT_ANONYMIZATION_PREFIX
                                                                         : sAnonymizationPrefix;
    m_aTemplates = _loadTemplates (eFormat);
  }

  /**
   * @return The anonymization format used by this anonymizer. Never <code>null</code>.
   */
  @NonNull
  public EAnonymizationFormat getFormat ()
  {
    return m_eFormat;
  }

  /**
   * @return The prefix used for all identifier replacement values. Neither <code>null</code> nor
   *         empty.
   */
  @NonNull
  @Nonempty
  public String getAnonymizationPrefix ()
  {
    return m_sAnonymizationPrefix;
  }

  @NonNull
  private Transformer _createTransformer () throws TransformerException
  {
    final Transformer ret = m_aTemplates.newTransformer ();
    ret.setParameter (XSLT_PARAM_ANONYMIZATION_PREFIX, m_sAnonymizationPrefix);
    return ret;
  }

  /**
   * Anonymize an XML document from a {@link Source} to a {@link javax.xml.transform.Result}.
   *
   * @param aSource
   *        The XML source to anonymize. May not be <code>null</code>.
   * @param aResult
   *        The result to write the anonymized XML to. May not be <code>null</code>.
   * @throws TransformerException
   *         On XSLT transformation error.
   */
  public void anonymize (@NonNull final Source aSource, @NonNull final Result aResult) throws TransformerException
  {
    ValueEnforcer.notNull (aSource, "Source");
    ValueEnforcer.notNull (aResult, "Result");

    final Transformer aTransformer = _createTransformer ();
    aTransformer.transform (aSource, aResult);
    LOGGER.info ("Successfully anonymized XML document using format " + m_eFormat.getID ());
  }

  /**
   * Anonymize an XML file and write the result to an output stream.
   *
   * @param aInputFile
   *        The input XML file. May not be <code>null</code>.
   * @param aOS
   *        The output stream to write the anonymized XML to. May not be <code>null</code>.
   * @throws TransformerException
   *         On XSLT transformation error.
   */
  public void anonymize (@NonNull final File aInputFile, @NonNull final OutputStream aOS) throws TransformerException
  {
    ValueEnforcer.notNull (aInputFile, "InputFile");
    ValueEnforcer.notNull (aOS, "OutputStream");

    anonymize (new StreamSource (aInputFile), new StreamResult (aOS));
  }

  /**
   * Anonymize an XML file and write the result to an output file.
   *
   * @param aInputFile
   *        The input XML file. May not be <code>null</code>.
   * @param aOutputFile
   *        The output file to write the anonymized XML to. May not be <code>null</code>.
   * @throws TransformerException
   *         On XSLT transformation error.
   */
  public void anonymize (@NonNull final File aInputFile, @NonNull final File aOutputFile) throws TransformerException
  {
    ValueEnforcer.notNull (aInputFile, "InputFile");
    ValueEnforcer.notNull (aOutputFile, "OutputFile");

    anonymize (new StreamSource (aInputFile), new StreamResult (aOutputFile));
  }

  /**
   * Anonymize an XML {@link Document} and return the result as a new {@link Document}.
   *
   * @param aDoc
   *        The input XML document. May not be <code>null</code>.
   * @return The anonymized XML document. Never <code>null</code>.
   * @throws TransformerException
   *         On XSLT transformation error.
   */
  @NonNull
  public Document anonymize (@NonNull final Document aDoc) throws TransformerException
  {
    ValueEnforcer.notNull (aDoc, "Document");

    final DOMResult aResult = new DOMResult ();
    anonymize (new DOMSource (aDoc), aResult);
    return (Document) aResult.getNode ();
  }

  /**
   * Auto-detect the anonymization format of an XML document using the DDD (Document Details
   * Determinator) library. This also handles unwrapping of envelope formats (SBDH, XHE).
   *
   * @param aDoc
   *        The XML document to inspect. May not be <code>null</code>.
   * @return The detected format, or <code>null</code> if the document type could not be determined
   *         or is not supported for anonymization.
   */
  @Nullable
  public static EAnonymizationFormat detectFormat (@NonNull final Document aDoc)
  {
    ValueEnforcer.notNull (aDoc, "Document");

    final DocumentDetails aDetails = DDD.findDocumentDetails (aDoc.getDocumentElement ());
    if (aDetails == null)
    {
      LOGGER.warn ("DDD could not determine document details for namespace '" +
                   aDoc.getDocumentElement ().getNamespaceURI () +
                   "'");
      return null;
    }

    final EAnonymizationFormat eFormat = EAnonymizationFormat.getFromDDDSyntaxIDOrNull (aDetails.getSyntaxID ());
    if (eFormat == null)
      LOGGER.warn ("DDD syntax '" + aDetails.getSyntaxID () + "' is not supported for anonymization");
    return eFormat;
  }

  /**
   * Convenience method to anonymize an XML file with auto-detected format, using
   * {@link #DEFAULT_ANONYMIZATION_PREFIX}.
   *
   * @param aInputFile
   *        The input XML file. May not be <code>null</code>.
   * @param aOutputFile
   *        The output file. May not be <code>null</code>.
   * @return <code>true</code> if anonymization was successful, <code>false</code> otherwise.
   */
  public static boolean anonymizeAutoDetect (@NonNull final File aInputFile, @NonNull final File aOutputFile)
  {
    return anonymizeAutoDetect (aInputFile, aOutputFile, DEFAULT_ANONYMIZATION_PREFIX);
  }

  /**
   * Convenience method to anonymize an XML file with auto-detected format.
   *
   * @param aInputFile
   *        The input XML file. May not be <code>null</code>.
   * @param aOutputFile
   *        The output file. May not be <code>null</code>.
   * @param sAnonymizationPrefix
   *        The prefix to be used for all identifier replacement values. If <code>null</code> or
   *        empty, {@link #DEFAULT_ANONYMIZATION_PREFIX} is used.
   * @return <code>true</code> if anonymization was successful, <code>false</code> otherwise.
   */
  public static boolean anonymizeAutoDetect (@NonNull final File aInputFile,
                                             @NonNull final File aOutputFile,
                                             @Nullable final String sAnonymizationPrefix)
  {
    ValueEnforcer.notNull (aInputFile, "InputFile");
    ValueEnforcer.notNull (aOutputFile, "OutputFile");

    final Document aDoc = DOMReader.readXMLDOM (aInputFile);
    if (aDoc == null)
    {
      LOGGER.error ("Failed to parse input file '" + aInputFile.getAbsolutePath () + "'");
      return false;
    }

    final EAnonymizationFormat eFormat = detectFormat (aDoc);
    if (eFormat == null)
    {
      LOGGER.error ("Failed to detect anonymization format for file '" +
                    aInputFile.getAbsolutePath () +
                    "' with namespace '" +
                    aDoc.getDocumentElement ().getNamespaceURI () +
                    "'");
      return false;
    }

    try
    {
      new XMLAnonymizer (eFormat, sAnonymizationPrefix).anonymize (aInputFile, aOutputFile);
      return true;
    }
    catch (final TransformerException ex)
    {
      LOGGER.error ("Failed to anonymize file '" + aInputFile.getAbsolutePath () + "'", ex);
      return false;
    }
  }
}
