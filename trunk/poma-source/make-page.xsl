<?xml version="1.0" encoding="UTF-8" ?>
<!--
This script implements all navigation functions in the electronic edition
of the GUAMAN POMA manuscript

Author Sigfrid Lundberg slu@kb.dk

Last updated $Date: 2008/10/28 10:12:22 $ by $Author: slu $

$Id: make-page.xsl,v 1.14 2008/10/28 10:12:22 slu Exp $
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:h="http://www.w3.org/1999/xhtml"
		xmlns:l="http://www.tei-c.org/ns/1.0"
		xmlns:exsl="http://exslt.org/common"
		extension-element-prefixes="exsl"
		exclude-result-prefixes="l h exsl"
		version="1.0">

  <xsl:param name="contents"
	     select="''"/>
  <xsl:param name="xcontents"
	     select="''"/>
  <xsl:param name="xImageContents"
	     select="''"/>
  <xsl:param name="lang"
	     select="'es'"/>
  <xsl:param name="image" 
	     select="''"/>
  <xsl:param name="open"
	     select="''"/>
  <xsl:param name="info"  
	     select="''"/>
  <xsl:param name="identifier" 
	     select="''"/>
  <xsl:param name="toggle"
	     select="''"/>
  <xsl:param name="mode"
	     select="'text'"/>
  <xsl:param name="base_url" 
	     select="''"/>
  <xsl:param name="debug" 
	     select="''"/>
  <xsl:param name="slider"
	     select="''"/>
  <xsl:param name="fontsize"
	     select="''"/>
  <xsl:param name="imagesize" 
	     select="'normal'"/>
  <xsl:param name="query"  
	     select="''"/>
  <xsl:param name="operator"
	     select="'and'"/>
  <xsl:param name="field"
	     select="'body'"/>
  <xsl:param name="query_url" 
	     select="''"/>
  <xsl:param name="navigationclass">
    <xsl:choose>
      <xsl:when test="$slider">Off</xsl:when>
      <xsl:otherwise><xsl:text></xsl:text></xsl:otherwise>
    </xsl:choose>
  </xsl:param>
  <xsl:param name="imagedoc"   select="document($image)"/>
  <xsl:param name="tocdoc"     select="document($contents)"/>
  <xsl:param name="xtocdoc"    select="document($xcontents)"/>

  <xsl:param name="max_bread_crumb_string_length" select="'45'"/>

  <xsl:param name="metsid">
    <xsl:for-each select="$xtocdoc//l:item[l:ref[@n&lt;=$identifier]]">
      <xsl:if test="position()=last()">
	<xsl:value-of select="l:ref/@target"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:param>

  <xsl:param name="localmetsid">
    <xsl:value-of select="$imagedoc/html/div[@class='image']/img/@id"/>
  </xsl:param>

  <xsl:output omit-xml-declaration="yes"
	      indent="yes"
	      method="xml"
	      encoding="UTF-8"
	      media-type="application/xhtml+xml; charset=UTF-8"
	      doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
	      doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" />

  <xsl:template match="@*|node()">
    <xsl:choose>
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

  <xsl:template match="img">
    <xsl:element name="img">
      <xsl:if test="@src">
	<xsl:copy-of select="@src"/>
      </xsl:if>
      <xsl:choose>
	<xsl:when test="@alt">
	  <xsl:copy-of select="@alt"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:attribute name="alt"/>
	</xsl:otherwise>
      </xsl:choose>
      <xsl:if test="@title">
	<xsl:copy-of select="@title"/>
      </xsl:if>
    </xsl:element>
  </xsl:template>

  <xsl:template match="ul">
    <xsl:element name="ul">
      <xsl:if test="not(@id='')">
	<xsl:copy-of select="@id"/>
      </xsl:if>
      <xsl:copy-of select="@style"/>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="li">
    <xsl:element name="li">
      <xsl:if test="@id/text()">
	<xsl:copy-of select="@id"/>
      </xsl:if>
      <xsl:if test="@style/text()">
	<xsl:copy-of select="@style"/>
      </xsl:if>
      <xsl:element name="a">
	<xsl:choose>
	  <xsl:when test="not($identifier='titlepage') and @id=$metsid">
	    <xsl:attribute name="class">sel</xsl:attribute>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:if test="a[@id]">
	      <xsl:attribute name="class">off</xsl:attribute>
	    </xsl:if>
	  </xsl:otherwise>
	</xsl:choose>
	<xsl:if test="a[@id]/@id">
	  <xsl:attribute name="id">
	    <xsl:value-of select="a[@id]/@id"/>
	  </xsl:attribute>
	</xsl:if>
	<xsl:if test="a[@id]/@onclick">
	  <xsl:attribute name="onclick">
	    <xsl:value-of select="a[@id]/@onclick"/>
	  </xsl:attribute>
	</xsl:if>
	<xsl:attribute name="href">
	  <xsl:value-of select="a[@href]/@href"/>
	</xsl:attribute>
	<xsl:if test="a/@href">
	  <xsl:apply-templates select="a[@href]/text()"/>
	</xsl:if>
	<xsl:text>
	</xsl:text>
      </xsl:element>

      <xsl:apply-templates select="ul"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="h:script">
    <xsl:element name="script">
      <xsl:copy-of select="@*"/>
      <xsl:text disable-output-escaping="yes">//&lt;![CDATA[</xsl:text>
      <xsl:value-of select="." disable-output-escaping="yes"/>
      <xsl:text disable-output-escaping="yes">//]]&gt;</xsl:text>
    </xsl:element>
  </xsl:template>

  <xsl:template match="/">
    <html xml:lang="{$lang}" lang="{$lang}" xmlns="http://www.w3.org/1999/xhtml">
      <xsl:apply-templates/>
    </html>
  </xsl:template>

  <xsl:template match="html">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="head">
    <head>
      <meta charset="UTF-8" />

      <title>

	<xsl:choose>
	  <xsl:when test="$info">
	    <xsl:choose>
	      <xsl:when test="document($info)/h:html/h:head/h:title[@lang=$lang]">
		<xsl:apply-templates
		    select="document($info)/
			    h:html/
			    h:head/
			    h:title[@lang=$lang]/
			    node()"/>
	      </xsl:when>
	      <xsl:otherwise>
		<xsl:apply-templates
		    select="document($info)/
			    h:html/
			    h:head/
			    h:title/
			    node()"/>
	      </xsl:otherwise>
	    </xsl:choose>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:for-each select="$tocdoc//li[@id=$metsid]">
	      <xsl:if test="position()=last()">
		<xsl:apply-templates 
		    select="a[@href]/text()"/>
	      </xsl:if>
	      </xsl:for-each><xsl:text>
	    </xsl:text>
	    <xsl:value-of
		select="/html/body/div[@class='Contents']/div[@class='mspagenumber']/p/span/text()"/><xsl:text>: Guaman Poma, Nueva corónica y buen
	gobierno (1615)</xsl:text>
	  </xsl:otherwise>
	</xsl:choose>
      </title>

      <script type="text/javascript" src="js/poma.js">
	<xsl:text>
	</xsl:text>
      </script>

      <script type="text/javascript" src="js/manus.js">
	<xsl:text>
	</xsl:text>
      </script>

      <style type="text/css" media="screen">
	@import "css/global.css";
	div#workContent {position:absolute;}
	.contentFunction ul{
	float:left;
        width:12.3750em;
        margin:0;
        padding:0;
        list-style:none;
        position:relative;
        margin-right:1px;}
      </style>
      <style type="text/css" media="print">@import "css/print.css";</style>

    </head>
  </xsl:template>

  <xsl:template match="body">
    <xsl:element name="body">
      <xsl:if test="$fontsize">
	<xsl:attribute name="style">
	  <xsl:value-of select="concat('font-size: ',$fontsize)"/>
	</xsl:attribute>
      </xsl:if>
      <xsl:attribute name="onload">
      <xsl:text disable-output-escaping="yes">openDisplay('</xsl:text>
      <xsl:value-of select="$open"/>
      <xsl:text disable-output-escaping="yes">');</xsl:text>
      <xsl:text disable-output-escaping="yes">goAnchor('</xsl:text>
      <xsl:value-of select="concat('anchor',$open)"/>
      <xsl:text disable-output-escaping="yes">');</xsl:text></xsl:attribute>

      <table cellspacing="0" cellpadding="0" border="0">
	<tr>
<!--HEADER-->
          <td id="header">
	    <a href="https://www.kb.dk/"><img src="img/logo.gif" alt="Det Kongelige Bibliotek" border="0"/></a>
	    <a href="javascript:increase(15);" title="" class="zoomOut">
	    <xsl:text>
	    </xsl:text>
	    </a>
	    <a href="javascript:decrease(15);" title="" class="zoomIn">
	    <xsl:text>
	    </xsl:text>
	    </a>
	    <div class="clear">
	      <xsl:text>
	      </xsl:text>
	    </div>
	  </td>
	</tr>
	<tr>
<!--NAVIGATION-->
           <td id="nav">
	     <xsl:choose>
	       <xsl:when test="$lang = 'en'">
		 <ul>
                   <li><a href="https://www.kb.dk/"><!--Home-->www.kb.dk</a></li>
		   <li><a href="/permalink/2006/poma/info/en/foreword.htm">About the
		   transcription</a></li>
		   <li>
		     <a href="/permalink/2006/poma/info/en/project/project.htm">Project</a>
		   </li>
		   <li>
		     <a  href="/permalink/2006/poma/info/en/docs/index.htm">Resources</a>
		   </li>
		   <li>
		     <a  href="/permalink/2006/poma/info/en/biblio/index.htm">Bibliography</a>
		   </li>
		   <li class="lang"><a href="{$toggle}">Español</a></li>
		 </ul>
	       </xsl:when>
	       <xsl:otherwise>
		 <ul>
		   <li><a href="/en/"><!--Inicio-->www.kb.dk</a></li>
		   <li>
		     <a href="/permalink/2006/poma/info/es/foreword.htm">Sobre la
		     transcripción</a>
		   </li>
		   <li>
		     <a href="/permalink/2006/poma/info/es/project/project.htm">Proyecto</a>
		   </li>
		   <li>
		     <a href="/permalink/2006/poma/info/es/docs/index.htm">Recursos</a>
		   </li>
		   <li>
		     <a
			href="/permalink/2006/poma/info/es/biblio/index.htm">Bibliograf&#xED;a</a>
		   </li>
		     <li class="lang"><a href="{$toggle}">English</a></li>
		 </ul>
	       </xsl:otherwise>
	     </xsl:choose>
	     <div class="clear">
	       <xsl:text>
	       </xsl:text>
	     </div>
	   </td>
	</tr>
	<tr>
	  <!--CONTENT-->
	  <td id="content">
	    <table>
	      <tr>
		<!--CONTENTNAVIGATION-->
		<td id="contentNav" class="contentNav{$navigationclass}">
		  <h1>GKS 2232 4º: Guaman Poma, Nueva corónica y buen
		  gobierno (1615)</h1>
		  <ul>
		  <li>
		  <xsl:element name="h1">
		    <xsl:attribute name="style">
		      <xsl:value-of select="concat('font-size: ',$fontsize)"/>
		    </xsl:attribute>
		    <xsl:choose>
		      <xsl:when test="$mode = 'text'">
			<xsl:choose>
			  <xsl:when test="$lang='es'">
			    <xsl:text>Tabla de contenidos</xsl:text>
			  </xsl:when>
			  <xsl:otherwise>
			    <xsl:text>Table of contents</xsl:text>
			  </xsl:otherwise>
			</xsl:choose>
		      </xsl:when>
		      <xsl:otherwise>
			<xsl:choose>
			  <xsl:when test="$lang='es'">
			    <xsl:text>Tabla de dibujos</xsl:text>
			  </xsl:when>
			  <xsl:otherwise>
			    <xsl:text>Table of drawings</xsl:text>
			  </xsl:otherwise>
			</xsl:choose>
		      </xsl:otherwise>
		    </xsl:choose>
		  </xsl:element>
		  </li>
		  </ul>
		  <div id="workContent">
		    <xsl:apply-templates select="$tocdoc/ul" />
		  </div>
		  <div class="clear">
		    <xsl:text>
		    </xsl:text>
		  </div>
		</td>
<!--SLIDER-->
              <td id="slider">
		<a href="javascript:slide();" id="slideA" class='{$slider}' title="slide ind">
		  <xsl:text>
		  </xsl:text>
		</a>
              </td>
<!--CONTENTDATA-->
              <td>
		<!-- xsl:if test="not($info)" -->
		  <xsl:call-template name="content_functions"/>
		  <div id="breadCrumb">
		    <dl>
		      <dt>
			<p>
			  <xsl:element name="a">
			    <xsl:attribute name="href">
			      <xsl:value-of 
				  select="concat('/permalink/2006/poma/info/',$lang,'/',
					  'frontpage.htm')"/>
			    </xsl:attribute>
			    Guaman Poma
			  </xsl:element>
			</p></dt>
                        <dd>
			<dl>

		      <dd>
			<xsl:choose>
			  <xsl:when test="not($identifier='titlepage')">
			    <xsl:if
				test="$tocdoc//li[ul/li[@id=$metsid]/a[@href]]/a[@href]">
			      <p>
				<xsl:variable name="bread_crumb_text">
				  <xsl:value-of
				      select="$tocdoc//li[ul/li[@id=$metsid]/a[@href]]/a[@href]/text()"/>
				</xsl:variable>
				<xsl:variable name="bread_crumb_link">
				  <xsl:value-of
				      select="$tocdoc//li[ul/li[@id=$metsid]/a[@href]]/a[@href]/@href"/>
				</xsl:variable>
				<xsl:text>: </xsl:text>
				<xsl:element name="a">
				  <xsl:attribute name="href">
				    <xsl:value-of select="$bread_crumb_link"/>
				  </xsl:attribute>

				  <xsl:choose>
				    <xsl:when
					test="string-length($bread_crumb_text)
					      &gt; $max_bread_crumb_string_length">
				      <xsl:value-of 
					  select="substring($bread_crumb_text,
						  1,
						  $max_bread_crumb_string_length)"/>
				    </xsl:when>
				    <xsl:otherwise>
				      <xsl:value-of select="$bread_crumb_text"/>
				    </xsl:otherwise>
				  </xsl:choose>
				</xsl:element>
				<xsl:text>
				  ...
				</xsl:text>
			      </p>
			    </xsl:if>
			  </xsl:when>
			  <xsl:otherwise>
			    <xsl:if test="not($info) and not($query)">
			      <p>
				<xsl:text> : </xsl:text>
				<xsl:choose>
				  <xsl:when test="$lang = 'en'">
				    Title page
				  </xsl:when>
				  <xsl:otherwise>
				    Portada
				  </xsl:otherwise>
				</xsl:choose>
				<xsl:value-of
				    select="div[@class='Contents']/
					    div[@class='mspagenumber']/
					    p/
					    span/
					    text()"/>
			      </p>
			    </xsl:if>
			  </xsl:otherwise>
			</xsl:choose>
			<xsl:if test="not($identifier='titlepage')">

			    <dl>
			    <dd>
			      <p>
				<xsl:for-each select="$tocdoc//li[@id=$metsid]">
				  <xsl:if test="position()=last()">
				    <!-- xsl:apply-templates 
					select="a[@href]"/ -->

				    <xsl:variable name="bread_crumb_text">
				      <xsl:value-of
				      select="a[@href]/text()"/>
				    </xsl:variable>
				    <xsl:variable name="bread_crumb_link">
				      <xsl:value-of
					  select="a[@href]/@href"/>
				    </xsl:variable>

				    <xsl:text>: </xsl:text>
				    <xsl:element name="a">
				      <xsl:attribute name="href">
					<xsl:value-of select="$bread_crumb_link"/>
				      </xsl:attribute>
				      <xsl:choose>
					<xsl:when
					    test="string-length($bread_crumb_text)
						  &gt;
						  $max_bread_crumb_string_length">
					  <xsl:value-of 
					      select="substring($bread_crumb_text,
						      1,
						      $max_bread_crumb_string_length)"
					      />
					</xsl:when>
					<xsl:otherwise>
					  <xsl:value-of select="$bread_crumb_text"/>
					</xsl:otherwise>
				      </xsl:choose></xsl:element>
				    <xsl:text>
				      ...
				    </xsl:text>
				  </xsl:if>
				</xsl:for-each>
			      </p>
			    </dd>
			  </dl>
			</xsl:if>
		      </dd>
		    </dl>
		      </dd>
		    </dl>
		    <div class="clear">
		      <xsl:text>
		      </xsl:text>
		    </div>

		  </div>

		  <div id="contentHeader" style="display: none;">
		    <!--xsl:if test="$imagedoc/html/div[@class='annotation']"-->
		      <h1>
			<xsl:for-each select="$tocdoc//li[@id=$metsid]">
			  <xsl:if test="position()=last()">
			    <xsl:apply-templates 
				select="a[@href]/text()"/>
			  </xsl:if>
			</xsl:for-each>
			<xsl:text>
			</xsl:text>
		
			<xsl:value-of
			    select="/html/body/div[@class='Contents']/div[@class='mspagenumber']/p/span/text()"/>

		      </h1>
		    <!--/xsl:if-->
		    <!--h1>Sidens header</h1-->
		    <a href="" title="print">
		      <xsl:text>
		      </xsl:text>
		    </a>
		    <div class="clear">
		      <xsl:text>
		      </xsl:text>
		    </div>
		  </div>
		<!-- /xsl:if -->
                <div id="contentPage">
		  <xsl:choose>
		    <xsl:when test="$imagesize = 'XL'">
		      <xsl:for-each select="$imagedoc/html/div[@class='otherimages']">
			<xsl:for-each select="img">
			  <xsl:element name="img">
			    <xsl:attribute name="src">
			      <xsl:value-of select="@src"/>
			    </xsl:attribute>
			    <xsl:attribute name="alt">
			      <xsl:value-of select="@title"/>
			    </xsl:attribute>
			  </xsl:element>
			</xsl:for-each>
		      </xsl:for-each>
		      <xsl:call-template name="print_text"/>
		    </xsl:when>
		    <xsl:otherwise>
		      <xsl:choose>
			<xsl:when test="$query">
			  <xsl:copy-of select="document($query_url)"/>
			</xsl:when>
			<xsl:when test="$info">
			  <xsl:apply-templates
			      select="document($info)/h:html/h:body/node()"/>
			</xsl:when>
			<xsl:otherwise>
			  <xsl:for-each select="$imagedoc/html/div[@class='image']">
			    <xsl:element name="img">
			      <!--xsl:attribute name="width">389</xsl:attribute-->
			      <xsl:attribute name="height">549</xsl:attribute>
			      <xsl:attribute name="src">
				<xsl:value-of select="img/@src"/>
			      </xsl:attribute>
			      <xsl:attribute name="alt">
				<xsl:for-each select="$tocdoc//li[@id=$metsid]">
				  <xsl:if test="position()=last()">
				    <xsl:apply-templates 
					select="a[@href]/text()"/>
				  </xsl:if>
				</xsl:for-each>
			      </xsl:attribute>
			    </xsl:element>
			  </xsl:for-each>
			  <xsl:call-template name="print_text"/>
			</xsl:otherwise>
		      </xsl:choose>
		    </xsl:otherwise>
		  </xsl:choose>
		</div>

                <div class="clear">
		  <xsl:text>
		  </xsl:text>
		</div>

              </td>
            </tr>
          </table>
        </td>
      </tr>
      <tr>
