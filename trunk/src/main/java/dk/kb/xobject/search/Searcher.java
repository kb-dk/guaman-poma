package dk.kb.xobject.search;

import java.io.File;
import java.io.IOException;
import java.io.StringReader;
import java.util.ArrayList;
import java.util.List;
import org.apache.logging.log4j.*;
import org.apache.lucene.analysis.Analyzer;
import org.apache.lucene.analysis.SimpleAnalyzer;
import org.apache.lucene.analysis.TokenStream;
import org.apache.lucene.search.highlight.Highlighter;
import org.apache.lucene.search.highlight.InvalidTokenOffsetsException;
import org.apache.lucene.search.highlight.SimpleHTMLFormatter;
import org.apache.lucene.search.highlight.QueryScorer;
import org.apache.lucene.index.IndexReader;
import org.apache.lucene.index.MultiReader;
import org.apache.lucene.queryParser.MultiFieldQueryParser;
import org.apache.lucene.queryParser.ParseException;
import org.apache.lucene.queryParser.QueryParser;
import org.apache.lucene.search.*;
import org.apache.lucene.store.Directory;
import org.apache.lucene.store.SimpleFSDirectory;
import org.apache.lucene.util.Version;

/**
 * This is an Lucene Searcher class utilizing the index generated by the 
 * xslt_indexer
 *
 * @author Sigfrid Lundberg (slu@kb.dk)
 *
 * @version Last $Revision: 1.5 $ $Date: 2007/05/07 09:14:31 $ 
 * by $Author: slu $. Current checkout was made as build $Name:  $ 
 */
public class Searcher
{
    Logger log = LogManager.getLogger(Searcher.class);
    TopDocs resultset = null;
    IndexSearcher index_searcher = null;
    Analyzer analyzer = new SimpleAnalyzer(Version.LUCENE_36);
    SimpleHTMLFormatter formatter = null;
    Highlighter highlighter = null;
    Query query = null;
    private SortField sort = null;

    String[] searchFields = {"title",
            "creator",
            "description",
            "signature"};

    private String indexdir    = "/home/slu/development/index";
    QueryParser.Operator operator = QueryParser.AND_OPERATOR;

    public Searcher()
    {
    }

    public void setIndexDir (String dir) {
	log.debug("set index dir: " + dir);
        this.indexdir = dir;
    }

    public String getIndexDir () {
	log.debug("get index dir: " + this.indexdir);
        return this.indexdir;
    }

    public void setSearchFields(String[] field_list) {
        this.searchFields = field_list;
    }

    public void sortByRelevance() {
        this.sort = SortField.FIELD_SCORE;
    }

    public void sortByIndexOrder() {
        this.sort = SortField.FIELD_DOC;
    }

    public void sortByField(String field){
        this.sort = new SortField(field, SortField.STRING);
    }

    public void setDefaultOperator(String op) {
        if(op.equalsIgnoreCase("and")) {
            this.operator = QueryParser.AND_OPERATOR;
        } else {
            this.operator = QueryParser.OR_OPERATOR;
        }
    }

    public QueryParser.Operator getDefaultOperator() {
        return this.operator;
    }

    public Analyzer getAnalyzer() {
        return this.analyzer;
    }

    public void setAnalyzer(Analyzer analyzer) {
        this.analyzer = analyzer;
    }



    public boolean search(String querystring) throws java.io.IOException
    {
	this.resultset = null;
	
        Directory luceneDir = new SimpleFSDirectory(new File(indexdir));

	log.info("query string = " + querystring);
	
        IndexReader idr = MultiReader.open(luceneDir);
	index_searcher = new IndexSearcher(idr);

        //IndexReader i_reader = searcher.getIndexReader();

        //IndexSearcher[] arr = {searcher};
        //IndexReader[]   readArr = {i_reader};

        //MultiReader m_reader = new MultiReader(readArr);
        //MultiSearcher m_searcher = new MultiSearcher(arr);

        querystring = querystring.toLowerCase();

        MultiFieldQueryParser qp = new MultiFieldQueryParser(Version.LUCENE_36,this.searchFields, this.analyzer);
        qp.setDefaultOperator(this.getDefaultOperator());

        try {
            this.query = (Query)qp.parse(querystring);
        }
        catch(ParseException e) {
	    log.info("query parser failed " + e.getMessage());
            e.printStackTrace();
        }

        if(query != null) {
            if(this.sort == null) {
                this.resultset =  index_searcher.search(this.query, 500);
            } else {
                this.resultset =  index_searcher.search(this.query, 500 ,new Sort(this.sort));
            }
        }
	log.info("resultset says: " +  this.resultset.totalHits );
        return this.resultset != null;
    }

    public void setHighLightTags(String start, String end) {
        this.formatter = new SimpleHTMLFormatter(start,end);
        this.setHighlighter();
    }

    private void setHighlighter() {
        this.highlighter = new Highlighter(this.formatter,
                new QueryScorer(this.query));
    }

    public String hightLight(String field,
                             String text,
                             int number,
                             String seperator) {

        TokenStream tokenStream =
                this.analyzer.tokenStream(field,new StringReader(text));
        String result = "";
        try {
            result = this.highlighter.getBestFragments(tokenStream,
                    text,
                    number,
                    seperator);
        }
        catch(IOException e) {
            e.printStackTrace();
        } catch (InvalidTokenOffsetsException e) {
            e.printStackTrace();
        }
        return result;
    }

    public List getHits(int from_hit, int number) {
        List hits = new ArrayList();
        if(from_hit < this.getHitNumber()) {
            int stop = from_hit+number<this.getHitNumber() ?
                    from_hit+number:this.getHitNumber();

            for(int i=from_hit;i<stop; i++) {
                try{
                    hits.add(  index_searcher.doc(i)  );
                }
                catch(IOException e) {
                    e.printStackTrace();
                }
            }
        }
	log.info("getHits: " + hits.size() + " hits");
        return hits;
    }

    public int getHitNumber() {
        if(resultset != null) {
            return resultset.totalHits;
        } else {
            return 0;
        }
    }
}
