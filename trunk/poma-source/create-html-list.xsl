<?xml version="1.0" encoding="UTF-8" ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	       xmlns:t="http://www.tei-c.org/ns/1.0"
	       exclude-result-prefixes="t"
	       version="1.0">

  <xsl:param name="mode" 
	     select="'text'"/>
  <xsl:output method="xml"
	      media-type="text/html"
	      version="1.0"
	      indent = "yes"
	      encoding="UTF-8"/>

  <xsl:template match="/">
    <xsl:apply-templates select="t:list"/>
  </xsl:template>

  <xsl:template match="/t:list">
    <ul>
      <xsl:apply-templates select="t:item"/>
    </ul>
  </xsl:template>

 <xsl:template match="t:item/t:list">
   <xsl:param name="listid"/>
   <xsl:if test="t:item">
     <xsl:element name="ul">
       <xsl:if test="$listid">
	 <xsl:attribute name="id"><xsl:value-of select="$listid"/></xsl:attribute>
       </xsl:if>
       <xsl:attribute name="style">
	 <xsl:text>display:none</xsl:text>
	 <!--xsl:text>display:none; list-style-type:none</xsl:text-->
       </xsl:attribute>
       <xsl:apply-templates select="t:item">
	 <xsl:with-param name="listid" select="$listid"/>
       </xsl:apply-templates>
     </xsl:element>
   </xsl:if>
  </xsl:template>


  <xsl:template match="t:item">
    <xsl:param name="listid" select="generate-id(.)"/>
    <xsl:element name="li">
      <xsl:if test="t:ref/@target">
	<xsl:attribute name="id">
	  <xsl:value-of select="t:ref/@target"/>
	</xsl:attribute>
      </xsl:if>
      <xsl:if test="t:list">
	<xsl:element name="a">
	  <xsl:attribute name="id">
	    <xsl:value-of select="concat('anchor',$listid)"/>
	  </xsl:attribute>
	  <xsl:attribute name="class">off</xsl:attribute>
	  <xsl:attribute name="onclick">
	    <xsl:text>openDisplay('</xsl:text><xsl:value-of select="$listid"/><xsl:text>')</xsl:text>
	  </xsl:attribute>
	  <xsl:text> </xsl:text>
	</xsl:element>
      </xsl:if>

      <xsl:choose>
	<xsl:when test="t:ref">
	  <xsl:element name="a">
	    <xsl:attribute name="href">
	      <xsl:choose>
		<xsl:when test="t:ref/@n">
		  <xsl:value-of select="concat('/permalink/2006/poma',
					'/',t:ref/@n,
					'/',$lang,
					'/',$mode,
					'/?open=',$listid)"/>
		</xsl:when>
		<xsl:otherwise>
		  <xsl:if test="t:ref/@id">
		    <xsl:value-of select="concat('/permalink/2006/poma',
					  '/',t:ref/@id,
					  '/',$lang,
					  '/',$mode,
					  '/?open=',$listid)"/>
		  </xsl:if>
		</xsl:otherwise>
	      </xsl:choose>
	    </xsl:attribute>
	    <xsl:apply-templates select="t:ref"/>
	  </xsl:element>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:choose>
	    <xsl:when test="t:list/t:item[1]/t:ref/@n">
	      <xsl:element name="a">
		<xsl:attribute name="href">
		  <xsl:value-of select="concat('/permalink/2006/poma',
					'/',t:list/t:item[1]/t:ref/@n,
					'/',$lang,
					'/image',
					'/?open=',$listid)"/>
		</xsl:attribute>
		<xsl:apply-templates select="text()"/>
	      </xsl:element>
	    </xsl:when>
	    <xsl:otherwise>
		<xsl:apply-templates select="text()"/>
	    </xsl:otherwise>
	  </xsl:choose>
	</xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="t:list">
	<xsl:with-param name="listid" select="$listid"/>
      </xsl:apply-templates>
    </xsl:element>

  </xsl:template>




</xsl:transform>