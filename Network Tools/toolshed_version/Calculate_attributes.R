library(igraph)
library(dplyr)
library(ggplot2)

NetworkAttributes <- function(edges,centrality = "eigenvector",community="fast.greedy") {
  "This function takes in a SIF formatted dataframe and returns a node attribute dataframe."
  "It performs community optimization and calculates a centrality metric."
  nodes <- data.frame(V1 = unique(c(as.character(edges[,1]),as.character(edges[,2]))))
  graph <- graph.data.frame(edges, directed = FALSE, vertices = nodes)
  graph = simplify(graph)
  if(community == "optimal"){V(graph)$comm <- membership(optimal.community(graph))} # computationally intensive
  if(community == "fast.greedy"){V(graph)$comm <- membership(fastgreedy.community(graph))} # for larger datasets\
  if(community == "edge.betweenness"){V(graph)$comm <- membership(edge.betweenness.community(graph))}
  if(community == "walk.trap"){V(graph)$comm <- membership(walktrap.community(graph))}
  if(community == "spin.glass"){V(graph)$comm <- membership(spinglass.community(graph))}
  if(community == "leading.eigenvector"){V(graph)$comm <- membership(leading.eigenvector.community(graph))}
  if(community == "label.propagation"){V(graph)$comm <- membership(label.propagation.community(graph))}
  if(community == "multilevel"){V(graph)$comm <- membership(multilevel.community(graph))}

  if(centrality == "closeness"){V(graph)$closeness <- centralization.closeness(graph)$res}
  if(centrality == "betweenness"){V(graph)$betweenness <- centralization.betweenness(graph)$res}
  if(centrality == "eigenvector"){V(graph)$eigen <- centralization.evcent(graph)$vector}
  if(centrality == "PageRank"){V(graph)$page <- page_rank(graph)$vector}

  return(get.data.frame(graph, what = "vertices"))
}
#calculate_attributes(nodes,edgelist,centrality = "betweenness",community="fastgreedy")
args <- commandArgs(trailingOnly = TRUE)
edgelist <- read.table(file=as.character(args[1]), stringsAsFactors = FALSE,sep="\t",header=FALSE)
write.table(NetworkAttributes(edgelist,args[2],args[3]),"node_attr.txt",sep="\t",quote=FALSE,row.names=FALSE)
