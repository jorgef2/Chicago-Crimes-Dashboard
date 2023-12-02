# Chicago-Crimes-Dashboard
Creating an interactive dashboard in R using shinydashboard to display Chicago Crime Rates.

### Project Overview
The goal of this project is to visualize Chicago crime statistics with several different visualization techniques and get practice creating high-quality explanatory visualizations that communicate a story from the data.  

### Data Sources
Chicago Crime Statistics: The primary dataset used for this project is the "Crimes_-_2018_to_Present.csv" file, containing detailed information regarding reported incidents of crime (except murders where data exists for each victim) that occurred in the City of Chicago from 1/1/2018 to 1/1/2023. This data comes from the Chicago Data Portal, and is publicly available. The default dataset contains information from 2001-Present, however, it can be subset to the desired period. [Download here](https://data.cityofchicago.org/Public-Safety/Crimes-2001-to-Present/ijzp-q8t2).

Chicago Community Areas Shape File: A shapefile of Chicago community area boundaries: 'Boundaries - Community Areas (current)/geo_export_4f92246a-ce31-4997-a6f7-540918bea641.shp' The file again comes from the Chicago Data Portal, and is publicly available. [Download here](https://data.cityofchicago.org/Facilities-Geographic-Boundaries/Boundaries-Community-Areas-current-/cauq-8yn6)

### Tools
- R - [Download here](https://cran.r-project.org/bin/windows/base/)

### Data Cleaning/Preparation
In the initial data preparation phase, I performed the following tasks:
1. Data loading and inspection.
2. Data Formatting
3. Aggregating data as necessary to create visualizations

### Exploratory Data Analysis
EDA to find meaningful relationships to aid in choosing a direction of investigation. These preliminary visualizations included:
- Bar chart of community areas and crime frequencies
- Line graph of crime rates over time
- Arrest Rates of specific crimes

### Creating Dashboard
Decided to create an interactive dashboard displaying temporal and geospatial trends of chicago crime rates.



