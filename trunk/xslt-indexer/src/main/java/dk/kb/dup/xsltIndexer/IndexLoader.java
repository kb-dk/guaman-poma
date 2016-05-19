package dk.kb.dup.xsltIndexer;

import java.io.*;
import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.Iterator;
import org.apache.lucene.analysis.Analyzer;
import org.apache.lucene.analysis.SimpleAnalyzer;
import org.apache.lucene.analysis.WhitespaceAnalyzer;
import org.apache.lucene.index.IndexReader;
import org.apache.lucene.index.IndexWriter;
import org.apache.lucene.document.*;
import org.apache.lucene.search.*;
import org.apache.lucene.queryParser.QueryParser;
import java.io.IOException;
import org.apache.lucene.search.Searcher;
import org.w3c.dom.traversal.NodeIterator;
import org.w3c.dom.Node;
import org.w3c.dom.Element;
import org.w3c.dom.Document;
import org.apache.xerces.dom.DocumentImpl;
import org.apache.xml.serialize.OutputFormat;
import org.apache.xml.serialize.Serializer;
import org.apache.xml.serialize.SerializerFactory;
import org.apache.xml.serialize.XMLSerializer;

/**
 * This class is the glue between the Xalan XSLT processor and Lucene. The various
 * methods of the class are used as function inside the XSLT script which makes the
 * actual job.
 * 
 * @author Sigfrid Lundberg (slu@kb.dk)
 * 
 * @version Last $Revision: 1.20 $ $Date: 2010/06/23 09:26:33 $ 
 * by $Author: slu $. Current checkout was made as build $Name:  $ 
 * 
 */
public class IndexLoader
{

    private int debuglevel         = 0;
    private Analyzer analyzer      = null;
    private IndexWriter writer     = null;
    private IndexReader reader     = null;
    private org.apache.lucene.document.Document luceneDoc     = null;
    
    private String indexing_mode   = "";
    private String index_directory = "";
  
    public IndexLoader() {

    }
  
    /**
     * This method used to open a Lucene index in the directory given by 
     * --update or --create options in the command line.
     * The method will at some later time be deprecated, since this is now
     * done in the Driver class.
     */
    private void index_opener() {
	if(this.indexing_mode.equalsIgnoreCase("create")) {
	    this.writeDebug("create index in " + this.index_directory + "\n",0);
	} else {
	    this.writeDebug("update index in " + this.index_directory + "\n",0);
	}  
/*	try {
	    this.writer = new IndexWriter(this.index_directory,
					  this.analyzer,
					  this.indexing_mode.equalsIgnoreCase("create"));
	}
	catch(IOException e) 
	{
	    e.printStackTrace();
	    }*/
    }
  
    /**
     * This method tells the IndexLoader to open an index using a given
     * mode (update or create) in the directory given as an argument
     * either of the --update or --create in the command line. debug is
     * the debug level (currently 0,1,2,3).
     * The method used to instantiates a Lucene Analyzer.
     * This is now done in the Driver class (currently it is a SimpleAnalyzer):
     * @param debug
     * @param directory
     * @param mode
     */
    public void open_index(String mode, String directory, String debug) {
	this.debuglevel      = Integer.parseInt(debug);
/*	this.analyzer        = new SimpleAnalyzer();*/
	this.index_directory = directory;
	this.indexing_mode   = mode;     
    }

    public void setAnalyzer(Analyzer analyzer) {
	this.analyzer        = analyzer;
    }
   
    /**
     * Creates a new Lucene document. All subsequent calls to the
     * add_field method will refer to this document.  See Lucene <a
     * href="http://lucene.apache.org/java/docs/api/org/apache/lucene/document/Document.html">Document</a>
     * javadoc
     */
    public void open_document() {
	if(this.writer == null) {
	    this.index_opener();
	}
	this.luceneDoc = new  org.apache.lucene.document.Document();
	this.writeDebug("Open new document\n",1);
    }
  
