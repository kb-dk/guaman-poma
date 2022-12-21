# How to build Guaman Poma Website

I did successfully build and deploy this site December 21 2022, using

```
Apache Maven 3.6.3
Maven home: /usr/share/maven
Java version: 11.0.17, vendor: Ubuntu, runtime: /usr/lib/jvm/java-11-openjdk-amd64
Default locale: en_US, platform encoding: UTF-8
OS name: "linux", version: "5.15.0-56-generic", arch: "amd64", family: "unix"

```


## Preamble

You start by compiling the Lucene indexer. It lives in the directory `xslt-indexer`. Make

```
cd xslt-indexer
mvn install

```

After successful build there should be a file called `xslt-indexer-1.0.jar`. It is used to build the Lucene index used in the service.

The build seems to require `java 8`. The indexer is used only while building the app.

## Build the actual content

The data files lives in `poma-source`

Go there

### A. `poma-source` directories contain

1. The source files needed to build the web edition of Guaman Poma, Nueva corónica y buen gobierno (1615). The source files consists of

```
      tei/Poma-parsed.xml
      poma-mets.xml
      toc.xml.en
      toc.xml.es
      tables-of-images.xml
      manus-page-id.xml
```
2. The actual machinery for presenting the content, which is mostly written in xslt. Most important is

```
       make-page.xsl
```

3. Various scripts, build.sh and xslt-scripts, which generates the actual service contents.

4. Related information of different kinds situated in

```
      www-pages
```

### B. How to build

After revisions of whatever in A, just run build.sh

## Build web application

Just run maven in this directory

```
mvn install

```

After build, the web site should be a in a single war file in target.

```
guaman-poma/trunk$ ls -l  target
total 85888
drwxrwxr-x 3 slu slu     4096 Dec 21 08:51 classes
drwxrwxr-x 3 slu slu     4096 Dec 21 08:51 generated-sources
drwxrwxr-x 6 slu slu     4096 Dec 21 08:51 guaman-poma-1.0-SNAPSHOT
-rw-rw-r-- 1 slu slu 87927487 Dec 21 08:54 guaman-poma-1.0-SNAPSHOT.war
drwxrwxr-x 2 slu slu     4096 Dec 21 08:51 maven-archiver

```

Copy the `guaman-poma-1.0-SNAPSHOT.war` to a servlet container near
you, renaming it to guaman-poma.war.  Install the
`apache-httpd/permalink.conf` in the corresponding httpd customized
for you needs and you are done.

If you deploy it on your local machine, you will find it on

```
http://localhost/permalink/2006/poma/info/en/frontpage.htm

```

