<?xml version="1.0" encoding="utf-8" ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	       xmlns:h="http://www.w3.org/1999/xhtml"
	       xmlns:o="urn:oracle-rowdata"
	       exclude-result-prefixes="h o"
	       version="1.0">


  <xsl:param name="manuspageids" 
	     select="document('/home/slu/development/poma/manus-page-id.xml')"/>


  <xsl:output encoding="UTF-8"
	      indent="yes"
	      omit-xml-declaration="no"/>

  <xsl:template match="/">
    <list xmlns="http://www.tei-c.org/ns/1.0">
      <xsl:for-each select="//h:div[@id='content']/h:table/h:tr/h:td[2]">
	<item>
	  <xsl:if test="h:a and not(contains(h:a/@href,'#'))">
	    <xsl:element name="ref">
	      <xsl:variable name="pageno" 
			    select="substring-before(substring-after(h:a/@href,'p_PageNo='),'&amp;')"/>
	      <xsl:attribute name="n">
		<xsl:value-of select="$pageno"/>
	      </xsl:attribute>
	      <xsl:attribute name="target">
		<xsl:value-of
		    select="concat('manus:253:div:physical:',$manuspageids/o:ROWDATA/o:ROW[o:PAGENO=$pageno]/o:PAGEID)"/>
	      </xsl:attribute>
	      <xsl:apply-templates select="h:a"/>
	    </xsl:element>
	  </xsl:if>
	  <xsl:if test="h:p/h:a and not(contains(h:p/h:a/@href,'#'))">
	    <list>
	      <xsl:for-each select="h:p/h:a">
		<xsl:if test="not(contains(@href,'#'))">
		<item>
		  <xsl:element name="ref">
		    <xsl:variable name="pageno" 
				  select="substring-before(substring-after(@href,'p_PageNo='),'&amp;')"/>
		    <xsl:attribute name="n">
		      <xsl:value-of select="$pageno"/>
		    </xsl:attribute>
		    <xsl:attribute name="target">
		      <xsl:value-of
			  select="concat('manus:253:div:physical:',$manuspageids/o:ROWDATA/o:ROW[o:PAGENO=$pageno]/o:PAGEID)"/>
		    </xsl:attribute>
		    <xsl:apply-templates select="."/>
		  </xsl:element>
		</item>
		</xsl:if>
	      </xsl:for-each>
	    </list>
	  </xsl:if>
	</item>
      </xsl:for-each>
    </list>
  </xsl:template>



</xsl:transform>