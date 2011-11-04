# Makefile for Filters.

TOOLS=tools

# include $(TOOLS)/common.mk

# Previous build command that did everything
# all : filters.idlx SVGFilterReqs.html SVGFilterPrimer.html Filters.html definitions.xml definitions-primer.xml publish-reqs.xml publish-primer.xml publish.xml $(TOOLS)/publish.xsl
# java -classpath $(TOOLS)/saxon9.jar net.sf.saxon.Transform -ext:on -dtd:off -expand:off publish-reqs.xml $(TOOLS)/publish.xsl
# java -classpath $(TOOLS)/saxon9.jar net.sf.saxon.Transform -ext:on -dtd:off -expand:off publish-primer.xml $(TOOLS)/publish.xsl
# java -classpath $(TOOLS)/saxon9.jar net.sf.saxon.Transform -ext:on -dtd:off -expand:off publish.xml $(TOOLS)/publish.xsl

all : filters.idlx Filters.html definitions.xml definitions-primer.xml publish.xml $(TOOLS)/publish.xsl ../publish/ChangeLog
	java -classpath $(TOOLS)/saxon9.jar net.sf.saxon.Transform -ext:on -dtd:off -expand:off publish.xml $(TOOLS)/publish.xsl

filters.idlx : filters.idl
	java -classpath $(TOOLS)/idlparser.jar au.id.mcc.idlparser.IDLToXML filters.idl > filters.idlx

../publish/ChangeLog: ChangeLog
	/bin/cp ChangeLog ../publish/ChangeLog
