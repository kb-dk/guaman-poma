<?xml version="1.0" encoding="UTF-8" ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	       xmlns:exsl="http://exslt.org/common"
	       xmlns:m="http://www.loc.gov/METS/"
	       xmlns:xlink="http://www.w3.org/1999/xlink" 
	       xmlns:md="http://www.loc.gov/mods/v3"
	       exclude-result-prefixes="exsl xsl m xlink md"
	       extension-element-prefixes="exsl"
	       version="1.0">

  <xsl:param name="targetdir" select="'images'"/>

  <xsl:output method="xml"
	      encoding="UTF-8" />

  <xsl:template match="/">
      <xsl:for-each select="/m:mets/m:structMap/m:div[@DMDID='md-root']|
			    /m:mets/m:structMap[@type='physical']/m:div/m:div">
	<xsl:variable name="ourfileid">
	  <xsl:choose>
	    <xsl:when test="contains(@ORDERLABEL,'title')">
	      <xsl:value-of select="@ORDERLABEL"/>
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:value-of select="concat('n',@ORDERLABEL)"/>
	    </xsl:otherwise>
	  </xsl:choose>
	</xsl:variable>

	<xsl:variable name="file" select="concat($targetdir,'/',$ourfileid,'.html.',substring(@xml:lang,1,2))"/>
	<xsl:if test="not(contains($file,'Ind'))">
	  <exsl:document
	      href="{$file}"
	      method="xml"
	      media-type="text/xml"
	      version="1.0"
	      encoding="UTF-8"
	      indent = "yes"
	      exclude-result-prefixes="h"
	      >
	    <html>
	      <xsl:variable name="div_id" select="@ID"/>
	      <xsl:variable name="goto_id" select="@DMDID"/>
	      <xsl:variable name="xmllang" select="@xml:lang"/>
	      <xsl:apply-templates
		  select="//m:dmdSec[@ID=$goto_id]/m:mdWrap/m:xmlData">
		<xsl:with-param name="xmllang" select="$xmllang"/>
	      </xsl:apply-templates>

	      <xsl:if test="m:fptr">
		<div class="image">
		  <xsl:variable name="fptr" select="m:fptr/@FILEID"/>
		  <xsl:element name="img">
		    <xsl:attribute name="id">
		      <xsl:value-of select="$div_id"/>
		    </xsl:attribute>
		    <xsl:attribute name="alt">
		      <xsl:value-of select="@ORDERLABEL"/>
		    </xsl:attribute>
		    <xsl:attribute name="src">
		      <xsl:value-of 
			  select="/m:mets/m:fileSec/m:fileGrp/m:file[@ID=$fptr]/m:FLocat/@xlink:href"/>
		    </xsl:attribute>
		  </xsl:element>
		</div>
	      </xsl:if>
	      <div class="otherimages">
		<xsl:for-each 
		    select="/m:mets/m:structLink/m:smLink[@xml:lang=$xmllang and @xlink:from = $div_id]">

		  <xsl:variable name="variant_div" select="@xlink:to"/>
		  <xsl:variable 
		      name="variant_fptr" 
		      select="/m:mets/m:structMap/m:div[@ID=$variant_div]/m:fptr/@FILEID"/>
		  <xsl:element name="img">
		    <xsl:attribute name="id">
		      <xsl:value-of select="@xlink:to"/>
		    </xsl:attribute>
		    <xsl:attribute name="title">
		      <xsl:value-of select="@xlink:title"/>
		    </xsl:attribute>
		    <xsl:attribute name="src">
		      <xsl:value-of 
			  select="/m:mets/m:fileSec/m:fileGrp/m:file[@ID=$variant_fptr]/m:FLocat/@xlink:href"/>
		    </xsl:attribute>
		  </xsl:element>
		</xsl:for-each>
	      </div>
	    </html>
	  </exsl:document>
	</xsl:if>
      </xsl:for-each>
  </xsl:template>

  <xsl:template match="md:mods">
    <xsl:param name="xmllang" select="$xmllang"/>
    <xsl:if test="md:titleInfo[@xml:lang=$xmllang]">
      <h1><xsl:apply-templates select="md:titleInfo[@xml:lang=$xmllang]"/></h1>
    </xsl:if>
    <xsl:if test="md:note[@type='presentation' and @xml:lang=$xmllang]">
      <div class="presentation">
	<xsl:copy-of
	    select="md:note[@type='presentation' and @xml:lang=$xmllang]/div"/>
      </div>
    </xsl:if>
    <xsl:if test="md:note[@type='annotation' and @xml:lang=$xmllang]/text()">
      <div class="annotation">
	<xsl:copy-of
	    select="md:note[@type='annotation' and @xml:lang=$xmllang]/div"/>
      </div>
    </xsl:if>
  </xsl:template>

</xsl:transform>