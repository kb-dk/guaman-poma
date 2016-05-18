<%@ page contentType="text/html;charset=UTF-8"%>
<%     
response.setContentType("text/html");
request.setCharacterEncoding("UTF-8");

String query = "";
String my_title = "Poma NG prototype search engine";
if(request.getParameter("q") != null) {
  query = request.getParameter("q");
  my_title = "Search for " + query + " in the Poma NG prototype search engine";
}

 String language = "es";
if(request.getParameter("lang") != null) {
  language = request.getParameter("lang");
}

String sortby = "page";
/*
if(request.getParameter("sortby") != null) {
    sortby = request.getParameter("sortby");
}
*/

String  sortbyPage      = "";
String  sortbyRelevance = "";
if(sortby.equalsIgnoreCase("page")) {
    sortbyPage      = " checked=\"checked\" ";
} else {
    sortbyRelevance = " checked=\"checked\" ";
}

String sortSelector = ""; /*"<br /><strong>Sort by:</strong> ";
sortSelector += "<input onclick=\"JavaScript:submit();\" "    + sortbyPage
    + " type=\"radio\" name=\"sortby\" value=\"page\" />"      + " page ";
sortSelector += "<input onclick=\"JavaScript:submit();\" "    + sortbyRelevance 
+ " type=\"radio\" name=\"sortby\" value=\"relevance\" />" + " relevance ";*/




String operator = "and";
String allTerms = "and";
String anyTerm  = "";
if(request.getParameter("operator") != null) {
  operator = request.getParameter("operator");
}

if(operator.equalsIgnoreCase("and")) {
   allTerms = " checked=\"checked\" ";
   anyTerm  = "";
} else {
   allTerms = "";
   anyTerm  = " checked=\"checked\" ";
}
String useIndex = "poma";

String[] searchFields = {"title",  
                         "body",
                         "quechua",
                         "editorial_text"};
java.util.HashMap fieldToText = new java.util.HashMap();  

String searchableFields[] = {"body",
                             "quechua",
                             "editorial_text",
			     "any"};

if(language.equalsIgnoreCase("en")) {                       
    fieldToText.put("body","transcription only");
    fieldToText.put("quechua","normalized quechua");
    fieldToText.put("editorial_text","commentary and other notes");
    fieldToText.put("any","the entire text");
} else {
    fieldToText.put("body","solamente la transcripción");
    fieldToText.put("quechua","normalizado quechua");
    fieldToText.put("editorial_text","comentarios y otras notas");
    fieldToText.put("any","el texto completo");
}
                               
String field = "body";
if(request.getParameter("field") != null) {
  field = request.getParameter("field");
}

java.util.HashMap useField = new java.util.HashMap();
java.util.Set keys = fieldToText.keySet();

for(int keynum = 0;searchableFields.length>keynum;keynum++) {
  String key = searchableFields[keynum];
  if(key.equalsIgnoreCase(field)) {
    useField.put(key,"checked=\"checked\"");
  } else {
    useField.put(key,"");
  }
}

String fieldSelector = "\n<em>";
if(language.equalsIgnoreCase("en")) {
    fieldSelector += "Results from";
} else {
    fieldSelector += "Buscar en";
}
fieldSelector += "</em>\n";

for(int keynum = 0;searchableFields.length>keynum;keynum++) {
  String fieldName = searchableFields[keynum];
  fieldSelector += "<input onclick=\"JavaScript:submit();\" type=\"radio\" name=\"field\" value=\"" + fieldName +
      "\" " + useField.get(fieldName) + " />" + fieldToText.get(fieldName) + " ";
}

String useManus = " checked=\"checked\" ";
String useMusic = "";


javax.servlet.ServletContext context = request.getServletContext();
String indexDirectory = context.getRealPath("/WEB-INF/poma_index/");

int start = 0;
if(request.getParameter("start") != null) {
  Integer integer = new Integer(request.getParameter("start"));
  start = integer.intValue();
}
int max_number = 10; // maximum number of hits per page