<!--FOOTER-->
        <td id="footer">
	  <p>Det Kongelige Bibliotek, Postbox 2149, DK-1016
	  K&#xF8;benhavn K (+45) 33 47 47 47, kb@kb.dk EAN lokations
	  nr: 5798 000795297</p>
        </td>
      </tr>
    </table>

  </xsl:element>
</xsl:template>


  <xsl:template name="print_text">
    <div>
      <xsl:if 
	  test="$imagedoc/
		html/
		div[@class='annotation']/div/node()">
	<blockquote>
	  <p>
	    <xsl:choose>
	      <xsl:when test="$lang = 'en'">
		<xsl:text>Drawing </xsl:text>
	      </xsl:when>
	      <xsl:otherwise>
		<xsl:text>Dibujo </xsl:text>
	      </xsl:otherwise>
	    </xsl:choose>
	    <xsl:for-each 
		select="document($xImageContents)//
			l:item[l:ref[@n=$identifier]]">
	      <xsl:if test="position()=last()">
		<xsl:value-of select="l:ref/l:milestone/@n"/>
		<xsl:text> 
		</xsl:text>
	      </xsl:if>
	    </xsl:for-each>
	    <xsl:apply-templates 
		select="$imagedoc/
			html/
			div[@class='annotation']/div/node()"/>
	  </p>
	</blockquote>
      </xsl:if>
      
      <xsl:apply-templates
	  select="div/div[@class='mspagenumber']/p"/>
      <xsl:apply-templates
	  select="div/div[@class='imgheader']/p"/>
      <xsl:apply-templates
	  select="div/div[@class='imgtexts']/p"/>
      <xsl:apply-templates
	  select="div/div[@class='runninghead']/p"/>
      <xsl:apply-templates
	  select="div/div[@class='main']/p"/>       
      <xsl:apply-templates
	  select="div/div[@class='addition']/p"/>     
      <xsl:apply-templates
	  select="div/div[@class='quechua']/p"/>    
      <xsl:apply-templates
	  select="div/div[@class='notes']/p"/>      
      <xsl:apply-templates
	  select="div/div[@class='commentary']/p"/> 
    </div>
  </xsl:template>

  <xsl:template name="content_functions">
    <div id="function">
      <div class="pageFunction">
	<xsl:variable name="visible_id">
	  <xsl:choose>
	    <xsl:when test="$identifier = 'titlepage'">0</xsl:when>
	    <xsl:otherwise><xsl:value-of select="$identifier"/></xsl:otherwise>
	  </xsl:choose>
	</xsl:variable>
	<xsl:choose>
	  <xsl:when test="$mode = 'text'">
	    <xsl:choose>
	      <xsl:when test="div/
			      div/
			      p[@id='text-mode']/
			      a[@id = concat('previous-page-',$lang)]">
		<div class="borderTopLeft">
		  <div class="borderTopRight">
		    <div class="borderBottomRight">
		      <div class="borderBottomLeft">
			<p>
			  <xsl:element name="a">
			    <xsl:attribute name="href">
			      <xsl:value-of 
				  select="concat('/permalink/2006/poma/titlepage/',
					  $lang,'/text/')"/>
			    </xsl:attribute>
			    <xsl:attribute name="class">start</xsl:attribute>
			    <xsl:attribute name="title">First</xsl:attribute>
			    <xsl:text>|&lt;</xsl:text>
			  </xsl:element>
			</p>
		      </div>
		    </div>
		  </div>
		</div>
		<div class="borderTopLeft">
		  <div class="borderTopRight">
		    <div class="borderBottomRight">
		      <div class="borderBottomLeft">
			<p>
			  <xsl:element name="a">
			    <xsl:attribute name="href">
			      <xsl:value-of 
				  select="div/
					  div/
					  p[@id='text-mode']/
					  a[@id = concat('previous-page-',$lang)]/
					  @href"/>
			    </xsl:attribute>
			    <xsl:attribute name="title">
			      <xsl:apply-templates
				  select="div/
					  div/
					  p[@id='text-mode']/
					  a[@id = concat('previous-page-',$lang)]/
					  text()"/>
			    </xsl:attribute>
			    <xsl:text>&lt;</xsl:text>
			  </xsl:element>
			</p>
		      </div>
		    </div>
		  </div>
		</div>
	      </xsl:when>
	      <xsl:otherwise>
		<div class="borderTopLeft">
		  <div class="borderTopRight">
		    <div class="borderBottomRight">
		      <div class="borderBottomLeft">
			<p><a><xsl:text>|&lt;</xsl:text></a></p>
		      </div>
		    </div>
		  </div>
		</div>
		<div class="borderTopLeft">
		  <div class="borderTopRight">
		    <div class="borderBottomRight">
		      <div class="borderBottomLeft">
			<p><a><xsl:text>&lt;</xsl:text></a></p>
		      </div>
		    </div>
		  </div>
		</div>
	      </xsl:otherwise>
	    </xsl:choose>
	    <xsl:variable name="press_return">
	      <xsl:choose>
		<xsl:when test="$lang = 'en'">
		  Enter page number and hit return
		</xsl:when>
		<xsl:otherwise>
		  Ingrese el número de página y pressione Retorno
		</xsl:otherwise>
	      </xsl:choose>
	    </xsl:variable>
	    <div class="borderTopLeft">
	      <div class="borderTopRight">
		<div class="borderBottomRight">
		  <div class="borderBottomLeft">
		    <form method="get" 
			  action="javascript:location='/permalink/2006/poma/'+encodeURI(document.getElementById('goto').value.replace(' ', '+'))+'/{$lang}/text/';">
		      <p>
			<input type="text" 
			       id="goto" 
			       value="{$visible_id}" 
			       class="text" 
			       title="{$press_return}"
			       onfocus="this.value='';" />
			<input type="hidden"
			       value="{$imagesize}"/>
		      </p>
		    </form>
		  </div>
		</div>
	      </div>
	    </div>
	    <xsl:if test="div/
			  div/
			  p[@id='text-mode']/
			  a[@id = concat('next-page-',$lang)]">
	      <div class="borderTopLeft">
		<div class="borderTopRight">
		  <div class="borderBottomRight">
		    <div class="borderBottomLeft">
		      <p>
			<xsl:element name="a">
			  <xsl:if test="$visible_id &lt; 1189">
			    <xsl:attribute name="href">
			      <xsl:value-of 
				  select="div/
					  div/
					  p[@id='text-mode']/
					  a[@id = concat('next-page-',$lang)]/@href"/>
			    </xsl:attribute>
			    <xsl:attribute name="title">
			      <xsl:apply-templates
				  select="div/
					  div/
					  p[@id='text-mode']/
					  a[@id = concat('next-page-',$lang)]/
					  text()"/>
			    </xsl:attribute>
			  </xsl:if>
			  <xsl:text>&gt;</xsl:text>
			</xsl:element>
		      </p>
		    </div>
		  </div>
		</div>
	      </div>
	      <div class="borderTopLeft">
		<div class="borderTopRight">
		  <div class="borderBottomRight">
		    <div class="borderBottomLeft">
		      <p>
			<xsl:element name="a">
			  <xsl:if test="$visible_id &lt; 1189">
			    <xsl:attribute name="href">
			      <xsl:value-of 
				  select="concat('/permalink/2006/poma/1189/',
					  $lang,
					  '/text/')"/>
			    </xsl:attribute>
			  </xsl:if>
			  <xsl:text>&gt;|</xsl:text>
			</xsl:element>
		      </p>
		    </div>
		  </div>
		</div>
	      </div>
	    </xsl:if>
	  </xsl:when>
	  <xsl:otherwise>
	    <div class="borderTopLeft">
	      <div class="borderTopRight">
		<div class="borderBottomRight">
		  <div class="borderBottomLeft">
		    <p>
		      <a href="/permalink/2006/poma/titlepage/{$lang}/image/"
			 class="start" 
			 title="First">
			<xsl:text>|&lt;</xsl:text>
		      </a>
		    </p>
		  </div>
		</div>
	      </div>
	    </div>

	    <div class="borderTopLeft">
	      <div class="borderTopRight">
		<div class="borderBottomRight">
		  <div class="borderBottomLeft">
		    <p>
		      <xsl:choose>
			<xsl:when test="$visible_id &gt; 0">
			  <xsl:for-each
			      select="div/div/p[@id='image-mode' and @lang=$lang]">
			    <xsl:element name="a">
			      <xsl:attribute name="href">
				<xsl:value-of 
				    select="a[1]/@href"/>
			      </xsl:attribute>
			      <xsl:attribute name="title">
				<xsl:apply-templates
				    select="a[1]/text()"/>
			      </xsl:attribute>
			      <xsl:text>&lt;</xsl:text>
			    </xsl:element>
			  </xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
			  <xsl:for-each
			      select="div/div/p[@id='image-mode' and @lang=$lang]">
			    <xsl:element name="a">
			      <xsl:attribute name="title">
				<xsl:apply-templates
				    select="a[1]/text()"/>
			      </xsl:attribute>
			      <xsl:text>&lt;</xsl:text>
			    </xsl:element>
			  </xsl:for-each>
			</xsl:otherwise>
		      </xsl:choose>
		    </p>
		  </div>
		</div>
	      </div>
	    </div>
	    <div class="borderTopLeft">
	      <div class="borderTopRight">
		<div class="borderBottomRight">
		  <div class="borderBottomLeft">
		    <form method="get" 
			  action="javascript:location='/permalink/2006/poma/'+encodeURI(document.getElementById('goto').value.replace(' ', '+'))+'/{$lang}/text/';">
		      <p>
			<input type="text" 
			       id="goto" 
			       value="{$visible_id}" 
			       class="text" 
			       size="10" 
			       onFocus="this.value='';" />
		      </p>
		    </form>
		  </div>
		</div>
	      </div>
	    </div>
	    <div class="borderTopLeft">
	      <div class="borderTopRight">
		<div class="borderBottomRight">
		  <div class="borderBottomLeft">
		    <p>
		      <xsl:element name="a">
			<xsl:if test="$visible_id &lt; 1189">
			  <xsl:choose>
			    <xsl:when test="$visible_id &gt; 0">
			      <xsl:for-each
				  select="div/
					  div/
					  p[@id='image-mode' and @lang=$lang]">
				<xsl:attribute name="href">
				  <xsl:value-of 
				      select="a[2]/@href"/>
				</xsl:attribute>
				<xsl:attribute name="title">
				  <xsl:apply-templates
				      select="a[2]/text()"/>
				</xsl:attribute>
			      </xsl:for-each>
			    </xsl:when>
			    <xsl:otherwise>
			      <xsl:for-each
				  select="div/
					  div/
					  p[@id='image-mode' and @lang=$lang]">
				<xsl:attribute name="href">
				  <xsl:value-of 
				      select="a[1]/@href"/>
				</xsl:attribute>
				<xsl:attribute name="title">
				  <xsl:apply-templates
				      select="a[1]/text()"/>
				</xsl:attribute>
			      </xsl:for-each>
			    </xsl:otherwise>
			  </xsl:choose>
			</xsl:if>
			<xsl:text>&gt;</xsl:text>
		      </xsl:element>
		    </p>
		  </div>
		</div>
	      </div>
	    </div>
	    
	    <div class="borderTopLeft">
	      <div class="borderTopRight">
		<div class="borderBottomRight">
		  <div class="borderBottomLeft">
		    <p>
		      <a href="/permalink/2006/poma/1189/es/image/" 
			 title="Last">
			<xsl:text>&gt;|</xsl:text>
		      </a>
		    </p>
		  </div>
		</div>
	      </div>
	    </div>
	  </xsl:otherwise>
	</xsl:choose>
      </div>
      <div class="contentFunction">
	<div class="borderTopLeft">
	  <div class="borderTopRight">
	    <div class="borderBottomRight">
	      <div class="borderBottomLeft">
		<xsl:variable name="tocstring">
		  <xsl:choose>
		    <xsl:when test="$lang = 'es'">
		      <xsl:text>Navegar por páginas</xsl:text>
		    </xsl:when>
		    <xsl:otherwise>
		      <xsl:text>Navigate by pages</xsl:text>
		    </xsl:otherwise>
		  </xsl:choose>
		</xsl:variable>
		<xsl:variable name="imagetocstring">
		  <xsl:choose>
		    <xsl:when test="$lang = 'es'">
		      <xsl:text>Navegar por dibujos</xsl:text>
		    </xsl:when>
		    <xsl:otherwise>
		      <xsl:text>Navigate by drawings</xsl:text>
		    </xsl:otherwise>
		  </xsl:choose>
		</xsl:variable>

		<!--xsl:value-of select="concat('/permalink/2006/poma',
						      '/',$identifier,
						      '/',$lang,
						      '/text/')"/ -->

		<form id="select_navigation_mode">
		  <p>
		    <input type="hidden"
			   value="{$imagesize}"/>
		    <select id="pulldownmenu" 
			    onchange="location = this.options[this.selectedIndex].value;">
		      <xsl:element name="option">
			<xsl:variable name="goto">
			  <xsl:value-of select="concat('/permalink/2006/poma',
						'/',$identifier,
						'/',$lang,
						'/text/')"/>
			</xsl:variable>
			<xsl:attribute name="value">
			  <xsl:value-of select="$goto"/>
			</xsl:attribute>
			<xsl:if test="$mode='text'">
			  <xsl:attribute name="selected">selected</xsl:attribute>
			</xsl:if>
			<xsl:value-of select="$tocstring"/>
		      </xsl:element>
		      <xsl:element name="option">
			<xsl:choose>
			  <xsl:when test="$mode='image'">
			    <xsl:attribute name="selected">selected</xsl:attribute>
			    <xsl:attribute name="value">
			      <xsl:value-of select="concat('/permalink/2006/poma',
						    '/',$identifier,
						    '/',$lang,
						    '/image/')"/>
			    </xsl:attribute>
			  </xsl:when>
			  <xsl:otherwise>
			    <xsl:choose> 
			      <xsl:when test="$imagedoc/
					      html/
					      div[@class='annotation']/
					      div/
					      node()">
				<xsl:attribute name="value">
				  <xsl:value-of select="concat('/permalink/2006/poma',
							'/',$identifier,
							'/',$lang,
							'/image/')"/>
				</xsl:attribute>
			      </xsl:when>
			      <xsl:otherwise>
				<xsl:attribute name="value">
				  <xsl:value-of select="concat('/permalink/2006/poma',
							'/titlepage',
							'/',$lang,
							'/image/')"/>
				</xsl:attribute>
			      </xsl:otherwise>
			    </xsl:choose>
			  </xsl:otherwise>
			</xsl:choose>
			<xsl:value-of select="$imagetocstring"/>
		      </xsl:element>
		    </select>
		  </p>
		</form>
	      </div>
	    </div>
	  </div>
	</div>
      </div>
      <div class="buttonFunction">
	<xsl:choose>
	  <xsl:when test="not($imagesize = 'XL')">
	    <xsl:for-each select="$imagedoc/html/div[@class='otherimages']">
	      <xsl:for-each select="img[1]">
		<div class="borderTopLeft">
		  <div class="borderTopRight">
		    <div class="borderBottomRight">
		      <div class="borderBottomLeft">
			<p>
			  <xsl:element name="a">
			    <xsl:attribute name="href">
			      <xsl:value-of select="concat('/permalink/2006/poma/',
						    $identifier,'/',
						    $lang,'/',
						    $mode,'/?',
						    'open=',$open,
						    '&amp;imagesize=XL')">
			      </xsl:value-of>
			    </xsl:attribute>
			    <xsl:choose>
			      <xsl:when test="$lang = 'es'">
				Ampliación
			      </xsl:when>
			      <xsl:otherwise>
				Larger image
			      </xsl:otherwise>
			    </xsl:choose>
			  </xsl:element>
			</p>
		      </div>
		    </div>
		  </div>
		</div>
	      </xsl:for-each>
	    </xsl:for-each>
	  </xsl:when>
	  <xsl:otherwise>
	    <div class="borderTopLeft">
	      <div class="borderTopRight">
		<div class="borderBottomRight">
		  <div class="borderBottomLeft">
		    <p>
		      <xsl:element name="a">
			<xsl:attribute name="href">
			  <xsl:value-of select="concat('/permalink/2006/poma/',
						$identifier,'/',
						$lang,'/',
						$mode,'/?',
						'open=',$open,
						'&amp;imagesize=normal')">
			  </xsl:value-of>
			</xsl:attribute>
			<xsl:choose>
			  <xsl:when test="$lang = 'es'">
			    Imagen normal
			  </xsl:when>
			  <xsl:otherwise>
			    Standard image
			  </xsl:otherwise>
			</xsl:choose>
		      </xsl:element>
		    </p>
		  </div>
		</div>
	      </div>
	    </div>
	  </xsl:otherwise>
	</xsl:choose>
      </div>
      <div class="searchFunction">
	<xsl:choose>
	  <xsl:when test="$lang = 'en'">
	    <xsl:variable name="inputvalue">
	      <xsl:choose>
		<xsl:when test="$query">
		  <xsl:value-of select="$query"/>
		</xsl:when>
		<xsl:otherwise>Type search string</xsl:otherwise>
	      </xsl:choose>
	    </xsl:variable>
	    <form action="/permalink/2006/poma/titlepage/en/text/" method="get">
	      <input type="hidden" name="start" value="0"/>
	      <input type="hidden" name="field" value="{$field}"/>
	      <input type="hidden" name="operator" value="{$operator}"/>
	      <div class="borderTopLeft">
		<div class="borderTopRight">
		  <div class="borderBottomRight">
		    <div class="borderBottomLeft">
		      <p>
			<input type="text" 
			       class="text"
			       name="q"
			       value="{$inputvalue}" >
			  <xsl:if test="not($query)">
			    <xsl:attribute name="onfocus">
			      this.value='';
			    </xsl:attribute>
			  </xsl:if>
			</input>
		      </p>
		    </div>
		  </div>
		</div>
	      </div>
	      <div class="borderTopLeft">
		<div class="borderTopRight">
		  <div class="borderBottomRight">
		    <div class="borderBottomLeft">
		      <p>
			<input type="submit" 
			       value="Search" 
			       class="button" />
		      </p>
		    </div>
		  </div>
		</div>
	      </div>
	    </form>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:variable name="inputvalue">
	      <xsl:choose>
		<xsl:when test="$query">
		  <xsl:value-of select="$query"/>
		</xsl:when>
		<xsl:otherwise>Ingrese texto a buscar</xsl:otherwise>
	      </xsl:choose>
	    </xsl:variable>
	    <form action="/permalink/2006/poma/titlepage/es/text/" method="get">
	      <input type="hidden" name="start" value="0"/>
	      <input type="hidden" name="operator" value="{$operator}"/>
	      <input type="hidden" name="field" value="{$field}"/>
	      <div class="borderTopLeft">
		<div class="borderTopRight">
		  <div class="borderBottomRight">
		    <div class="borderBottomLeft">
		      <p>
			<input type="text" 
			       class="text"
			       name="q"
			       value="{$inputvalue}" >
			  <xsl:if test="not($query)">
			    <xsl:attribute name="onfocus">
			      this.value='';
			    </xsl:attribute>
			  </xsl:if>
			</input>
		      </p>
		    </div>
		  </div>
		</div>
	      </div>
	      <div class="borderTopLeft">
		<div class="borderTopRight">
		  <div class="borderBottomRight">
		    <div class="borderBottomLeft">
		      <p>
			<input type="submit" 
			       value="Buscar" 
			       class="button" />
		      </p>
		    </div>
		  </div>
		</div>
	      </div>
	    </form>
	  </xsl:otherwise>
	</xsl:choose> 
      </div>
      <div class="clear">
	<xsl:text>
	</xsl:text>
      </div>
    </div>
  </xsl:template>
<!--
$Log: make-page.xsl,v $
Revision 1.14  2008/10/28 10:12:22  slu
Checking in whatever there is to check in

Revision 1.13  2007/05/15 06:52:19  slu
Fixed bug in create-html-list.xsl that emits entries in the table of images
that lead to invalid links

Revision 1.12  2007/04/25 11:55:44  slu
Implemented the new design.

-->
</xsl:stylesheet>
