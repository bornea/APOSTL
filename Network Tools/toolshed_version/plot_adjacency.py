import sys
def readTab(infile): # read in txt file
    with open(infile, 'r') as input_file:
    # read in tab-delim text
        output = []
        for input_line in input_file:
            input_line = input_line.strip()
            temp = input_line.split('\t')
            output.append(temp)
    return output
def network2JSON(nodes_att_file, edge_file):
	nodes = readTab(nodes_att_file)
	edges = readTab(edge_file)

	start = """{"nodes":  ["""
  	node_numbers = {}
  	cnt=0
  	for i in nodes[1:]:
  		node_numbers[i[0]] = cnt
  		cnt+=1
  		start = start + '{"name":'+'"'+i[0]+'", "EV":'+i[2]+', "group":'+i[1]+"},"
  	start = start[:-1]
  	start = start+"""], "links":  ["""
  	for i in edges:
  		start = start + """{"source":"""+str(node_numbers[i[0]])+""","target":"""+str(node_numbers[i[1]])+""","value":1},"""
  	start = start[:-1]
  	start = start + """]}"""
  	return start
def labelCentrality(nodes_att_file):
	nodes = readTab(nodes_att_file)
	if nodes[0][2] == "eigen":
		return "Eigenvector Centrality"
	if nodes[0][2] == "closeness":
		return "Closeness Centrality"
	if nodes[0][2] == "betweenness":
		return "Betweenness Centrality"
	if nodes[0][2] == "page":
		return "Page Rank"



adjacency_start = """
<!DOCTYPE html>
<html><head>
<meta charset="utf-8">
<style>
.background {fill: #fff;}
line {stroke: #000;}
text.active {fill: red;font-weight:bold;}
</style>
<script src="http://d3js.org/d3.v2.min.js" charset="utf-8"></script>
<script src="https://cdn.rawgit.com/eligrey/Blob.js/0cef2746414269b16834878a8abc52eb9d53e6bd/Blob.js""></script>
<script src="https://cdn.rawgit.com/eligrey/FileSaver.js/e9d941381475b5df8b7d7691013401e171014e89/FileSaver.min.js"></script>
</head>
<aside style = "margin-top: 80px">
<p>Order: <select id="order">
  <option value="name">Name</option>
  <option value="EV">""" + labelCentrality(sys.argv[1]) + """</option>
  <option value="group">Modularity</option>
</select>
<button id="generate">Save as SVG</button>
</aside>

<script>
var margin = {top: 200, right: 0, bottom: 10, left: 200},
    width = 720,
    height = 720;

var x = d3.scale.ordinal().rangeBands([0, width]),
    z = d3.scale.linear().domain([0, 4]).clamp(true),
    c = d3.scale.category10().domain(d3.range(10));

var svg = d3.select("body").append("svg")
    .attr("id","adjmatrix")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom)
    //.style("margin-left", -margin.left + "px")
  .append("g")
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");"""


################# Create JSON formatted Network ################

jsondata = """\njsondata ='""" + network2JSON(sys.argv[1],sys.argv[2])+"'"

