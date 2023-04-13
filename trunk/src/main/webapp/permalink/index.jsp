<%@ page contentType="text/html; charset=UTF-8"%><%
response.setContentType("text/html");
request.setCharacterEncoding("UTF-8");

//
// Handle some cookies
//

String cookieName = "dk.kb.www.mets.menu";
String cookieName2 = "dk.kb.www.mets.fontSize";
String c = "";
String size = "";
Cookie cookies [] = request.getCookies ();
Cookie myCookie = null;
if (cookies != null){
    for (int i = 0; i < cookies.length; i++) {
	if (cookies [i].getName().equals (cookieName)){
	    myCookie = cookies[i];
	    if(myCookie.getValue().equals("none")){ 
		c = "out";
	    }
	}
	if (cookies [i].getName().equals (cookieName2)){
	    myCookie = cookies[i];
	    if(!(myCookie.getValue()).equals("100%")){
		size = myCookie.getValue();	
	    }
	}
    }
}

String key = request.getRequestURI() + request.getQueryString();
dk.kb.cache.Page cpage = dk.kb.cache.Page.getInstance();

String xmlString = cpage.getText(key);

if(xmlString == null) {

    //
    // Handle and set some parameters
    //

    String lang      = "es";
    if(request.getParameter("lang") != null) {
	lang  = request.getParameter("lang");
    }

    String toggle       = "/permalink/2006/poma/";
    String toggleVar    = "lang";
    String toggleValue  = "en";
    if(lang.equalsIgnoreCase("en")) {
	toggleValue = "es";
    }

    if( request.getParameter("info") != null) {
	toggle       = toggle      +"info/" + 
	    toggleValue + "/" + 
	    request.getParameter("info");
    } else {
	String[] parameters = {"id","lang","mode"};
                           
	for(int i=0;i<parameters.length;i++) {
	    if(request.getParameter(parameters[i]) != null) {
		if(parameters[i].equalsIgnoreCase(toggleVar)) {
		    toggle = toggle + toggleValue + "/";
		} else {
		    toggle = toggle + request.getParameter(parameters[i]) + "/";
		}
	    } 
	}
    }

    String infoMetsPath  = "http://localhost:9091/guaman-poma/data/";

    String metsPath = "file://" + request.getSession().getServletContext().getRealPath( "/" )+"/data/";

    String infoPages = metsPath + "www-files/";
    String html      = metsPath + "pages/";
    String image     = metsPath + "images/";

    String xsl = "make-page.xsl";
    String imageList = "table-of-images.html";
    String textList  = "toc.html";

    String xImageList = "table-of-images." + lang +  ".xml";
    String xTextList  = "toc." + lang +  ".xml";

    String toc       = textList;
    String tocUri    = "";
    String xContent  = metsPath + xTextList;

    if(request.getParameter("mode") != null && request.getParameter("mode").equalsIgnoreCase("image")) {
	toc      = imageList;    
	xContent = metsPath + xImageList;
    }
    String xImageContentList = metsPath + xImageList;
    tocUri = metsPath + toc + "." + lang;

    String xslUrl = metsPath + xsl;

    String     startId = "titlepage";
    if(request.getParameter("id") != null) {
	if(request.getParameter("id").equalsIgnoreCase("0")) {
	    startId = "titlepage";
	} else {
	    startId = request.getParameter("id");
	}
    }

    String imageSize = "normal";
    if(request.getParameter("imagesize") != null) {
	imageSize = request.getParameter("imagesize");
    }

    String infoPage = "";
    if(request.getParameter("info") != null) {
	infoPage = request.getParameter("info");
    }

    infoPage = infoPages + infoPage;

    if(startId.equalsIgnoreCase("titlepage")) {
	html  = html  + startId + ".html";
	image = image + startId + ".html." + lang;
    } else {
	html  = html  + "n" + java.net.URLEncoder.encode(startId,"UTF-8") + ".html";
	image = image + "n" + java.net.URLEncoder.encode(startId,"UTF-8") + ".html." + lang;
    }

    //
    // Now we are coming to the real business. Here we pass all the information to
    // the XSLT processor
    //

    String docId = "253";
    String metsUrl = metsPath + "poma-mets.xml";

    java.net.URL hdoc = new java.net.URL(html);

    java.io.InputStream input = hdoc.openStream();


    javax.xml.parsers.DocumentBuilderFactory dfactory  = javax.xml.parsers.DocumentBuilderFactory.newInstance();

    dfactory.setNamespaceAware(true);
    // dfactory.setXIncludeAware(true);

    javax.xml.parsers.DocumentBuilder dBuilder = dfactory.newDocumentBuilder();

    javax.xml.transform.dom.DOMSource source = new javax.xml.transform.dom.DOMSource(dBuilder.parse(input));

    java.io.StringWriter xmlOutWriter = new java.io.StringWriter();

    javax.xml.transform.stream.StreamResult result = 
	new javax.xml.transform.stream.StreamResult(xmlOutWriter);

    javax.xml.transform.TransformerFactory factory =
	//new com.icl.saxon.TransformerFactoryImpl();
	new org.apache.xalan.processor.TransformerFactoryImpl();
    javax.xml.transform.Transformer transformer = 
	factory.newTransformer(new javax.xml.transform.stream.StreamSource(xslUrl));


    transformer.setParameter("identifier",startId);
    transformer.setParameter("lang",lang);
    transformer.setParameter("contents", tocUri);
    transformer.setParameter("xcontents",xContent);
    transformer.setParameter("image",image);
    transformer.setParameter("toggle",toggle);
    transformer.setParameter("slider",c);
    transformer.setParameter("fontsize",size);
    transformer.setParameter("imagesize",imageSize);
    transformer.setParameter("xImageContents",xImageContentList);

    if(request.getParameter("q") != null) {

	String query_path = "http://localhost:9091"
	    + "/guaman-poma/permalink/poma-search-response.jsp";

	String query_url = "q=" + request.getParameter("q");

	String start = "0";
	if(request.getParameter("start") != null) {
	    start = request.getParameter("start");
	}
	query_url = "start=" + start + "&" + query_url;

	String field = "body";
	if(request.getParameter("field") != null) {
	    field = request.getParameter("field");
	}
	query_url = "field=" + field + "&" + query_url;

	String operator = "and";
	if(request.getParameter("operator") != null) {
	    operator=request.getParameter("operator");
	}
	query_url = "operator=" + operator + "&" + query_url;

	query_url = query_path + "?" + query_url + "&index=poma&lang=" + lang;

	transformer.setParameter("query",request.getParameter("q"));
	transformer.setParameter("query_url",query_url);

    }




    if( request.getParameter("debug") != null) {
	transformer.setParameter("debug",request.getParameter("debug"));
    }
    if( request.getParameter("mode") != null) {
	transformer.setParameter("mode",request.getParameter("mode"));
    }
    if(request.getParameter("open") != null) {
	transformer.setParameter("open",request.getParameter("open"));
    }
    if(request.getParameter("info") != null) {
	transformer.setParameter("info",infoPage);
	if(infoPage.indexOf("docs")>0) {
	    transformer.setParameter("base_url",infoPages + "docs/");
	} else if(infoPage.indexOf("biblio")>0) {
	    transformer.setParameter("base_url",infoPages + "biblio/");
	} else {
	    transformer.setParameter("base_url",infoPages);
	}
    }
    transformer.transform(source,result);  

    xmlString = xmlOutWriter.toString();
    cpage.setText(key,xmlString);

}

out.println(xmlString);
 

// out.println(result.getOutputStream());

%>

<!-- 
<%
out.println( request.getPathTranslated() );
out.println( request.getPathInfo()       );
out.println( request.getContextPath()    );

%>
-->
