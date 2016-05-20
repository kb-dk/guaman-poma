package dk.kb.dup.xsltIndexer;

import java.io.*;
import java.text.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import org.apache.lucene.analysis.SimpleAnalyzer;
import org.apache.lucene.index.IndexReader;
import org.apache.lucene.index.IndexWriter;
import org.dom4j.Document;
import org.dom4j.DocumentException;
import org.dom4j.Element;
import org.dom4j.Namespace;
import org.dom4j.Node;
import org.dom4j.QName;
import org.dom4j.DocumentHelper;
import org.dom4j.dom.DOMDocument;
import org.dom4j.dom.DOMElement;
import org.dom4j.io.SAXReader;
import org.dom4j.io.DocumentSource;
import org.dom4j.io.DocumentResult;
import org.dom4j.io.OutputFormat;
import org.dom4j.io.XMLWriter;
import gnu.getopt.*;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.stream.StreamSource;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerException;
import org.apache.xalan.processor.TransformerFactoryImpl;


/**
  * This is a utility for indexing XML documents, using the Xalan XSLT processor
  * with java extensions, such that text is added to a Lucene index 
  * (http://lucene.apache.org/) through XSLT functions defined in Java.
  * 
  * @author Sigfrid Lundberg (slu@kb.dk)
  * 
  * @version Last $Revision: 1.16 $ $Date: 2010/06/18 14:42:59 $ 
  * by $Author: slu $. Current checkout was made as build $Name:  $ 
  */
public class Driver 
{
    String dataSourceField = "data_source_identifier";
  
    public Driver()
    {
    }
  
    /**
     * Most of the processing takes place in the main method.
     * 
     * @throws java.io.IOException
     * @param args
     */
    public static void main(String[] args) throws IOException, FileNotFoundException
    {
     
	LongOpt[] options = new LongOpt[7];
     
	StringBuffer sb = new StringBuffer();
	options[0] = new LongOpt("help",     LongOpt.NO_ARGUMENT,        null, 'h');
	options[1] = new LongOpt("xslt",     LongOpt.REQUIRED_ARGUMENT,  sb,   'x'); 
	options[2] = new LongOpt("create",   LongOpt.REQUIRED_ARGUMENT,  sb,   'c');
	options[3] = new LongOpt("update",   LongOpt.REQUIRED_ARGUMENT,  sb,   'u');
	options[4] = new LongOpt("datafile", LongOpt.REQUIRED_ARGUMENT,  sb,   'd'); 
	options[5] = new LongOpt("source",   LongOpt.REQUIRED_ARGUMENT,  sb,   's');  
	options[6] = new LongOpt("verbose",  LongOpt.REQUIRED_ARGUMENT,  sb,   'v');
     
	String xslt        = "";
	String indexdir    = "";
	String datafile    = "";
	String source      = "";
	String mode        = "";
	String recordsfile = "";
	String verbose     = "0";
     
	String sorry = "Sorry, but something is wrong with your command line\n";
	char   opt; 
	int c;
	Getopt g   = new Getopt("xslt_indexer",args,"hx:c:u:d:s:v:",options);
     
	while( (c = g.getopt()) != -1) {
        
	    switch(c) {
		case 0:   opt = (char)(new Integer(sb.toString())).intValue();
                    String val = g.getOptarg();
                    System.out.println(opt + " " + val);
                    if(opt == 'x') {
                      xslt     = val;
                    } else if (opt == 'c') {
                      indexdir = val;
                      mode     = "create";
                    } else if (opt == 'u') {
                      indexdir = val;
                      mode     = "update";
                    } else if (opt == 'd') {
                      datafile = val;
		    } else if (opt == 's') {
                      source   = val;
                    } else if (opt == 'v') {
                      verbose  = val;                      
                    } else if (opt == 'h') {
                      System.out.println(message());
                      System.exit(0);
                    } else {
                      System.out.println(sorry + message());
                      System.exit(0);
                    }                   
                    break;
	    case 'h': System.out.println(message());
		System.exit(0);
	    case 'x': xslt       = g.getOptarg();
		System.out.println(xslt);
		break;
	    case 'c': indexdir   = g.getOptarg();
		mode = "create";
		System.out.println(indexdir);
		break;
	    case 'u': indexdir   = g.getOptarg();
		mode = "update";
		System.out.println(indexdir);
		break;          
	    case 'd': datafile   = g.getOptarg();
		System.out.println(datafile);
		break; 
	    case 's': source     = g.getOptarg();
		System.out.println(source);
		break; 
	    case 'v': verbose    = g.getOptarg();
		System.out.println(verbose);
		break;                
	    case '?': System.err.println(sorry + message());
		System.exit(1);
	    }
	}
     
	if(xslt.equalsIgnoreCase("")     || 
	   indexdir.equalsIgnoreCase("") || mode.equalsIgnoreCase("")) {
	    String look_at = "Look at -x, -c or -u options\n";
	    System.err.println(sorry + look_at + message());
	    System.exit(1);
	}

	if( !(
	      (datafile.equalsIgnoreCase("")  && !source.equalsIgnoreCase("") )
	      ||
	      (!datafile.equalsIgnoreCase("") && source.equalsIgnoreCase("")))
            ) {
	    String look_at = "Look at -s or -d options\n";
	    System.err.println(sorry + look_at + message());
	    System.exit(1);
	}

	Driver driver = new Driver();

	driver.go(xslt,indexdir,datafile,source,mode,recordsfile,verbose);
    }

