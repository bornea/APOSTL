![Logo](https://raw.githubusercontent.com/bornea/APOSTL/master/logo.png)
Automated Processing of SAINT Templated Layouts
===================


APOSTL is an interactive affinity proteomics analysis software developed to reformat affinity proteomics data (both spectral counting and MS1) for input into the SAINTexpress statistical package and to visualize the output(s).  APOSTL was developed at H. Lee Moffitt Cancer Center &amp; Research Institute and distributed under a GNU General Public License (GPL). APOSTL is built in Python and R and integrated with SAINTexpress into a cohesive affinity proteomics data analysis package using the Galaxy framework.




Installing APOSTL from Galaxy
-------------
The easiest way to get the majority of APOSTL tool is to install them from the galaxy toolshed the instructions for which can be found at https://wiki.galaxyproject.org/Admin/Tools/AddToolFromToolShedTutorial. The tools can be found at https://toolshed.g2.bx.psu.edu/view/bornea/apostl_tools/6f6e2eb3e81b. 

Most of the tools require an R environment to run. If the R package within galaxy works in your instance feel free to use it but it is not automatically installed when the tools are installed. APOSTL also requires bioconductor packages to be installed, bioconductor packages may require additional linux libraries for installation. In CentOS environments libcurl and xml2lib are required to install bioconductor packages. The script will attempt to install all require R packages automatically but this is imperfect. You may need to make sure that Rscript is your $PATH variable. If the packages are not installed automatically you can enter your R environment and use the following commands in R to install are required packages. 
```R
> install.packages("dplyr", "tidyr", "httr", "jsonlite", "colorRamps", "gplots", "ggrepel", "ggplot2", "data.table", "rcytoscapejs", "stringr", "VennDiagram", "clusterProfiler", repos = "http://cran.us.r-project.org") 
> source("https://bioconductor.org/biocLite.R") 
> biocLite(c('mygene','affy','clusterProfiler','org.Hs.eg.db'))
```


Installing APOSTL Shiny
-------------

Please refer to https://www.rstudio.com/products/shiny/download-server/ for how to install the shiny server on different distributions of linux.
Additional packages libcurl-devel, libxml2-devel, openssl-devel, gsl-devel.x86_64 and libpng-devel will need to be installed (on CentOS installed via yum package manager). The shiny R package must be installed (should be done as part of shiny install).

```R
install.packages('shiny', repos = 'http://cran.r-project.org')
```
Once installed please change the permissions of the /srv/shiny-server directory and the shiny bubble directory should be copied into /srv/shiny-server.

```bash
chmod -R 777 /srv/shiny-server
cp -r ~/APOSTL/shiny_bubble /srv/shiny-server
```
The Shiny tool wrapper python file (APOSTL_Interactive_Analysis.py) and xml wrapper (APOSTL_Interactive_Analysis.xml) needs to be moved into galaxy tools directory. The tool pointer needs to be included in the `galaxy_repo/config/tool_conf.xml` file that is being used by galaxy. It may also be necessary to change the run_as variable in the `/etc/shiny-server/shiny-server.conf` file to the user that runs galaxy. 

Default is to run the shiny server on port 3838 which will need to be open in order to access the APOSTL shiny application. Please edit the APOSTL_Interactive_Analysis.py line 67 to reflect your network configuration. 
```python
x.write("<html><body> open <a href=\"http://127.0.0.1:3838/" 
```
> **Note:** This is a hyperlink to the shiny server written by the tool, make sure that the IP or Domain information on this line reflects how the shiny server is accessed. 


APOSTL Docker Image
-------------
The APOSTL Docker Image is a running version of Galaxy, Shiny and all of the APOSTL tools built on a CentOS 7 framework. This image is located at https://hub.docker.com/r/bornea/apostl_shiny/.

Within docker to get the image started use

```bash
docker run -p 8080:8080 -p 3838:3838 -ti bornea/apostl_shiny /bin/bash
```

The image will be running in interactive mode so you can change information in the /galaxy-apostl-docker/config/galaxy.ini.sample to reflect the network configuration. It is recommended that the galaxy server is started once in the interactive mode.

```bash
cd /galaxy-apostl-docker
sh run.sh
```

Once the startup has completed escape with a Keyboard Interrupt and restart Galaxy in daemon mode and start the shiny server.

```bash
sh run.sh --daemon
sh ./shiny_galaxy_run.sh
```

APOSTL should be accessible from a web browser at http://127.0.0.1:8080. If using a non-linux OS then the IP is determined by how the docker virtual machine is set up. 

## APOSTL Walkthrough

This walkthrough will guide you through using APOSTL with sample data and pre-made workflows available in this Galaxy instance.

### 1) Create a User Account

Creating a user account allows you to access all the tools and features of APOSTL. User accounts are free, are generated immediately, and can be used immediately.Please select the <span style="font-weight: bold;">Register</span> button under the <span style="font-weight: bold;">User</span> tab on the menu.

![register_button](https://raw.githubusercontent.com/bornea/APOSTL/master/wk_images/register_button.png)
<span style="font-family: Helvetica;">
Fill out the form with your e-mail, a strong password, and a diplay name (mainly for sharing data/workflows with other users; data is not shared automatically).</span>
![register_form](https://raw.githubusercontent.com/bornea/APOSTL/master/wk_images/register_form.png)
<span style="font-family: Helvetica;">Once you click <span style="font-weight: bold;">Submit</span> you will be redirected to the Home page. Although this walkthrough focuses on using pre-defined workflows, all of the tools that make up APOSTL can be accessed on the left hand side of the screen under APOSTL Tools.</span>

![register_form](https://raw.githubusercontent.com/bornea/APOSTL/master/wk_images/apostl_tools.png)</div>

Instructions for some of the tools are provided on their respective pages. For help with tools maintained by other groups, please see <span style="color: #fd1701;"><span style="color: #000000;">the [SAINT user manual](https://raw.githubusercontent.com/bornea/APOSTL/master/wk_images/SAINTexpress-manual.pdf), the [ProHits user manual](http://prohitsms.com/Prohits_download/list.php), and the [crapome guide](http://crapome.org/)</span>.</span> 

### <span style="font-weight: bold; font-family: Helvetica;">2) Upload Data</span>

<span style="color: #000000;">One file is needed to complete the entire APOSTL work flow, the MaxQuant _peptides.txt _a Scaffold _Sample Report_. Uploading the file can be accomplished by selecting either the upload button or the upload tool on the upper left hand side. </span>

<span style="color: #000000;">![](https://raw.githubusercontent.com/bornea/APOSTL/master/wk_images/upload_button.png)</span>

<span style="color: #000000;">Both option will bring up the upload interface where you can drag and drop a file or select **Choose a local file**. When uploading it is best to leave the Type as auto-detect and the Genome as unspecified.</span>

<span style="color: #000000;">![](https://raw.githubusercontent.com/bornea/APOSTL/master/wk_images/upload_screen.png)Once your files have been selected use the **Start** button to initiate the upload.</span>

### 3) <span style="font-weight: bold;">SAINT Pre-processing</span> Tool and Bait-create

A bait file can also be provided by the user using an upload functionality, for formatting on the bait file refer to the <span style="color: #fd1701;"><span style="color: #000000;">[SAINT user manual](https://raw.githubusercontent.com/bornea/APOSTL/master/wk_images/SAINTexpress-manual.pdf)</span></span>. If one is not provided it can be created with the **SAINT pre-processing** tool's Bait Create Function.

![](https://raw.githubusercontent.com/bornea/APOSTL/master/wk_images/preproc.png)

To use this function when using the preprocessing tool select **No** for Are You Providing Your Own bait file. Select the **Insert Bait Create** <span style="color: #000000;">to add additional baits which require the Bait, a Bait group assignment and needs to set to control or experimental. </span>

<span style="color: #000000;">![](https://raw.githubusercontent.com/bornea/APOSTL/master/wk_images/bait_create.png)</span>

<span style="color: #000000;">This approach has the advantage of checking your baits against the Scaffold or MaxQuant file prior to using SAINT and ensures proper formatting of the bait file.</span>**<span style="color: red;">
</span>**

### 4) Select a Workflow

The Galaxy portion of APOSTL is a number of individual tools strung together using workflows. To access the pre-made workflows available on this Galaxy instance, select the <span style="font-weight: bold;">Shared Data</span> dropdown followed by <span style="font-weight: bold;">Published Workflows</span> on the top menu.

![shared_wrkfl](https://raw.githubusercontent.com/bornea/APOSTL/master/wk_images/shared_wrkfl.png)

You will be able to select from two pre-made workflows, depending on the type of data you are using (MaxQuant or Scaffold).

![](https://raw.githubusercontent.com/bornea/APOSTL/master/wk_images/wkflws.png)

Alternatively, you can click on the workflow name directly to view each step and the presets involved. From this page the workflow can be imported with the <span style="font-weight: bold;">+</span> button in the top right, and the workflow can be downloaded using the floppy disk icon in the top right corner. 

![share_flow](https://raw.githubusercontent.com/bornea/APOSTL/master/wk_images/share_flow.png)

### 5) Importing Workflows

If the user is not using apostl.moffitt.org or the provided docker image the workflows will need to be imported into the galaxy instance. This can be accomplished by selecting **Workflow** and the **Upload or import workflow.**

![](https://raw.githubusercontent.com/bornea/APOSTL/master/wk_images/uploadwrkflw.png)

The two workflows can be found at [Github Workflows](https://github.com/bornea/APOSTL/tree/master/Workflows) once dowloaded to your local machine they can be imported into any galaxy instance which has APOSTL tools installed.

### 6) Using a Workflow

Once imported, the workflows can be accessed from the <span style="font-weight: bold;">Workflow</span> menu tab at the top of the screen.

![wrkflw_menu]https://raw.githubusercontent.com/bornea/APOSTL/master/wk_images/wrkflw_menu.png)

The Workflow can be run or edited by clicking on the Workflow and selecting <span style="font-weight: bold;">Run</span> or <span style="font-weight: bold;">Edit</span>. Select the workflow you just imported and click <span style="font-weight: bold;">Run. </span>

![wkflw_select](https://raw.githubusercontent.com/bornea/APOSTL/master/wk_images/wkflw_select.png)

Select your previously uploaded Scaffold or MaxQuant output from step 2a using the dropdown menus. You will also need to provide a bait file unless you just generated one using step 2b. Other options can be chosen at this time but are not required (i.e. a custom fasta database for identification of proteins). Unless otherwise specified, APOSTL will use <span style="color: #000000;">Uniprot database updated on 08//2014.</span>

![wrkflw_items](https://raw.githubusercontent.com/bornea/APOSTL/master/wk_images/wrkflw_items.png)

Once you have selected the necessary files and options, click the <span style="font-weight: bold;">Run Workflow</span> button at the bottom of the page.

![run_wrkflw](https://raw.githubusercontent.com/bornea/APOSTL/master/wk_images/run_wrkflw.png)

<span style="font-family: Helvetica;">The jobs will begin running and show up in your History on the right side of the screen</span><span style="font-family: Helvetica;">. Jobs that successfully complete will be colored in green. Jobs that do not successfully complete will be colored red and the execution of the workflow will be halted. If everything completes successfully, select the xx output, click the eye icon, and click the link to be taken to the Shiny portion of APOSTL.

</span>

### 7) Trouble Shooting

<span style="font-family: Helvetica;">APOSTL has been tested on a number of datasets and different species. The most common errors in Galaxy typically stem from bad formatting of input files (e.g., spaces instead of tabs in a file that should be <span style="font-style: italic;">tab delimited</span>). <span style="color: red;"><span style="color: black;">APOSTL has been tested with MaxQuant version 1.2.2.5 <span style="color: red;"><span style="color: black;">as well as Scaffold version</span> <span style="color: #000000;">4.3.4.</span></span> </span></span></span><span style="font-family: Helvetica;">If you are using properly formatted input files from a software known to work with APOSTL, then <span style="color: #000000;">click on the Bug Report</span> </span><span style="font-family: Helvetica;"><span style="color: red;">. <span style="color: black;">We are happy to hear from you if you are experiencing difficulties getting APOSTL to work. Please send questions or other correspondence to <span style="color: #000000;">[Paul Stewart](mailto:Paul.Stewart@moffitt.org).</span></span></span>

</span>

### 8) Pre-published History

Access the Published Histories for both Scaffold and MaxQuant by selecting Shared Histories under the Shared Data tab on the menu.

![shared_histories](https://raw.githubusercontent.com/bornea/APOSTL/master/wk_images/shared_histories.png)

Select either History by clicking on it.

*   The shared History will show you all the steps completed, the History can be imported with the Import History in the upper right hand corner.

![share_history](https://raw.githubusercontent.com/bornea/APOSTL/master/wk_images/share_history.png)

Once imported the History will be shown in the History right side column.

*   When clicked on the dataset will expand. The eye button will open the dataset for viewing in the web browser, and the floppy dick icon can be used to download the dataset.

![his_panel](https://raw.githubusercontent.com/bornea/APOSTL/master/wk_images/his_panel.png)

The shiny version can be accessed by selecting the Shiny dataset, hitting the eye button and click on the APOSTL Interactive Analysis link (or right click and open in new tab).

![open_shiny.png](https://raw.githubusercontent.com/bornea/APOSTL/master/wk_images/open_shiny.png)

Any job can be run with the same settings using the circular arrows button.

![rerun.png](https://raw.githubusercontent.com/bornea/APOSTL/master/wk_images/rerun.png)


## References

1.  Teo G, Liu G, Zhang J, Nesvizhskii AI, Gingras A-C, Choi H. SAINTexpress: improvements and additional features in Significance Analysis of INTeractome software. J Proteomics. 2014 Apr 4

2.  Zybailov B, Mosley AL, Sardiu ME, Coleman MK, Florens L, Washburn MP. Statistical Analysis of Membrane Proteome Expression Changes in  Saccharomyces cerevisiae. J Proteome Res. 2006 Apr 10

3.  Knight JD, Liu G, Zhang JP, Pasculescu A, Choi H, Gingras AC. A web-tool for visualizing quantitative protein-protein interaction data.  Proteomics. 2015 Jan 19

## Contact us

APOSTL support is provided by the Haura and Rix labs:

*   Adam Borne: [Adam.Borne@moffitt.org](mailto:Adam.Borne@moffitt.org)
*   Brent Kuenzi: [Brent.Kuenzi@moffitt.org](mailto:Brent.Kuenzi@moffitt.org)
*   Paul Stewart, PhD: [Paul.Stewart@moffitt.org](mailto:Paul.Stewart@moffitt.org)
