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
def network2JSON(node_attr_file,edge_file):
    nodes = readTab(node_attr_file)
    edges = readTab(edge_file)

    connections = {}
    communities = {}
    for i in nodes[1:]:
      communities[i[0]] = i[1]
    for i in nodes[1:]:
        temp = []
        for j in edges:
            if i[0] in j:
                if i[0] != j[0]:
                    temp.append(str(communities[j[0]]) + "." + str(j[0]))
                if i[0] != j[1]:
                    temp.append(str(communities[j[1]])+"."+str(j[1]))
        connections[i[0]] = temp
    json = "["
    for i in nodes[1:]:
        json = json + '{"name":"' + i[1] + '.' + str(i[0]) + '" ,"imports":'+str(connections[i[0]])+'},'
    json = json[:-1]
    json = json + "]"
    json = json.replace("'",'"')
    return json
############################################
top = """<!DOCTYPE html>
<meta charset="utf-8">
<style>

.node {
  font: 300 11px "Arial", Arial, Arial, Arial;
  fill: #bbb;
}

.node:hover {
  fill: #d62728;
}

.link {
  stroke: steelblue;
  stroke-opacity: .4;
  fill: none;
  pointer-events: none;
}

.node:hover,
.node--source,
.node--target {
  font-weight: 700;
}

.node--source {
  fill: black;
}

.node--target {
  fill: black;
}

.link--source,
.link--target {
  stroke-opacity: 1;
  stroke-width: 2px;
}

.link--source {
  stroke: #d62728;
}

.link--target {
  stroke: #d62728;
}

</style>
<body>
<script src="http://d3js.org/d3.v3.min.js"></script>
<script>

var diameter = 960,
    radius = diameter / 2,
    innerRadius = radius - 120;

var cluster = d3.layout.cluster()
    .size([360, innerRadius])
    .sort(null)
    .value(function(d) { return d.size; });

var bundle = d3.layout.bundle();

var line = d3.svg.line.radial()
    .interpolate("bundle")
    .tension(.85)
    .radius(function(d) { return d.y; })
    .angle(function(d) { return d.x / 180 * Math.PI; });

var svg = d3.select("body").append("svg")
    .attr("width", diameter)
    .attr("height", diameter)
  .append("g")
    .attr("transform", "translate(" + radius + "," + radius + ")");

var link = svg.append("g").selectAll(".link"),
    node = svg.append("g").selectAll(".node");"""
############################################

middle = "\njsondata = '" + network2JSON(sys.argv[1],sys.argv[2]) + "'\n"

############################################
bottom = """var data = JSON.parse(jsondata);
function bundle_edges(classes){

  var nodes = cluster.nodes(packageHierarchy(classes)),
      links = packageImports(nodes);

  link = link
      .data(bundle(links))
    .enter().append("path")
      .each(function(d) { d.source = d[0], d.target = d[d.length - 1]; })
      .attr("class", "link")
      .attr("d", line);

  node = node
      .data(nodes.filter(function(n) { return !n.children; }))
    .enter().append("text")
      .attr("class", "node")
      .attr("dy", ".31em")
      .attr("transform", function(d) { return "rotate(" + (d.x - 90) + ")translate(" + (d.y + 8) + ",0)" + (d.x < 180 ? "" : "rotate(180)"); })
      .style("text-anchor", function(d) { return d.x < 180 ? "start" : "end"; })
      .text(function(d) { return d.key; })
      .on("mouseover", mouseovered)
      .on("mouseout", mouseouted);
};

function mouseovered(d) {
  node
      .each(function(n) { n.target = n.source = false; });

  link
      .classed("link--target", function(l) { if (l.target === d) return l.source.source = true; })
      .classed("link--source", function(l) { if (l.source === d) return l.target.target = true; })
    .filter(function(l) { return l.target === d || l.source === d; })
      .each(function() { this.parentNode.appendChild(this); });

  node
      .classed("node--target", function(n) { return n.target; })
      .classed("node--source", function(n) { return n.source; });
}

function mouseouted(d) {
  link
      .classed("link--target", false)
      .classed("link--source", false);

  node
      .classed("node--target", false)
      .classed("node--source", false);
}

d3.select(self.frameElement).style("height", diameter + "px");

// Lazily construct the package hierarchy from class names.
function packageHierarchy(classes) {
  var map = {};

  function find(name, data) {
    var node = map[name], i;
    if (!node) {
      node = map[name] = data || {name: name, children: []};
      if (name.length) {
        node.parent = find(name.substring(0, i = name.lastIndexOf(".")));
        node.parent.children.push(node);
        node.key = name.substring(i + 1);
      }
    }
    return node;
  }

  classes.forEach(function(d) {
    find(d.name, d);
  });

  return map[""];
}

// Return a list of imports for the given array of nodes.
function packageImports(nodes) {
  var map = {},
      imports = [];

  // Compute a map from name to node.
  nodes.forEach(function(d) {
    map[d.name] = d;
  });

  // For each import, construct a link from the source to target node.
  nodes.forEach(function(d) {
    if (d.imports) d.imports.forEach(function(i) {
      imports.push({source: map[d.name], target: map[i]});
    });
  });

  return imports;
}
bundle_edges(data);
</script>"""
############################################
with open(sys.argv[3],"w") as x:
	x.write(top + middle + bottom)
