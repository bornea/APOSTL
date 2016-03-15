![APOSTL icon](/Users/brentkuenzi/Desktop/SAINT\ Pre-Processing/shiny_bubble/www/APOSTL_icon.png)
**APOSTL**: Automated Processing of SAINT Templated Layouts
===================
----------
[TOC]

----------
Overview
-----------------
APOSTL is an interactive affinity proteomics analysis software developed to reformat affinity proteomics data (both spectral counting and MS1) for input into the SAINTexpress statistical package$^1$ and to visualize the output(s).  APOSTL was developed at H. Lee Moffitt Cancer Center & Research Institute and distributed under a GNU General Public License (GPL). APOSTL is built in Python and R and integrated with SAINTexpress into a cohesive affinity proteomics data analysis package using the Galaxy framework.

Pre-processing
----------------------
Within the **Galaxy environment** APOSTL is able to recognize either a Scaffold ([Proteome Software][6]) *Samples Report* file (tab-delimited txt file) or the *peptides.txt* file output in the Maxquant ([link][7]) *txt* output folder. No modifications should be made to these files. Using the **Bait Create** tool, you can create your *bait.txt* file. It is important that the individual bait names match the bait names within your scaffold or maxquant output. APOSTL uses the bait file to find the user's baits of interest. Additionally there is an option to make the prey file (Y/N).

When making a prey file, APOSTL queries a user provided FASTA database in order to extract protein amino acid lengths and gene names. This may take several minutes depending on your computer and if your Galaxy distribution is cluster enabled. Some users may want to run SAINTexpress using the same data set while changing which baits are considered test or control. It is useful to toggle **Make Prey** off in order to save time by circumventing this step as the same prey file can be used for both SAINTexpress runs.

**Supported Inputs**:

- Scaffold output:
	- *Samples Report* output
- Maxquant output:
	- *peptides.txt* file

> **Note:** All files must be *tab delimited txt*

Post-processing
-----------------------
Once SAINTexpress has been run, APOSTL is able to read the resulting *list.txt* file. From here APOSTL does a number of things calculates normalized spectral abundance factor$^2$ (NSAF) values for each prey based on the average spectra observed for each bait. *Optionally*, APOSTL calculates the probability of a specific interaction based on prey prevalence in the [CRAPome][1]. 

-----
Within an **interactive analysis environment**, APOSTL offers various visualization and analysis options including:

1) *Quality control*: Pearson correlations between replicate runs
2) *Quality control*: Boxplots of selected protein across all replicates
3) Bubble graphs for each bait with numerous customization options:

- Axis and bubble scaling choices:
	- $ln(NSAF) = ln(\frac{SpC/L}{\sum_{n=1}^N (SpC/L)})$
	- $\sum_{n=1}^N SpC$
	- $log_{2}(FC)$
	- $Saint Score$
	- $Log Odds Score$

> $SpC$ = Spectral Count
> $L$ = Amino Acid Length
> $FC$ = Fold Change


- *Optional*: bubble color corresponds to the CRAPome probability of a specific interaction in which an 80% cutoff is applied where prey with ≤ 80% are colored separately. Input is the respective output file from [Workflow 1][3] from the CRAPome website.
- Numerous cosmetic options including labels, color schemes and plotting themes

4) Histograms of all baits for options specified above
5) Cytoscape networks of all preys passing filtering criteria displaying newly identified bait-prey interactions
6) Filtered data displayed as a table
7) KEGG pathway analysis of filtered data
8) Gene Ontology (GO) term analysis of filtered data

All graphs, images and data can be saved using the <i class="icon-download"></i> Download buttons or alternatively by <kbd>RMC + Save As</kbd> to generate 600 dpi figures.

-----
Within the **Galaxy environment**, APOSTL offers several other analysis options including:

1) Protein-protein interaction networks querying known PPI as annotated in [ConsensusPathDB][2] following filtering for simple cytoscape import using the *import network from file* option.

2) Dot plot and clustering analysis from the the [Prohits Visualization Tool][4]$^3$

References
---------------
1. Teo G, Liu G, Zhang J, Nesvizhskii AI, Gingras A-C, Choi H. SAINTexpress: improvements and additional features in Significance Analysis of INTeractome software. *J Proteomics*. 2014 Apr 4

2. NSAF paper

3. Prohits Viz Paper

Contact us
---------------
APOSTL support is provided by the Haura and Rix labs:

- Adam Borne: <Adam.Borne@moffitt.org>
- Brent Kuenzi: <Brent.Kuenzi@moffitt.org>
- Paul Stewart, PhD: <Paul.Stewart@moffitt.org>

Source code is available on [Github][5]

  [1]: http://crapome.org
  [2]: http://consensuspathdb.org
  [3]: http://crapome.org/?q=wk_1_1_search
  [4]: http://prohitstools.mshri.on.ca
  [5]: https://github.com/bornea/Saint_On_Galaxy
  [6]: http://www.proteomesoftware.com/products/scaffold/
  [7]: http://coxdocs.org/doku.php?id=maxquant:start.