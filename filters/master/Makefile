# Makefile for SVG Filters.

TOOLS=../../../../SVG/tools

# include $(TOOLS)/common.mk

all : svgfilters.idlx SVGFilterReqs.html SVGFilterPrimer.html SVGFilter.html definitions.xml definitions-primer.xml publish-reqs.xml publish-primer.xml publish.xml $(TOOLS)/publish.xsl
	java -classpath $(TOOLS)/saxonb/saxon9.jar net.sf.saxon.Transform -ext:on -dtd:off -expand:off publish-reqs.xml $(TOOLS)/publish.xsl
	java -classpath $(TOOLS)/saxonb/saxon9.jar net.sf.saxon.Transform -ext:on -dtd:off -expand:off publish-primer.xml $(TOOLS)/publish.xsl
	java -classpath $(TOOLS)/saxonb/saxon9.jar net.sf.saxon.Transform -ext:on -dtd:off -expand:off publish.xml $(TOOLS)/publish.xsl

svgfilters.idlx : svgfilters.idl
	java -classpath $(TOOLS)/idlparser/idlparser.jar au.id.mcc.idlparser.IDLToXML svgfilters.idl > svgfilters.idlx
