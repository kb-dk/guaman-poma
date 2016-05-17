
//Jacob Larsen                               
//IT-Konsulent                                
//Web-Teknik / (DUP)                   
//Det Kongelige Bibliotek.                              
//email: jac@kb.dk

function slide(){
 if(document.getElementById('contentNav').className=='contentNav'){

  document.getElementById('contentNav').className='contentNavOff';
  document.getElementById('slideA').className='out';
  createCookie('dk.kb.www.mets.menu','none');
 }else{
  document.getElementById('contentNav').className='contentNav';
  document.getElementById('slideA').className='';
  createCookie('dk.kb.www.mets.menu','block');
 }
}

function createCookie(name,value,days) {
	if (days) {
		var date = new Date();
		date.setTime(date.getTime()+(days*24*60*60*1000));
		var expires = "; expires="+date.toGMTString();
	}
	else var expires = "";
	document.cookie = name+"="+value+expires+"; path=/";
}
	
function increase(val){
  if(document.getElementsByTagName('body')[0].style.fontSize==''){
    var initSize = 100+'%';
  }else{
    var initSize = document.getElementsByTagName('body')[0].style.fontSize;
  }
    var a = initSize.substring(0,initSize.indexOf('%'));
    var c = a*1 + val;
    document.getElementsByTagName('body')[0].style.fontSize = c+'%';
    createCookie('dk.kb.www.mets.fontSize',c+'%',10000);
}
	
function decrease(val){
  if(document.getElementsByTagName('body')[0].style.fontSize==''){
    var initSize = 100+'%';
  }else{
    var initSize = document.getElementsByTagName('body')[0].style.fontSize;
   }
    var a = initSize.substring(0,initSize.indexOf('%'));
    var c = a*1 - val;
    document.getElementsByTagName('body')[0].style.fontSize = c+'%';
    createCookie('dk.kb.www.mets.fontSize',c+'%',10000);
  }

function createCookie(name,value,days) {
	if (days) {
		var date = new Date();
		date.setTime(date.getTime()+(days*24*60*60*1000));
		var expires = "; expires="+date.toGMTString();
	}
	else var expires = "";
	document.cookie = name+"="+value+expires+"; path=/";
}

var open="";
function toggleMenu(a,u){
 if(open==""){
    document.getElementById(u).style.display='none';
    document.getElementById(a).className='off';
    open='true';
}else{
    document.getElementById(u).style.display='block';
    document.getElementById(a).className='on';
    open='';

}


}