    public void go(String xslt,
		   String indexdir,
		   String datafile,
		   String source,
		   String mode,
		   String recordsfile,
		   String verbose)  throws IOException, FileNotFoundException {

	TransformerFactory factory = new TransformerFactoryImpl();
	Transformer transformer = null;
	try {
	    transformer = factory.newTransformer(new StreamSource(xslt));
	} 
	catch(TransformerConfigurationException e) {
	    e.printStackTrace();
	}
	IndexReader reader = null;
	IndexWriter writer = null;

	org.apache.lucene.store.Directory directory = 
	    new org.apache.lucene.store.SimpleFSDirectory(new java.io.File(indexdir));
	    

	if(transformer != null) {
	    SimpleAnalyzer analyzer        = new SimpleAnalyzer();
	    transformer.setParameter("analyzer",analyzer);
	    try {
		writer = new IndexWriter(directory,
					 analyzer,
					 mode.equalsIgnoreCase("create"),
					 org.apache.lucene.index.IndexWriter.MaxFieldLength.UNLIMITED);
		writer.commit();
		transformer.setParameter("writer",writer);
	    }
	    catch(IOException e) 
	    {
		e.printStackTrace();
	    }
	    try{
		reader   = IndexReader.open(directory);
		transformer.setParameter("reader",reader);
	    }
	    catch(Exception e) {
		e.printStackTrace();
	    }
	}


	BufferedReader in = null;
	if(source.equalsIgnoreCase("")) {
	    if(datafile.equalsIgnoreCase("-")) {
		in = new BufferedReader (new InputStreamReader (System.in));
		if(in != null && transformer != null) {
		    String line ="";
		    int counter = 1;
		    while((line = in.readLine()) != null) {
			runXslt(mode,
				this.dataSourceField,
				indexdir,
				verbose,
				counter,
				transformer,
				line);
			counter++;
		    }
		    if(writer != null) {
			writer.optimize();
			writer.close();
		    }
		}     
	    } else {
		int counter = 1;
		runXslt(mode,
			this.dataSourceField,
			indexdir,
			verbose,
			counter,
			transformer,
			datafile);
		if(writer != null) {
		    writer.optimize();
		    writer.close();
		}
	    }
	} else {
	    if(source.equalsIgnoreCase("-")) {
		in = new BufferedReader(new InputStreamReader(System.in));
	    } else {
		FileReader fread = new FileReader(source);
		in = new BufferedReader(fread);
	    }
	    if(in != null && transformer != null) {
		String line ="";
		int counter = 1;
		while((line = in.readLine()) != null) {
		    runXsltTransformString(mode,
					   dataSourceField,
					   indexdir,
					   verbose,
					   counter,
					   transformer,
					   line);
		    counter++;
		}
		if(writer != null) {
		    writer.optimize();
		    writer.close();
		}
	    } 
	}
    }

    private static void runXslt(String mode,
			String dataSourceField,
			String indexdir,
			String verbose,
			int    counter,
			Transformer transformer,
			String xml_file_name) throws FileNotFoundException {

	File xmlfile = new File(xml_file_name);
	InputStreamReader inreader =
	    new InputStreamReader(new FileInputStream(xmlfile));
	org.dom4j.Document xdoc = null;       
	SAXReader xmlreader = new SAXReader();
	try {
	    xdoc = xmlreader.read(inreader);
	}
	catch(DocumentException e) {
	    e.printStackTrace();
	}
        
	DocumentSource source = new DocumentSource(xdoc);
	DocumentResult result = new DocumentResult();
	if(counter==1) {
	    transformer.setParameter("mode",mode);
	} else {
	    transformer.setParameter("mode","update");
	}
 
	transformer.setParameter("datasource",xml_file_name);
	transformer.setParameter("sourcefield",dataSourceField);
	transformer.setParameter("index_directory",indexdir);
	transformer.setParameter("debug_level",verbose);
	try {
	    transformer.transform(source,result); 
	}
	catch(TransformerException e) {
	    e.printStackTrace();
	}           
    }

