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
Decided to create an interactive dashboard displaying temporal and geospatial trends of Chicago crime rates.
![dashboard_screenshot](https://github.com/jorgef2/Chicago-Crimes-Dashboard/assets/135895624/7ca3f3d0-0e49-4fe2-94c9-8bb6cce7a07f)

Individual Plots:

This interactive dashboard consists of 4 components:
- A bar chart of crime-type frequencies ![crime_freq_bar](https://github.com/jorgef2/Chicago-Crimes-Dashboard/assets/135895624/2578a110-aa47-4c7b-a1e9-ba3e7150d9ae)

- A line graph of crime rates over time ![crime_time_line](https://github.com/jorgef2/Chicago-Crimes-Dashboard/assets/135895624/839888fe-e058-4112-8e85-3fdb0cb6d812)

- A choropleth of crimes by community area ![crime_choropleth](https://github.com/jorgef2/Chicago-Crimes-Dashboard/assets/135895624/f2dc8fd0-4d72-40c0-8d4f-a788513e581a)

- A bar chart of crimes by community area ![crime_ca_bar](https://github.com/jorgef2/Chicago-Crimes-Dashboard/assets/135895624/6b914f2b-1793-437d-b3e6-11dce81913b7)


The motivation behind creating a choropleth and bar chart of the same information was to help the audience understand the values that were mapped on the choropleth. A choropleth is useful for gaining insights into a general trend; however, color is not a great encoding for distinguishing specific values. The sorted bar chart makes it so that the number of reported incidents is much easier to read and compare between community areas. 

Interactivity:
- Users of the application can select which type of crime they wish to analyze - either by using the drop-down menu or by clicking on a specific crime in the crime-frequency bar chart
- All of the plots display text widgets when hovered over displaying the time/location/crime along with the reported incidents.  



