<?xml version="1.0"?>

<!-- Input document should be a publish.xml file. -->

<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
                xmlns:h="http://www.w3.org/1999/xhtml"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:edit="http://xmlns.grorg.org/SVGT12NG/"
                xmlns:x="http://mcc.id.au/ns/local"
                xmlns:saxon="http://saxon.sf.net/"
                xmlns:xs='http://www.w3.org/2001/XMLSchema'
                xmlns:idl='http://mcc.id.au/ns/idl'
                xmlns:_xml='data:,'
                xpath-default-namespace="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="h edit x saxon xs idl"
                version="2.0">

  <xsl:output method='text'/>
  <xsl:output name='chapter' method='xml' omit-xml-declaration='yes' doctype-public='-//W3C//DTD XHTML 1.0 Transitional//EN' doctype-system='http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd'/>

  <xsl:namespace-alias stylesheet-prefix='_xml' result-prefix='xml'/>

  <xsl:variable name='MATURITIES'>
    <x:maturity code='ED' short='ED' long='Editor’s Draft' longer='Editor’s Draft'/>
    <x:maturity code='WG-NOTE' short='NOTE' long='Working Group Note' longer='Working Group Note'/>
    <x:maturity code='WD' short='WD' long='Working Draft' longer='Working Draft'/>
    <x:maturity code='FPWD' short='WD' long='Working Draft' longer='First Public Working Draft'/>
    <x:maturity code='LCWD' short='WD' long='Working Draft' longer='Last Call Working Draft'/>
    <x:maturity code='FPLCWD' short='WD' long='Working Draft' longer='First Public and Last Call Working Draft'/>
    <x:maturity code='CR' short='CR' long='Candidate Recommendation' longer='Candidate Recommendation'/>
    <x:maturity code='PR' short='PR' long='Proposed Recommendation' longer='Proposed Recommendation'/>
    <x:maturity code='PER' short='PER' long='Proposed Edited Recommendation' longer='Proposed Edited Recommendation'/>
    <x:maturity code='REC' short='REC' long='Recommendation' longer='Recommendation'/>
    <x:maturity code='RSNCD' short='RSCND' long='Rescinded Recommendation' longer='Rescinded Recommendation'/>
  </xsl:variable>

  <xsl:variable name='conf-document' select='/'/>
  <xsl:variable name='conf' select='/*'/>

  <xsl:variable name='maturity' select='$conf/x:maturity'/>
  <xsl:variable name='maturity-short' select='$MATURITIES/*[@code=$maturity]/@short'/>
  <xsl:variable name='maturity-long' select='$MATURITIES/*[@code=$maturity]/@long'/>
  <xsl:variable name='maturity-longer' select='$MATURITIES/*[@code=$maturity]/@longer'/> 

  <xsl:variable name='publication-date' select='if ($conf/x:publication-date) then xs:date($conf/x:publication-date) else xs:date(current-dateTime())' as='xs:date'/>

  <xsl:variable name='this-version' select='if ($maturity = "ED") then $conf/x:versions/x:cvs/@href else $conf/x:versions/x:this/@href'/>

  <xsl:variable name='idl-document' select='document($conf/x:interfaces/@idl, $conf-document)'/>
  <xsl:variable name='idl' select='$idl-document/*'/>

  <xsl:variable name='empty-defs-document'><xsl:document><x:definitions/></xsl:document></xsl:variable>

  <xsl:variable name='defs-document' select='document($conf/x:definitions/@href, $conf-document)'/>
  <xsl:variable name='defs' select='x:collate-defs($defs-document, $empty-defs-document, "")/*'/>

  <xsl:variable name='single-chapter' select='not(($conf/x:chapter, $conf/x:appendix, $conf/x:page))'/>

  <xsl:param name='chapters-to-build' select='string-join($conf/(x:index | x:chapter | x:appendix | x:page)/@name, " ")'/>
  <xsl:variable name='to-build' select='tokenize($chapters-to-build, " ")'/>

  <xsl:variable name='publish-dir'>
    <xsl:choose>
      <xsl:when test='$conf/x:output/@use-publish-directory != "true"'>/</xsl:when>
      <xsl:when test='$conf/x:output/@publish-directory'><xsl:value-of select='$conf/x:output/@publish-directory'/>/</xsl:when>
      <xsl:otherwise>publish/</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:template match='/'>
    <xsl:if test='not(x:publish-conf)'>
      <xsl:message terminate='yes'>Input document must be a publish.xml file.</xsl:message>
    </xsl:if>
    <xsl:for-each select='$conf/x:index[@name=$to-build]'>
      <xsl:variable name='title-extra' select='if (@title-extra) then string(@title-extra) else""'/>
      <xsl:result-document format='chapter' href='../{$publish-dir}{@name}.html'>
        <xsl:variable name='d' select='document(concat(@name, ".html"), .)/html'/>
        <xsl:variable name='master-directory' select='if ($conf/x:output/@use-publish-directory = "true") then "../master/" else "../"'/>
        <xsl:comment>
          <xsl:text>&#10;  </xsl:text>
          <xsl:value-of select='$conf/x:title'/>
          <xsl:value-of select='$title-extra'/>
          <xsl:text>&#10;&#10;  &#36;Id$&#10;&#10;  Note: This document is generated from </xsl:text>
          <xsl:value-of select='concat($master-directory, @name, ".html")'/>
          <xsl:text>.&#10;  Run "make" from </xsl:text>
          <xsl:value-of select='$master-directory'/>
          <xsl:text> to regenerate it.&#10;  </xsl:text>
        </xsl:comment>
        <xsl:text>&#10;</xsl:text>
        <xsl:apply-templates select='$d'>
          <xsl:with-param name='chapter-number' select='""' tunnel='yes'/>
          <xsl:with-param name='chapter-type' select='"index"' tunnel='yes'/>
          <xsl:with-param name='title-extra' select='$title-extra' tunnel='yes'/>
        </xsl:apply-templates>
      </xsl:result-document>
    </xsl:for-each>
    <xsl:apply-templates select='$conf/x:page'/>
    <xsl:apply-templates select='$conf/x:chapter'/>
    <xsl:apply-templates select='$conf/x:appendix'/>
  </xsl:template>

  <xsl:template match='x:chapter | x:appendix | x:page'>
    <xsl:if test='@name=$to-build'>
      <xsl:variable name='chapter-type' select='local-name()'/>
      <xsl:variable name='chapter-number'>
        <xsl:choose>
          <xsl:when test='$chapter-type = "page"'/>
          <xsl:when test='@number'><xsl:value-of select='@number'/></xsl:when>
          <xsl:when test='$chapter-type = "appendix"'><xsl:number value='position()' format='A'/></xsl:when>
          <xsl:otherwise><xsl:value-of select='position()'/></xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:result-document format='chapter' href='../{$publish-dir}{@name}.html'>
        <xsl:variable name='d' select='document(concat(@name, ".html"), .)/html'/>
        <xsl:variable name='master-directory' select='if ($conf/x:output/@use-publish-directory = "true") then "../master/" else "../"'/>
        <xsl:comment>
          <xsl:text>&#10;  </xsl:text>
          <xsl:value-of select='$conf/x:title'/>
          <xsl:text>&#10;  </xsl:text>
          <xsl:value-of select='if (self::x:chapter) then "Chapter" else "Appendix"'/>
          <xsl:text> </xsl:text>
          <xsl:value-of select='$chapter-number'/>
          <xsl:text>: </xsl:text>
          <xsl:value-of select='$d/head/title'/>
          <xsl:text>&#10;&#10;  &#36;Id$&#10;&#10;  Note: This document is generated from </xsl:text>
          <xsl:value-of select='concat($master-directory, @name, ".html")'/>
          <xsl:text>.&#10;  Run "make" from </xsl:text>
          <xsl:value-of select='$master-directory'/>
          <xsl:text> to regenerate it.&#10;  </xsl:text>
        </xsl:comment>
        <xsl:text>&#10;</xsl:text>
        <xsl:apply-templates select='$d'>
          <xsl:with-param name='chapter-number' select='$chapter-number' tunnel='yes'/>
          <xsl:with-param name='chapter-type' select='$chapter-type' tunnel='yes'/>
          <xsl:with-param name='previous-chapter' select='reverse(preceding-sibling::x:chapter | preceding-sibling::x:appendix | preceding-sibling::x:page)[1]/@name' tunnel='yes'/>
          <xsl:with-param name='next-chapter' select='(following-sibling::x:chapter | following-sibling::x:appendix | following-sibling::x:page)[1]/@name' tunnel='yes'/>
        </xsl:apply-templates>
      </xsl:result-document>
    </xsl:if>
  </xsl:template>

  <xsl:template match='/html'>
    <xsl:param name='chapter-number' tunnel='yes'/>
    <xsl:param name='chapter-type' tunnel='yes'/>
    <xsl:param name='previous-chapter' tunnel='yes'/>
    <xsl:param name='next-chapter' tunnel='yes'/>
    <xsl:param name='title-extra' tunnel='yes'/>

    <!--
      First, gather the sections in the chapter so that the table of
      contents and section numbers can be generated efficiently.
      -->
    <xsl:variable name='sections' select='x:gather-sections(if ($single-chapter) then .//div[@class="head"][1]/following-sibling::* else .//h1[1], $chapter-number)'/>

    <html>
      <head>
        <meta http-equiv='Content-Type' content='text/html;charset=UTF-8'/>
        <title>
          <xsl:choose>
            <xsl:when test='$chapter-type = "index"'>
              <xsl:value-of select='$conf/x:title'/><xsl:value-of select='$title-extra'/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select='head/title'/> &#x2013; <xsl:value-of select='$conf/x:short-title'/>
            </xsl:otherwise>
          </xsl:choose>
        </title>
        <xsl:apply-templates select='head/*[not(self::link) and not(self::meta) and not(self::title)]'/>
        <xsl:apply-templates select='head/link[not(@rel="stylesheet" and contains(@href, "StyleSheets/TR") or @media="print")]'/>
        <link rel='stylesheet' href='http://www.w3.org/StyleSheets/TR/W3C-{$maturity-short}'/>
        <xsl:apply-templates select='head/link[@rel="stylesheet" and @media="print"]'/>
      </head>
      <body>
        <xsl:variable name='header'>
          <xsl:call-template name='header'>
            <xsl:with-param name='previous-chapter' select='$previous-chapter'/>
            <xsl:with-param name='next-chapter' select='$next-chapter'/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:if test='$chapter-type != "index"'>
          <div class='header top'>
            <xsl:copy-of select='$header'/>
          </div>
        </xsl:if>
        <xsl:apply-templates select='body/node()'>
          <xsl:with-param name='sections' select='$sections' tunnel='yes'/>
        </xsl:apply-templates>
        <xsl:if test='$chapter-type != "index" or $conf/(x:chapter | x:appendix | x:page)'>
          <div class='header bottom'>
            <xsl:copy-of select='$header'/>
          </div>
        </xsl:if>
