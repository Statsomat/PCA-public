# Define server logic
function(input, output, session) {

  # Reload app if disconnected
  observeEvent(input$disconnect, {
    session$close()
  })

  # Reload app button
  observeEvent(input$reload,session$reload())

  # On session end
  session$onSessionEnded(stopApp)

  # Upload message
  observeEvent(input$file, {
    showModal(modalDialog(
      title = "Reading Data", "Please Wait",
      footer = NULL,
      fade = FALSE,
      easyClose = TRUE,
    ))
    Sys.sleep(2)
  }, priority=100)


  # Upload data
  datainput <- reactive({

    ###############
    # Validations
    ###############

    # Check if file is uploaded
    req(input$file)
    
    # Validate file extension
    validate(need(tools::file_ext(input$file$datapath) == "csv", 
                  "Error. Not a CSV file. Please upload a CSV file."))
    
    # Attempt to read file with auto detected delimiters, separators and encoding
    tryCatch({
      datainput1 <- fread(input$file$datapath,
                          header = "auto",
                          sep = "auto",
                          dec = "auto",
                          encoding = "unknown",
                          data.table = FALSE,
                          na.strings = "")
      return(datainput1)
      
    }, error = function(e) {
      validate(need(FALSE, paste("Error reading file:", e$message)))
      return(NULL)
    })
  })



  # Row limits
  observe({

    req(input$file, datainput())

    removeModal()


    if (nrow(datainput()) > 100000){
      showNotification("Maximum sample size exceeded. ", duration=30)
      Sys.sleep(5)
      session$close()
    }

    if (nrow(datainput()) < 10){
      showNotification("Error: Minimum 10 observations required. ", duration=30)
      Sys.sleep(5)
      session$close()
    }


  })




  # Select Variables
  output$selection1 <- renderUI({

    req(datainput())

    removeModal()

    chooserInput("selection1", "Available", "Selected",
                 colnames(datainput()), c(), size = 15, multiple = TRUE)

  })


  # Stop if column names not distinct or if too many columns selected
  observe({

    req(input$file, datainput())

    removeModal()

    if (length(unique(input$selection1$left)) != length(input$selection1$left)){
      showNotification("Error: The columns names of the dataset are not distinct. ", duration=40)
      Sys.sleep(5)
      session$close()
    }


    if (length(input$selection1$right) > 25 ){
      showNotification("Maximum number of columns exceeded. ", duration=30)
      Sys.sleep(5)
      session$close()
    }

  })


  # This creates a short-term storage location for a filepath
  report <- reactiveValues(filepath = NULL)

  # Render report
  observeEvent(input$generate, {

    req(input$file, datainput(), input$selection1$right)

    src0 <- normalizePath('report_kernel.Rmd')
    src1 <- normalizePath('report.Rmd')
    src4 <- normalizePath('references.bib')
    src6 <- normalizePath('report_code_common.Rmd')
    src7 <- normalizePath('report_code_UTF8.Rmd')
    src8 <- normalizePath('FiraSans-Bold.otf')
    src9 <- normalizePath('FiraSans-Regular.otf')


    # Temporarily switch to the temp dir
    owd <- setwd(tempdir())
    on.exit(setwd(owd))
    file.copy(src0, 'report_kernel.Rmd', overwrite = TRUE)
    file.copy(src1, 'report.Rmd', overwrite = TRUE)
    file.copy(src4, 'references.bib', overwrite = TRUE)
    file.copy(src6, 'report_code_common.Rmd', overwrite = TRUE)
    file.copy(src7, 'report_code_UTF8.Rmd', overwrite = TRUE)
    file.copy(src8, 'FiraSans-Bold.otf', overwrite = TRUE)
    file.copy(src9, 'FiraSans-Regular.otf', overwrite = TRUE)


    # Set up parameters to pass to Rmd document
    enc_guessed <- guess_encoding(input$file$datapath)
    enc_guessed_first <- enc_guessed[[1]][1]


    params <- list(data = datainput(), filename=input$file, fencoding="unknown", decimal="auto", enc_guessed = enc_guessed_first,
                     vars1 = input$selection1$right)


    tryCatch({

      withProgress(message = 'Please wait, the Statsomat app is computing. This may take a while.', value=0, {

        for (i in 1:15) {
          incProgress(1/15)
          Sys.sleep(0.25)

        }

        if (input$rcode == "No"){

          tmp_file <- render('report.Rmd', pdf_document(latex_engine = "xelatex"),
                        params = params,
                        envir = new.env(parent = globalenv())
          )

        } else {
          tmp_file <- render('report_code_UTF8.Rmd', pdf_document(latex_engine = "xelatex"),
                             params = params,
                             envir = new.env(parent = globalenv())
          )
        }

        report$filepath <- tmp_file

      })

      showNotification("Now you can download the report.", duration=20)

    },

    error=function(e) {
      # Report not available
      showNotification("Something went wrong. Please contact support@statsomat.com. ",duration=20)
      }
    )

  })


  # Enable downloadbutton
  observe({
    req(!is.null(report$filepath))
    session$sendCustomMessage("check_generation", list(check_generation  = 1))
  })


  # Download report
  output$download <- downloadHandler(

    filename = function() {
      paste('MyReport',sep = '.','pdf')
    },

    content = function(file) {

      file.copy(report$filepath, file)

    }
  )


}
