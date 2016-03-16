![Logo](https://raw.githubusercontent.com/bornea/APOSTL/master/logo.png)
Automated Processing of SAINT Templated Layouts
===================


APOSTL is an interactive affinity proteomics analysis software developed to reformat affinity proteomics data (both spectral counting and MS1) for input into the SAINTexpress statistical package and to visualize the output(s).  APOSTL was developed at H. Lee Moffitt Cancer Center &amp; Research Institute and distributed under a GNU General Public License (GPL). APOSTL is built in Python and R and integrated with SAINTexpress into a cohesive affinity proteomics data analysis package using the Galaxy framework.




Installing APOSTL from Galaxy
-------------
The easiest way to get the majority of APOSTL tool is to install them from the galaxy toolshed the instruction for which can be found at https://wiki.galaxyproject.org/Admin/Tools/AddToolFromToolShedTutorial. The tools can be found at https://toolshed.g2.bx.psu.edu/view/bornea/apostl_tools/6f6e2eb3e81b. 

Most of the tools require an R environment to run. If the R package within galaxy works feel free to use that  but it is not automatically installed. It will also require bioconductor packages to be installed, this may require additional linux libraries to install. In CentOS environments libcurl and xml2lib are required to install bioconductor packages. The script will attempt to install all require R packages automaticaly but this is also imperfect. You may also may need to make sure that Rscript is your $PATH variable. If they do not install automatically you can enter your R environment and use the following commands in R to install are required packages. 

```R
> install.packages("dplyr", "tidyr", "httr", "jsonlite", "colorRamps", "gplots", "ggrepel", "ggplot2", "data.table", "rcytoscapejs", "stringr", "VennDiagram", "clusterProfiler", repos = "http://cran.us.r-project.org") 
> source("https://bioconductor.org/biocLite.R") 
> biocLite(c('mygene','affy','clusterProfiler','org.Hs.eg.db'))
```


Installing APOSTL Shiny
-------------

Please refer to https://www.rstudio.com/products/shiny/download-server/ for how to install the the shiny server on different distributions of linux. Additional packages libcurl-devel, libxml2-devel, openssl-devel, gsl-devel.x86_64 and libpng-devel will need to be installed. The shiny R package must be installed (should be done as part of shiny install).

```R
install.packages('shiny', repos = 'http://cran.r-project.org')
```
Once installed please change the permissions of the /srv/shiny-server directory and the shiny bubble directory should be copied into /srv/shiny-server.

```bash
chmod -R 777 /srv/shiny-server
cp -r ./APOSTL/shiny_bubble /srv/shiny-server
```
The Shiny tool wrapper python file (APOSTL_Interactive_Analysis.py) and xml wrapper (APOSTL_Interactive_Analysis.xml) needs to be moved into galaxy tools directory. The tool pointer needs to be included in the `galaxy_repo/config/tool_conf.xml` file that is being used by galaxy. It may also be necessary to change the run_as variable in the `/etc/shiny-server/shiny-server.conf` file to the user that runs galaxy.

Default is to run the shiny server on port 3838 which will need to be open in order to access the APOSTL shiny application. Please edit the shiny_wrapper.py line 67 to reflect your network configuration. 
```python
x.write("<html><body> open <a href=\"http://127.0.0.1:3838/" 
```
> **Note:** This is a hyperlink to the shiny server make sure that the IP or Domain information on this line reflects how the shiny server is accessed. 


APOSTL Docker Image
-------------
The APOSTL Docker Image is a fully running version of Galaxy, Shiny and all of the APOSTL tools built on a CentOS 7 framework. This image is located at https://hub.docker.com/r/bornea/apostl_shiny/.

Within docker to get the image start use

```bash
docker run -p 8080:8080 -p 3838:3838 -ti bornea/apostl_shiny /bin/bash
```

The image will be running in interactive mode so you can change information in the /galaxy-apostl-docker/config/galaxy.ini.sample to reflect the network configuration. It is reccomended that the galaxy server is started once in the interactive mode.

```bash
cd /galaxy-apostl-docker
sh run.sh
```

Once the startup has completed escape with a Keyboard Interrupt and restart in daemon mode and start the shiny server.

```bash
sh run.sh --daemon
sh ./shiny_galaxy_run.sh
```

APOSTL should be accessable from a web browser at http://127.0.0.1:8080. If using a non-linux OS then the IP is determined by how the docker virtual machine is set up.   

## References

1.  Teo G, Liu G, Zhang J, Nesvizhskii AI, Gingras A-C, Choi H. SAINTexpress: improvements and additional features in Significance Analysis of INTeractome software. J Proteomics. 2014 Apr 4

2.  Zybailov B, Mosley AL, Sardiu ME, Coleman MK, Florens L, Washburn MP. Statistical Analysis of Membrane Proteome Expression Changes in  Saccharomyces cerevisiae. J Proteome Res. 2006 Apr 10

3.  Knight JD, Liu G, Zhang JP, Pasculescu A, Choi H, Gingras AC. A web-tool for visualizing quantitative protein-protein interaction data.  Proteomics. 2015 Jan 19

## Contact us

APOSTL support is provided by the Haura and Rix labs:

*   Adam Borne: [Adam.Borne@moffitt.org](mailto:Adam.Borne@moffitt.org)
*   Brent Kuenzi: [Brent.Kuenzi@moffitt.org](mailto:Brent.Kuenzi@moffitt.org)
*   Paul Stewart, PhD: [Paul.Stewart@moffitt.org](mailto:Paul.Stewart@moffitt.org)