    /**
     * <p>This is the real work horse of the IndexLoader. It adds
     * "value" to "field".</p>
     * 
     * <p>Lucene stores it (for retrieval purposes) if storeField is
     * anything but store.no (typically store.yes) for the readability
     * of the XSL. Please refer to <a
     * href="http://lucene.apache.org/java/docs/api/org/apache/lucene/document/Field.Store.html">Field.Store</a>
     * in the Lucene javadoc.</p>
     * 
     * <p>The field may be indexed for searching purposes depending on
     * the indexField parameter.  It may take any of the following four
     * values: "tokenized" (the default), "index.no", "un_tokenized" and
     * "no_norms". "index.no" would be used for data which shouldn't be
     * used for searching but still are useful for presentation
     * purposes. "tokenized" splits the text in tokens (typically words)
     * that may be searched individually or as strings. "un_tokenized"
     * is used when the text should be searched as a string only.  This
     * is the case for a record ID. Please refer to <a
     * href="http://lucene.apache.org/java/docs/api/org/apache/lucene/document/Field.Index.html">Field.Index</a>
     * in the Lucene javadoc.</p>
     * 
     * @param indexField
     * @param storeField
     * @param value
     * @param field
     */
    public void add_field(String field, 
                          String value, 
                          String storeField, 
                          String indexField) {
     
	Field.Store store = Field.Store.YES;                     
	if(storeField.equalsIgnoreCase("store.no")) {
	    store = Field.Store.NO;
	}
     
	Field.Index index = Field.Index.ANALYZED;
	if(indexField.equalsIgnoreCase("index.no")) {
	    index = Field.Index.NO;
	} else if(indexField.equalsIgnoreCase("no_norms")) {
	    index = Field.Index.ANALYZED_NO_NORMS;
	} else if(indexField.equalsIgnoreCase("un_tokenized")) {
	    index = Field.Index.NOT_ANALYZED;
	}
     
	this.luceneDoc.add(new Field(field,
				     value,
				     store,
				     index)); 
     
	this.writeDebug("\tadd field:" + field + "\n",2);
	this.writeDebug("\t    value: " + value + "\n",2);
	this.writeDebug("\t    store: " + storeField + "\n",2);
	this.writeDebug("\t    index: " + indexField + "\n",2);
    
    }

    /**
     * Similar to add_field, but instead of accepting a text field as arguement it takes
     * a XSLT node-set. It means that you may store XML fragments taken from the source document
     * in the lucene index for presentation purposes.
     *
     * <p>All nodes in a node set are copied to a new XML document having the root element
     * &lt;fragment> ... &lt;/fragment>
     *
     * @param indexField
     * @param storeField
     * @param valueIterator
     * @param field
     *
     */
    public void add_xml_field(String field, 
			      NodeIterator valueIterator, 
			      String storeField, 
			      String indexField) {
	try {
	    this.writeDebug("\tadd xml field:" + field + "\n",2);
	    org.w3c.dom.Document w3doc        = new DocumentImpl(true);
	    org.w3c.dom.Element  rootElement  = w3doc.createElement("fragment");
	    w3doc.appendChild(rootElement);

	    Node value = valueIterator.nextNode();

	    while(value != null) {
		Node kid =  w3doc.importNode(value,true);
		if(kid != null) {
		    rootElement.appendChild(kid);
		}
		value = valueIterator.nextNode();
	    }

	    OutputFormat  format    = new OutputFormat( w3doc );  
	    StringWriter  stringOut = new StringWriter();         
	    XMLSerializer serial    = new XMLSerializer( stringOut, format );
	    serial.asDOMSerializer();                             
	    serial.serialize( w3doc.getDocumentElement() );
	    this.add_field(field,stringOut.toString(),storeField,indexField);
	
	} catch ( Exception ex ) {
            ex.printStackTrace();
        }

    }
    
    /**
     * Closes the current Lucene document. I.e., the Lucene will add it to the index.
     */
    public void close_document() {
	try {
	    this.writer.addDocument(this.luceneDoc);
	}
	catch(IOException e) 
	{
	    e.printStackTrace();
	}
	this.writeDebug("close document\n",1);
    }
  
    /**
     * This method used to close the index and optimize it. These functions have
     * moved to the driver class, and the method will be deprecated in some future
     * version of this software.
     */
    public void close_index() {
     /*	try {
	    writer.optimize();
	    writer.close();
	}
	catch(java.io.IOException e)
	{
	    e.printStackTrace();
	}*/
	this.writeDebug("closing index\n",0);
    }
  
    private void writeDebug(String msg,int lvl) {  
	if((int)this.debuglevel > lvl) 
	{
	    System.err.print(msg);
	}
    }

    /**
     * @param IndexReader reader
     * the IndexReader is now instantiated in the Driver, and is passed to us 
     * Xalan. This gives us a tremendous performance boost.
     */
    public void setIndexReader(IndexReader reader) {
	this.reader = reader;
    }