    private static void runXsltTransformString(String mode,
			String dataSourceField,
			String indexdir,
			String verbose,
			int    counter,
			Transformer transformer,
			String xml_document) {

	org.dom4j.Document xdoc = null;       
	try {
	    xdoc = DocumentHelper.parseText(xml_document);
	}
	catch(DocumentException e) {
	    e.printStackTrace();
	}
        
	DocumentSource source = new DocumentSource(xdoc);
	DocumentResult result = new DocumentResult();
	if(counter==1) {
	    transformer.setParameter("mode",mode);
	} else {
	    transformer.setParameter("mode","update");
	}
 
	transformer.setParameter("datasource","");
	transformer.setParameter("sourcefield",dataSourceField);
	transformer.setParameter("index_directory",indexdir);
	transformer.setParameter("debug_level",verbose);
	try {
	    transformer.transform(source,result); 
	}
	catch(TransformerException e) {
	    e.printStackTrace();
	}           
    }
    
  /**
   * Usage message for the main method of the class Driver
   * @return usage message
   */
   static String message() {
   
    return 
    "\nUsage:\n"+
    "-h or --help:                       Print this message\n"+
    "-x or --xslt     <xsl transform>:   A XSLT script performing the indexing\n"+
    "-c or --create   <index directory>: The directory where Lucene should\n" +
    "                                    create a new index\n"+
    "-u or --update   <index directory>: The directory where Lucene should\n" +
    "                                    update an existing index\n" +
    "-d or --datafile <file name>:       The name of an XML file to be indexed.\n" +
    "                                    If a - is given as argument, the\n" +
    "                                    program assumes that a list of file\n" +
    "                                    names can be read from STDIN.\n" +
    "-s or --source <file name>:         Similar to -d but instead of containing a\n" + 
    "                                    single XML object file is supposed to\n" +
    "                                    contain one single XML document per line\n" +
    "                                    as a single string. If the argument is -,\n" +
    "                                    these XML objects are read from STDIN.\n" +
    "-v or --verbose <verbosity>:        verbosity (debug level) 1, 2 or 3\n" +
    "                                    The log is written to STDERR. You will\n" +
    "                                    redirect to file yourself\n" +
    "\nAll files and directory should be given with complete path\n";
   
   }


}

/*
 * $Log: Driver.java,v $
 * Revision 1.16  2010/06/18 14:42:59  slu
 * this is for lucene 3.0.1
 *
 * Revision 1.15  2008/04/02 12:26:39  slu
 * Starting to split up the main method, in order to make it possible to
 * use the xslt_indexer as an API
 *
 * Revision 1.14  2007/04/25 14:47:55  slu
 * Corrected the usage message, which was erroneous for the case
 * --datafile <file name> was given
 *
 * Revision 1.13  2007/04/13 08:13:05  slu
 * Changed the communication between the Driver and the IndexLoader, such
 * that the lucene IndexReader and IndexWriter objects are created in the
 * Driver and passed to the IndexLoader via Xalan transformer
 * setParameter method.
 *
 * Revision 1.12  2007/03/02 12:09:36  slu
 * Typographic improvements
 *
 * Revision 1.11  2007/03/02 08:45:07  slu
 * Fixed brief Getopt string
 *
 * Revision 1.10  2007/03/01 15:15:31  slu
 * Can now run single XML files with longOpt. Short options still buggy
 *
 * Revision 1.9  2007/02/21 10:43:35  slu
 * Removed some import statements that were not needed. The list has been
 * automatically generated by jdev and borrowed from an earlier
 * program. Needs pruning but that will have to wait.
 *
 * Revision 1.8  2007/02/21 08:15:22  slu
 * Looked through the javadoc
 *
 * Revision 1.7  2007/02/02 14:12:13  slu
 * Implemented the incremental update scheme
 *
 * Revision 1.6  2007/02/02 10:31:32  slu
 * Improved help text
 *
 * Revision 1.5  2007/02/02 09:28:26  slu
 * Removed the printing of resulting document
 *
 * Revision 1.4  2007/02/02 09:01:28  slu
 * Some cosmetic changes: Writing error messages to STDERR rather than STDOUT.
 *
 * Revision 1.3  2007/02/01 08:52:33  slu
 * [no comments]
 *
 * Revision 1.2  2007/01/30 14:40:49  slu
 * This class now, theoretically ;-) , reads file names from a file or from STDIN, reads and parses them and performs a XSL transform
 *
 * Revision 1.1  2007/01/30 12:25:41  slu
 * General Lucene XML indexer
 *
 *
 */
