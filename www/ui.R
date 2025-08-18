# Define UI for application
shinyUI(fluidPage(

  # Google Analytics tracking
  tags$head(
    HTML(sprintf('
    <!-- Google tag (gtag.js) -->
    <script async src="https://www.googletagmanager.com/gtag/js?id=%s"></script>
    <script>
    window.dataLayer = window.dataLayer || [];
    function gtag(){dataLayer.push(arguments);}
    gtag("js", new Date());

    gtag("config", "%s");
    </script>
    ', ga_id, ga_id))
  ),
  

  # Disconnect message
  disconnectMessage(
    text = "Your session timed out or error. ",
    refresh = "Reload now",
    background = "#ff9900",
    colour = "white",
    overlayColour = "grey",
    overlayOpacity = 0.3,
    refreshColour = "black"
  ),

  # Reload button
  actionButton("reload", "Reload the App", style="
                                    color: black;
                                    background-color: #ff9900;
                                    float: right"),

  # Style uploading modal
  tags$head(tags$style(".modal-body {padding: 10px}
                     .modal-content  {-webkit-border-radius: 6px !important;-moz-border-radius: 6px !important;border-radius: 6px !important;}
                     .modal-dialog { width: 400px; display: inline-block; text-align: center; vertical-align: top;}
                     .modal-header {background-color: #ff9900; border-top-left-radius: 6px; border-top-right-radius: 6px}
                     .modal { text-align: center; padding-right:10px; padding-top: 24px;}
                     .close { font-size: 16px}")),



  tags$head(
    tags$style(HTML("
                   .shiny-notification{

                    position: fixed;
                    top: 10px;
                    left: calc(50% - 400px);;
                    width: 850px;
                    /* Make sure it draws above all Bootstrap components */
                    z-index: 2000;
                    background-color: #ff9900;

                   }

                    "))
    ),


  #Disable download button until check positive
  singleton(tags$head(HTML(
    '
  <script type="text/javascript">


    $(document).ready(function() {
      $("#download").attr("disabled", "true").attr("onclick", "return false;");
      Shiny.addCustomMessageHandler("check_generation", function(message) {
        $("#download").removeAttr("disabled").removeAttr("onclick").html("");
      });
    })



  </script>
  '
  ))),

  br(),

  tags$div(a(img(src='Logo.jpg', width=200), href="https://www.statsomat.com", target="_blank")),

  h1("Principal Components Analysis",
     style = "font-family: 'Helvetica';
     color: #fff; text-align: center;
     background-color: #396e9f;
     padding: 20px;
     margin-bottom: 0px;"),
  h5("Statsomat/PCA",
     style = "font-family: 'Helvetica';
     color: #fff; text-align: center;
     background-color: #2fa42d;
     padding: 5px;
     margin-top: 0px;"),

  br(),


  fluidRow(


      column(8, offset=2,
             # Interactive Description
             wellPanel(
               style = "background: #c5fbc4",
               # Short description
               tags$div(
                 id = "description-short",
                 includeHTML("www/Description_short.html")
               ),
               # Full description
               tags$div(
                 id = "description-full",
                 includeHTML("www/Description_full.html"),
                 style = "display: none;"
               ),
               actionLink("toggle_description", "Read More", style = "cursor: pointer; font-weight: bold; color: #2a7bcf;"),
               tags$script(HTML("$('#toggle_description').on('click', function() {
                                 $('#description-short, #description-full').toggle();
                                 var link = $(this);
                                  link.text(link.text() === 'Read More' ? 'Read Less' : 'Read More');
                                  });
              "))
             ),
             wellPanel(
               style = "background: #fff; display: none;",
               id = "instructions-panel",
               includeHTML("www/Instructions.html")
             ),
             tags$script(HTML("
             $(document).on('click', '#toggle_instructions', function(e) {
               e.preventDefault();
               $('#instructions-panel').toggle();
               var link = $(this);
               link.text(link.text() === 'click here' ? 'hide instructions' : 'click here');
             });
           ")),
          
             wellPanel(style = "background: #adc7de;",

                          h3("Upload"),

                          # File input
                          fileInput("file", "Choose CSV file",
                                    accept = c(
                                      "text/csv",
                                      "text/comma-separated-values",
                                      ".csv"),
                                    buttonLabel = "Browse...",
                                    placeholder = "No file selected"),

                       tags$b("By clicking the Browse button and uploading a file, you agree to the Statsomat",
                              style="color: #808080;"),

                       tags$a(href="https://statsomat.com/terms", target="_blank", "Terms of Use.", style="
                              font-weight: bold;")
            ),


            wellPanel(style = "background: #adc7de;",

                      h3("Select Variables"),
                      h5("Please include between 3 and 25 variables. Only blanks as missings! "),

                      uiOutput("selection1")

            ),


          wellPanel(style = "background: #ff9900", align="center",

                    h3("Generate the Report"),

                    radioButtons('rcode', 'Include R Code', c('Yes','No'), inline = TRUE),

                    h5("Click the button to generate the report"),

                    actionButton("generate", "", style="
                                    height:145px;
                                    width:84px;
                                    padding-top: 3px;
                                    color:#ff9900;
                                    background-color: #ff9900;
                                    background-image: url('Button.gif');
                                    border: none;
                                    outline: none;
                                    box-shadow: none !important;
                                   ")


          ),


          wellPanel(style = "background: #ff9900", align="center",

                    h3("Download the Report"),

                    h5("Click the button to download the report"),

                    downloadButton("download", "", style="
                                    height:145px;
                                    width:84px;
                                    padding-top: 3px;
                                    color:#ff9900;
                                    background-color: #ff9900;
                                    border-color: #ff9900;
                                    background-image: url('Button.gif');")
          

          ),

          wellPanel(style = "background: #fff;", includeHTML("www/Secure.html")),
          wellPanel(style = "background: #fff;", includeHTML("www/OpenSource.html")),
          wellPanel(style = "background: #fff;", includeHTML("www/Contact.html"))

      )
  ),

 includeHTML("www/Footer.html"),

 hr()

))

