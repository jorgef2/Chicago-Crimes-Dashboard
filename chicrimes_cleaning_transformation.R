library(data.table) 
library(ggplot2) 
library(dplyr) 
library(sf) 
library(viridis) 
library(leaflet) 
library(plotly)
library(lubridate)


# Read in data 
ChiCrimes <- fread("Crimes_-_2018_to_Present.csv")


# Drop columns that I know I won't need at all
ChiCrimes <- ChiCrimes[, -c(25:27)] 

#------------------------------------------- 
# Create DF of Type and Location Columns 
#------------------------------------------- 

# get columns of interest for crimes choropleths
locationData <- ChiCrimes[, c('Primary Type', 'Arrest', 'Latitude', 'Longitude', 'Ward', 
                              'Zip Codes', 'Community Area', 'District', 'Beat', 
                              'Boundaries - ZIP Codes', 'Police Districts', 
                              'Police Beats', 'Date')]



# rename some columns using clean_names function
locationData <- locationData %>% 
  clean_names() 

# further cleaning
locationData$zip_boundaries <- locationData$boundaries_minus_zip_codes
locationData <- locationData[,-c(10)] 

# drop nas 
locationData <- na.omit(locationData) 

# convert to Dataframe 
locationData <- as.data.frame(locationData) 


head(locationData)
#------------------------------------------- 
# Get shapefile for choropleth 
#------------------------------------------- 
# Read in and project polygon to WGS84 for leaflet mapview
community_areas <- st_read('Boundaries - Community Areas (current)/geo_export_4f92246a-ce31-4997-a6f7-540918bea641.shp')%>%
                             sf::st_transform('+proj=longlat +datum=WGS84')

community_areas

#------------------------------------------- 
# Group by and summarize crime types 
#------------------------------------------- 
crimes <- locationData %>% 
  group_by(community_area) %>% 
  summarize(`Total Crime` = n(),
            Arson = sum(primary_type == "ARSON"),
            Assault = sum(primary_type == "ASSAULT"), 
            Battery = sum(primary_type == "BATTERY"), 
            Burglary = sum(primary_type == "BURGLARY"),
            `Concealed Carry Licence Violation` = sum(primary_type == "CONCEALED CARRY LICENSE VIOLATION"),
            `Crim Sexual Assault` = sum(primary_type == "CRIM SEXUAL ASSAULT"),
            `Criminal Damage` = sum(primary_type == "CRIMINAL DAMAGE"), 
            `Criminal Sexual Assault` = sum(primary_type == "CRIMINAL SEXUAL ASSAULT"),
            `Criminal Trespass` = sum(primary_type == "CRIMINAL TRESPASS"),
            `Deceptive Practice` = sum(primary_type == "DECEPTIVE PRACTICE"), 
            Gambling = sum(primary_type == "GAMBLING"),
            Homicide = sum(primary_type == "HOMICIDE"),
            `Human Trafficking` = sum(primary_type == "HUMAN TRAFFICKING"),
            `Interference With Public Officer` = sum(primary_type == "INTERFERENCE WITH PUBLIC OFFICER"),
            Intimidation = sum(primary_type == "INTIMIDATION"),
            Kidnapping = sum(primary_type == "KIDNAPPING"),
            `Liquor Law Violation` = sum(primary_type == "LIQUOR LAW VIOLATION"),
            Narcotics = sum(primary_type == "NARCOTICS"),
            `Non-Criminal` = sum(primary_type == "NON-CRIMINAL"),
            `Non-Criminal (subject specified)` = sum(primary_type == "NON-CRIMINAL (SUBJECT SPECIFIED)"),
            Obscenity = sum(primary_type == "OBSCENITY"),
            `Other Narcotic Violation` = sum(primary_type == "OTHER NARCOTIC VIOLATION"),
            `Offence Involving Children` = sum(primary_type == "OFFENSE INVOLVING CHILDREN"),
            `Other Offense` = sum(primary_type == "OTHER OFFENSE"),
            Prostitution = sum(primary_type == "PROSTITUTION"),
            `Public Indecency` = sum(primary_type == "PUBLIC INDECENCY"),
            `Public Peace violation` = sum(primary_type == "PUBLIC PEACE VIOLATION"),
            Ritualism = sum(primary_type == "RITUALISM"),
            Robbery = sum(primary_type == "ROBBERY"),
            `Sex Offence` = sum(primary_type == "SEX OFFENSE"),
            Stalking = sum(primary_type == "STALKING"),
            Theft = sum(primary_type == "THEFT"), 
            `Vehicle Theft` = sum(primary_type == "MOTOR VEHICLE THEFT"), 
            `Weapons Violation` = sum(primary_type == "WEAPONS VIOLATION"))

