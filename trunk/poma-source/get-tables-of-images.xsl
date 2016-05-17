<?xml version="1.0" encoding="UTF-8" ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	       xmlns:h="http://www.w3.org/1999/xhtml"
	       xmlns="http://www.tei-c.org/ns/1.0"
	       xmlns:o="urn:oracle-rowdata"
	       version="1.0">

  <xsl:param name="manuspageids" 
	     select="document('/home/slu/development/poma/manus-page-id.xml')"/>

  <xsl:output method="xml"
	      indent="yes"
	      encoding="UTF-8"/>

  <xsl:template match="/">
    <xsl:apply-templates select="//h:table[@id='theActualContent']"/>
  </xsl:template>

  <xsl:template match="h:table">
    <xsl:element name="list">
      <xsl:for-each select="h:tr[h:td/h:span]">
	<xsl:variable name="mysection" select="generate-id(.)"/>
	<xsl:element name="item">
	  <xsl:element name="head">
	    <xsl:attribute name="lang">es</xsl:attribute>
	    <xsl:apply-templates select="h:td[1]/h:span/h:a"/>
	  </xsl:element>
	  <xsl:element name="head">
	    <xsl:attribute name="lang">en</xsl:attribute>
	    <xsl:apply-templates select="h:td[2]/h:span/h:a"/>
	  </xsl:element>
	  <xsl:element name="list">
	    <xsl:for-each
		select="
                       following-sibling::h:tr[
                       h:td/h:p/h:a
		       and 
                       generate-id(preceding-sibling::h:tr[h:td/h:span][1])=$mysection
		       ]">

	      <xsl:element name="item">
		<xsl:element name="ref">
		  <xsl:attribute name="lang">es</xsl:attribute>
		  <xsl:variable name="pageno"
		      select="substring-before(
			      substring-after(
			      h:td[1]/h:p/h:a/@href,'p_PageNo='),'&amp;')"/>
		  <xsl:attribute name="n">
		    <xsl:value-of select="$pageno"/>
		  </xsl:attribute>
		  <xsl:attribute name="target">
		    <xsl:value-of 
			select="concat('manus:253:div:physical:',
				$manuspageids/o:ROWDATA/o:ROW[o:PAGENO=$pageno]/o:PAGEID)"/>
		  </xsl:attribute>
		  <xsl:apply-templates select="h:td[1]/h:p/text()"/>
		  <xsl:apply-templates select="h:td[1]/h:p/h:a"/>
		</xsl:element>
		<xsl:element name="ref">
		  <xsl:attribute name="lang">en</xsl:attribute>
		  <xsl:variable name="pageno" 
				select="substring-before(
				substring-after(
				h:td[2]/h:p/h:a/@href,'p_PageNo='),'&amp;')"/>
		  <xsl:variable name="pageid"><xsl:apply-templates 
			select="$manuspageids/o:ROWDATA/o:ROW[o:PAGENO=$pageno]/o:PAGEID"/></xsl:variable>
		  <xsl:attribute name="n">
		    <xsl:value-of select="$pageno"/>
		  </xsl:attribute>
		  <xsl:attribute name="target">
		    <xsl:value-of 
			select="concat('manus:253:physical:',$pageid)"/>
		  </xsl:attribute>
		  <xsl:apply-templates select="h:td[2]/h:p/text()"/>
		  <xsl:apply-templates select="h:td[2]/h:p/h:a"/>
		</xsl:element>
	      </xsl:element>

	    </xsl:for-each>
	  </xsl:element>
	</xsl:element>
      </xsl:for-each>
    </xsl:element>
    
  </xsl:template>

</xsl:transform>