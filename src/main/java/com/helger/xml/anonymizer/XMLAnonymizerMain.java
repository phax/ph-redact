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
package com.helger.xml.anonymizer;

import java.io.File;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.Callable;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.w3c.dom.Document;

import com.helger.xml.serialize.read.DOMReader;

import picocli.CommandLine;
import picocli.CommandLine.Command;
import picocli.CommandLine.Option;
import picocli.CommandLine.Parameters;

/**
 * Command-line interface for the XML anonymizer.
 *
 * @author Philip Helger
 */
@Command (description = "XML Anonymizer for UBL 2.1 and CII D16B documents",
          name = "xml-anonymizer",
          mixinStandardHelpOptions = true,
          separator = " ")
public class XMLAnonymizerMain implements Callable <Integer>
{
  private static final Logger LOGGER = LoggerFactory.getLogger (XMLAnonymizerMain.class);

  @Option (names = { "-t", "--target" }, description = "Target output directory (default: current directory)")
  private String m_sTargetDir = ".";

  @Option (names = { "-s", "--suffix" }, description = "Output filename suffix (default: -anonymized)")
  private String m_sOutputSuffix = "-anonymized";

  @Option (names = { "-f", "--format" }, description = "Force format: ubl21 or cii-d16b (default: auto-detect)")
  private String m_sFormat;

  @Option (names = { "--verbose" }, description = "Enable verbose output")
  private boolean m_bVerbose;

  @Parameters (description = "One or more XML files to anonymize", arity = "1..*")
  private List <String> m_aSourceFiles;

  @SuppressWarnings ("unused")
  private void _dummySetter ()
  {
    // Only here to avoid the members are set to final
    m_sTargetDir = null;
    m_sOutputSuffix = null;
  }

  @Override
  public Integer call ()
  {
    final File aTargetDir = new File (m_sTargetDir).getAbsoluteFile ();
    if (!aTargetDir.exists () && !aTargetDir.mkdirs ())
    {
      LOGGER.error ("Failed to create target directory '" + aTargetDir.getAbsolutePath () + "'");
      return Integer.valueOf (1);
    }

    // Resolve forced format if provided
    final EAnonymizationFormat eForcedFormat;
    if (m_sFormat != null)
    {
      eForcedFormat = EAnonymizationFormat.getFromIDOrNull (m_sFormat);
      if (eForcedFormat == null)
      {
        LOGGER.error ("Unknown format '" + m_sFormat + "'. Supported: ubl21, cii-d16b");
        return Integer.valueOf (1);
      }
    }
    else
      eForcedFormat = null;

    int nSuccess = 0;
    int nErrors = 0;
    final Map <EAnonymizationFormat, XMLAnonymizer> aAnonymizers = new HashMap <> ();
    for (final String sSourceFile : m_aSourceFiles)
    {
      final File aSourceFile = new File (sSourceFile).getAbsoluteFile ();
      if (!aSourceFile.isFile () || !aSourceFile.canRead ())
      {
        LOGGER.error ("Cannot read source file '" + aSourceFile.getAbsolutePath () + "'");
        nErrors++;
        continue;
      }

      // Determine output filename
      String sBaseName = aSourceFile.getName ();
      final int nDotIdx = sBaseName.lastIndexOf ('.');
      final String sExt;
      if (nDotIdx > 0)
      {
        sExt = sBaseName.substring (nDotIdx);
        sBaseName = sBaseName.substring (0, nDotIdx);
      }
      else
        sExt = ".xml";

      final File aOutputFile = new File (aTargetDir, sBaseName + m_sOutputSuffix + sExt);

      if (m_bVerbose)
        LOGGER.info ("Processing '" + aSourceFile.getAbsolutePath () + "' -> '" + aOutputFile.getAbsolutePath () + "'");

      // Detect or use forced format
      final EAnonymizationFormat eFormat;
      if (eForcedFormat != null)
      {
        eFormat = eForcedFormat;
      }
      else
      {
        final Document aDoc = DOMReader.readXMLDOM (aSourceFile);
        if (aDoc == null)
        {
          LOGGER.error ("Failed to parse XML file '" + aSourceFile.getAbsolutePath () + "'");
          nErrors++;
          continue;
        }

        eFormat = XMLAnonymizer.detectFormat (aDoc);
        if (eFormat == null)
        {
          LOGGER.error ("Could not detect format of '" + aSourceFile.getAbsolutePath () + "'");
          nErrors++;
          continue;
        }
      }

      if (m_bVerbose)
        LOGGER.info ("Using format " + eFormat.getID ());

      try
      {
        aAnonymizers.computeIfAbsent (eFormat, XMLAnonymizer::new).anonymize (aSourceFile, aOutputFile);
        LOGGER.info ("Anonymized '" + aSourceFile.getName () + "' -> '" + aOutputFile.getName () + "'");
        nSuccess++;
      }
      catch (final Exception ex)
      {
        LOGGER.error ("Failed to anonymize '" + aSourceFile.getAbsolutePath () + "': " + ex.getMessage ());
        nErrors++;
      }
    }

    LOGGER.info ("Done. " + nSuccess + " file(s) anonymized, " + nErrors + " error(s).");
    return Integer.valueOf (nErrors > 0 ? 1 : 0);
  }

  public static void main (final String [] aArgs)
  {
    final CommandLine cmd = new CommandLine (new XMLAnonymizerMain ());
    cmd.setCaseInsensitiveEnumValuesAllowed (true);
    final int nExitCode = cmd.execute (aArgs);
    System.exit (nExitCode);
  }
}