# create column for merging 
crimes$area_num_1 <- as.character(crimes$community_area)


# Merge the spatial data with crimes data 
merged_data <- merge(community_areas, crimes, by = "area_num_1") 

#------------------------------------------- 
# Group by and summarize arrest data 
#------------------------------------------- 
arrestData <- locationData[ , c("primary_type", "arrest")]

arrestData <- arrestData %>% 
  group_by(primary_type, arrest) %>% 
  summarize(Total_Crime = n()) %>% 
  data.frame() %>% 
  add_row(primary_type = "TOTAL_CRIME", arrest = FALSE, Total_Crime = 969746) %>% 
  add_row(primary_type = "TOTAL_CRIME", arrest = TRUE, Total_Crime = 193883) %>% 
  rename("Incidents" = "Total_Crime") %>% 
  # Renaming to match crimes table
  mutate(primary_type = recode(primary_type,  
                               ARSON = 'Arson',  
                               ASSAULT = 'Assault',  
                               BATTERY =  'Battery', 
                               BURGLARY = 'Burglary', 
                               `CONCEALED CARRY LICENSE VIOLATION` = 'Concealed Carry Licence Violation', 
                               `CRIM SEXUAL ASSAULT` = 'Crim Sexual Assault', 
                               `CRIMINAL DAMAGE` = 'Criminal Damage', 
                               `CRIMINAL SEXUAL ASSAULT` = 'Criminal Sexual Assault', 
                               `CRIMINAL TRESPASS` = 'Criminal Trespass', 
                               `DECEPTIVE PRACTICE` = 'Deceptive Practice', 
                               GAMBLING = 'Gambling', 
                               HOMICIDE = 'Homicide', 
                               `HUMAN TRAFFICKING` = 'Human Trafficking', 
                               `INTERFERENCE WITH PUBLIC OFFICER` = 'Interference With Public Officer', 
                               INTIMIDATION = 'Intimidation', 
                               KIDNAPPING = 'Kidnapping', 
                               `LIQUOR LAW VIOLATION` = 'Liquor Law Violation', 
                               `MOTOR VEHICLE THEFT` = 'Vehicle Theft', 
                               NARCOTICS = 'Narcotics',
                               `NON-CRIMINAL` = 'Non-Criminal',
                               `NON-CRIMINAL (SUBJECT SPECIFIED)` = 'Non-Criminal (subject specified)',
                               OBSCENITY = 'Obscenity', 
                               `OFFENSE INVOLVING CHILDREN` = 'Offence Involving Children',
                               `OTHER NARCOTIC VIOLATION` = 'Other Narcotic Violation',
                               `OTHER OFFENSE` = 'Other Offense',
                               PROSTITUTION = 'Prostitution', 
                               `PUBLIC INDECENCY` = 'Public Indecency', 
                               `PUBLIC PEACE VIOLATION` = 'Public Peace violation', 
                               ROBBERY = 'Robbery', 
                               RITUALISM = 'Ritualism',
                               `SEX OFFENSE` = 'Sex Offence', 
                               STALKING = 'Stalking', 
                               THEFT = 'Theft', 
                               `WEAPONS VIOLATION` = 'Weapons Violation', 
                               TOTAL_CRIME = 'Total Crime'))

# For bar chart
incidents_per_crime <- arrestData %>% 
  group_by(primary_type) %>% 
  summarize(Incidents = sum(Incidents))

