################################################################################
# R-code: APOSTL Interactive Environment Shiny Server
# Author: Brent Kuenzi
################################################################################
shinyServer(function(input, output, session) {  
  
  
################################################################################
############################ Plotting and Analyses #############################
################################################################################
  
######################### Cytoscape Network ####################################  
  jsnetwork <- reactive({
    str_x=paste0(input$main.x)
    str_y=paste0(input$main.y)
    str_color=paste0(input$main.color)
    str_size=paste0(input$main.size)
    str_cutoff= paste0(input$main.cutoff)
    str_label= input$main.label
    scl_size = input$main.scale
    main.data2 <- main.data[!(main.data$PreyGene %in% input$main.exclude),]
    main.data2 <- subset(main.data2, main.data2[(colnames(main.data2)=="log2(FoldChange)")] >= input$main.change)
    main.data2 <- subset(main.data2, main.data2[(colnames(main.data2)=="NSAF Score")] >= input$NSAFscore)
    cytoscape <- subset(main.data2, SaintScore>=as.numeric(str_cutoff), 
                        select = c(str_x,str_y,"Bait","PreyGene",str_size))
    id <- c(as.character(cytoscape$PreyGene),as.character(cytoscape$Bait))
    source <- as.character(cytoscape$Bait)
    name <- c(as.character(cytoscape$PreyGene),as.character(cytoscape$Bait))
    target <- as.character(cytoscape$PreyGene)
    node.data <- data.frame(id,name)
    edge.data <- data.frame(source,target)
    node.data$color <- rep(input$node.color, nrow(node.data))
    node.data$color[node.data$name %in% cytoscape$Bait] <- input$bait.color
    node.data$shape <- rep(input$node.shape, nrow(node.data))
    node.data$shape[node.data$name %in% cytoscape$Bait] <- input$bait.shape
    edge.data$color <- rep(input$edge.color, nrow(edge.data))
    network <- createCytoscapeJsNetwork(node.data, edge.data,
                                        edgeTargetShape="none",nodeLabelColor=input$node.label.color)
    rcytoscapejs(network$nodes, network$edges, showPanzoom=TRUE, 
                 layout=input$net.layout, highlightConnectedNodes=FALSE)
  })
############################ JSON  Cytoscape Network ###########################
  jsnetwork_flat <- reactive({
    str_x=paste0(input$main.x)
    str_y=paste0(input$main.y)
    str_color=paste0(input$main.color)
    str_size=paste0(input$main.size)
    str_cutoff= paste0(input$main.cutoff)
    str_label= input$main.label
    scl_size = input$main.scale
    main.data2 <- main.data[!(main.data$PreyGene %in% input$main.exclude),]
    main.data2 <- subset(main.data2, main.data2[(colnames(main.data2)=="log2(FoldChange)")] >= input$main.change)
    main.data2 <- subset(main.data2, main.data2[(colnames(main.data2)=="NSAF Score")] >= input$NSAFscore)
    cytoscape <- subset(main.data2, SaintScore>=as.numeric(str_cutoff), 
                        select = c(str_x,str_y,"Bait","PreyGene",str_size))
    id <- c(as.character(cytoscape$PreyGene),as.character(cytoscape$Bait))
    source <- as.character(cytoscape$Bait)
    name <- c(as.character(cytoscape$PreyGene),as.character(cytoscape$Bait))
    target <- as.character(cytoscape$PreyGene)
    node.data <- data.frame(id,name)
    edge.data <- data.frame(source,target)
    node.data$color <- rep("#888888", nrow(node.data))
    node.data$color[node.data$name %in% cytoscape$Bait] <- "#FF0000"
    network <- toJSON(as.list(createCytoscapeJsNetwork(node.data, edge.data)))
  })
############################ SIF  Cytoscape Network ###########################
jsnetwork_sif <- reactive({
  str_cutoff= paste0(input$main.cutoff)
  main.data2 <- main.data[!(main.data$PreyGene %in% input$main.exclude),]
  main.data2 <- subset(main.data2, main.data2[(colnames(main.data2)=="log2(FoldChange)")] >= input$main.change)
  main.data2 <- subset(main.data2, main.data2[(colnames(main.data2)=="NSAF Score")] >= input$NSAFscore)
  main.data2$interaction <- rep("pp",times=length(main.data2$PreyGene))
  cytoscape <- subset(main.data2, SaintScore>=as.numeric(str_cutoff), 
                      select=c("Bait","interaction","PreyGene"))
  colnames(cytoscape) <- c("node1","interaction","node2")
  cytoscape
})

############################ Bubblebeam Plot ##################################
  bubblebeam <- reactive({
    str_x=paste0(input$main.x)
    str_y=paste0(input$main.y)
    str_color=paste0(input$main.color)
    str_size=paste0(input$main.size)
    str_cutoff= paste0(input$main.cutoff)
    str_label= input$main.label
    scl_size = input$main.scale
    main.data2 <- main.data[!(main.data$PreyGene %in% input$main.exclude),]
    main.data2 <- subset(main.data2, main.data2[(colnames(main.data2)=="log2(FoldChange)")] >= input$main.change)
    main.data2 <- subset(main.data2, main.data2[(colnames(main.data2)=="NSAF Score")] >= input$NSAFscore)
    
    c <- subset(main.data2, SaintScore>=as.numeric(str_cutoff), select = c(str_x,str_y,"Bait","PreyGene",str_size))
    colnames(c) <- c("x","y","Bait","PreyGene","size")
    p <- ggplot(data=c, x=x, y=y,size=size)+ geom_point(data=c, aes(x=x, y=y,size=size), fill=input$bubble.color,color=input$outline.color,pch=21) + scale_size(range=scl_size)
    p <- p + labs(x=str_x, y=str_y, size=str_size) + scale_size(range=scl_size)
    if(length(levels(c$Bait) > 1)) {p <- p + facet_wrap(~Bait)}
    if(str_label== 'all' & length(c$x)>=1) {set.seed=42; p <- p + ggrepel::geom_text_repel(data=c, aes(x=x,y=y,label=PreyGene),
                                                                    segment.color="black",force=1, fontface='bold',
                                                                    box.padding=unit(0.25,'lines'), 
                                                                    point.padding=unit(0.25,'lines'),
                                                                    max.iter=1e4, segment.size=0.5)}
    if(input$theme== "classic") {p <- p + theme_classic()}
    if(input$theme== "b/w") {p <- p + theme_bw()}
    if(input$theme== "minimal") {p <- p + theme_minimal()}
    if(input$theme== "dark") {p <- p + theme_dark()}
    if(input$theme== "linedraw") {p <- p + theme_linedraw()}
    
    
    
    if(str_color=="crapome") {
      a <- subset(main.data2, CrapomePCT <80 & SaintScore >=as.numeric(str_cutoff), select = c(str_x,str_y,"Bait","PreyGene",str_size,"CrapomePCT"))
      b <- subset(main.data2, CrapomePCT >=80 & SaintScore >=as.numeric(str_cutoff), select = c(str_x,str_y,"Bait","PreyGene",str_size,"CrapomePCT"))
      colnames(a) <- c("x","y","Bait","PreyGene","size", "CrapomePCT")
      colnames(b) <- c("x","y","Bait","PreyGene","size","CrapomePCT")
      p <- ggplot(data=a, x=x, y=y,size=size) + geom_point(data=a,aes(x=x,y=y,size=size),fill=input$filt.color,pch=21,color=input$outline.color) +
        scale_size(range=scl_size)
      if(length(levels(a$Bait) > 1)) {p <- p + facet_wrap(~Bait)}
      if(str_label== "all" & length(a$x)>=1) {set.seed=42; p <- p + ggrepel::geom_text_repel(data=a, aes(x=x,y=y,label=PreyGene),
                                                                      segment.color=input$label.color,force=1, fontface='bold',
                                                                      box.padding=unit(0.25,'lines'), 
                                                                      point.padding=unit(0.25,'lines'),
                                                                      color=input$label.color,
                                                                      max.iter=1e4, segment.size=0.5)}
      
      p <- p + geom_point(data=b, aes(x=x, y=y, size=size, fill=CrapomePCT),color=input$outline.color,pch=21) + 
        scale_fill_gradient(limits=c(80, 100), low=input$filt.color, high=input$bubble.color) + 
        labs(colour="CRAPome Probability \nof Specific Interaction (%)", x=str_x, y=str_y,size=str_size)
      if(str_label== '>cutoff' & length(b$x)>=1) {set.seed=42; p <- p + ggrepel::geom_text_repel(data=b, aes(x=x,y=y,label=PreyGene),
                                                                      segment.color=input$label.color,force=1, fontface='bold',
                                                                      box.padding=unit(0.25,'lines'), 
                                                                      point.padding=unit(0.25,'lines'),
                                                                      color=input$label.color,
                                                                      max.iter=1e4, segment.size=0.5)}
      if(str_label== 'all' & length(b$x)>=1) {set.seed=42; p <- p + ggrepel::geom_text_repel(data=b, aes(x=x,y=y,label=PreyGene),
                                                                      segment.color=input$label.color,force=1, fontface='bold',
                                                                      box.padding=unit(0.25,'lines'), 
                                                                      point.padding=unit(0.25,'lines'),
                                                                      color=input$label.color,
                                                                      max.iter=1e4, segment.size=0.5)}
      if(input$theme== "classic") {p <- p + theme_classic()}
      if(input$theme== "b/w") {p <- p + theme_bw()}
      if(input$theme== "minimal") {p <- p + theme_minimal()}
      if(input$theme== "dark") {p <- p + theme_dark()}
      if(input$theme== "linedraw") {p <- p + theme_linedraw()}
    }
    p <- p + theme(axis.title.y = element_text(size=rel(1.5),face="bold"),
                   axis.title.x = element_text(size=rel(1.5),face="bold"),
                   axis.text.x = element_text(size=rel(1.5),face="bold"),
                   axis.text.y = element_text(size=rel(1.5),face="bold"),
                   strip.text.x = element_text(size=rel(1.5),face="bold"),
                   legend.text = element_text(face="bold"),
                   legend.title = element_text(face="bold"))
}) 
############################ Density Plots ####################################
hist_plot <- reactive({
  str_cutoff= paste0(input$main.cutoff)
  str_x=paste0(input$hist.x)
  main.data2 <- main.data[!(main.data$PreyGene %in% input$main.exclude),]
  main.data2 <- subset(main.data2, select=c(str_x,"Bait"))
  colnames(main.data2) <- c("x","Bait")
  main.data2 <- subset(main.data2, main.data2$Bait %in% input$bait.choice)
  ggplot(main.data2, aes(x=x,fill=Bait)) + geom_density(alpha=0.3) + 
    scale_fill_brewer(palette = "Set1") + labs(x=NULL,y="Density") +
    theme(axis.title.y = element_text(size=rel(1.5),face="bold")) + 
    theme(axis.text.x = element_text(size=rel(1.5),face="bold"),
          axis.text.y = element_text(size=rel(1.5),face="bold"),
          legend.text = element_text(face="bold"),
          legend.title = element_text(face="bold"))
})
############################ Replicate Correlations ###########################
repl_corr <- reactive({
  x1 = inter_df[input$corr_x == inter_df$V1,]$V4
  y1 = inter_df[input$corr_y == inter_df$V1,]$V4
  if(input$corr_log == "No"){
  p <- ggplot(x=x1,y=y1) + geom_point(aes(x=x1,y=y1),size=rel(5),pch=21,color="black",fill=input$corr.color) + 
       ylab(input$corr_y) + xlab(input$corr_x) + geom_smooth(aes(x=x1,y=y1),method="lm",color="black",linetype="dashed")
  p <- p + geom_label(aes(label=paste0("R-squared = ",round(summary(lm(y1~x1))$r.squared,2)),
                     x=max(x1)*0.1,y=max(y1)*0.75),size=rel(5), fontface="bold",
                     label.padding=unit(0.5,"lines"))}
  if(input$corr_log == "Yes"){
    x2 <- log10(x1); y2 <- log10(y1)
    x2[!is.finite(x2)] <- 0; y2[!is.finite(y2)] <- 0
    p <- ggplot(x=x2,y=y2) + geom_point(aes(x=x2,y=y2),size=rel(5),pch=21,color="black",fill=input$corr.color) + 
      ylab(input$corr_y) + xlab(input$corr_x) + geom_smooth(aes(x=x2,y=y2),method="lm",color="black",linetype="dashed")
    p <- p + geom_label(aes(label=paste0("R-squared = ",round(summary(lm(y2~x2))$r.squared,2)),
                            x=max(x2)*0.2,y=max(y2)*0.8),size=rel(5), fontface="bold",
                        label.padding=unit(0.5,"lines"))}
  if(input$corr_theme== "classic") {p <- p + theme_classic()}
  if(input$corr_theme== "b/w") {p <- p + theme_bw()}
  if(input$corr_theme== "minimal") {p <- p + theme_minimal()}
  if(input$corr_theme== "dark") {p <- p + theme_dark()}
  if(input$corr_theme== "linedraw") {p <- p + theme_linedraw()}
  p <- p + theme(axis.title.y = element_text(size=rel(1.5),face="bold"),
                 axis.title.x = element_text(size=rel(1.5),face="bold"),
                 axis.text.x = element_text(size=rel(1.5),face="bold"),
                 axis.text.y = element_text(size=rel(1.5),face="bold"),
                 strip.text.x = element_text(size=rel(1.5),face="bold"),
                 legend.text = element_text(face="bold"),
                 legend.title = element_text(face="bold"))
  
})
############################ Protein Box Plots ################################
prot_box <- reactive({
  protein <- subset(main.data,main.data$PreyGene == input$prot.box)
  protein <- unique(protein$Prey)
  prot_filt <- inter_df[protein == inter_df$V3,]
  p <- ggplot(prot_filt,aes(x=V2,y=V4)) + geom_boxplot(fill=input$box.color) + 
    ylab("Abundance") + xlab("")
  if(input$prot_log == "Yes"){
    prot_filt$V4 <- log10(prot_filt$V4)
    prot_filt$V4[!is.finite(prot_filt$V4)] <- 0
    p <- ggplot(prot_filt,aes(x=V2,y=V4)) + geom_boxplot(fill=input$box.color) + 
    ylab("Abundance") + xlab("")}
  if(input$box_theme== "classic") {p <- p + theme_classic()}
  if(input$box_theme== "b/w") {p <- p + theme_bw()}
  if(input$box_theme== "minimal") {p <- p + theme_minimal()}
  if(input$box_theme== "dark") {p <- p + theme_dark()}
  if(input$box_theme== "linedraw") {p <- p + theme_linedraw()}
  p <- p + theme(axis.title.y = element_text(size=rel(1.5),face="bold"),
                 axis.title.x = element_text(size=rel(1.5),face="bold"),
                 axis.text.x = element_text(size=rel(1.5),face="bold",angle=45,hjust=1),
                 axis.text.y = element_text(size=rel(1.5),face="bold"),
                 strip.text.x = element_text(size=rel(1.5),face="bold"),
                 legend.text = element_text(face="bold"),
                 legend.title = element_text(face="bold"))
  })
############################ Display Filtered SAINT table #######################
table_display <- reactive({
  str_cutoff= paste0(input$main.cutoff)
  main.data2 <- main.data[!(main.data$PreyGene %in% input$main.exclude),]
  main.data2 <- subset(main.data2, main.data2[(colnames(main.data2)=="log2(FoldChange)")] >= input$main.change)
  main.data2 <- subset(main.data2, main.data2[(colnames(main.data2)=="NSAF Score")] >= input$NSAFscore)
  table <- subset(main.data2, SaintScore>=as.numeric(str_cutoff))
  table
}) 
############################ KEGG Pathway Graph ################################
pathway_graph <- eventReactive(input$KEGGbutton,{
  toggle(id = "loading-content-KEGG")
  str_val <- input$path_x
  str_cutoff= paste0(input$main.cutoff)
  main.data2 <- main.data[!(main.data$PreyGene %in% input$main.exclude),]
  main.data2 <- subset(main.data2, main.data2[(colnames(main.data2)=="log2(FoldChange)")] >= input$main.change)
  main.data2 <- subset(main.data2, main.data2[(colnames(main.data2)=="NSAF Score")] >= input$NSAFscore)
  table <- subset(main.data2, SaintScore>=as.numeric(str_cutoff))
  preys <- unique(as.character(table$PreyGene))
  EG_IDs <- list()
  for(i in 1:length(preys)){
    EG_IDs[i] <- mygene::query(preys[i])$hits$entrezgene[1]
  }
  
  pathways <- enrichKEGG(EG_IDs, 
                         organism = paste0(input$path_org), 
                         pvalueCutoff = as.numeric(paste0(input$path_pval)),
                         pAdjustMethod = paste0(input$path_adj),
                         readable=TRUE)
  
  pathways <- as.data.frame(summary(pathways))
  pathways$x <- factor(pathways$Description,levels=rev(pathways$Description))
  if(input$top10KEGG == TRUE) {pathways <- pathways[1:10,]}
  if(str_val=="pvalue"){
    p <- ggplot(data=pathways, aes(y=-log(pvalue), x=x)) + 
      geom_bar(stat="identity",fill=input$KEGG.color) + coord_flip()}
  if(str_val=="p.adjust"){
    p <- ggplot(data=pathways, aes(y=-log(p.adjust), x=x)) + 
      geom_bar(stat="identity",fill=input$KEGG.color) + coord_flip()}
  
  if(input$KEGG_theme== "classic") {p <- p + theme_classic()}
  if(input$KEGG_theme== "b/w") {p <- p + theme_bw()}
  if(input$KEGG_theme== "minimal") {p <- p + theme_minimal()}
  if(input$KEGG_theme== "dark") {p <- p + theme_dark()}
  if(input$KEGG_theme== "linedraw") {p <- p + theme_linedraw()}
  
  p <- p + xlab("")+theme(axis.title.y = element_text(size=rel(1.5),face="bold"),
                          axis.title.x = element_text(size=rel(1.5),face="bold"),
                          axis.text.x = element_text(size=rel(1.5),face="bold"),
                          axis.text.y = element_text(size=rel(1.5),face="bold"),
                          strip.text.x = element_text(size=rel(1.5),face="bold"),
                          legend.text = element_text(face="bold"),
                          legend.title = element_text(face="bold"))
})

############################ KEGG Pathway as Table #############################
pathway_table <- reactive({
  str_val <- input$path_x
  str_cutoff= paste0(input$main.cutoff)
  main.data2 <- main.data[!(main.data$PreyGene %in% input$main.exclude),]
  main.data2 <- subset(main.data2, main.data2[(colnames(main.data2)=="log2(FoldChange)")] >= input$main.change)
  main.data2 <- subset(main.data2, main.data2[(colnames(main.data2)=="NSAF Score")] >= input$NSAFscore)
  table <- subset(main.data2, SaintScore>=as.numeric(str_cutoff))
  preys <- unique(as.character(table$PreyGene))
  EG_IDs <- list()
  for(i in 1:length(preys)){
    EG_IDs[i] <- mygene::query(preys[i])$hits$entrezgene[1]
  }

  pathways <- enrichKEGG(EG_IDs, 
                         organism = paste0(input$path_org), 
                         pvalueCutoff = as.numeric(input$path_pval),
                         pAdjustMethod = paste0(input$path_adj),
                         readable=TRUE)
  summary(pathways)
})
############################ GeneGO Graph #####################################
ontology_graph <- eventReactive(input$GObutton,{
  toggle(id = "loading-content-GO")
  str_val <- input$path_x
  str_cutoff= paste0(input$main.cutoff)
  main.data2 <- main.data[!(main.data$PreyGene %in% input$main.exclude),]
  main.data2 <- subset(main.data2, main.data2[(colnames(main.data2)=="log2(FoldChange)")] >= input$main.change)
  main.data2 <- subset(main.data2, main.data2[(colnames(main.data2)=="NSAF Score")] >= input$NSAFscore)
  table <- subset(main.data2, SaintScore>=as.numeric(str_cutoff))
  preys <- unique(as.character(table$PreyGene))
  EG_IDs <- list()
  for(i in 1:length(preys)){
    EG_IDs[i] <- mygene::query(preys[i])$hits$entrezgene[1]
  }
  
  
  pathways <- enrichGO(EG_IDs, 
                       organism = paste0(input$path_org),
                       pvalueCutoff = as.numeric(paste0(input$path_pval)),
                       pAdjustMethod = paste0(input$path_adj),
                       readable=TRUE,
                       ont = input$GO_ont)
  pathways <- as.data.frame(summary(pathways))
  pathways$x <- factor(pathways$Description,levels=rev(pathways$Description))
  if(input$top10GO == TRUE) {pathways <- pathways[1:10,]}
  if(str_val=="pvalue"){
    p <- ggplot(data=pathways, aes(y=-log(pvalue), x=x)) + 
      geom_bar(stat="identity",fill=input$GO.color) + coord_flip()}
  if(str_val=="p.adjust"){
    p <- ggplot(data=pathways, aes(y=-log(p.adjust), x=x)) + 
      geom_bar(stat="identity",fill=input$GO.color) + coord_flip()}
  
  if(input$GO_theme== "classic") {p <- p + theme_classic()}
  if(input$GO_theme== "b/w") {p <- p + theme_bw()}
  if(input$GO_theme== "minimal") {p <- p + theme_minimal()}
  if(input$GO_theme== "dark") {p <- p + theme_dark()}
  if(input$GO_theme== "linedraw") {p <- p + theme_linedraw()}
  
  p <- p + xlab("")+theme(axis.title.y = element_text(size=rel(1.5),face="bold"),
                          axis.title.x = element_text(size=rel(1.5),face="bold"),
                          axis.text.x = element_text(size=rel(1.5),face="bold"),
                          axis.text.y = element_text(size=rel(1.5),face="bold"),
                          strip.text.x = element_text(size=rel(1.5),face="bold"),
                          legend.text = element_text(face="bold"),
                          legend.title = element_text(face="bold"))
})
############################ GeneGO as Table ###################################
ontology_table <- reactive({
  str_val <- input$path_x
  str_cutoff= paste0(input$main.cutoff)
  main.data2 <- main.data[!(main.data$PreyGene %in% input$main.exclude),]
  main.data2 <- subset(main.data2, main.data2[(colnames(main.data2)=="log2(FoldChange)")] >= input$main.change)
  main.data2 <- subset(main.data2, main.data2[(colnames(main.data2)=="NSAF Score")] >= input$NSAFscore)
  table <- subset(main.data2, SaintScore>=as.numeric(str_cutoff))
  preys <- unique(as.character(table$PreyGene))
  EG_IDs <- list()
  for(i in 1:length(preys)){
    EG_IDs[i] <- mygene::query(preys[i])$hits$entrezgene[1]
  }

  pathways <- enrichGO(EG_IDs, 
                       organism = paste0(input$path_org), 
                       pvalueCutoff = as.numeric(input$path_pval),
                       pAdjustMethod = paste0(input$path_adj),
                       readable=TRUE,
                       ont = input$GO_ont)
  summary(pathways)
  })

###############################################################################
############################ Rendering and Saving Files #######################
###############################################################################

# Render Replicate Correlation
  output$corr=renderPlot({
    print(repl_corr())
  })
# Render Box Plot
  output$box=renderPlot({
    print(prot_box())
  })
# Render Density Plot
  output$hist=renderPlot({
    print(hist_plot())
  }) 
# Render Bubble Graph
  output$bubbles=renderPlot({
     print(bubblebeam())
   })
# Render Cytoscape Network
  output$network=renderRcytoscapejs({
    jsnetwork()
  })
# Render SAINT Table
  output$table=renderDataTable({
    table_display()
  })
# Render Pathway Analysis Graph
  output$pathPlot=renderPlot({
  hide(id = "loading-content-KEGG",time=0.01)
  print(pathway_graph())
  hide(id = "loading-content-KEGG")
  })
# Save Pathway Analysis Table
  output$pathTable = downloadHandler(
  filename = function() {
    paste(Sys.Date(), "_KEGG.txt",sep='')}, 
  content= function(file){
    x = pathway_table()
    write.table(x, file, quote=FALSE,
                sep = "\t", row.names=FALSE)})
# Render Gene Ontology Graph
  output$ontPlot=renderPlot({
  hide(id = "loading-content-GO",time=0.01)
  print(ontology_graph())
  hide(id = "loading-content-GO")
  })
# Save Gene Ontology Table
  output$ontTable = downloadHandler(
  filename = function() {
    paste(Sys.Date(), "_GO_",as.character(input$GO_ont),".txt",sep='')}, 
  content= function(file){
    x = ontology_table()
    write.table(x, file, quote=FALSE,
                sep = "\t", row.names=FALSE)})
# Save SAINT table
  output$saveTable = downloadHandler(
    filename = function() {
    paste(Sys.Date(), "_dataTable.txt",sep='')}, 
    content= function(file){
      x = table_display()
      write.table(x, file, quote=FALSE,
        sep = "\t", row.names=FALSE)})
# Save Network as sif
output$network.sif = downloadHandler(
  filename = function() {
    paste(Sys.Date(), "_network.sif",sep='')}, 
  content= function(file){
    x = jsnetwork_sif()
    write.table(x, file, quote=FALSE,
                sep = "\t", row.names=FALSE, col.names=FALSE)})
# Download Bubble Graph
output$main.down = downloadHandler(filename = function() {
  paste(Sys.Date(), "_bubbleplot",input$main.file,sep='')},
  content = function(file){
    p=bubblebeam()
    if(input$main.file == ".png"){png(file); print(p); dev.off()}
    if(input$main.file == ".pdf"){pdf(file); print(p); dev.off()}
    if(input$main.file == ".tif"){tiff(file); print(p); dev.off()}
    if(input$main.file == ".jpg"){jpeg(file); print(p); dev.off()}
    if(input$main.file == ".svg"){svg(file); print(p); dev.off()}
    if(input$main.file == ".eps"){postscript(file); print(p); dev.off()}
    })
# Download Density Plot
output$hist.down = downloadHandler(filename = function() {
  paste(Sys.Date(), "_density_plot",input$hist.file,sep='')},
  content = function(file){
    p=hist_plot()
    if(input$hist.file == ".png"){png(file); print(p); dev.off()}
    if(input$hist.file == ".pdf"){pdf(file); print(p); dev.off()}
    if(input$hist.file == ".tif"){tiff(file); print(p); dev.off()}
    if(input$hist.file == ".jpg"){jpeg(file); print(p); dev.off()}
    })
# Download KEGG Pathway Graph
output$pathway.down = downloadHandler(filename = function() {
  paste(Sys.Date(), "_KEGG",input$pathway.file,sep='')},
  content = function(file){
    p=pathway_graph()
    if(input$pathway.file == ".png"){png(file); print(p); dev.off()}
    if(input$pathway.file == ".pdf"){pdf(file); print(p); dev.off()}
    if(input$pathway.file == ".tif"){tiff(file); print(p); dev.off()}
    if(input$pathway.file == ".jpg"){jpeg(file); print(p); dev.off()}
    if(input$pathway.file == ".svg"){svg(file); print(p); dev.off()}
    if(input$pathway.file == ".eps"){postscript(file); print(p); dev.off()}
    })
# Download Gene Ontology Graph
output$ontology.down = downloadHandler(filename = function() {
  paste(Sys.Date(), "_GO",input$ontology.file,sep='')},
  content = function(file){
    p=ontology_graph()
    if(input$ontology.file == ".png"){png(file); print(p); dev.off()}
    if(input$ontology.file == ".pdf"){pdf(file); print(p); dev.off()}
    if(input$ontology.file == ".tif"){tiff(file); print(p); dev.off()}
    if(input$ontology.file == ".jpg"){jpeg(file); print(p); dev.off()}
    if(input$ontology.file == ".svg"){svg(file); print(p); dev.off()}
    if(input$ontology.file == ".eps"){postscript(file); print(p); dev.off()}
    })

## Save cytoscape network image
# Critical assistance from Augustin Luna (Memorial Sloan Kettering) to get this working  
observeEvent(input$saveImage, {
  session$sendCustomMessage(type="saveImage", message="NULL")
})

# Save cytoscape network as JSON
output$saveJSON = downloadHandler(filename="network.json",
  content = function(file){
    write(jsnetwork_flat(),file=file)
    })
# Save Replicate Correlation Graph
output$correlation.down = downloadHandler(filename = function() {
  paste(Sys.Date(),"_",input$corr_y,"~",input$corr_x,input$correlation.file,sep='')},
  content = function(file){
    p=repl_corr()
    if(input$correlation.file == ".png"){png(file); print(p); dev.off()}
    if(input$correlation.file == ".pdf"){pdf(file); print(p); dev.off()}
    if(input$correlation.file == ".tif"){tiff(file); print(p); dev.off()}
    if(input$correlation.file == ".jpg"){jpeg(file); print(p); dev.off()}
    if(input$correlation.file == ".svg"){svg(file); print(p); dev.off()}
    if(input$correlation.file == ".eps"){postscript(file); print(p); dev.off()}
    })
    #ggsave(file,plot = p,dpi=600)})

# Save Box Plot
output$box.down = downloadHandler(filename = function() {
  paste(Sys.Date(),input$prot.box,"boxplot",input$box.file,sep='_')},
  content = function(file){
    p=prot_box()
    if(input$box.file == ".png"){png(file); print(p); dev.off()}
    if(input$box.file == ".pdf"){pdf(file); print(p); dev.off()}
    if(input$box.file == ".tif"){tiff(file); print(p); dev.off()}
    if(input$box.file == ".jpg"){jpeg(file); print(p); dev.off()}
    if(input$box.file == ".svg"){svg(file); print(p); dev.off()}
    if(input$box.file == ".eps"){postscript(file); print(p); dev.off()}
    })
# Save Parameters
output$param = downloadHandler(filename = function() {
  paste(Sys.Date(),"parameter.txt",sep='_')},
  content = function(file){
    main.data2 <- main.data[!(main.data$PreyGene %in% input$main.exclude),]
    main.data2 <- subset(main.data2, main.data2[(colnames(main.data2)=="log2(FoldChange)")] >= input$main.change)
    main.data2 <- subset(main.data2, main.data2[(colnames(main.data2)=="NSAF Score")] >= input$NSAFscore)
    table <- subset(main.data2, SaintScore>=as.numeric(input$main.cutoff))
    writeLines(con=file,
               text=c(paste0(Sys.Date()," ","APOSTL Analysis Parameters"),
                      "",
                      paste0("The following global cutoffs were applied to ",length(main.data$PreyGene),
                             " interactions to generate a list of ",length(table$PreyGene)," high confidence interactions",sep = ''),
                      paste0("\tSaintScore Cutoff: ",input$main.cutoff),
                      paste0("\tFoldChange Cutoff: ",input$main.change),
                      "",
                      "The following proteins have been excluded from the analysis:",
                      paste0("\t",input$main.exclude)
                      )
               )
    })
# END
})