################################################################
adjacency_end = """;
var data = JSON.parse(jsondata);

function plot_adjacency(data) {
  var matrix = [],
      nodes = data.nodes,
      n = nodes.length;

  // Compute index per node.
  nodes.forEach(function(node, i) {
    node.index = i;
    node.count = 0;
    matrix[i] = d3.range(n).map(function(j) { return {x: j, y: i, z: 0}; });
  });

  // Convert edges to matrix
  data.links.forEach(function(link) {
    matrix[link.source][link.target].z += link.value;
    matrix[link.target][link.source].z += link.value;
    matrix[link.source][link.source].z += link.value; // self loop
    matrix[link.target][link.target].z += link.value; // self loop

  });

  // order based on modularity, name and eigenvector centrality
  var orders = {
    name: d3.range(n).sort(function(a, b) { return d3.ascending(nodes[a].name, nodes[b].name); }),
    EV: d3.range(n).sort(function(a, b) { return nodes[b].EV - nodes[a].EV; }),
    group: d3.range(n).sort(function(a, b) { return nodes[b].group - nodes[a].group; })
  };

  // The default sort order.
  x.domain(orders.name);

  svg.append("rect")
      .attr("class", "background")
      .attr("width", width)
      .attr("height", height)
      .attr("fill-opacity",0);

  var row = svg.selectAll(".row")
      .data(matrix)
    .enter().append("g")
      .attr("class", "row")
      .attr("transform", function(d, i) { return "translate(0," + x(i) + ")"; })
      .each(row);

  row.append("line")
      .attr("x2", width)
      .attr("stroke","black");

  row.append("text")
      .attr("x", -6)
      .attr("y", x.rangeBand() / 2)
      .attr("dy", ".32em")
      .attr("text-anchor", "end")
      .attr("font-size", 850 * (1/nodes.length))
      .text(function(d, i) { return nodes[i].name; });

  var column = svg.selectAll(".column")
      .data(matrix)
    .enter().append("g")
      .attr("class", "column")
      .attr("transform", function(d, i) { return "translate(" + x(i) + ")rotate(-90)"; });

  column.append("line")
      .attr("x1", -width)
      .attr("stroke","black");

  column.append("text")
      .attr("x", 6)
      .attr("y", x.rangeBand() / 2)
      .attr("dy", ".32em")
      .attr("text-anchor", "start")
      .style("font-style","15px")
      .attr("font-size", 850 * (1/nodes.length))
      .text(function(d, i) { return nodes[i].name; });

  function row(row) {
    var cell = d3.select(this).selectAll(".cell")
        .data(row.filter(function(d) { return d.z; }))
      .enter().append("rect")
        .attr("class", "cell")
        .attr("x", function(d) { return x(d.x); })
        .attr("width", x.rangeBand())
        .attr("height", x.rangeBand())
        .style("fill-opacity", function(d) { return 0.4 * d.z; })
        .style("fill", function(d) { return nodes[d.x].group == nodes[d.y].group ? c(nodes[d.x].group) : null; })
        .on("mouseover", mouseover)
        .on("mouseout", mouseout);
  }

  function mouseover(p) {
    d3.selectAll(".row text").classed("active", function(d, i) { return i == p.y; });
    d3.selectAll(".column text").classed("active", function(d, i) { return i == p.x; });
  }

  function mouseout() {
    d3.selectAll("text").classed("active", false);
  }

  d3.select("#order").on("change", function() {
    clearTimeout(timeout);
    order(this.value);
  });


  function order(value) {
    x.domain(orders[value]);

    var t = svg.transition().duration(2500);

    t.selectAll(".row")
        .delay(function(d, i) { return x(i) * 4; })
        .attr("transform", function(d, i) { return "translate(0," + x(i) + ")"; })
      .selectAll(".cell")
        .delay(function(d) { return x(d.x) * 4; })
        .attr("x", function(d) { return x(d.x); });

    t.selectAll(".column")
        .delay(function(d, i) { return x(i) * 4; })
        .attr("transform", function(d, i) { return "translate(" + x(i) + ")rotate(-90)"; });
  }

  var timeout = setTimeout(function() {
    order("group");
    d3.select("#order").property("selectedIndex", 2).node().focus();
  }, 5000);


};
plot_adjacency(data);
d3.select("#generate")
    .on("click", writeDownloadLink);

function writeDownloadLink(){ //saving entire file instead of just SVG element
    try {
        var isFileSaverSupported = !!new Blob();
    } catch (e) {
        alert("blob not supported");
    }

    var html = document.getElementById("adjmatrix").outerHTML

    var blob = new Blob([html], {type: "image/svg+xml"});
    saveAs(blob, "myProfile.svg");
};
</script>


</body></html>
"""
with open(sys.argv[3],"w") as x:
	x.write(adjacency_start+jsondata+adjacency_end)
