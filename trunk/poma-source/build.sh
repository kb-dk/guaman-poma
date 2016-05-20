#!/bin/sh

DEST="../src/main/webapp/data"
WEBINF="../src/main/webapp/WEB-INF"

# xsltproc images-generator.xsl poma-mets.xml

xsltproc --param lang "'en'" --param mode "'text'" create-html-list.xsl  \
    toc.xml.en > toc.html.en

xsltproc --param lang "'es'" --param mode "'text'" create-html-list.xsl  \
    toc.xml.es > toc.html.es

xsltproc --param lang "'en'" --param mode "'image'" create-html-list.xsl  \
    table-of-images.xml.en > table-of-images.html.en

xsltproc --param lang "'es'" --param mode "'image'" create-html-list.xsl  \
    table-of-images.xml.es > table-of-images.html.es

xsltproc images-generator.xsl  poma-mets.xml
xsltproc render-pages.xsl tei/Poma-parsed.xml

rm    -rf "$WEBINF/poma_index"  
mkdir  -p "$WEBINF/poma_index"  

../xslt-indexer/scripts/xsl_index  \
    -x ../xslt-indexer/xslt/tei2lucene.xsl \
    -c "$WEBINF/poma_index"  \
    -d ./tei/Poma-parsed.xml -v 3

# ../xslt-indexer/scripts/xsl_index  \
#    -x ../xslt-indexer/xslt/tei2lucene.xsl \
#    -u "$WEBINF/poma_index"  \
#    -d ./tei/Poma-parsed.xml -v 0

mkdir -p $DEST

cp -r images pages www-files $DEST
cp  toc.html.en toc.html.es  table-of-images.html.en table-of-images.html.es "$DEST"
cp table-of-images.xml.en "$DEST/table-of-images.en.xml"
cp table-of-images.xml.es "$DEST/table-of-images.es.xml"
cp toc.xml.en "$DEST/toc.en.xml"
cp toc.xml.es "$DEST/toc.es.xml"

cp  make-page.xsl $DEST


