<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
		version="1.0">

  <xsl:param name="lang" select="'dan'"/>

  <xsl:output omit-xml-declaration="no" 
	      method="xml" 
	      media-type="text/xml"
              encoding="UTF-8" indent="yes"/>

  <xsl:template match="@* | node()">
    <xsl:choose>
      <xsl:when test="local-name()='head'">
	<xsl:if test="@xml:lang=$lang or @lang=$lang">
	  <xsl:apply-templates/>
	</xsl:if>
      </xsl:when>
      <xsl:when test="@xml:lang|@lang">
        <xsl:if test="@xml:lang=$lang or @lang=$lang">
          <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
          </xsl:copy>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