# # plot of crimes by incidents
# crime_type = incidents_per_crime[-c(33),]
# plot_ly(crime_type, x = ~primary_type, y=~Incidents, type='bar') %>%  
#   layout(xaxis = list(categoryorder = "total descending"), 
#          yaxis = list(side ="top", title = 'Reported Incidents'))
# 
# print(incidents_per_crime, n=40)
#------------------------------------------- 
# Creating df of just the timeseries data
#------------------------------------------- 
time_data <- locationData[ , c("primary_type", "date")]
time_data <-time_data %>%
  mutate(primary_type = recode(primary_type,  
                               ARSON = 'Arson',  
                               ASSAULT = 'Assault',  
                               BATTERY =  'Battery', 
                               BURGLARY = 'Burglary', 
                               `CONCEALED CARRY LICENSE VIOLATION` = 'Concealed Carry Licence Violation', 
                               `CRIM SEXUAL ASSAULT` = 'Crim Sexual Assault', 
                               `CRIMINAL DAMAGE` = 'Criminal Damage', 
                               `CRIMINAL SEXUAL ASSAULT` = 'Criminal Sexual Assault', 
                               `CRIMINAL TRESPASS` = 'Criminal Trespass', 
                               `DECEPTIVE PRACTICE` = 'Deceptive Practice', 
                               GAMBLING = 'Gambling', 
                               HOMICIDE = 'Homicide', 
                               `HUMAN TRAFFICKING` = 'Human Trafficking', 
                               `INTERFERENCE WITH PUBLIC OFFICER` = 'Interference With Public Officer', 
                               INTIMIDATION = 'Intimidation', 
                               KIDNAPPING = 'Kidnapping', 
                               `LIQUOR LAW VIOLATION` = 'Liquor Law Violation', 
                               `MOTOR VEHICLE THEFT` = 'Vehicle Theft', 
                               NARCOTICS = 'Narcotics',
                               `NON-CRIMINAL` = 'Non-Criminal',
                               `NON-CRIMINAL (SUBJECT SPECIFIED)` = 'Non-Criminal (subject specified)',
                               OBSCENITY = 'Obscenity', 
                               `OFFENSE INVOLVING CHILDREN` = 'Offence Involving Children',
                               `OTHER NARCOTIC VIOLATION` = 'Other Narcotic Violation',
                               `OTHER OFFENSE` = 'Other Offense',
                               PROSTITUTION = 'Prostitution', 
                               `PUBLIC INDECENCY` = 'Public Indecency', 
                               `PUBLIC PEACE VIOLATION` = 'Public Peace violation', 
                               ROBBERY = 'Robbery', 
                               RITUALISM = 'Ritualism',
                               `SEX OFFENSE` = 'Sex Offence', 
                               STALKING = 'Stalking', 
                               THEFT = 'Theft', 
                               `WEAPONS VIOLATION` = 'Weapons Violation', 
                               TOTAL_CRIME = 'Total Crime'))

#add column for total crime plotting
time_data$total_crime <- 'Total Crime'
time_data$date <- as.POSIXct(time_data$date,format="%m/%d/%Y %H:%M:%S",tz=Sys.timezone())

# formatting reactive for shiny app
count_time <- time_data %>% 
  filter_at(vars(primary_type, total_crime), any_vars(.%in% 'Total Crime'))

# 
count_time <- count_time %>% 
  group_by(Date = lubridate::floor_date(date, "week")) %>%
  summarize(`Reported Incidents` = n())

n <- dim(count_time)[1]
count_time<-count_time[1:(n-2),]

plot_ly(count_time, type = 'scatter', mode = 'lines', line = list(color = 'rgb(227, 66, 52)', width = 4))%>%
  add_trace(x = ~Date, y = ~`Reported Incidents`) %>%
  layout(showlegend = F) %>%
  layout(
    xaxis = list(zerolinecolor = '#ffff',
                 zerolinewidth = 2,
                 gridcolor = 'ffff'),
    yaxis = list(zerolinecolor = '#ffff',
                 zerolinewidth = 2,
                 gridcolor = 'ffff'),
    plot_bgcolor='#e5ecf6')


