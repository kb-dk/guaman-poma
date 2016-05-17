var labels = new Array();
var id = new Array();
var oldString ='';

var currentlyOpen = "";

function openDisplay(divID) {
   if(currentlyOpen == "") {
      currentlyOpen = divID;
      document.getElementById(divID).style.display = "block";
   } else if(currentlyOpen == divID) {
      closeDisplay(currentlyOpen);
      currentlyOpen="";
   } else {
      closeDisplay(currentlyOpen);
      currentlyOpen = divID;
      document.getElementById(divID).style.display = "block";
   }
}

function closeDisplay(divID) {
   document.getElementById(divID).style.display = "none";
}

var partOpen = "";
function goAnchor(partId){
   document.getElementById("workContent").scrollTop = 
      document.getElementById(partId).offsetTop;
   document.getElementById(partId).className="on";   
   if(partOpen != "") {
      document.getElementById(partOpen).className="off";      
   }
   partOpen = partId;
}

var searchTerm = "";
function setTerm(term) {
  searchTerm = term;
}

function clearField(field) {
  if (field.value == searchTerm) {
    field.value = "";
  }
}

function checkField(field) {
   if (field.value == "") {
     field.value = searchTerm;
   }
}
