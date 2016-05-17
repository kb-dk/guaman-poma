#!/bin/sh

DEST="../src/main/webapp/data"

# xsltproc images-generator.xsl poma-mets.xml

xsltproc --param lang "'en'" --param mode "'text'" create-html-list.xsl  \
    toc.xml.en > toc.html.en

xsltproc --param lang "'es'" --param mode "'text'" create-html-list.xsl  \
    toc.xml.es > toc.html.es

xsltproc --param lang "'en'" --param mode "'image'" create-html-list.xsl  \
    table-of-images.xml.en > table-of-images.html.en

xsltproc --param lang "'es'" --param mode "'image'" create-html-list.xsl  \
    table-of-images.xml.es > table-of-images.html.es

xsltproc render-pages.xsl tei/Poma-parsed.xml

mkdir -p "$DEST"
cp -r images pages www-files $DEST
cp  toc.html.en toc.html.es  table-of-images.html.en table-of-images.html.es "$DEST"
cp  make-page.xsl $DEST


