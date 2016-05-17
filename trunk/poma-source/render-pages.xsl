<?xml version="1.0" encoding="UTF-8" ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	       xmlns:exsl="http://exslt.org/common"
	       xmlns:l="http://www.tei-c.org/ns/1.0"
	       extension-element-prefixes="exsl str"
	       xmlns:str="http://exslt.org/strings"
	       exclude-result-prefixes="l exsl"
	       version="1.0">

  <xsl:param name="targetdir" select="'pages'"/>
  <xsl:param name="contents_en" select="document('toc.xml.en')"/>
  <xsl:param name="contents_es" select="document('toc.xml.es')"/>
  <xsl:param name="htcontents_en" select="document('toc.html.en')"/>
  <xsl:param name="htcontents_es" select="document('toc.html.es')"/>

  <xsl:param name="img_htcontents_en" select="document('table-of-images.html.en')"/>
  <xsl:param name="img_htcontents_es" select="document('table-of-images.html.es')"/>

  <xsl:param name="img_xcontents_en" select="document('table-of-images.xml.en')"/>
  <xsl:param name="img_xcontents_es" select="document('table-of-images.xml.es')"/>

  <xsl:param name="img_contents_en">
    <l:list>
      <xsl:for-each select="document('table-of-images.xml.en')//l:item">
	<xsl:copy-of select="l:ref"/>
      </xsl:for-each>
    </l:list>
  </xsl:param>
  <xsl:param name="img_contents_es">
    <l:list>
      <xsl:for-each select="document('table-of-images.xml.es')//l:item">
	<xsl:copy-of select="l:ref"/>
      </xsl:for-each>
    </l:list>
  </xsl:param>
  

  <xsl:output method="xml"
	      indent="yes"
	      encoding="UTF-8"/>

  <xsl:template match="/">
    <xsl:apply-templates select="TEI.2/text/body/div1"/>
  </xsl:template>

  <xsl:template match="div1">
    <xsl:for-each select="div2">
      <xsl:variable name="identifier" select="@id"/>
      <xsl:apply-templates select=".">
	<xsl:with-param name="navi">
	  <div>
	  <p id="text-mode">

	    <xsl:if test="preceding-sibling::div2[1]/@n">

	      <xsl:variable name="opensect_en">
		<xsl:for-each select="preceding-sibling::div2[1]">
		  <xsl:call-template name="hunt_prev_div">
		    <xsl:with-param name="htcont" select="$htcontents_en"/>
		    <xsl:with-param name="cont"   select="$contents_en"/>
		  </xsl:call-template>
		</xsl:for-each>
	      </xsl:variable>
	    
	      <xsl:variable name="opensect_es">
		<xsl:for-each select="preceding-sibling::div2[1]">
		  <xsl:call-template name="hunt_prev_div">
		    <xsl:with-param name="htcont" select="$htcontents_es"/>
		    <xsl:with-param name="cont"   select="$contents_es"/>
		  </xsl:call-template>
		</xsl:for-each>
	      </xsl:variable>
	    
	      &lt;&lt;
	      <xsl:element name="a">
		<xsl:attribute name="id">
		  <xsl:text>previous-page-en</xsl:text>
		</xsl:attribute>
		<xsl:attribute name="xml:lang">en</xsl:attribute>
		<xsl:attribute name="lang">en</xsl:attribute>
		<xsl:attribute name="href">
		  <xsl:value-of 
		      select="concat('/permalink/2006/poma','/',
			      str:encode-uri(
			      translate(preceding-sibling::div2[1]/@n,' ','+'),
			      false()),
			      '/en/text',
			      '/?open=',$opensect_en)"/>
		</xsl:attribute>
		previous page</xsl:element>


	      <xsl:element name="a">
		<xsl:attribute name="id">
		  <xsl:text>previous-page-es</xsl:text>
		</xsl:attribute>
		<xsl:attribute name="xml:lang">es</xsl:attribute>
		<xsl:attribute name="lang">es</xsl:attribute>
		<xsl:attribute name="href">
		  <xsl:value-of 
		      select="concat('/permalink/2006/poma','/',
			      str:encode-uri(
			      translate(preceding-sibling::div2[1]/@n,' ','+'),
			      false()),
			      '/es/text',
			      '/?open=',$opensect_es)"/>
		</xsl:attribute>
		página anterior</xsl:element>
	    </xsl:if>
	    <xsl:if test="preceding-sibling::div2[1]/@n and
			  following-sibling::div2[1]/@n">
	      <xsl:text>
		
		||

	      </xsl:text>
	    </xsl:if>
	    <xsl:if test="following-sibling::div2[1]/@n">

	      <xsl:variable name="opensect_en">
		<xsl:for-each select="following-sibling::div2[1]">
		  <xsl:call-template name="hunt_prev_div">
		    <xsl:with-param name="htcont" select="$htcontents_en"/>
		    <xsl:with-param name="cont"   select="$contents_en"/>
		  </xsl:call-template>
		</xsl:for-each>
	      </xsl:variable>
	    
	      <xsl:variable name="opensect_es">
		<xsl:for-each select="following-sibling::div2[1]">
		  <xsl:call-template name="hunt_prev_div">
		    <xsl:with-param name="htcont" select="$htcontents_es"/>
		    <xsl:with-param name="cont"   select="$contents_es"/>
		  </xsl:call-template>
		</xsl:for-each>
	      </xsl:variable>


	      <xsl:element name="a">
		<xsl:attribute name="xml:lang">en</xsl:attribute>
		<xsl:attribute name="lang">en</xsl:attribute>
		<xsl:attribute name="id">
		  <xsl:text>next-page-en</xsl:text>
		</xsl:attribute>
		<xsl:attribute name="href">
		  <xsl:value-of 
		      select="concat('/permalink/2006/poma','/',
			      str:encode-uri(
			      translate(following-sibling::div2[1]/@n,' ','+'),
			      false()),
			      '/en/text/',
			      '?open=',$opensect_en)"/>
		  </xsl:attribute>næste side</xsl:element>


	      <xsl:element name="a">
		<xsl:attribute name="xml:lang">es</xsl:attribute>
		<xsl:attribute name="lang">es</xsl:attribute>
		<xsl:attribute name="id">
		  <xsl:text>next-page-es</xsl:text>
		</xsl:attribute>
		<xsl:attribute name="href">
		  <xsl:value-of 
		      select="concat('/permalink/2006/poma','/',
			      str:encode-uri(
			      translate(following-sibling::div2[1]/@n,' ','+'),
			      false()),
			      '/es/text/',
			      '?open=',$opensect_es)"/>
		  </xsl:attribute>página siguiente</xsl:element> &gt;&gt;
	    </xsl:if>
	  </p>

	  <xsl:variable name="num" select="@n"/>

	  <xsl:for-each 
		select="exsl:node-set($img_contents_en)//l:ref[@n=$num]">
	    <p id="image-mode" xml:lang="en" lang="en">

	      <xsl:if test="preceding-sibling::l:ref[1]/@n">

		<xsl:variable name="prev_id">
		  <xsl:value-of select="preceding-sibling::l:ref[1]/@target"/>
		</xsl:variable>
		<xsl:variable name="popensect_en">
		  <xsl:value-of 
		      select="substring-after($img_htcontents_en//li[@id=$prev_id]/a/@href,'open=')"/>
		</xsl:variable>

		&lt;&lt; <xsl:element name="a">
		<xsl:attribute name="href">
		  <xsl:value-of 
		      select="concat('/permalink/2006/poma','/',
			      str:encode-uri(
			      translate(preceding-sibling::l:ref[1]/@n,' ','+'),
			      false()),
			      '/en/image/?',
			      'open=',$popensect_en)"/>
		  </xsl:attribute>previous drawing</xsl:element>

	      </xsl:if>
	      <xsl:if test="preceding-sibling::l:ref[1]/@n and
			    following-sibling::l:ref[1]/@n">
		<xsl:text>
		  ||
		</xsl:text>
	      </xsl:if>
	      <xsl:if test="following-sibling::l:ref[1]/@n">

		<xsl:variable name="next_id">
		  <xsl:value-of select="following-sibling::l:ref[1]/@target"/>
		</xsl:variable>
		<xsl:variable name="nopensect_en">
		  <xsl:value-of 
		      select="substring-after($img_htcontents_en//li[@id=$next_id]/a/@href,'open=')"/>
		</xsl:variable>

		<xsl:element name="a">
		  <xsl:attribute name="href">
		    <xsl:value-of 
			select="concat('/permalink/2006/poma','/',
				str:encode-uri(
				translate(following-sibling::l:ref[1]/@n,' ','+'),
				false()),
				'/en/image',
				'/?open=',$nopensect_en)"/>
		    </xsl:attribute>next drawing</xsl:element> &gt;&gt;
	      </xsl:if>

	    </p>
	    
	  </xsl:for-each>


	  <xsl:for-each 
		select="exsl:node-set($img_contents_es)//l:ref[@n=$num]">
	    <p id="image-mode"  xml:lang="es" lang="es">

	      <xsl:if test="preceding-sibling::l:ref[1]/@n">

		<xsl:variable name="prev_id">
		  <xsl:value-of select="preceding-sibling::l:ref[1]/@target"/>
		</xsl:variable>
		<xsl:variable name="popensect_es">
		  <xsl:value-of 
		      select="substring-after($img_htcontents_es//li[@id=$prev_id]/a/@href,'open=')"/>
		</xsl:variable>

		&lt;&lt; <xsl:element name="a">
		<xsl:attribute name="href">
		  <xsl:value-of 
		      select="concat('/permalink/2006/poma','/',
			      str:encode-uri(
			      translate(preceding-sibling::l:ref[1]/@n,' ','+'),
			      false()),
			      '/es/image',
			      '?open=',$popensect_es)"/>
		  </xsl:attribute>dibujo anterior</xsl:element>
	      </xsl:if>

	      <xsl:if test="preceding-sibling::l:ref[1]/@n and
			    following-sibling::l:ref[1]/@n">
		<xsl:text>
		  ||
		</xsl:text>
	      </xsl:if>

	      <xsl:if test="following-sibling::l:ref[1]/@n">

	
		<xsl:variable name="next_id">
		  <xsl:value-of select="following-sibling::l:ref[1]/@target"/>
		</xsl:variable>
		<xsl:variable name="nopensect_es">
		  <xsl:value-of 
		      select="substring-after($img_htcontents_es//li[@id=$next_id]/a/@href,'open=')"/>
		</xsl:variable>


		<xsl:element name="a">
		  <xsl:attribute name="href">
		    <xsl:value-of 
			select="concat('/permalink/2006/poma','/',
				str:encode-uri(
				translate(following-sibling::l:ref[1]/@n,' ','+'),
				false()),
				'/es/image',
				'/?open=',$nopensect_es)"/>
		    </xsl:attribute>dibujo siguiente</xsl:element> &gt;&gt;
	      </xsl:if>

	    </p>
	    
	  </xsl:for-each>
	  
	  </div>
	</xsl:with-param>
      </xsl:apply-templates>

    </xsl:for-each>
  </xsl:template>

  <xsl:template match="div2">
    <xsl:param    name="navi" select="$navi"/>
    <xsl:variable name="file" select="concat($targetdir,'/',@id,'.html')"/>

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
	<head>
	  <title>
	    <xsl:apply-templates mode="gettextonly"
				 select="div3[@type='runninghead'] |
					 div3[@type='mspagenumber']"/>
	  </title>

	</head>
	<body>
	  <!--div class="tableOfContents">
	    <xsl:apply-templates select="$contents/list"/>
	  </div-->
	  <div class="Contents">
	    <xsl:copy-of select="$navi"/>
	    <xsl:apply-templates select="div3"/>
	  </div>
	</body>
      </html>
    </exsl:document>
  </xsl:template>

  <xsl:template name="hunt_prev_div">
    <xsl:param name="htcont"/>
    <xsl:param name="cont"  />
    <xsl:variable name="prev_n">
      <xsl:value-of select="@n"/>
    </xsl:variable>

    <xsl:variable name="prev_id">
      <xsl:value-of select="$cont//l:item/l:ref[@n=$prev_n]/@target"/>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="substring-after($htcont//li[@id=$prev_id]/a/@href,'open=')">
	<xsl:value-of 
	    select="substring-after($htcont//li[@id=$prev_id]/a/@href,'open=')"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:for-each select="preceding-sibling::div2[1]">
	  <xsl:call-template name="hunt_prev_div">
	    <xsl:with-param name="htcont" select="$htcont"/>
	    <xsl:with-param name="cont"   select="$cont"/>
	  </xsl:call-template>
	</xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

