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
package com.helger.xml.redact;

import org.jspecify.annotations.NonNull;
import org.jspecify.annotations.Nullable;

import com.helger.annotation.Nonempty;
import com.helger.base.id.IHasID;
import com.helger.base.lang.EnumHelper;

/**
 * Enumeration of supported XML anonymization formats.
 *
 * @author Philip Helger
 */
public enum EAnonymizationFormat implements IHasID <String>
{
  /** OASIS Universal Business Language 2.1 */
  UBL_21 ("ubl21", "xslt/ubl21-anonymize.xslt"),
  /** UN/CEFACT Cross Industry Invoice D16B */
  CII_D16B ("cii-d16b", "xslt/cii-d16b-anonymize.xslt");

  private final String m_sID;
  private final String m_sXSLTPath;

  EAnonymizationFormat (@NonNull @Nonempty final String sID, @NonNull @Nonempty final String sXSLTPath)
  {
    m_sID = sID;
    m_sXSLTPath = sXSLTPath;
  }

  @NonNull
  @Nonempty
  public String getID ()
  {
    return m_sID;
  }

  /**
   * @return The classpath-relative path to the XSLT stylesheet for this format.
   */
  @NonNull
  @Nonempty
  public String getXSLTPath ()
  {
    return m_sXSLTPath;
  }

  @Nullable
  public static EAnonymizationFormat getFromIDOrNull (@Nullable final String sID)
  {
    return EnumHelper.getFromIDOrNull (EAnonymizationFormat.class, sID);
  }

  /**
   * Map a DDD syntax ID to the corresponding anonymization format.
   *
   * @param sDDDSyntaxID
   *        The DDD syntax ID (e.g. "ubl2-invoice", "cii-d16b"). May be
   *        <code>null</code>.
   * @return The matching format, or <code>null</code> if the syntax ID is not
   *         supported for anonymization.
   */
  @Nullable
  public static EAnonymizationFormat getFromDDDSyntaxIDOrNull (@Nullable final String sDDDSyntaxID)
  {
    if (sDDDSyntaxID == null)
      return null;
    if (sDDDSyntaxID.startsWith ("ubl2-"))
      return UBL_21;
    if ("cii-d16b".equals (sDDDSyntaxID))
      return CII_D16B;
    return null;
  }
}
