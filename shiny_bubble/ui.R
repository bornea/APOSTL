################################################################################
# R-code: APOSTL Interactive Environment User Interface
# Author: Brent Kuenzi
################################################################################
shinyUI(fluidPage(
  pageWithSidebar(
    headerPanel("Welcome to APOSTL!"),
    ################################ GLOBAL SIDEBAR ############################
    sidebarPanel(img(src="APOSTL_icon_no_border.png", height = 100, width = 150),br(),
             sliderInput("main.cutoff", "Saint Score Cutoff", min=0, max=1, value=0.8),
             sliderInput("main.change", "Log2(Fold Change) Cutoff", 
                         min=round(min(main.data[(colnames(main.data)=="log2(FoldChange)")]),0),
                         max=round(max(main.data[(colnames(main.data)=="log2(FoldChange)")]),0), 
                         value=round(min(main.data[(colnames(main.data)=="log2(FoldChange)")]),0),
                         step=0.1
                         ),
             numericInput("NSAFscore", "NSAF Score Cutoff", 
                         min=min(main.data[(colnames(main.data)=="NSAF Score")]),
                         max=max(main.data[(colnames(main.data)=="NSAF Score")]), 
                         value=min(main.data[(colnames(main.data)=="NSAF Score")])
             ),
             selectInput("main.exclude", "Click or search to select proteins to exclude", multiple=TRUE, choices=preys),
             downloadButton('param', 'Download Analysis Parameters')
             ),
  mainPanel(
  tabsetPanel(type="pills",
    ################################# ABOUT PANEL ##############################
    tabPanel("About",tags$div(HTML(md_render))),
    ########################## Replicate Correlations ##########################
    tabPanel("Replicate Correlations",
             column(4,selectInput("corr_x","Select X Axis", choices=replicates),
                    selectInput("corr_y","Select Y Axis", choices=replicates)),
             column(4,selectInput("corr.color","Select Bubble Color", multiple=FALSE, 
                                  choices=colors, selected="#5D8AA8"),
                    selectInput("corr_theme","Select Theme",choices=c("Default","b/w","minimal","classic","dark","linedraw"),
                                selected="Default")
                    ),
             column(4,selectInput("correlation.file", "Bubble Plot File Type", choices=c(".pdf",".png",".tif",".svg",".eps",".jpg"), selected=".png"),
                    downloadButton('correlation.down', 'Download Bubble Plot')),
             column(4, radioButtons("corr_log","Log Transform?",choices=c("Yes","No"),selected="No")),
            plotOutput("corr",width="100%",height="500px")
             ),
    ################################ Boxplots #############################
    tabPanel("Protein Boxplots",
             column(4,
                    selectInput("prot.box","Select Protein", choices=preys,selected=preys[0]),
                    selectInput("box_theme","Select Theme",
                                choices=c("Default","b/w","minimal","classic","dark","linedraw"),
                                selected="Default")),
              column(4,selectInput("box.color","Select Box Color", multiple=FALSE, 
                                  choices=colors, selected="#5D8AA8"),
                     radioButtons("prot_log","Log Transform?",choices=c("Yes","No"),selected="No")),
             column(4,
                    selectInput("box.file", "Bubble Plot File Type", choices=c(".pdf",".png",".tif",".svg",".eps",".jpg"), selected=".png"),
                    downloadButton('box.down', 'Download Bubble Plot')),
             plotOutput("box",width="100%",height="500px")
      ),
    ################################ Histogram #############################
    tabPanel("Density Plot",
             column(4,selectInput("hist.x", "Select X Axis", selected="log2(FoldChange)",choices=c("ln(NSAF)","SpecSum", "log2(FoldChange)", "SaintScore", "logOddsScore","NSAF Score"))),
             column(4,selectInput("bait.choice", "Select Baits to Include", multiple=TRUE, choices=baits,selected=baits)),
             column(4,selectInput("hist.file", "Select File Type", choices=c(".pdf",".png",".tif",".svg",".jpg"), selected=".png"),
                    downloadButton('hist.down', 'Download Density Plot')),
             plotOutput("hist", width="100%",height="500px")
             ),
    ################################ BUBBLE GRAPHS #############################
    tabPanel("Bubble Graph",
      plotOutput("bubbles",width="100%",height="500px", click = "plot1_click"),
      p(column(4,
        selectInput("main.x","X axis",selected = "ln(NSAF)",choices=c("ln(NSAF)","SpecSum", "log2(FoldChange)", "SaintScore", "logOddsScore","NSAF Score")),
        selectInput("bubble.color", "Bubble Color", multiple=FALSE, choices=colors, selected="#FF0000")),
      column(4,
        selectInput("main.y","Y axis",selected = "log2(FoldChange)",choices=c("ln(NSAF)","SpecSum", "log2(FoldChange)", "SaintScore", "logOddsScore","NSAF Score")),
        selectInput("filt.color","CRAPome Filtered Bubble Color",choices=colors,selected="#D2B48C")),
      column(4,
        selectInput("main.size", "Bubble Size", selected = "SpecSum", choices=c("ln(NSAF)","SpecSum", "log2(FoldChange)", "SaintScore", "logOddsScore","NSAF Score")),
        selectInput("theme","Select Theme",choices=c("Default","b/w","minimal","classic","dark","linedraw"),selected="Default"))),
      p(column(4,
              selectInput(inputId = "main.label",label="Bubble Labels",choices=c("none",">cutoff","all")),
              radioButtons("main.color","Color",choices=c("crapome","fixed"),selected="crapome",inline=TRUE)
              ),
        column(4,
              selectInput("outline.color", "Outline Color", multiple=FALSE, choices=c("white","black"), selected="black"),
              selectInput("label.color", "Label Color", multiple=FALSE, choices=c("white","black"), selected="black")
              ),
        column(4,
               sliderInput("main.scale", "Scale Bubble Size", min=0.1, max=100, value=c(1,10))),
        column(4,selectInput("main.file", "Bubble Plot File Type", choices=c(".pdf",".png",".tif",".svg",".eps",".jpg"), selected=".png"),
               downloadButton('main.down', 'Download Bubble Plot'))
        )),
    ################################ CYTOSCAPE NETWORK #########################
    tabPanel("Network",
             visNetworkOutput("networkproxynodes",height="600px"),
             column(4,
                    selectInput("PreyColor", "Prey Color", multiple=FALSE, choices=colors,selected="#5D8AA8"),
                    selectInput("BaitColor", "Bait Color", multiple=FALSE, choices=colors,selected="#F0F8FF"),
                    radioButtons("smooth", "Smooth Edges",choices=c("On"=TRUE, "Off"=FALSE), selected=FALSE),
                    radioButtons("hierLayout","Hierarchical Layout",choices=c("Yes","No"),selected="No")),
             column(4,
                    actionButton("physics", "Physics", icon=icon("stop",lib = "font-awesome")),#,choices=c("On"=TRUE, "Off"=FALSE), selected=TRUE),
                    sliderInput("PreySize", "Prey Size",min=1,max=100, value=25),
                    sliderInput("BaitSize", "Bait Size",min=1,max=100, value=25)),
             column(4,
                    selectInput("PreyShape","Prey Shape", 
                                choices= shapes, 
                                selected="circle"),
                    selectInput("BaitShape","Bait Shape", 
                                choices= shapes, 
                                selected="circle"),
                    downloadButton("network.sif","Export network as SIF"),
                    actionButton("saveJSON","Export network as GEPHI JSON"))
    ),
    ################################ TABLE DISPLAY #############################
    tabPanel("Data Table",
             dataTableOutput('table'),
             downloadButton("saveTable", "Save Table")),
    ################################ KEGG ANALYSIS #############################
    tabPanel("Pathway Analysis",useShinyjs(),inlineCSS(appCSS_KEGG),
             h2(id="loading-content-KEGG","Querying Pathways..."),
             plotOutput("pathPlot",width="100%",height="500px"),
             column(4,
                    actionButton("KEGGbutton","Analyze"),
                    selectInput("path_org","Organism", choices=c("mouse","yeast","human"),multiple=FALSE,selected="human"),
                    sliderInput("path_pval", "pValue Cutoff",min=0,max=1, value=0.05),
                    selectInput("KEGG_theme","Select Theme",choices=c("Default","b/w","minimal","classic","dark","linedraw"),selected="Default")),
             column(4,
                    selectInput("path_adj","pAdjustMethod", 
                                choices=c("holm", "hochberg", "hommel", "bonferroni", "BH", "BY", "fdr", "none"),
                                multiple=FALSE, selected="bonferroni"),
                    selectInput("KEGG.color", "Select bar color", multiple=FALSE, choices=colors, selected="#000000"),
                    selectInput("pathway.file", "Graph File Type", choices=c(".pdf",".png",".tif",".svg",".eps",".jpg"), selected=".png")),
             column(4,
                    selectInput("path_x","select x-axis",choices=c("pvalue","p.adjust")),
                    radioButtons("top10KEGG","Top 10 Only", choices=c("Yes"=TRUE,"No"=FALSE),selected=FALSE),
                    downloadButton("pathTable", "Download Raw Data")),
             column(4,downloadButton("pathway.down", "Download Graph"))
    ),
    ################################ GO ANALYSIS ###############################
    tabPanel("Gene Ontology",useShinyjs(),inlineCSS(appCSS_GO),
             h2(id="loading-content-GO","Querying GO Terms..."),
             plotOutput("ontPlot",width="100%",height="500px"),
             column(4,
                    actionButton("GObutton","Analyze"),
                    selectInput("path_org","Organism", choices=c("mouse","yeast","human"),multiple=FALSE,selected="human"),
                    sliderInput("path_pval", "pValue Cutoff",min=0,max=1, value=0.05),
                    selectInput("GO_theme","Select Theme",choices=c("Default","b/w","minimal","classic","dark","linedraw"),selected="Default")),
             column(4,
                    selectInput("path_adj","pAdjustMethod", 
                                choices=c("holm", "hochberg", "hommel", "bonferroni", "BH", "BY", "fdr", "none"),
                                multiple=FALSE, selected="bonferroni"),
                    selectInput("GO_ont","Select Ontology", choices=c("MF","BP","CC")),
                    selectInput("GO.color", "Select bar color", multiple=FALSE, choices=colors, selected="#000000")),
             column(4,
                    selectInput("path_x","select x-axis",choices=c("pvalue","p.adjust")),
                    radioButtons("top10GO","Top 10 Only", choices=c("Yes"=TRUE,"No"=FALSE),selected=FALSE),
                    selectInput("ontology.file", "Graph File Type", choices=c(".pdf",".png",".tif",".svg",".eps",".jpg"), selected=".png")),
             column(4,
                    downloadButton("ontTable", "Download Raw Data")),
             column(4,downloadButton("ontology.down", "Download Graph"))
    )
  ))
  )))