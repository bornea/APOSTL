################################################################################
# R-code: APOSTL Interactive Environment User Interface
# Author: Brent Kuenzi
################################################################################
library(shinydashboard)
library(gplots)
sidebar <- dashboardSidebar(
  #Active selection
  tags$head(tags$style(HTML('.skin-blue .main-sidebar .sidebar .sidebar-menu .active a{
    background-color: #367FA9;
      color: #FFFFFF;
  }'))),
  # Hover selection
  tags$head(tags$style(HTML('.skin-blue .main-sidebar .sidebar .sidebar-menu a:hover{
    background-color: #367FA9;color: #FFFFFF;}'))),
  tags$head(tags$style(HTML('.skin-blue .main-sidebar .sidebar .sidebar-menu a:{
    background-color: #367FA9;color: #FFFFFF;}'))),
  # Logo Hover
  tags$head(tags$style(HTML('.skin-blue .main-header .logo:hover {
                              background-color: #f4b943;color: #000000;
                              }'))),
  # Sidebar 
  tags$head(tags$style(HTML('.skin-blue .main-sidebar .sidebar .sidebar-menu a{
                            color: #000000;}'))),
  # Main Sidebar
  tags$head(tags$style(HTML('.skin-blue .main-sidebar {height: 90vh; overflow-y: auto;
    background-color: #FFFFFF;color: #000000;}'))),
  (tags$style(HTML('.skin-black .main-sidebar selectInputid {color: #000000;}'))),
  hr(),
  ################################ GLOBAL SIDEBAR ############################
  sidebarMenu(img(src="APOSTL_icon_no_border.png", height = 100, width = 150),
              hr(),color="gray",
              sliderInput("main.cutoff", label = HTML('<p style="color:black;">Saint Score Cutoff</p>'), min=0, max=1, value=0.8),
              sliderInput("main.change", label = HTML('<p style="color:black;">Log2(Fold Change) Cutoff</p>'), 
                          min=round(min(main.data[(colnames(main.data)=="log2(FoldChange)")]),0),
                          max=round(max(main.data[(colnames(main.data)=="log2(FoldChange)")]),0), 
                          value=round(min(main.data[(colnames(main.data)=="log2(FoldChange)")]),0),
                          step=0.1
              ),
              numericInput("NSAFscore", label = HTML('<p style="color:black;">NSAF Score Cutoff</p>'), 
                           min=min(main.data[(colnames(main.data)=="NSAF Score")]),
                           max=max(main.data[(colnames(main.data)=="NSAF Score")]), 
                           value=min(main.data[(colnames(main.data)=="NSAF Score")])
              ),
              selectInput("main.exclude", label = HTML('<p style="color:black;">Click or search to select proteins to exclude</p>'), multiple=TRUE, choices=preys),
              downloadButton('param', label = HTML('<p style="color:black;">Download Analysis Parameters</p>')),
              menuItem("About",tabName="about", icon=icon("question")),
              menuItem("Data QC",tabName="QC", icon = icon("line-chart")),
              menuItem("Interactions",icon=icon("puzzle-piece"),
                       menuSubItem("Bubble Graph",tabName="bubblebeam"),
                       menuSubItem("PPI Network",tabName="network"),
                       menuSubItem("Bait2Bait",tabName="baits")),
              menuItem("Table",tabName="table",icon=icon("table")),
              menuItem("Pathway Analysis",tabName="pathway",icon=icon("map"))
              
  ))
body <- dashboardBody(
  tabItems(
    ################################# ABOUT PANEL ##############################
    tabItem(tabName="about",tags$div(HTML(md_render))),
    ########################## Replicate Correlations ##########################
    tabItem(tabName = "QC",
            fluidRow(
              box(title="Replicate Correlations",status="primary",plotOutput("corr",width="100%",height="500px"),solidHeader=TRUE,collapsible = TRUE),
              box(title="Inputs",status="primary",solidHeader=TRUE,collapsible = TRUE,
                  radioButtons("corr_log","Log Transform?",choices=c("Yes","No"),selected="No"),
                  selectInput("corr_x","Select X Axis", choices=replicates),
                  selectInput("corr_y","Select Y Axis", choices=replicates),
                  sliderInput("Rpos", "Select info position", min=0, max=1, value=c(0.1,0.75)),
                  selectInput("corr.color","Select Bubble Color", multiple=FALSE, choices=colors, selected="#5D8AA8"),
                  selectInput("corr_theme","Select Theme",choices=c("Default","b/w","minimal","classic","dark","linedraw"), selected="Default"),
                  selectInput("correlation.file", "Bubble Plot File Type", choices=c(".pdf",".png",".tif",".svg",".eps",".jpg"), selected=".png"),
                  downloadButton('correlation.down', 'Download Scatter Plot')
              )
            ),
            fluidRow(
              box(title="Protein Boxplots",status="success",plotOutput("box",width="100%",height="500px"),solidHeader=TRUE,collapsible = TRUE),
              box(title="Inputs",status="success",solidHeader=TRUE,collapsible = TRUE,
                  radioButtons("prot_log","Log Transform?",choices=c("Yes","No"),selected="No"),
                  selectInput("prot.box","Select Protein", choices=preys,selected=preys[0]),
                  selectInput("box_theme","Select Theme", choices=c("Default","b/w","minimal","classic","dark","linedraw"), selected="Default"),
                  selectInput("box.color","Select Box Color", multiple=FALSE, choices=colors, selected="#5D8AA8"),
                  selectInput("box.file", "Bubble Plot File Type", choices=c(".pdf",".png",".tif",".svg",".eps",".jpg"), selected=".png"),
                  downloadButton('box.down', 'Download Box Plot')
              )
            ),
            fluidRow(
              box(title="Density Plot",status="danger",plotOutput("hist", width="100%",height="500px"),solidHeader = TRUE,collapsible = TRUE),
              box(title="Inputs",status="danger",solidHeader=TRUE,collapsible = TRUE,
                       selectInput("hist.x", "Select X Axis", selected="log2(FoldChange)",choices=c("ln(NSAF)","SpecSum", "log2(FoldChange)", "SaintScore", "logOddsScore","NSAF Score")),
                       selectInput("bait.choice", "Select Baits to Include", multiple=TRUE, choices=baits,selected=baits),
                       selectInput("hist.file", "Select File Type", choices=c(".pdf",".png",".tif",".svg",".jpg"), selected=".png"),
                       downloadButton('hist.down', 'Download Density Plot'))
              )
            ),
    tabItem(tabName = "bubblebeam",
            fluidRow(
              box(width=12,title="Bubble Graph",status="primary",solidHeader=TRUE,collapsible = TRUE,
                  plotOutput("bubbles",width="100%",height="500px"))
            ),
            fluidRow(
              box(title="Data Inputs",status="primary",solidHeader=TRUE,collapsible = TRUE,
                  selectInput("main.x","X axis",selected = "ln(NSAF)",choices=c("ln(NSAF)","SpecSum", "log2(FoldChange)", "SaintScore", "logOddsScore","NSAF Score")),
                  selectInput("main.y","Y axis",selected = "log2(FoldChange)",choices=c("ln(NSAF)","SpecSum", "log2(FoldChange)", "SaintScore", "logOddsScore","NSAF Score")),
                  selectInput("main.size", "Bubble Size", selected = "SpecSum", choices=c("ln(NSAF)","SpecSum", "log2(FoldChange)", "SaintScore", "logOddsScore","NSAF Score")),
                  selectInput(inputId = "main.label",label="Bubble Labels",choices=c("none",">cutoff","all")),
                  radioButtons("main.color","Color",choices=c("crapome","fixed"),selected="crapome",inline=TRUE),
                  sliderInput("main.scale", "Scale Bubble Size", min=0.1, max=100, value=c(1,10))
              ),
              box(title="Visual Inputs",status="primary",solidHeader=TRUE,collapsible = TRUE,
                  selectInput("bubble.color", "Bubble Color", multiple=FALSE, choices=colors, selected="#FF0000"),
                  selectInput("filt.color","CRAPome Filtered Bubble Color",choices=colors,selected="#D2B48C"),
                  selectInput("outline.color", "Outline Color", multiple=FALSE, choices=c("white","black"), selected="black"),
                  selectInput("label.color", "Label Color", multiple=FALSE, choices=c("white","black"), selected="black"),
                  selectInput("theme","Select Theme",choices=c("Default","b/w","minimal","classic","dark","linedraw"),selected="Default"),
                  selectInput("main.file", "Bubble Plot File Type", choices=c(".pdf",".png",".tif",".svg",".eps",".jpg"), selected=".png"),
                  downloadButton('main.down', 'Download Bubble Plot')
              )
            )
    ),
    tabItem(tabName = "network",
            fluidRow(
              box(width=12,title="Network",status="success",solidHeader=TRUE,collapsible = TRUE,
                  visNetworkOutput("networkproxynodes",height="600px")
              )
            ),
            fluidRow(
              box(title="Visuals",status="success",collapsible=TRUE,solidHeader=TRUE,
                  selectInput("PreyColor", "Prey Color", multiple=FALSE, choices=colors,selected="#5D8AA8"),
                  selectInput("BaitColor", "Bait Color", multiple=FALSE, choices=colors,selected="#F0F8FF"),
                  sliderInput("PreySize", "Prey Size",min=1,max=100, value=25),
                  sliderInput("BaitSize", "Bait Size",min=1,max=100, value=25),
                  selectInput("PreyShape","Prey Shape", choices= shapes, selected="circle"),
                  selectInput("BaitShape","Bait Shape", choices= shapes, selected="circle")
              ),
              box(title="Network Options",status="success",collapsible=TRUE,solidHeader=TRUE,
                  actionButton("physics", "Physics", icon=icon("stop",lib = "font-awesome")),
                  radioButtons("smooth", "Smooth Edges",choices=c("On"=TRUE, "Off"=FALSE), selected=FALSE),
                  radioButtons("hierLayout","Hierarchical Layout",choices=c("Yes","No"),selected="No"),
                  downloadButton("network.sif","Export network as SIF"),
                  actionButton("saveJSON","Export network as GEPHI JSON")
              )
            )
    ),
    tabItem(tabName="baits",
            fluidRow(
              box(width=12,title="Bait2Bait Heatmap",status="primary",solidHeader=TRUE,collapsible = TRUE,
                  plotOutput('baittable',width="100%",height="500px")
              )
            ),
            fluidRow(
              box(title="Inputs",status="primary",collapsible=TRUE,solidHeader=TRUE,
                  selectInput("lowcol", "Low Color", multiple=FALSE, choices=colors,selected="#FFFFFF"),
                  selectInput("highcol", "High Color", multiple=FALSE, choices=colors,selected="#000000"),
                  sliderInput("margin", "Plot Margin",min=1,max=100, value=c(20,20))
                  ## ADD DOWNLOAD BOXES
                  ## Try this for downloading of an image
                  # width  <- session$clientData$output_myImage_width
                  # height <- session$clientData$output_myImage_height
              )
            )
    ),
    # Use this as an example to make my heatmaps
    # https://github.com/mblanche/heatmap-app
    tabItem(tabName="table",
            dataTableOutput('table'),
            downloadButton("saveTable", "Save Table")
    ),
    tabItem(tabName="pathway",
            fluidRow(
              box(width=12,title="KEGG Pathway Analysis", status="primary",solidHeader=TRUE,collapsible = TRUE,
                  useShinyjs(),inlineCSS(appCSS_KEGG),
                  h2(id="loading-content-KEGG","Loading Pathways..."),
                  plotOutput("pathPlot",width="100%",height="500px")
              )
            ),
            fluidRow(
              box(title="Inputs",status="primary",collapsible=TRUE,solidHeader=TRUE,
                  actionButton("KEGGbutton","Analyze"),
                  radioButtons("top10KEGG","Top 10 Only", choices=c("Yes"=TRUE,"No"=FALSE),selected=FALSE),
                  selectInput("path_org","Organism", choices=c("mouse","yeast","human"),multiple=FALSE,selected="human"),
                  sliderInput("path_pval", "pValue Cutoff",min=0,max=1, value=0.05),
                  selectInput("path_x","select x-axis",choices=c("pvalue","p.adjust")),
                  selectInput("path_adj","pAdjustMethod", 
                              choices=c("holm", "hochberg", "hommel", "bonferroni", "BH", "BY", "fdr", "none"),
                              multiple=FALSE, selected="bonferroni")
              ),
              box(title="Visuals and Downloads",status="primary",collapsible=TRUE,solidHeader=TRUE,
                  selectInput("KEGG.color", "Select bar color", multiple=FALSE, choices=colors, selected="#000000"),
                  selectInput("KEGG_theme","Select Theme",choices=c("Default","b/w","minimal","classic","dark","linedraw"),selected="Default"),
                  selectInput("pathway.file", "Graph File Type", choices=c(".pdf",".png",".tif",".svg",".eps",".jpg"), selected=".png"),
                  downloadButton("pathway.down", "Download Bar Graph"),
                  downloadButton("pathTable", "Download Raw Data")
              )
            ),
          fluidRow(
              box(width=12,title="Gene Ontology Analysis",status="success",solidHeader=TRUE,collapsible = TRUE,
                  useShinyjs(),inlineCSS(appCSS_GO),
                  h2(id="loading-content-GO","Loading Ontology..."),
                  plotOutput("ontPlot",width="100%",height="500px")
              )
            ),
            fluidRow(
              box(title="Inputs",status="success",collapsible=TRUE,solidHeader=TRUE,
                  actionButton("GObutton","Analyze"),
                  radioButtons("top10GO","Top 10 Only", choices=c("Yes"=TRUE,"No"=FALSE),selected=FALSE),
                  selectInput("path_org","Organism", choices=c("mouse","yeast","human"),multiple=FALSE,selected="human"),
                  selectInput("GO_ont","Select Ontology", choices=c("MF","BP","CC")),
                  sliderInput("path_pval", "pValue Cutoff",min=0,max=1, value=0.05),
                  selectInput("path_x","select x-axis",choices=c("pvalue","p.adjust")),
                  selectInput("path_adj","pAdjustMethod", 
                              choices=c("holm", "hochberg", "hommel", "bonferroni", "BH", "BY", "fdr", "none"),
                              multiple=FALSE, selected="bonferroni")
              ),
              box(title="Visuals and Downloads",status="success",collapsible=TRUE,solidHeader=TRUE,
                  selectInput("GO.color", "Select bar color", multiple=FALSE, choices=colors, selected="#000000"),
                  selectInput("GO_theme","Select Theme",choices=c("Default","b/w","minimal","classic","dark","linedraw"),selected="Default"),
                  selectInput("ontology.file", "Graph File Type", choices=c(".pdf",".png",".tif",".svg",".eps",".jpg"), selected=".png"),
                  downloadButton("ontology.down", "Download Bar Graph"),
                  downloadButton("ontTable", "Download Raw Data")
              )
            )
    )
  )
)
################################ Render ###############################
dashboardPage(
  dashboardHeader(title = "Welcome to APOSTL!"),
  sidebar,
  body
)