<!--

Each div2 consists of, obviously div3 elements. In this text they may 
have the following types

mspagenumber vänster
runninghead  centreras
main         "prosa"
addition     
imgheader
imgtexts
quechua      "prosa" Text på inka 
notes        finstilt
commentary   finstilt


-->

  <xsl:template match="div3">
    <xsl:if test="node()">
      <xsl:element name="div">
	<xsl:attribute name="class">
	  <xsl:value-of select="@type"/>
	</xsl:attribute>
	<xsl:apply-templates/>
      </xsl:element>
    </xsl:if>
  </xsl:template>

  <xsl:template mode="gettextonly" match="*">
    <xsl:apply-templates mode="gettextonly"/>
  </xsl:template>

  <xsl:template match="p">
    <p>
      <xsl:apply-templates/>
    </p>
  </xsl:template>

  <xsl:template match="term">
    <xsl:element name="span">
      <xsl:attribute name="class"><xsl:value-of select="@type"/></xsl:attribute>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="xref">
    <xsl:element name="a">
      <xsl:attribute name="lang">en</xsl:attribute>
      <xsl:attribute name="xml:lang">en</xsl:attribute>
      <xsl:attribute name="href">
	<xsl:choose>
	  <xsl:when test="contains(@httarget,'www.kb.dk')">
	    <xsl:value-of select="concat('/permalink/2006/poma/info/en/',
				  substring-after(@httarget,
				  'http://www.kb.dk/elib/mss/poma/'))"/>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:value-of select="@httarget"/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:attribute>
      <xsl:apply-templates/>
    </xsl:element>

    <xsl:element name="a">
      <xsl:attribute name="lang">es</xsl:attribute>
      <xsl:attribute name="xml:lang">es</xsl:attribute>
      <xsl:attribute name="href">
	<xsl:choose>
	  <xsl:when test="contains(@httarget,'www.kb.dk')">
	    <xsl:value-of select="concat('/permalink/2006/poma/info/es/',
				  substring-after(@httarget,
				  'http://www.kb.dk/elib/mss/poma/'))"/>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:value-of select="@httarget"/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:attribute>
      <xsl:apply-templates/>
    </xsl:element>

  </xsl:template>

  <xsl:template match="hi">
    <xsl:choose>
      <xsl:when test="@rend='italics'">
	<em><xsl:apply-templates/></em>
      </xsl:when>
      <xsl:when test="@rend='sup'">
	<sup><xsl:apply-templates/></sup>
      </xsl:when>
      <xsl:otherwise>
	<xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="div4[@type='comment']/p/hi[@rend='sup']">
    <xsl:element name="sup">
      <xsl:attribute name="id">
	<xsl:value-of select="concat('comment',generate-id())"/>
      </xsl:attribute>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  
</xsl:transform>