    /**
     * @param IndexWriter writer
     * the IndexWriter is now instantiated in the Driver, and is passed to us 
     * Xalan. This gives us a tremendous performance boost.
     */
    public void setIndexWriter(IndexWriter writer) {
	this.writer = writer;
    }
  
    /**
     * Deletes all Lucene documents in the index which have "dataSourceId" stored in
     * "dataSourceField".
     * @param dataSourceId
     * @param dataSourceField
     */
    public void delete_documents(String dataSourceField, String dataSourceId) {
   
	try{

	    org.apache.lucene.index.Term matchTerm = 
		new org.apache.lucene.index.Term(dataSourceField,dataSourceId);

	    org.apache.lucene.index.TermDocs termdocs =
		this.reader.termDocs(matchTerm);

	    int count = 0;
	    while(termdocs.next()) {
		this.reader.deleteDocument(termdocs.doc());
		count++;
	    }

	    //	    this.reader.commit(); // javac claims that this method
	    //      doesn't exist

	    this.writeDebug("deleted " + count + 
			    " records from source "+ dataSourceId + "\n",0);

	} catch (Exception e) {
	    System.err.println("deleteDocument caught: " + e.toString());
	}
    }
   
    /**
     * @param String str Any string you want to URI encode
     * @return URI encoded string. The java.net.URLEncoder is much better than the one built into most exslt compatible xslt processors.
     */
    public String encode_uri(String str) {
	String estr = "";
	try {
	    estr = URLEncoder.encode(str,"UTF-8");
	}
	catch(UnsupportedEncodingException e) {
	    System.err.println(e.getMessage());
	}
	return estr;
    }
}

/*
 * $Log: IndexLoader.java,v $
 * Revision 1.20  2010/06/23 09:26:33  slu
 * the only file that I had to edit
 *
 * Revision 1.19  2010/06/18 14:42:59  slu
 * this is for lucene 3.0.1
 *
 * Revision 1.18  2009/01/20 09:40:58  slu
 * trying to rewrite this to java class proper (which can be used from inside other software)
 *
 * Revision 1.17  2007/04/30 12:35:05  slu
 * The add_xml_field method works now, after too many hours work.
 *
 * Revision 1.16  2007/04/25 14:30:09  slu
 * add_xml_field implemented. If it works is another issue. That is, it
 * is an empirical problem.
 *
 * Revision 1.15  2007/04/23 09:43:05  slu
 * Now the code compiles as well as being more efficient...
 *
 * Revision 1.14  2007/04/23 09:39:55  slu
 * Now with documentation of the last revision, in which the
 * instantiation of the reader, writer and analyzer is done in the Driver
 * class rather than here. (Since it was done for each document, it
 * caused a tremendous overhead and a very poor performance for large
 * collections of documents).
 *
 * Revision 1.13  2007/04/13 08:12:40  slu
 * Changed the communication between the Driver and the IndexLoader, such
 * that the lucene IndexReader and IndexWriter objects are created in the
 * Driver and passed to the IndexLoader via Xalan transformer
 * setParameter method.
 *
 * Revision 1.12  2007/02/21 09:15:03  slu
 * Now with fairly detailed javadoc
 *
 * Revision 1.11  2007/02/06 13:47:05  slu
 * Incremental indexing now working
 *
 * Revision 1.10  2007/02/02 15:34:05  slu
 * [no comments]
 *
 * Revision 1.9  2007/02/02 15:24:07  slu
 * Rewritten some code, e.g., added a private method that actually instantiates the index writer after the deletion method has been invoked.
 *
 * Revision 1.8  2007/02/02 14:35:29  slu
 * Log cosmetics
 *
 * Revision 1.7  2007/02/02 14:24:19  slu
 * Added logging from on record deletion
 *
 * Revision 1.6  2007/02/02 13:39:04  slu
 * Implemented deletion of records based on a datasource field
 *
 * Revision 1.5  2007/02/02 12:08:34  slu
 * Streamlined the open index method
 *
 * Revision 1.4  2007/02/02 09:22:50  slu
 * Improved log file lay-out
 *
 * Revision 1.3  2007/02/02 08:56:25  slu
 * The indexer is fully operational
 *
 * Revision 1.2  2007/01/30 14:45:23  slu
 * This is as yet a mere skeleton
 *
 */
