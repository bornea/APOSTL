// Wait for cy to be defined and then add event listener
$(document).ready(function() {
  Shiny.addCustomMessageHandler("saveJSON",
    function(message) {
      //console.log("saveImage");
      
      var result = cy.add(); 
      //Shiny.onInputChange("imgContent", result);
      console.log("imgContent: " + result);
      // I think we can include code as-is from stackoverflow with proper attribution (the link might be enough). Please check this to be sure.
      // From: http://stackoverflow.com/questions/25087009/trigger-a-file-download-on-click-of-button-javascript-with-contents-from-dom
      dl = document.createElement('a');
      document.body.appendChild(dl);
      dl.download = "download.json";
      dl.href = result;
      dl.click();
    }
  );
});

Shiny.addCustomMessageHandler("testMessage",
  function(message) {
    alert(JSON.stringify(message));
  }
);