%>
<div>
<%  
    if(query.length() > 0) {
      dk.kb.xobject.search.Searcher searcher = new dk.kb.xobject.search.Searcher();
      
      searcher.setDefaultOperator(operator);
      searcher.setIndexDir(indexDirectory);
      if(sortby.equalsIgnoreCase("page")) {
	  searcher.sortByIndexOrder();
      } else {
	  searcher.sortByRelevance();
      }
      searcher.setSearchFields(searchFields);
      String sendQuery = query;
      if(!field.equalsIgnoreCase("any")) {
        sendQuery = field + ":(" + query + ")";
      }
      if(searcher.search(sendQuery)) {
        
         int number_of_hits = searcher.getHitNumber();
         int pstart = 0;
         if(start>0) {
            pstart = start-max_number>0?start-max_number:0;
         }
         int nstart = 0;
         if(number_of_hits-start>max_number) {
            nstart = start + max_number;
         }
         java.util.List hits = searcher.getHits(start,max_number);
         String previous = "previous";
         String hit      = "results";
	 if(language.equalsIgnoreCase("es")) {
	     previous = "previos";
	     hit      = "resultados";
	 }
         if(start>0) {
            previous = "&lt; <a href=\"" +
                           "?start=" + pstart +
                           "&amp;operator=" + operator +
                           "&amp;index=" + useIndex +
                           "&amp;field=" + field +
/*                          "&amp;sortby=" + sortby +*/
                           "&amp;q=" + 
                           java.net.URLEncoder.encode(query,"UTF-8")  + 
                           "\">" + previous + "</a>";
         }
         String next = "next";
	 if(language.equalsIgnoreCase("es")) {
	     next = "proximos";
	 }
         if(number_of_hits-start>max_number) {
            next = "<a href=\"" +
                               "?start=" + nstart +
                               "&amp;operator=" + operator +
                               "&amp;index=" + useIndex +
                               "&amp;field=" + field +
		/*                               "&amp;sortby=" + sortby +*/
                               "&amp;q=" +
                               java.net.URLEncoder.encode(query,"UTF-8")  +
                               "\">" + next +  "</a> &gt;";
         }
        
	 out.println("<form action=\"/permalink/2006/poma/titlepage/" + 
		     language + "/text/\" method=\"get\"><p>");
         out.print("<strong>");
         if(language.equalsIgnoreCase("en")) {
	    out.print("Refine search");
 
         } else {
             out.print("Búsqueda detallada");
         }
         out.print("</strong><br />");
	 out.print("<input type='hidden' name='lang' value='" + language + "' />");
         out.print("<input name=\"q\" type=\"hidden\" value=\"");
         out.print(query.replaceAll("\"","&quot;"));
         out.print("\" />");
	 out.print("<input type='hidden' name='start' value='0' />");

	 out.print("<em>");
         if(language.equalsIgnoreCase("en")) {
	     out.print(" Hit ");
	 } else {
	     out.print(" Resultados de ");
	 }
         out.print("</em>");

         out.print("<input type=\"radio\" onclick=\"JavaScript:submit();\" name=\"operator\"  value=\"and\" ");
         out.print(allTerms); 
         out.print("/>");
	 if(language.equalsIgnoreCase("en")) {
	     out.println(" all words ");
	 } else {
	     out.println(" todas las palabras ");
	 }

	 out.print("<input type=\"radio\" onclick=\"JavaScript:submit();\" name=\"operator\"   value=\"or\" ");
         out.print(anyTerm); 
         out.print("/>");
	 if(language.equalsIgnoreCase("en")) {
	     out.println(" at least one word ");
	 } else {
	     out.println("  por lo menos una palabra ");
	 }
         out.print("<br />");
         out.println(fieldSelector);
	 /*         out.println(sortSelector);*/
	 out.println("</p></form>");

         String navigate_results = "\n<p>";
         navigate_results += "<strong>";
         navigate_results += number_of_hits + " " + hit + "<br />";  
         navigate_results += "</strong>";
         if(start>0) {
            navigate_results += previous ;
         }
        
         navigate_results += "\n";
         if(number_of_hits>max_number) {
           for(int i=0;i<(number_of_hits/max_number) + 1; i++) {
               int localstart = i*max_number;
               int here = i + 1;
               if(start != localstart) {
                  navigate_results += "<a href=\"" +
                                       "?start=" + localstart +
                                       "&amp;operator=" + operator +
                                       "&amp;index=" + useIndex +
                                       "&amp;field=" + field +
	                               "&amp;q=" +
                                       java.net.URLEncoder.encode(query,"UTF-8")  +
                                       "\">" + here + "</a>";
               } else {
                  navigate_results += " " + here + " ";
               }
            }
         }
         if(number_of_hits>start+max_number) {
             navigate_results += next;
         }
         navigate_results += "</p>";
         
         out.println(navigate_results);

         searcher.setHighLightTags("<strong class=\"hit\">","</strong>");
         
         java.util.Iterator hiterator = hits.iterator();
         while(hiterator.hasNext()) {
            String result = "";
            org.apache.lucene.document.Document doc = 
                    (org.apache.lucene.document.Document)hiterator.next();

            out.println("<p>");                    
            String title = "missing title";  
            String missing_title = title;
            if(doc.getField("title") != null) {
               title = doc.getField("title").stringValue();
               result += searcher.hightLight("title",title,3," ... ");
            }
            String identifier = "missing identifier";
            if(doc.getField("identifier") != null) {
               identifier = doc.getField("identifier").stringValue();
            }

	    identifier = identifier + language + "/text/";
  
            for(int i=0;i<searchFields.length;i++) {
              if(doc.getField(searchFields[i]) != null) { 
                 if(field.equalsIgnoreCase("any") || searchFields[i].equalsIgnoreCase(field)) {
                   String value = doc.getField(searchFields[i]).stringValue();  
                   String extract = searcher.hightLight(searchFields[i],value,5," ... ");
                   if(extract.length()>0) {  
                      String human_readable_field = "";
                      if( !searchFields[i].equalsIgnoreCase("title") ) {
                         String hfield = "";
                         if(searchFields[i].equalsIgnoreCase("body")) {
                           if(language.equalsIgnoreCase("en")) {
                              hfield = "Text";
                           }  else {
                              hfield = "Texto";
                           }                   
                         } else if (searchFields[i].equalsIgnoreCase("editorial_text")) {
                           if(language.equalsIgnoreCase("en")) {
                              hfield = "Annotation";
                           }  else {
                              hfield = "Annotación";
                           }
                         } else {
                              hfield = "Quechua";
                         }
                         human_readable_field = " (" + hfield + ")\n";
                      }

                      result += extract + human_readable_field;
                      if(i<searchFields.length-1) {
                        result += "<br />"; 
                      }
                   }
                 }
              }
            }

            out.println("<a href='" + identifier + "'>" + title + "</a><br />");
            out.println(result);
            out.println("</p>");
            
         }   
         if(number_of_hits>max_number) {
            out.println(navigate_results); 
         }     
       }
    }
  %>
  
</div>