<!--        <script src='style/expanders.js' type='text/javascript'><xsl:text> </xsl:text></script> -->
      </body>
    </html>
  </xsl:template>
  
  <xsl:function name='x:gather-sections'>
    <xsl:param name='n'/>
    <xsl:param name='chapter-number'/>

    <xsl:document>
      <x:chapter number='{$chapter-number}' title='{$n}'>
        <xsl:variable name='ignored-group' select='not(($n/following::*)[1]/self::h2[not(@edit:toc="no")])'/>
        <xsl:for-each-group select='$n/following::*' group-starting-with='h2[not(@edit:toc="no")]'>
          <xsl:if test='self::h2[not(@edit:toc="no")]'>
            <xsl:variable name='pos' select='position() - (if ($ignored-group) then 1 else 0)'/>
            <xsl:variable name='sec' select='if ($chapter-number) then concat($chapter-number, ".", $pos) else string($pos)'/>
            <x:section _xml:id='{x:section-id(.)}' number='{$sec}'>
              <x:title><xsl:copy-of select='node()'/></x:title>
              <xsl:call-template name='gather-sections-rec'>
                <xsl:with-param name='level' select='3'/>
                <xsl:with-param name='sec' select='$sec'/>
              </xsl:call-template>
            </x:section>
          </xsl:if>
        </xsl:for-each-group>
      </x:chapter>
    </xsl:document>
  </xsl:function>

  <xsl:template name='gather-sections-rec'>
    <xsl:param name='level' as='xs:integer'/>
    <xsl:param name='sec' as='xs:string'/>
    <xsl:variable name='ln' select='concat("h", $level)'/>
    <xsl:variable name='ignored-group' select='local-name(current-group()[1]) ne $ln or current-group()[1]/@edit:toc = "no"'/>
    <xsl:for-each-group select='current-group()' group-starting-with='*[local-name() eq $ln and not(@edit:toc="no")]'>
      <xsl:if test='current-group()[1][local-name() eq $ln and not(@edit:toc="no")]'>
        <xsl:variable name='pos' select='position() - (if ($ignored-group) then 1 else 0)'/>
        <xsl:variable name='sec' select='concat($sec, ".", $pos)'/>
        <x:section _xml:id='{x:section-id(.)}' number='{$sec}'>
          <x:title><xsl:apply-templates select='node()' mode='no-id'/></x:title>
          <xsl:if test='$level &lt; 6'>
            <xsl:call-template name='gather-sections-rec'>
              <xsl:with-param name='level' select='$level + 1'/>
              <xsl:with-param name='sec' select='$sec'/>
            </xsl:call-template>
          </xsl:if>
        </x:section>
      </xsl:if>
    </xsl:for-each-group>
  </xsl:template>

  <!-- Generate a Table of Contents below the chapter title -->
  <xsl:template match='h1'>
    <xsl:param name='chapter-number' tunnel='yes'/>
    <xsl:param name='chapter-type' tunnel='yes'/>
    <xsl:param name='sections' tunnel='yes'/>
    <h1>
      <xsl:copy-of select='@*[namespace-uri() = ""]'/>
      <xsl:if test='$chapter-number'>
        <xsl:value-of select='if ($chapter-type = "appendix") then concat("Appendix ", $chapter-number, ": ") else concat($chapter-number, " ")'/>
      </xsl:if>
      <xsl:apply-templates select='node()'/>
    </h1>
    <xsl:if test='$chapter-type != "index" and $sections/*/*'>
      <h2 id='toc'>Contents</h2>
      <ul class='toc'>
        <xsl:apply-templates select='$sections/*/x:section'/>
      </ul>
    </xsl:if>
  </xsl:template>

  <xsl:template match='edit:minitoc'>
    <xsl:if test='$conf/x:page'>
      <ul class='toc'>
        <xsl:for-each select='$conf/x:page'>
          <li class='tocline1'><a href='{@name}.html'><xsl:value-of select='document(concat(@name, ".html"), .)/html/body/h1'/></a></li>
        </xsl:for-each>
      </ul>
    </xsl:if>
    <xsl:if test='$conf/x:chapter'>
      <ol class='toc'>
        <xsl:for-each select='$conf/x:chapter'>
          <li class='tocline1'><a href='{@name}.html'><xsl:value-of select='position()'/><xsl:text> </xsl:text><xsl:value-of select='document(concat(@name, ".html"), .)/html/body/h1'/></a></li>
        </xsl:for-each>
      </ol>
    </xsl:if>
    <xsl:if test='$conf/x:appendix'>
      <ol class='toc'>
        <xsl:for-each select='$conf/x:appendix'>
          <li class='tocline1'><a href='{@name}.html'>Appendix <xsl:number value='position()' format='A'/>: <xsl:value-of select='document(concat(@name, ".html"), .)/html/body/h1'/></a></li>
        </xsl:for-each>
      </ol>
    </xsl:if>
  </xsl:template>

  <xsl:template match='edit:fulltoc'>
    <xsl:param name='sections' tunnel='yes'/>
    <xsl:choose>
      <xsl:when test='$single-chapter'>
        <ul class='toc'>
          <xsl:apply-templates select='$sections/*/x:section'/>
        </ul>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test='$conf/x:page'>
          <ul class='toc'>
            <xsl:for-each select='$conf/x:page'>
              <li class='tocline1'><a href='{@name}.html'><xsl:value-of select='document(concat(@name, ".html"), .)/html/body/h1'/></a></li>
            </xsl:for-each>
          </ul>
        </xsl:if>
        <xsl:if test='$conf/x:chapter'>
          <ol class='toc'>
            <xsl:for-each select='$conf/x:chapter'>
              <xsl:variable name='doc' select='document(concat(@name, ".html"), .)'/>
              <xsl:variable name='s' select='x:gather-sections($doc//h1[1], position())'/>
              <li><div class='tocline1'><a href='{@name}.html'><xsl:value-of select='position()'/><xsl:text> </xsl:text><xsl:value-of select='$doc/html/body/h1'/></a></div>
                <xsl:if test='$s/*/x:section'>
                  <ul class='toc'>
                    <xsl:apply-templates select='$s/*/x:section'>
                      <xsl:with-param name='toc-filename' select='concat(@name, ".html")' tunnel='yes'/>
                    </xsl:apply-templates>
                  </ul>
                </xsl:if>
              </li>
            </xsl:for-each>
          </ol>
        </xsl:if>
        <xsl:if test='$conf/x:appendix'>
          <ol class='toc'>
            <xsl:for-each select='$conf/x:appendix'>
              <xsl:variable name='doc' select='document(concat(@name, ".html"), .)'/>
              <xsl:variable name='num'>
                <xsl:number value='position()' format='A'/>
              </xsl:variable>
              <xsl:variable name='s' select='x:gather-sections($doc//h1[1], $num)'/>
              <li><div class='tocline1'><a href='{@name}.html'>Appendix <xsl:value-of select='$num'/>: <xsl:value-of select='$doc/html/body/h1'/></a></div>
                <xsl:if test='$s/*/x:section'>
                  <ul class='toc'>
                    <xsl:apply-templates select='$s/*/x:section'>
                      <xsl:with-param name='toc-filename' select='concat(@name, ".html")' tunnel='yes'/>
                    </xsl:apply-templates>
                  </ul>
                </xsl:if>
              </li>
            </xsl:for-each>
          </ol>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Insert section numbers in <h2>, <h3>, <h4>, <h5> and <h6> elements -->
  <xsl:template match='h2|h3|h4'>
    <xsl:param name='sections' tunnel='yes'/>
    <xsl:param name='chapter-type' tunnel='yes'/>
    <xsl:variable name='section-number' select='x:section-number($sections, x:section-id(.))'/>
    <xsl:element namespace='http://www.w3.org/1999/xhtml' name='{local-name()}'>
      <xsl:copy-of select='@*[namespace-uri() = ""]'/>
      <xsl:value-of select='if (not($chapter-type = "index" and not($single-chapter)) and $section-number) then concat($section-number, " ") else ""'/>
      <xsl:apply-templates select='node()'/>
    </xsl:element>
  </xsl:template>

  <xsl:template match='x:section'>
    <xsl:param name='toc-filename' tunnel='yes'/>
    <xsl:text>&#10;</xsl:text>
    <li>
      <a href='{$toc-filename}#{@xml:id}'>
        <xsl:value-of select='@number'/>
        <xsl:text> </xsl:text>
        <xsl:apply-templates select='x:title/node()'/>
      </a>
      <xsl:if test='x:section'>
        <ul class='toc'>
          <xsl:apply-templates select='x:section'/>
        </ul>
      </xsl:if>
    </li>
  </xsl:template>

  <xsl:template match='h:*' mode='no-id'>
    <xsl:element name='{local-name()}'>
      <xsl:copy-of select='@*[local-name() != "id" and namespace-uri() = ""]'/>
      <xsl:apply-templates select='node()'/>
    </xsl:element>
  </xsl:template>

  <xsl:template match='h:*'>
    <xsl:element name='{local-name()}'>
      <xsl:copy-of select='@*[namespace-uri() = ""]'/>
      <xsl:apply-templates select='node()'/>
    </xsl:element>
  </xsl:template>

  <xsl:template match='edit:completeidl'>
    <xsl:variable name='modules' select='tokenize(@modules, ", ")'/>
    <pre class='idl'>
      <xsl:for-each select='$idl/(idl:module[@scopedname=$modules] | idl:interface | idl:exception)'>
        <xsl:if test='position() != 1'><xsl:text>&#10;&#10;</xsl:text></xsl:if>
        <xsl:apply-templates select='.'/>
      </xsl:for-each>
    </pre>
  </xsl:template>

  <xsl:template match='idl:module'>
    <xsl:text>module </xsl:text>
    <b><xsl:value-of select='@name'/></b>
    <xsl:text> {&#10;&#10;</xsl:text>
    <xsl:for-each select='idl:interface | idl:exception'>
      <xsl:if test='position() != 1'><xsl:text>&#10;</xsl:text></xsl:if>
      <xsl:apply-templates select='.'/>
      <xsl:text>&#10;</xsl:text>
    </xsl:for-each>
    <xsl:text>&#10;};</xsl:text>
  </xsl:template>

  <xsl:template match='edit:interface'>
    <xsl:variable name='interface-name' select='@name'/>
    <xsl:variable name='interface' select='$idl//(idl:interface | idl:exception)[@scopedname=$interface-name]'/>
    <xsl:variable name='interface-desc' select='$interface/idl:description'/>
    <xsl:apply-templates select='$interface-desc/(h:* | edit:* | text())'>
      <xsl:with-param name='interface' select='$interface' tunnel='yes'/>
    </xsl:apply-templates>
    <pre class='idl'>
      <xsl:apply-templates select='$interface'/>
    </pre>
    <xsl:variable name='associatedConsts' select='if ($interface/self::idl:exception) then root($interface)//idl:const[@associatedexception=$interface-name] else ()'/>
    <xsl:if test='$interface/(idl:attribute | idl:operation | idl:const | idl:member) | $associatedConsts'>
      <dl class='interface'>
        <xsl:if test='$interface/idl:const | $associatedConsts'>
          <xsl:for-each select='distinct-values(($interface/idl:const/@defgroup, $associatedConsts/self::idl:const/@defgroup))'>
            <xsl:variable name='defgroup' select='.'/>
            <dt>Constants in group “<xsl:value-of select='.'/>”:</dt>
            <dd>
              <dl class='constants'>
                <xsl:apply-templates select='$interface/idl:const[@defgroup=$defgroup] | $associatedConsts/self::idl:const[@defgroup=$defgroup]' mode='prose'>
                  <xsl:with-param name='interface' select='$interface'/>
                </xsl:apply-templates>
              </dl>
            </dd>
          </xsl:for-each>
          <xsl:variable name='ungrouped-consts' select='$interface/idl:const[not(@defgroup)] | $associatedConsts/self::idl:const[not(@defgroup)]'/>
          <xsl:if test='$ungrouped-consts'>
            <dt>
              <xsl:choose>
                <xsl:when test='$interface/idl:const/@defgroup | $associatedConsts/self::idl:const/@defgroup'>Other constants:</xsl:when>
                <xsl:otherwise>Constants:</xsl:otherwise>
              </xsl:choose>
            </dt>
            <dd>
              <dl class='constants'>
                <xsl:apply-templates select='$ungrouped-consts' mode='prose'>
                  <xsl:with-param name='interface' select='$interface'/>
                </xsl:apply-templates>
              </dl>
            </dd>
          </xsl:if>
        </xsl:if>
        <xsl:if test='$interface/idl:attribute'>
          <dt>Attributes:</dt>
          <dd>
            <dl class='attributes'>
              <xsl:apply-templates select='$interface/idl:attribute' mode='prose'>
                <xsl:with-param name='interface' select='$interface'/>
              </xsl:apply-templates>
            </dl>
          </dd>
        </xsl:if>
        <xsl:if test='$interface/idl:member'>
          <dt>Exception members:</dt>
          <dd>
            <dl class='attributes'>
              <xsl:apply-templates select='$interface/idl:member' mode='prose'>
                <xsl:with-param name='interface' select='$interface'/>
              </xsl:apply-templates>
            </dl>
          </dd>
        </xsl:if>
        <xsl:if test='$interface/idl:operation'>
          <dt>Operations:</dt>
          <dd>
            <dl class='attributes'>
              <xsl:apply-templates select='$interface/idl:operation' mode='prose'>
                <xsl:with-param name='interface' select='$interface'/>
              </xsl:apply-templates>
            </dl>
          </dd>
        </xsl:if>
      </dl>
    </xsl:if>
  </xsl:template>

  <xsl:template match='idl:interface | idl:exception'>
    <xsl:variable name='i' select='.'/>
    <xsl:value-of select='concat(local-name(), " ")'/>
    <xsl:variable name='name' select='@name'/>
    <b><xsl:value-of select='@name'/></b>
    <xsl:if test='idl:extends'>
      <xsl:text> : </xsl:text>
      <xsl:apply-templates select='idl:extends[1]'/>
      <xsl:for-each select='idl:extends[position() &gt; 1]'>
        <xsl:text>,&#10;             </xsl:text>
        <xsl:value-of select='replace($name, ".", " ")'/>
        <xsl:apply-templates select='.'/>
      </xsl:for-each>
    </xsl:if>
    <xsl:text> {&#10;</xsl:text>
    <xsl:variable name='spaces' select='count((idl:member[1], idl:attribute[1], idl:operation[1], idl:const[@defgroup][1], idl:const[not(@defgroup)][1])) &gt; 1'/>
    <xsl:if test='idl:const[not(@defgroup)] and $spaces'>
      <xsl:text>&#10;</xsl:text>
    </xsl:if>
    <xsl:for-each select='idl:const[not(@defgroup)]'>
      <xsl:text>  </xsl:text>
      <xsl:apply-templates select='.'/>
      <xsl:text>&#10;</xsl:text>
    </xsl:for-each>
    <xsl:for-each select='distinct-values(idl:const/@defgroup)'>
      <xsl:if test='$spaces'>
        <xsl:text>&#10;</xsl:text>
      </xsl:if>
      <xsl:text>  // </xsl:text>
      <xsl:value-of select='.'/>
      <xsl:text>&#10;</xsl:text>
      <xsl:variable name='defgroup' select='.'/>
      <xsl:for-each select='$i/idl:const[@defgroup=$defgroup]'>
        <xsl:text>  </xsl:text>
        <xsl:apply-templates select='.'/>
        <xsl:text>&#10;</xsl:text>
      </xsl:for-each>
    </xsl:for-each>
    <xsl:if test='idl:attribute'>
      <xsl:variable name='indent' select='count(idl:attribute[@readonly="true"]) != 0'/>
      <xsl:if test='$spaces'>
        <xsl:text>&#10;</xsl:text>
      </xsl:if>
      <xsl:for-each select='idl:attribute'>
        <xsl:text>  </xsl:text>
        <xsl:apply-templates select='.'>
          <xsl:with-param name='indent' select='$indent'/>
        </xsl:apply-templates>
        <xsl:text>&#10;</xsl:text>
      </xsl:for-each>
    </xsl:if>
    <xsl:if test='idl:member'>
      <xsl:for-each select='idl:member'>
        <xsl:text>  </xsl:text>
        <xsl:apply-templates select='.'/>
        <xsl:text>&#10;</xsl:text>
      </xsl:for-each>
    </xsl:if>
    <xsl:if test='idl:operation'>
      <xsl:if test='$spaces'>
        <xsl:text>&#10;</xsl:text>
      </xsl:if>
      <xsl:for-each select='idl:operation'>
        <xsl:text>  </xsl:text>
        <xsl:apply-templates select='.'/>
        <xsl:text>&#10;</xsl:text>
      </xsl:for-each>
    </xsl:if>
    <xsl:text>};</xsl:text>
    <xsl:variable name='scopedname' select='@scopedname'/>
    <xsl:variable name='associatedConsts' select='if (self::idl:exception) then root(.)//idl:const[@associatedexception=$scopedname] else ()'/>
    <xsl:if test='$associatedConsts'>
      <xsl:text>&#10;</xsl:text>
      <xsl:for-each select='$associatedConsts/self::idl:const[not(@defgroup)]'>
        <xsl:text>&#10;</xsl:text>
        <xsl:apply-templates select='.'/>
      </xsl:for-each>
      <xsl:for-each select='distinct-values($associatedConsts/self::idl:const/@defgroup)'>
        <xsl:text>&#10;</xsl:text>
        <xsl:text>// </xsl:text>
        <xsl:value-of select='.'/>
        <xsl:variable name='defgroup' select='.'/>
        <xsl:for-each select='$associatedConsts/self::idl:const[@defgroup=$defgroup]'>
          <xsl:text>&#10;</xsl:text>
          <xsl:apply-templates select='.'/>
        </xsl:for-each>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>

  <xsl:template match='idl:extends'>
    <xsl:variable name='superintf' select='id(@ref, .)'/>
    <xsl:variable name='name' select='($superintf/@name, @name)[1]'/>
    <xsl:choose>
      <xsl:when test='$defs/x:interface[@name=$superintf/@name]'>
        <xsl:copy-of select='x:interface-link($superintf/@name, .)'/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select='$name'/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match='idl:member' mode='prose'>
    <xsl:param name='interface'/>
    <xsl:text>&#10;</xsl:text>
    <dt id='{replace(@scopedname, ":", "_")}'>
      <b><xsl:value-of select='@name'/></b>
      <span class='idl-type-parenthetical'>
        <xsl:text> (</xsl:text>
        <xsl:call-template name='idl-type'/>
        <xsl:text>)</xsl:text>
      </span>
    </dt>
    <dd>
      <xsl:variable name='description' select='idl:description'/>
      <xsl:choose>
        <xsl:when test='not($description/node())'>&#160;</xsl:when>
        <xsl:when test='local-name($description/node()[1]) = ""'>
          <div>
            <xsl:apply-templates select='$description/node()'>
              <xsl:with-param name='interface' select='$interface' tunnel='yes'/>
            </xsl:apply-templates>
          </div>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select='$description/node()'>
            <xsl:with-param name='interface' select='$interface' tunnel='yes'/>
          </xsl:apply-templates>
        </xsl:otherwise>
      </xsl:choose>
    </dd>
  </xsl:template>

  <xsl:template match='idl:member'>
    <xsl:call-template name='idl-type'/>
    <xsl:text> </xsl:text>
    <a href='{substring-before($defs/x:interface[@name=current()/../@name]/@href, "#")}#{replace(@scopedname, ":", "_")}'><xsl:value-of select='@name'/></a>
    <xsl:text>;</xsl:text>
  </xsl:template>

  <xsl:template match='idl:attribute' mode='prose'>
    <xsl:param name='interface'/>
    <xsl:text>&#10;</xsl:text>
    <dt id='{replace(@scopedname, ":", "_")}'>
      <b><xsl:value-of select='@name'/></b>
      <span class='idl-type-parenthetical'>
        <xsl:text> (</xsl:text>
        <xsl:if test='@readonly="true"'>readonly </xsl:if>
        <xsl:call-template name='idl-type'/>
        <xsl:text>)</xsl:text>
      </span>
    </dt>
    <dd>
      <xsl:variable name='description' select='idl:description'/>
      <xsl:choose>
        <xsl:when test='not($description/node())'>&#160;</xsl:when>
        <xsl:when test='local-name($description/node()[1]) = ""'>
          <div>
            <xsl:apply-templates select='$description/node()'>
              <xsl:with-param name='interface' select='$interface' tunnel='yes'/>
            </xsl:apply-templates>
          </div>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select='$description/node()'>
            <xsl:with-param name='interface' select='$interface' tunnel='yes'/>
          </xsl:apply-templates>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test='idl:getraises | idl:setraises'>
        <dl class='attribute'>
          <xsl:if test='idl:getraises'>
            <dt>Exceptions on getting</dt>
            <dd>
              <dl class='exceptions'>
                <xsl:for-each select='idl:getraises'>
                  <xsl:sort select='@name'/>
                  <xsl:variable name='getraises' select='.'/>
                  <xsl:for-each select='idl:description'>
                    <dt>
                      <xsl:copy-of select='x:interface-link(id($getraises/@ref, .)/@name, .)'/>
                      <xsl:if test='@code'>, code <xsl:value-of select='@code'/></xsl:if>
                    </dt>
                    <dd>
                      <xsl:apply-templates select='node()'/>
                    </dd>
                  </xsl:for-each>
                </xsl:for-each>
              </dl>
            </dd>
          </xsl:if>
          <xsl:if test='idl:setraises'>
            <dt>Exceptions on setting</dt>
            <dd>
              <dl class='exceptions'>
                <xsl:for-each select='idl:setraises'>
                  <xsl:sort select='@name'/>
                  <xsl:variable name='setraises' select='.'/>
                  <xsl:for-each select='idl:description'>
                    <dt>
                      <xsl:copy-of select='x:interface-link(id($setraises/@ref, .)/@name, .)'/>
                      <xsl:if test='@code'>, code <xsl:value-of select='@code'/></xsl:if>
                    </dt>
                    <dd>
                      <xsl:apply-templates select='node()'/>
                    </dd>
                  </xsl:for-each>
                </xsl:for-each>
              </dl>
            </dd>
          </xsl:if>
        </dl>
      </xsl:if>
    </dd>
  </xsl:template>

  <xsl:template match='idl:attribute'>
    <xsl:param name='indent' select='true()' as='xs:boolean'/>
    <xsl:value-of select='if (@readonly="true") then "readonly attribute " else if ($indent) then "         attribute " else "attribute "'/>
    <xsl:call-template name='idl-type'/>
    <xsl:text> </xsl:text>
    <a href='{substring-before($defs/x:interface[@name=current()/../@name]/@href, "#")}#{replace(@scopedname, ":", "_")}'><xsl:value-of select='@name'/></a>
    <xsl:if test='idl:getraises'>
      <xsl:text> getraises(</xsl:text>
      <xsl:for-each select='idl:getraises'>
        <xsl:if test='position() != 1'>, </xsl:if>
        <xsl:call-template name='idl-type'>
          <xsl:with-param name='name' select='id(@ref, .)/@name'/>
        </xsl:call-template>
      </xsl:for-each>
      <xsl:text>)</xsl:text>
    </xsl:if>
    <xsl:if test='idl:setraises'>
      <xsl:text> setraises(</xsl:text>
      <xsl:for-each select='idl:setraises'>
        <xsl:if test='position() != 1'>, </xsl:if>
        <xsl:call-template name='idl-type'>
          <xsl:with-param name='name' select='id(@ref, .)/@name'/>
        </xsl:call-template>
      </xsl:for-each>
      <xsl:text>)</xsl:text>
    </xsl:if>
    <xsl:text>;</xsl:text>
  </xsl:template>

  <xsl:template match='idl:operation' mode='prose'>
    <xsl:param name='interface'/>
    <xsl:param name='op' select='.'/>
    <xsl:text>&#10;</xsl:text>
    <dt id='{replace(@scopedname, ":", "_")}'>
      <xsl:call-template name='idl-type'/>
      <xsl:text> </xsl:text>
      <b><xsl:value-of select='@name'/></b>
      <xsl:text>(</xsl:text>
      <xsl:for-each select='idl:argument'>
        <xsl:if test='position() != 1'>, </xsl:if>
        <xsl:text>in </xsl:text>
        <xsl:call-template name='idl-type'/>
        <xsl:text> </xsl:text>
        <var><xsl:value-of select='@name'/></var>
      </xsl:for-each>
      <xsl:text>)</xsl:text>
    </dt>
    <dd>
      <xsl:variable name='description' select='idl:description'/>
      <xsl:choose>
        <xsl:when test='not($description/node())'>&#160;</xsl:when>
        <xsl:when test='local-name($description/node()[1]) = ""'>
          <div>
            <xsl:apply-templates select='$description/node()'>
              <xsl:with-param name='interface' select='$interface' tunnel='yes'/>
            </xsl:apply-templates>
          </div>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select='$description/node()'>
            <xsl:with-param name='interface' select='$interface' tunnel='yes'/>
          </xsl:apply-templates>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test='not(@type="void") or (idl:argument | idl:raises)'>
        <dl class='operation'>
          <xsl:if test='idl:argument'>
            <dt>Parameters</dt>
            <dd>
              <ol class='parameters'>
                <xsl:for-each select='idl:argument'>
                  <xsl:variable name='argnum' select='position()'/>
                  <li>
                    <div class='parameter'>
                      <xsl:call-template name='idl-type'/>
                      <xsl:text> </xsl:text>
                      <var><xsl:value-of select='@name'/></var>
                    </div>
                    <xsl:text> </xsl:text>
                    <xsl:choose>
                      <xsl:when test='not(idl:description/node())'>&#160;</xsl:when>
                      <xsl:when test='local-name(idl:description/node()[1]) = ""'>
                        <div>
                          <xsl:apply-templates select='idl:description/node()'>
                            <xsl:with-param name='interface' select='$interface' tunnel='yes'/>
                          </xsl:apply-templates>
                        </div>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:apply-templates select='idl:description/node()'>
                          <xsl:with-param name='interface' select='$interface' tunnel='yes'/>
                        </xsl:apply-templates>
                      </xsl:otherwise>
                    </xsl:choose>
                  </li>
                </xsl:for-each>
              </ol>
            </dd>
          </xsl:if>
          <xsl:if test='not(@type="void")'>
            <dt>Returns</dt>
            <dd>
              <xsl:choose>
                <xsl:when test='not(idl:returns/idl:description/node())'>&#160;</xsl:when>
                <xsl:when test='local-name(idl:returns/idl:description/node()[1]) = ""'>
                  <div>
                    <xsl:apply-templates select='idl:returns/idl:description/node()'>
                      <xsl:with-param name='interface' select='$interface' tunnel='yes'/>
                    </xsl:apply-templates>
                  </div>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:apply-templates select='idl:returns/idl:description/node()'>
                    <xsl:with-param name='interface' select='$interface' tunnel='yes'/>
                  </xsl:apply-templates>
                </xsl:otherwise>
              </xsl:choose>
            </dd>
          </xsl:if>
          <xsl:if test='idl:raises'>
            <dt>Exceptions</dt>
            <dd>
              <dl class='exceptions'>
                <xsl:for-each select='idl:raises'>
                  <xsl:sort select='@name'/>
                  <xsl:variable name='raises' select='.'/>
                  <xsl:for-each select='idl:description'>
                    <dt>
                      <xsl:copy-of select='x:interface-link(id($raises/@ref, .)/@name, .)'/>
                      <xsl:if test='@code'>, code <xsl:value-of select='@code'/></xsl:if>
                    </dt>
                    <dd>
                      <xsl:apply-templates select='node()'>
                        <xsl:with-param name='interface' select='$interface' tunnel='yes'/>
                      </xsl:apply-templates>
                    </dd>
                  </xsl:for-each>
                </xsl:for-each>
              </dl>
            </dd>
          </xsl:if>
        </dl>
      </xsl:if>
    </dd>
  </xsl:template>

  <xsl:template match='idl:operation'>
    <xsl:call-template name='idl-type'/>
    <xsl:text> </xsl:text>
    <a href='{substring-before($defs/x:interface[@name=current()/../@name]/@href, "#")}#{replace(@scopedname, ":", "_")}'><xsl:value-of select='@name'/></a>
    <xsl:text>(</xsl:text>
    <xsl:for-each select='idl:argument'>
      <xsl:if test='position() != 1'>, </xsl:if>
      <xsl:text>in </xsl:text>
      <xsl:call-template name='idl-type'/>
      <xsl:text> </xsl:text>
      <xsl:value-of select='@name'/>
    </xsl:for-each>
    <xsl:text>)</xsl:text>
    <xsl:if test='idl:raises'>
      <xsl:text> raises(</xsl:text>
      <xsl:for-each select='idl:raises'>
        <xsl:if test='position() != 1'>, </xsl:if>
        <xsl:call-template name='idl-type'>
          <xsl:with-param name='name' select='id(@ref, .)/@name'/>
        </xsl:call-template>
      </xsl:for-each>
      <xsl:text>)</xsl:text>
    </xsl:if>
    <xsl:text>;</xsl:text>
  </xsl:template>

  <xsl:template match='idl:const' mode='prose'>
    <xsl:param name='interface'/>
    <xsl:text>&#10;</xsl:text>
    <dt id='{replace(@scopedname, ":", "_")}'>
      <b><xsl:value-of select='@name'/></b>
      <span class='idl-type-parenthetical'>
        <xsl:text> (</xsl:text>
        <xsl:call-template name='idl-type'/>
        <xsl:text>)</xsl:text>
      </span>
    </dt>
    <dd>
      <xsl:variable name='description' select='idl:description'/>
      <xsl:choose>
        <xsl:when test='not($description/node())'>&#160;</xsl:when>
        <xsl:when test='local-name($description/node()[1]) = ""'>
          <div>
            <xsl:apply-templates select='$description/node()'>
              <xsl:with-param name='interface' select='$interface' tunnel='yes'/>
            </xsl:apply-templates>
          </div>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select='$description/node()'>
            <xsl:with-param name='interface' select='$interface' tunnel='yes'/>
          </xsl:apply-templates>
        </xsl:otherwise>
      </xsl:choose>
    </dd>
  </xsl:template>

  <xsl:template match='idl:const'>
    <xsl:text>const </xsl:text>
    <xsl:call-template name='idl-type'/>
    <xsl:text> </xsl:text>
    <xsl:variable name='ae' select='@associatedexception'/>
    <xsl:variable name='container' select='if (../self::idl:interface) then ../@scopedname else if ($ae) then $ae else ()'/>
    <xsl:variable name='x' select='$idl//(idl:interface | idl:exception)[@scopedname=$container]'/>
    <a href='{substring-before($defs/x:interface[@name=$x/@name]/@href, "#")}#{replace(@scopedname, ":", "_")}'><xsl:value-of select='@name'/></a>
    <xsl:text> = </xsl:text>
    <xsl:value-of select='@value'/>
    <xsl:text>;</xsl:text>
  </xsl:template>

  <xsl:template name='idl-type'>
    <xsl:param name='name' select='(idl:type/idl:scopedname/@name, @type)'/>
    <xsl:choose>
      <xsl:when test='$defs/x:interface[@name=$name]'>
        <xsl:copy-of select='x:interface-link($name, .)'/>
      </xsl:when>
      <xsl:when test='$defs/x:interface[@name=substring-after($name, "::")]'>
        <xsl:copy-of select='x:interface-link(substring-after($name, "::"), .)'/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select='$name'/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name='header'>
    <xsl:param name='previous-chapter'/>
    <xsl:param name='next-chapter'/>
    <span class='namedate'><xsl:value-of select='$conf/x:short-title'/> – <xsl:value-of select='format-date($publication-date, "[D01] [MNn] [Y]", "en", (), ())'/></span>
    <ul>
      <li><a href='{$conf/x:index/@name}.html'>Top</a></li>
      <xsl:if test='$conf/x:toc'>
        <li><a href='{$conf/x:toc/@href}'>Contents</a></li>
      </xsl:if>
      <xsl:if test='$previous-chapter != ""'>
        <li><a href='{$previous-chapter}.html'>Previous</a></li>
      </xsl:if>
      <xsl:if test='$next-chapter != ""'>
        <li><a href='{$next-chapter}.html'>Next</a></li>
      </xsl:if>
      <xsl:if test='$conf/x:elementindex'>
        <li><a href='{$conf/x:elementindex/@href}'>Elements</a></li>
      </xsl:if>
      <xsl:if test='$conf/x:attributeindex'>
        <li><a href='{$conf/x:attributeindex/@href}'>Attributes</a></li>
      </xsl:if>
      <xsl:if test='$conf/x:propertyindex'>
        <li><a href='{$conf/x:propertyindex/@href}'>Properties</a></li>
      </xsl:if>
    </ul>
    <div class='after'><xsl:comment/></div>
  </xsl:template>

  <xsl:template match='span[tokenize(@class, " ") = ("element-name", "attr-name", "prop-name") and starts-with(., "&#39;") and ends-with(., "&#39;")]'>
    <span>
      <xsl:copy-of select='@*[namespace-uri() = ""]'/>
      <xsl:value-of select='concat("‘", substring(., 2, string-length() - 2), "’")'/>
    </span>
  </xsl:template>

  <xsl:template match='a[not(@href) and node()]'>
    <xsl:param name='interface' as='node()?' select='()' tunnel='yes'/>
    <xsl:param name='context-element' as='xs:string?' select='()' tunnel='yes'/>
    <xsl:variable name='this' select='normalize-space(.)'/>
    <xsl:choose>
      <xsl:when test='$interface/(idl:operation|idl:attribute|idl:const)[@name=$this]'>
        <xsl:variable name='idlattr' select='$interface/(idl:operation|idl:attribute|idl:const)[@name=$this]'/>
        <a class='idlattr{if (@class) then " " else ""}{@class}' href='#{replace($idlattr/@scopedname, ":", "_")}'>
          <xsl:copy-of select='@*[local-name() != "class" and namespace-uri() = ""]'/>
          <xsl:value-of select='$this'/>
        </a>
      </xsl:when>
      <xsl:when test='$defs/x:interface[@name=$this]'>
        <a class='idlinterface{if (@class) then " " else ""}{@class}' href='{$defs/x:interface[@name=$this]/@href}'>
          <xsl:copy-of select='@*[local-name() != "class" and namespace-uri() = ""]'/>
          <xsl:value-of select='$this'/>
        </a>
      </xsl:when>
      <xsl:when test='matches($this, "^[^:]+::[^:]+$")'>
        <xsl:variable name='before' select='substring-before($this, "::")'/>
        <xsl:variable name='after' select='substring-after($this, "::")'/>
        <xsl:variable name='member' select='$idl//(idl:interface | idl:exception)[@name=substring-before($this, "::")]/(idl:attribute|idl:operation|idl:const|idl:member)[@name=substring-after($this, "::")]'/>
        <xsl:choose>
          <xsl:when test='$member'>
            <a class='idlattr{if (@class) then " " else ""}{@class}' href='{substring-before($defs/(x:interface | x:exception)[@name=$before]/@href, "#")}#{replace($member/@scopedname, ":", "_")}'>
              <xsl:copy-of select='@*[local-name() != "class" and namespace-uri() = ""]'/>
              <xsl:if test='@edit:format="expanded"'><xsl:value-of select='$member/../@name'/>::</xsl:if>
              <xsl:value-of select='$after'/>
            </a>
          </xsl:when>
          <xsl:otherwise>
            <a style='background: red; color: white' href='data:,'>
              <xsl:message>Unknown interface member "<xsl:value-of select='$this'/>" at <xsl:value-of select="concat(base-uri(.), ' line ', saxon:line-number())"/>.</xsl:message>
              <xsl:copy-of select='@*[namespace-uri() = ""]'/>
              <xsl:apply-templates/>
            </a>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test='starts-with($this, "&#39;") and ends-with($this, "&#39;")'>
        <xsl:variable name='name' select='substring($this, 2, string-length() - 2)'/>
        <xsl:choose>
          <xsl:when test='contains($name, "/")'>
            <xsl:variable name='parts' select='tokenize($name, "/")'/>
            <xsl:copy-of select='x:attribute-link($parts[2], $parts[1], false(), .)'/>
          </xsl:when>
          <xsl:when test='contains($name, " ")'>
            <xsl:variable name='parts' select='tokenize($name, " ")'/>
            <xsl:choose>
              <xsl:when test='$parts[2] = "element"'>
                <xsl:copy-of select='x:element-link($parts[1], .)'/>
              </xsl:when>
              <xsl:when test='$parts[2] = "presentationattribute"'>
                <xsl:copy-of select='x:presentation-attribute-link($parts[1], .)'/>
              </xsl:when>
              <xsl:when test='$parts[2] = "attribute"'>
                <xsl:copy-of select='x:attribute-link($parts[1], $context-element, true(), .)'/>
              </xsl:when>
              <xsl:when test='$parts[2] = "property"'>
                <xsl:copy-of select='x:property-link($parts[1], .)'/>
              </xsl:when>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy-of select='x:name-link($name, $context-element, .)'/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test='starts-with($this, "&#60;") and ends-with($this, "&#62;")'>
        <xsl:variable name='name' select='substring($this, 2, string-length() - 2)'/>
        <xsl:copy-of select='x:symbol-link($name, .)'/>
      </xsl:when>
      <xsl:when test='$defs/x:term[lower-case(@name)=lower-case($this)]'>
        <xsl:variable name='term' select='$defs/x:term[lower-case(@name)=lower-case($this)]'/>
        <a href='{$term/@href}'><span class='{if ($term/@class) then $term/@class else "svg-term"}'><xsl:value-of select='.'/></span></a>
      </xsl:when>
      <xsl:otherwise>
        <a style='background: red; color: white' href='data:,'>
          <xsl:message>Unknown term "<xsl:value-of select='$this'/>" at <xsl:value-of select="concat(base-uri(.), ' line ', saxon:line-number())"/>.</xsl:message>
          <xsl:copy-of select='@*[namespace-uri() = ""]'/>
          <xsl:apply-templates/>
        </a>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match='edit:example'>
    <xsl:variable name='text' select='unparsed-text(resolve-uri(@href, base-uri(.)))'/>
    <pre class='xml'><xsl:value-of select='replace($text, "\s+$", "")'/></pre>
    <xsl:if test='@image="yes"'>
      <table summary="Example {@title}">
        <caption align="bottom">Example <xsl:value-of select="@name"/></caption>
        <tr><td><img alt="Example {@name}{if (@description) then concat(' — ', @description) else ''}" src='{replace(@href, "\.svg$", ".png")}'/></td></tr>
      </table>
    </xsl:if>
    <xsl:if test='@link="yes"'>
      <p class='view-as-svg'><a href='{@href}'>View this example as SVG (SVG-enabled browsers only)</a></p>
    </xsl:if>
  </xsl:template>

  <xsl:template match='edit:includefile'>
    <pre><xsl:value-of select='replace(unparsed-text(resolve-uri(@href, base-uri(.))), "\s+$", "")'/></pre>
  </xsl:template>

  <xsl:template match='edit:elementsummary'>
    <!--xsl:param name='context-element' as='xs:string?' select='()' tunnel='yes'/-->
    <xsl:for-each select='$defs/x:element[@name = current()/@name]'>
      <xsl:variable name='element' select='.'/>
      <xsl:variable name='name' select='@name'/>
      <div class='element-summary'>
        <div class='element-summary-name'><span class='element-name'>‘<xsl:value-of select='@name'/>’</span></div>
        <dl>
          <dt>Categories:</dt>
          <dd>
            <xsl:variable name='categories' select='$defs/x:elementcategory[tokenize(@elements, ", ") = current()/@name]'/>
            <xsl:choose>
              <xsl:when test='not($categories)'>None</xsl:when>
              <xsl:otherwise>
                <xsl:for-each select='$categories'>
                  <xsl:variable name='text' select='if (position() = 1) then concat(upper-case(substring(@name, 1, 1)), substring(@name, 2)) else @name'/>
                  <xsl:if test='position() != 1'>, </xsl:if>
                  <a href='{@href}'><xsl:value-of select='$text'/> element</a>
                </xsl:for-each>
              </xsl:otherwise>
            </xsl:choose>
          </dd>
          <dt>Content model:</dt>
          <dd>
            <xsl:choose>
              <xsl:when test='x:contentmodel'>
                <xsl:apply-templates select='x:contentmodel/node()'/>
              </xsl:when>
              <xsl:when test='@contentmodel=("textoranyof", "anyof", "oneormoreof")'>
                <xsl:value-of select='if (@contentmodel="oneormoreof") then "One or more" else "Any number"'/> of the following elements<xsl:if test='textoranyof'> or character data</xsl:if>, in any order:
                <ul class='no-bullets'>
                  <xsl:for-each select='tokenize(@elementcategories, ", ")'>
                    <xsl:variable name='category' select='$defs/x:elementcategory[@name=current()]'/>
                    <li>
                      <xsl:choose>
                        <xsl:when test='$category'>
                          <a href='{$category/@href}'><xsl:value-of select='.'/> elements</a>
                          <span class='expanding'>
                            <xsl:text> — </xsl:text>
                            <xsl:for-each select='tokenize($category/@elements, ", ")'>
                              <xsl:sort/>
                              <xsl:if test='position() != 1'>, </xsl:if>
                              <xsl:choose>
                                <xsl:when test='$defs/x:element[@name=current()]'>
                                  <a href='{$defs/x:element[@name=current()]/@href}'>
                                    <span class='element-name'>
                                      <xsl:value-of select='concat("‘", ., "’")'/>
                                    </span>
                                  </a>
                                </xsl:when>
                                <xsl:otherwise>
                                  <xsl:message>Unknown name "<xsl:value-of select='.'/>" at <xsl:value-of select="concat(base-uri($category), ' line ', saxon:line-number())"/>.</xsl:message>
                                  <a href='data:,' style='background: red; color: white'>@@ unknown name '<xsl:value-of select='.'/>'</a>
                                </xsl:otherwise>
                              </xsl:choose>
                            </xsl:for-each>
                          </span>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:message>Unknown element category "<xsl:value-of select='.'/>" at <xsl:value-of select="concat(base-uri($element), ' line ', saxon:line-number())"/>.</xsl:message>
                          <a href='data:,' style='background: red; color: white'>@@ unknown element category '<xsl:value-of select='.'/>'</a>
                        </xsl:otherwise>
                      </xsl:choose>
                    </li>
                  </xsl:for-each>
                  <xsl:for-each select='tokenize(@elements, ", ")'>
                    <xsl:sort/>
                    <li><xsl:copy-of select='x:element-link(., $element)'/></li>
                  </xsl:for-each>
                </ul>
              </xsl:when>
              <xsl:when test='@contentmodel="any"'>
                Any elements or character data.
              </xsl:when>
              <xsl:when test='@contentmodel="text"'>
                Character data.
              </xsl:when>
              <xsl:otherwise>Empty.</xsl:otherwise>
            </xsl:choose>
          </dd>
          <dt>Attributes:</dt>
          <dd>
            <xsl:choose>
              <xsl:when test='@attributecategories or @attributes or x:attribute'>
                <ul class='no-bullets'>
                  <xsl:for-each select='tokenize(@attributecategories, ", ")'>
                    <xsl:variable name='category' select='$defs/x:attributecategory[@name=current()]'/>
                    <xsl:if test='$category/@href'>
                      <li>
                        <xsl:choose>
                          <xsl:when test='$category'>
                            <a href='{$category/@href}'><xsl:value-of select='.'/> attributes</a>
                            <span class='expanding'>
                              <xsl:text> — </xsl:text>
                              <xsl:variable name='attributes' select='tokenize($category/@attributes, ", ")'/>
                              <xsl:variable name='presentationattributes' select='tokenize($category/@presentationattributes, ", ")'/>
                              <xsl:variable name='attributeelements' select='$category/x:attribute/@name'/>
                              <xsl:for-each select='$attributes'>
                                <xsl:if test='position() != 1'>, </xsl:if>
                                <xsl:copy-of select='x:attribute-link(., $name, true(), $category)'/>
                              </xsl:for-each>
                              <xsl:for-each select='$presentationattributes'>
                                <xsl:if test='count($attributes) or position() != 1'>, </xsl:if>
                                <xsl:copy-of select='x:presentation-attribute-link(., $category)'/>
                              </xsl:for-each>
                              <xsl:for-each select='$attributeelements'>
                                <xsl:if test='count($attributes) or count($presentationattributes) or position() != 1'>, </xsl:if>
                                <xsl:copy-of select='x:attribute-link(., $name, true(), $category)'/>
                              </xsl:for-each>
                            </span>
                          </xsl:when>
                          <xsl:otherwise>
                            <xsl:message>Unknown attribute category "<xsl:value-of select='.'/>" at <xsl:value-of select="concat(base-uri($element), ' line ', saxon:line-number())"/>.</xsl:message>
                            <a href='data:,' style='background: red; color: white'>@@ unknown attribute category '<xsl:value-of select='.'/>'</a>
                          </xsl:otherwise>
                        </xsl:choose>
                      </li>
                    </xsl:if>
                  </xsl:for-each>
                  <xsl:for-each select='tokenize(@attributecategories, ", ")'>
                    <xsl:variable name='category' select='$defs/x:attributecategory[@name=current()]'/>
                    <xsl:if test='$category and not($category/@href)'>
                      <xsl:variable name='attributes' select='tokenize($category/@attributes, ", ")'/>
                      <xsl:variable name='presentationattributes' select='tokenize($category/@presentationattributes, ", ")'/>
                      <xsl:variable name='attributeelements' select='$category/x:attribute/@name'/>
                      <xsl:for-each select='$attributes'>
                        <li><xsl:copy-of select='x:attribute-link(., $name, true(), $category)'/></li>
                      </xsl:for-each>
                      <xsl:for-each select='$presentationattributes'>
                        <li><xsl:copy-of select='x:presentation-attribute-link(., $category)'/></li>
                      </xsl:for-each>
                      <xsl:for-each select='$attributeelements'>
                        <li><xsl:copy-of select='x:attribute-link(., $name, true(), $category)'/></li>
                      </xsl:for-each>
                    </xsl:if>
                  </xsl:for-each>
                  <xsl:for-each select='tokenize(@attributes, ", *")'>
                    <li><xsl:copy-of select='x:attribute-link(., $name, true(), $element)'/></li>
                  </xsl:for-each>
                  <xsl:for-each select='x:attribute'>
                    <li><xsl:copy-of select='x:attribute-link(@name, $name, true(), $element)'/></li>
                  </xsl:for-each>
                </ul>
              </xsl:when>
              <xsl:otherwise>None</xsl:otherwise>
            </xsl:choose>
          </dd>
          <dt>DOM Interfaces:</dt>
          <dd>
            <ul class='no-bullets'>
              <xsl:for-each select='tokenize(@interfaces, ", *")'>
                <li><xsl:copy-of select='x:interface-link(., $element)'/></li>
              </xsl:for-each>
            </ul>
          </dd>
        </dl>
      </div>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match='edit:with'>
    <xsl:param name='context-element' select='()' as='xs:string?' tunnel='yes'/>
    <xsl:variable name='context-element' select='if (@element) then @element else $context-element'/>
    <xsl:apply-templates select='node()'>
      <xsl:with-param name='context-element' select='$context-element' tunnel='yes'/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match='edit:toc'>[generated toc goes here]</xsl:template>

  <xsl:template match='edit:maturity'><xsl:value-of select='$maturity-long'/></xsl:template>

  <xsl:template match='edit:date'>
    <xsl:value-of select='format-date($publication-date, "[D01] [MNn] [Y]", "en", (), ())'/>
  </xsl:template>

  <xsl:template match='edit:thisversion'>
    <a href='{$this-version}' class='url'><xsl:value-of select='$this-version'/></a>
  </xsl:template>

  <xsl:template match='edit:latestversion'>
    <xsl:variable name='href' select='$conf/x:versions/x:latest/@href'/>
    <a href='{$href}' class='url'><xsl:value-of select='$href'/></a>
  </xsl:template>

  <xsl:template match='edit:previousversion'>
    <xsl:variable name='href' select='$conf/x:versions/x:previous/@href'/>
    <a href='{$href}' class='url'><xsl:value-of select='$href'/></a>
  </xsl:template>

  <xsl:template match='edit:copyright'>
    <p class="copyright"><a href="http://www.w3.org/Consortium/Legal/ipr-notice#Copyright">Copyright</a> © <xsl:value-of select='year-from-date($publication-date)'/><xsl:text> </xsl:text><a href="http://www.w3.org/"><acronym title="World Wide Web Consortium">W3C</acronym></a><sup>®</sup> (<a href="http://www.csail.mit.edu/"><acronym title="Massachusetts Institute of Technology">MIT</acronym></a>, <a href="http://www.ercim.org/"><acronym title="European Research Consortium for Informatics and Mathematics">ERCIM</acronym></a>, <a href="http://www.keio.ac.jp/">Keio</a>), All Rights Reserved. W3C <a href="http://www.w3.org/Consortium/Legal/ipr-notice#Legal_Disclaimer">liability</a>, <a href="http://www.w3.org/Consortium/Legal/ipr-notice#W3C_Trademarks">trademark</a> and <a href="http://www.w3.org/Consortium/Legal/copyright-documents">document use</a> rules apply.</p>
  </xsl:template>

  <xsl:template match='edit:locallink'>
    <xsl:variable name='s' select='resolve-uri(@href, $this-version)'/>
    <a href='{$s}'>
      <xsl:choose>
        <xsl:when test='node()'>
          <xsl:apply-templates/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select='$s'/>
        </xsl:otherwise>
      </xsl:choose>
    </a>
  </xsl:template>

  <xsl:template match='edit:attributetable'>
    <table class='vert property-table' summary='Alphabetic list of attributes'>
      <tr>
        <th>Attribute</th>
        <th>Elements on which the attribute may be specified</th>
        <th title="Animatable"><a href="animate.html#Animatable">Anim.</a></th>
      </tr>
      <xsl:for-each select='$defs//x:attribute'>
        <xsl:sort select='@name'/>
        <xsl:sort select='@elements'/>
        <xsl:choose>
          <xsl:when test='../self::x:element'>
            <tr>
              <td><xsl:copy-of select='x:attribute-link(@name, ../@name, true(), .)'/></td>
              <td><xsl:copy-of select='x:element-link(../@name, .)'/></td>
              <td><xsl:copy-of select='if (x:lookup-attribute(@name, ../@name, true())/@animatable="yes") then "✓" else ""'/></td>
            </tr>
          </xsl:when>
          <xsl:when test='../self::x:attributecategory'>
            <xsl:variable name='attributecategory' select='..'/>
            <tr>
              <td><xsl:copy-of select='x:attribute-link(@name, $defs/x:element[tokenize(@attributecategories, ", ")=$attributecategory/@name][1]/@name, true(), .)'/></td>
              <td>
                <xsl:for-each select='$defs/x:element[tokenize(@attributecategories, ", ")=$attributecategory/@name]'>
                  <xsl:sort select='@name'/>
                  <xsl:if test='not(position()=1)'>, </xsl:if>
                  <xsl:copy-of select='x:element-link(@name, .)'/>
                </xsl:for-each>
              </td>
              <td><xsl:copy-of select='if (x:lookup-attribute(@name, $defs/x:element[tokenize(@attributecategories, ", ")=$attributecategory/@name][1]/@name, true())/@animatable="yes") then "✓" else ""'/></td>
            </tr>
          </xsl:when>
          <xsl:otherwise>
            <xsl:variable name='attribute-name' select='@name'/>
            <xsl:variable name='element-names' select='if (@elements) then tokenize(@elements, ", ") else ../x:element[tokenize(@attributes, ", ") = $attribute-name]/@name'/>
            <xsl:variable name='element-name' select='$element-names[1]'/>
            <tr>
              <td><xsl:copy-of select='x:attribute-link(@name, $element-name, true(), .)'/></td>
              <td>
                <xsl:for-each select='$element-names'>
                  <xsl:sort select='.'/>
                  <xsl:if test='not(position()=1)'>, </xsl:if>
                  <xsl:copy-of select='x:element-link(., .)'/>
                </xsl:for-each>
              </td>
              <td><xsl:copy-of select='if (x:lookup-attribute(@name, $element-name, true())/@animatable="yes") then "✓" else ""'/></td>
            </tr>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </table>
  </xsl:template>

  <xsl:template match='edit:elementcategory'>
    <xsl:variable name='elementcategory' select='$defs/x:elementcategory[@name=current()/@name]'/>
    <xsl:variable name='all'>
      <xsl:perform-sort>
        <xsl:sort select='string(.)'/>
        <xsl:for-each select='tokenize($elementcategory/@elements, ", ")'>
          <xsl:copy-of select='x:element-link(., $elementcategory)'/>
        </xsl:for-each>
      </xsl:perform-sort>
    </xsl:variable>
    <xsl:for-each select='$all/*'>
      <xsl:if test='position() != 1'>
        <xsl:choose>
          <xsl:when test='position() = last()'> and </xsl:when>
          <xsl:otherwise>, </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
      <xsl:copy-of select='.'/>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match='edit:attributecategory'>
    <xsl:variable name='attributecategory' select='$defs/x:attributecategory[@name=current()/@name]'/>
    <xsl:variable name='all'>
      <xsl:perform-sort>
        <xsl:sort select='string(.)'/>
        <xsl:for-each select='tokenize($attributecategory/@presentationattributes, ", ")'>
          <xsl:copy-of select='x:presentation-attribute-link(., $attributecategory)'/>
        </xsl:for-each>
        <xsl:for-each select='tokenize($attributecategory/@attributes, ", ")'>
          <xsl:copy-of select='x:attribute-link(., (), true(), $attributecategory)'/>
        </xsl:for-each>
        <xsl:for-each select='$attributecategory/x:attribute'>
          <a href="{@href}"><span class="attr-name">‘<xsl:value-of select='@name'/>’</span></a>
        </xsl:for-each>
      </xsl:perform-sort>
    </xsl:variable>
    <xsl:for-each select='$all/*'>
      <xsl:if test='position() != 1'>
        <xsl:choose>
          <xsl:when test='position() = last()'> and </xsl:when>
          <xsl:otherwise>, </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
      <xsl:copy-of select='.'/>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match='edit:elementswithattributecategory'>
    <xsl:variable name='elementswithattributecategory' select='.'/>
    <xsl:for-each select='$defs/x:element[tokenize(@attributecategories, ", ") = current()/@name]'>
      <xsl:if test='position() != 1'>
        <xsl:choose>
          <xsl:when test='position() = last()'> and </xsl:when>
          <xsl:otherwise>, </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
      <xsl:copy-of select='x:element-link(@name, $elementswithattributecategory)'/>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match='*'/>


  <xsl:function name='x:section-number'>
    <xsl:param name='sections'/>
    <xsl:param name='section-id'/>
    <xsl:variable name='e' select='id($section-id, $sections)'/>
    <xsl:if test='$e'>
      <xsl:value-of select='$e/@number'/>
    </xsl:if>
  </xsl:function>

  <xsl:function name='x:section-id' as='xs:string'>
    <xsl:param name='headerElement'/>
    <xsl:value-of select='if ($headerElement/@id) then $headerElement/@id
                          else if ($headerElement/a/@id) then $headerElement/a/@id
                          else if ($headerElement/a/@name) then $headerElement/a/@name
                          else if ($headerElement/preceding-sibling::a[1]/@id) then $headerElement/preceding-sibling::a[1]/@id
                          else $headerElement/preceding-sibling::a[1]/@name'/>
  </xsl:function>

  <xsl:function name='x:lookup-element' as='element()?'>
    <xsl:param name='name'/>
    <xsl:copy-of select='$defs/x:element[@name=$name]'/>
  </xsl:function>

  <xsl:function name='x:lookup-attribute' as='element()?'>
    <xsl:param name='name'/>
    <xsl:param name='element-name'/>
    <xsl:param name='definitely-attribute'/>
    <xsl:variable name='element' select='if ($element-name="") then () else $defs/x:element[@name=$element-name]'/>
    <xsl:variable name='attributes' select='($defs/x:attribute[not(@elements) and @name=$name],
                                             if ($element) then ($element/x:attribute[@name=$name],
                                                                 $defs/x:attributecategory[tokenize($element/@attributecategories, ", ") = @name]/x:attribute[@name=$name],
                                                                 $defs/x:attribute[@name=$name and tokenize(@elements, ", ") = $element-name])
                                                           else ())'/>

    <xsl:variable name='any-attributes' select='if (not($attributes) and ($definitely-attribute or (not($defs/x:element[@name=$name]) and not($defs/x:property[@name=$name])))) then $defs/(x:attributecategory/x:attribute | x:attribute)[@name=$name] else ()'/>
    <xsl:variable name='final-attributes' select='if ($attributes) then $attributes else if (count($any-attributes) = 1) then $any-attributes else ()'/>
    <xsl:choose>
      <xsl:when test='count($final-attributes) > 1'><x:ambiguous/></xsl:when>
      <xsl:when test='count($final-attributes)'><xsl:copy-of select='$final-attributes'/></xsl:when>
    </xsl:choose>
  </xsl:function>

  <xsl:function name='x:lookup-property' as='element()?'>
    <xsl:param name='name'/>
    <xsl:copy-of select='$defs/x:property[@name=$name]'/>
  </xsl:function>

  <xsl:function name='x:attribute-link' as='element()'>
    <xsl:param name='name'/>
    <xsl:param name='element'/>
    <xsl:param name='prefer-attributes'/>
    <xsl:param name='referencing-element'/>
    <xsl:variable name='attribute' select='x:lookup-attribute($name, $element, $prefer-attributes)'/>
    <xsl:variable name='property' select='if ($prefer-attributes and $attribute) then () else x:lookup-property($name)'/>
    <xsl:variable name='title' select='if ($property and not($attribute)) then concat("Presentation attribute for property ‘", $name, "’") else ""'/>
    <xsl:variable name='x' select='($attribute, $property)[1]'/>
    <xsl:choose>
      <xsl:when test='$x/self::x:ambiguous'>
        <xsl:message>Ambiguous attribute "<xsl:value-of select='$name'/>" at <xsl:value-of select="concat(base-uri($referencing-element), ' line ', saxon:line-number())"/>.</xsl:message>
        <a href='data:,' style='background: red; color: white'>@@ ambiguous attribute '<xsl:value-of select='$name'/>'</a>
      </xsl:when>
      <xsl:when test='$x'>
        <a href='{$x/@href}'>
          <xsl:if test='$title != ""'>
            <xsl:attribute name='title'><xsl:value-of select='$title'/></xsl:attribute>
          </xsl:if>
          <span class='attr-name'>
            <xsl:value-of select='concat("‘", $name, "’")'/>
          </span>
        </a>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>Unknown attribute "<xsl:value-of select='$name'/>" at <xsl:value-of select="concat(base-uri($referencing-element), ' line ', saxon:line-number())"/>.</xsl:message>
        <a href='data:,' style='background: red; color: white'>@@ unknown attribute '<xsl:value-of select='$name'/>'</a>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name='x:element-link' as='element()'>
    <xsl:param name='name'/>
    <xsl:param name='referencing-element'/>
    <xsl:variable name='element' select='x:lookup-element($name)'/>
    <xsl:choose>
      <xsl:when test='$element/self::x:ambiguous'>
        <xsl:message>Ambiguous element "<xsl:value-of select='$name'/>" at <xsl:value-of select="concat(base-uri($referencing-element), ' line ', saxon:line-number())"/>.</xsl:message>
        <a href='data:,' style='background: red; color: white'>@@ ambiguous element '<xsl:value-of select='$name'/>'</a>
      </xsl:when>
      <xsl:when test='$element'>
        <a href='{$element/@href}'>
          <span class='element-name'>
            <xsl:value-of select='concat("‘", $name, "’")'/>
          </span>
        </a>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>Unknown element "<xsl:value-of select='$name'/>" at <xsl:value-of select="concat(base-uri($referencing-element), ' line ', saxon:line-number())"/>.</xsl:message>
        <a href='data:,' style='background: red; color: white'>@@ unknown element '<xsl:value-of select='$name'/>'</a>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name='x:property-link' as='element()'>
    <xsl:param name='name'/>
    <xsl:param name='referencing-element'/>
    <xsl:variable name='property' select='x:lookup-property($name)'/>
    <xsl:choose>
      <xsl:when test='$property'>
        <a href='{$property/@href}'>
          <span class='prop-name'>
            <xsl:value-of select='concat("‘", $name, "’")'/>
          </span>
        </a>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>Unknown property "<xsl:value-of select='$name'/>" at <xsl:value-of select="concat(base-uri($referencing-element), ' line ', saxon:line-number())"/>.</xsl:message>
        <a href='data:,' style='background: red; color: white'>@@ unknown property '<xsl:value-of select='$name'/>'</a>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name='x:presentation-attribute-link' as='element()'>
    <xsl:param name='name'/>
    <xsl:param name='referencing-element'/>
    <xsl:variable name='property' select='x:lookup-property($name)'/>
    <xsl:choose>
      <xsl:when test='$property'>
        <a href='{$property/@href}'>
          <span class='attr-name' title='Presentation attribute for property ‘{$name}’'>
            <xsl:value-of select='concat("‘", $name, "’")'/>
          </span>
        </a>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>Presentation attribute for unknown property "<xsl:value-of select='$name'/>" at <xsl:value-of select="concat(base-uri($referencing-element), ' line ', saxon:line-number())"/>.</xsl:message>
        <a href='data:,' style='background: red; color: white'>@@ presentation attribute for unknown property '<xsl:value-of select='$name'/>'</a>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name='x:symbol-link' as='element()'>
    <xsl:param name='name'/>
    <xsl:param name='referencing-element'/>
    <xsl:variable name='symbol' select='$defs/x:symbol[@name=$name]'/>
    <xsl:choose>
      <xsl:when test='not($symbol)'>
        <xsl:message>Unknown grammar symbol "<xsl:value-of select='$name'/>" at <xsl:value-of select="concat(base-uri($referencing-element), ' line ', saxon:line-number())"/>.</xsl:message>
        <a href='data:,' style='background: red; color: white'>@@ unknown symbol '<xsl:value-of select='$name'/>'</a>
      </xsl:when>
      <xsl:otherwise>
        <a href='{$symbol/@href}'>&lt;<xsl:value-of select='$name'/>&gt;</a>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name='x:name-link' as='element()'>
    <xsl:param name='name'/>
    <xsl:param name='context-element'/>
    <xsl:param name='referencing-element'/>
    <xsl:variable name='element' select='x:lookup-element($name)'/>
    <xsl:variable name='attribute' select='x:lookup-attribute($name, $context-element, false())'/>
    <xsl:variable name='property' select='x:lookup-property($name)'/>
    <xsl:variable name='all' select='($element, $property, $attribute)'/>
    <xsl:choose>
      <xsl:when test='$all/self::x:ambiguous or count($all) &gt; 1'>
        <xsl:message>Ambiguous name "<xsl:value-of select='$name'/>" at <xsl:value-of select="concat(base-uri($referencing-element), ' line ', saxon:line-number())"/>.</xsl:message>
        <a href='data:,' style='background: red; color: white'>@@ ambiguous name '<xsl:value-of select='$name'/>'</a>
      </xsl:when>
      <xsl:when test='not($all)'>
        <xsl:message>Unknown name "<xsl:value-of select='$name'/>" at <xsl:value-of select="concat(base-uri($referencing-element), ' line ', saxon:line-number())"/>.</xsl:message>
        <a href='data:,' style='background: red; color: white'>@@ unknown name '<xsl:value-of select='$name'/>'</a>
      </xsl:when>
      <xsl:otherwise>
        <a href='{$all/@href}'>
          <span class='{if ($element) then "element" else if ($attribute) then "attr" else "prop"}-name'>
            <xsl:value-of select='concat("‘", $name, "’")'/>
          </span>
        </a>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name='x:interface-link' as='element()'>
    <xsl:param name='name'/>
    <xsl:param name='referencing-element'/>
    <xsl:variable name='interface' select='$defs/x:interface[@name=$name]'/>
    <xsl:choose>
      <xsl:when test='$interface'>
        <a class='idlinterface' href='{$interface/@href}'>
          <xsl:value-of select='$name'/>
        </a>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>Unknown interface "<xsl:value-of select='$name'/>" at <xsl:value-of select="concat(base-uri($referencing-element), ' line ', saxon:line-number())"/>.</xsl:message>
        <a href='data:,' style='background: red; color: white'>@@ unknown interface '<xsl:value-of select='$name'/>'</a>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:key name='key-element' match='x:element' use='@name'/>
  <xsl:key name='key-elementcategory' match='x:elementcategory' use='@name'/>
  <xsl:key name='key-attribute' match='x:definitions/x:attribute' use='@name'/>
  <xsl:key name='key-attributecategory' match='x:attributecategory' use='@name'/>
  <xsl:key name='key-property' match='x:property' use='@name'/>
  <xsl:key name='key-interface' match='x:interface' use='@name'/>
  <xsl:key name='key-symbol' match='x:symbol' use='@name'/>
  <xsl:key name='key-term' match='x:term' use='@name'/>

  <xsl:function name='x:collate-defs' as='node()'>
    <xsl:param name='currentdoc' as='node()'/>
    <xsl:param name='resultdoc' as='node()'/>
    <xsl:param name='base'/>
    <xsl:variable name='newresultdoc'>
      <xsl:document>
        <x:definitions>
          <xsl:copy-of select='$resultdoc/*/*'/>
          <xsl:for-each select='$currentdoc/*/*[not(self::x:import) and not(key(concat("key-", local-name(.)), @name, $resultdoc))]'>
            <xsl:copy>
              <xsl:copy-of select='@*[local-name() != "href" and namespace-uri() = ""]'/>
              <xsl:if test='@href'>
                <xsl:attribute name='href' select='if ($base = "") then @href else resolve-uri(@href, $base)'/>
              </xsl:if>
              <xsl:copy-of select='node()'/>
            </xsl:copy>
          </xsl:for-each>
        </x:definitions>
      </xsl:document>
    </xsl:variable>
    <xsl:copy-of select='x:collate-defs-import($newresultdoc, $currentdoc/*/x:import)'/>
  </xsl:function>

  <xsl:function name='x:collate-defs-import' as='node()'>
    <xsl:param name='currentdoc' as='node()'/>
    <xsl:param name='imports' as='element()*'/>
    <xsl:choose>
      <xsl:when test='$imports'>
        <xsl:copy-of select='x:collate-defs-import(x:collate-defs(document($imports[1]/@definitions),
                                                                  $currentdoc,
                                                                  if ($maturity = "ED" and $imports[1]/@cvs-href) then $imports[1]/@cvs-href else $imports[1]/@href), subsequence($imports, 2))'/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select='$currentdoc'/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
</xsl:stylesheet>
