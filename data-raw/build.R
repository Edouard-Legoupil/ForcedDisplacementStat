


#################

#install.packages("sinew")
#devtools::install_github("mdlincoln/docthis")
library(tidyverse)
library(readr)
library(sinew)
#library(docthis)

ckanr::ckanr_setup("https://data.humdata.org")

ckanr::package_search("name:unhcr-population-data-for-world", as = "table") %>% 
  purrr::pluck("results", "resources", 1, "url") %>% 
  purrr::walk(~ckanr::ckan_fetch(., store = "disk", path = fs::path("data-raw", fs::path_file(.))))

read_sans_hxl <- function(file, ...) {
  hdrs <- readr::read_csv(file, n_max = 0) %>% names()
  
  readr::read_csv(file, col_names = hdrs, skip = 2, ...)
}



## Displaced ##########

end_year_population_totals <- read_sans_hxl(file =  here::here("data-raw","end_year_population_totals_residing_world.csv"))


# Rename column to have proper Variable names
end_year_population_totals <- plyr::rename(end_year_population_totals, c("Country of Origin Code"="CountryOriginCode",
                                       "Country of Asylum Code"="CountryAsylumCode", 
                                       "Country of Origin Name"="CountryOriginName",
                                       "Country of Asylum Name"="CountryAsylumName", 
                                       "Refugees"="REF", 
                                       "Internally displaced persons"="IDP", 
                                       "Asylum seekers"="ASY",
                                       "Others of concern to UNHCR"="OOC",
                                       "Stateless Persons"="STA",    
                                      #  "Venezuelans Displaced Abroad"="VDA"
                                       "Host community" = "HCO",
                                       "Other people in need of international protection"="OIP"))
cat(names(end_year_population_totals))

sinew::makeOxygen(end_year_population_totals, add_fields = "source")

save(end_year_population_totals, file =  here::here("data","end_year_population_totals.RData"))
# Note: significantly better compression could be obtained
#by using R CMD build --resave-data
tools::resaveRdaFiles(here::here("data","end_year_population_totals.RData"),compress="bzip2")

 



## Create a long format for the dataset

end_year_population_totals_long <- reshape2::melt(end_year_population_totals,
                                           # ID variables - all the variables to keep but not split apart on
                                           id.vars=c("Year", "CountryOriginCode","CountryAsylumCode","CountryOriginName","CountryAsylumName" ),
                                           # The source columns
                                           measure.vars=c("REF","IDP", "ASY","OOC","STA","VDA","HC"),
                                           # Name of the destination column that will identify the original
                                           # column that the measurement came from
                                           variable.name="Population.type",
                                           value.name="Value")

end_year_population_totals_long <- end_year_population_totals_long[end_year_population_totals_long$Value > 0, ]

end_year_population_totals_long$Population.type.label <- ""
end_year_population_totals_long$Population.type.label[end_year_population_totals_long$Population.type=="REF"] <- "Refugees"
end_year_population_totals_long$Population.type.label[end_year_population_totals_long$Population.type=="IDP"] <- "Internally displaced persons"
end_year_population_totals_long$Population.type.label[end_year_population_totals_long$Population.type=="ASY"] <- "Asylum seekers"
end_year_population_totals_long$Population.type.label[end_year_population_totals_long$Population.type=="OOC"] <- "Others of concern to UNHCR"
end_year_population_totals_long$Population.type.label[end_year_population_totals_long$Population.type=="STA"] <- "Stateless Persons"
#end_year_population_totals_long$Population.type.label[end_year_population_totals_long$Population.type=="VDA"] <- "Venezuelans Displaced Abroad"
end_year_population_totals_long$Population.type.label[end_year_population_totals_long$Population.type=="OIP"] <- "Other people in need of international protection"
end_year_population_totals_long$Population.type.label[end_year_population_totals_long$Population.type=="HCO"] <- "Host community"

end_year_population_totals_long$Population.type.label.short <- ""
end_year_population_totals_long$Population.type.label.short[end_year_population_totals_long$Population.type=="REF"] <- "Refugees"
end_year_population_totals_long$Population.type.label.short[end_year_population_totals_long$Population.type=="IDP"] <- "IDPs"
end_year_population_totals_long$Population.type.label.short[end_year_population_totals_long$Population.type=="ASY"] <- "Asylum seekers"
end_year_population_totals_long$Population.type.label.short[end_year_population_totals_long$Population.type=="OOC"] <- "Others of concern"
end_year_population_totals_long$Population.type.label.short[end_year_population_totals_long$Population.type=="STA"] <- "Stateless Persons"
#end_year_population_totals_long$Population.type.label.short[end_year_population_totals_long$Population.type=="VDA"] <- "Venezuelans Abroad"
end_year_population_totals_long$Population.type.label.short[end_year_population_totals_long$Population.type=="OIP"] <- "In need of int. protect."
#end_year_population_totals_long$Population.type.label.short[end_year_population_totals_long$Population.type=="VDA"] <- "Venezuelans Abroad"
end_year_population_totals_long$Population.type.label.short[end_year_population_totals_long$Population.type=="HCO"] <- "Host community"

  
save(end_year_population_totals_long, file =  here::here("data","end_year_population_totals_long.RData"))
# Note: significantly better compression could be obtained
#by using R CMD build --resave-data 
tools::resaveRdaFiles(here::here("data","end_year_population_totals_long.RData"),compress="xz") 



## Solutions ##########

solutions_residing <- read_sans_hxl(file =  here::here("data-raw","solutions_residing_world.csv"))

sinew::makeOxygen(solutions_residing, add_fields = "source")
# Rename column to have proper Variable names
solutions <- plyr::rename(solutions_residing, c("Country of Origin Code"="CountryOriginCode",
                                                                         "Country of Asylum Code"="CountryAsylumCode", 
                                                                         "Country of Origin Name"="CountryOriginName",
                                                                         "Country of Asylum Name"="CountryAsylumName", 
                                                                         "Resettlement arrivals"="RST",
                                                                         "Refugee returns"="RET",
                                                                         "Naturalisation"="NAT",
                                                                         "IDP returns"="RDP" ))

save(solutions, file =  here::here("data","solutions.RData"))
sinew::makeOxygen(solutions, add_fields = "source")
# Note: significantly better compression could be obtained
#by using R CMD build --resave-data
tools::resaveRdaFiles(here::here("data","solutions.RData"),compress="bzip2")

solutions_long <- reshape2::melt(solutions,
                                                  # ID variables - all the variables to keep but not split apart on
                                                  id.vars=c("Year", "CountryOriginCode","CountryAsylumCode","CountryOriginName","CountryAsylumName" ),
                                                  # The source columns
                                                  measure.vars=c("NAT","RST", "RET","RDP"),
                                                  # Name of the destination column that will identify the original
                                                  # column that the measurement came from
                                                  variable.name="Solution.type",
                                                  value.name="Value")

solutions_long <- solutions_long[solutions_long$Value > 0, ]


solutions_long$Solution.type.label <- ""
solutions_long$Solution.type.label[solutions_long$Solution.type=="RST"] <- "Resettlement arrivals"
solutions_long$Solution.type.label[solutions_long$Solution.type=="NAT"] <- "Naturalisation"
solutions_long$Solution.type.label[solutions_long$Solution.type=="RET"] <- "Refugee returns"
solutions_long$Solution.type.label[solutions_long$Solution.type=="RDP"] <- "IDP returns"

save(solutions_long , file =  here::here("data","solutions_long.RData"))
sinew::makeOxygen(solutions_long , add_fields = "source")
# Note: significantly better compression could be obtained
#by using R CMD build --resave-data
tools::resaveRdaFiles(here::here("data","solutions_long.RData"),compress="xz")

## Demographics ##########

demographics_residing <- read_sans_hxl(file =  here::here("data-raw","demographics_residing_world.csv"))

names(demographics_residing)

sinew::makeOxygen(demographics_residing, add_fields = "source")
# Rename column to have proper Variable names
demographics <- plyr::rename(demographics_residing, c("Country of Origin Code"="CountryOriginCode",
                                                         "Country of Asylum Code"="CountryAsylumCode", 
                                                         "Country of Origin Name"="CountryOriginName",
                                                         "Country of Asylum Name"="CountryAsylumName",  
                                                         "Population Type"= "Population.type",
                                                         "Female 0-4"="Female04", 
                                                         "Female 5-11"="Female511", 
                                                         "Female 12-17"="Female1217", 
                                                         "Female 18-59"="Female1859",
                                                         "Female 60 or more"="Female60ormore",
                                                         "Female Unknown"="FemaleUnknown",
                                                         "Female Total"="FemaleTotal", 
                                                         "Male 0-4"="Male04", 
                                                         "Male 5-11"="Male511", 
                                                         "Male 12-17"="Male1217", 
                                                         "Male 18-59"="Male1859",
                                                         "Male 60 or more"="Male60ormore",
                                                         "Male Unknown"="MaleUnknown",
                                                         "Male Total"="MaleTotal")
                                                         )


#names(demographics)

demographics$Population.type.label <- ""
demographics$Population.type.label[demographics$Population.type=="REF"] <- "Refugees"
demographics$Population.type.label[demographics$Population.type=="IDP"] <- "Internally displaced persons"
demographics$Population.type.label[demographics$Population.type=="ASY"] <- "Asylum seekers"
demographics$Population.type.label[demographics$Population.type=="OOC"] <- "Others of concern to UNHCR"
demographics$Population.type.label[demographics$Population.type=="STA"] <- "Stateless Persons"
#demographics$Population.type.label[demographics$Population.type=="VDA"] <- "Venezuelans Displaced Abroad"
demographics$Population.type.label[demographics$Population.type=="OIP"] <- "Other people in need of international protection"
demographics$Population.type.label[demographics$Population.type=="HCO"] <- "Host community" 
demographics$Population.type.label[demographics$Population.type=="RET"] <- "Refugee returns"
demographics$Population.type.label[demographics$Population.type=="RDP"] <- "IDP returns"

demographics$Population.type.label.short <- ""
demographics$Population.type.label.short[demographics$Population.type=="REF"] <- "Refugees"
demographics$Population.type.label.short[demographics$Population.type=="IDP"] <- "IDPs"
demographics$Population.type.label.short[demographics$Population.type=="ASY"] <- "Asylum seekers"
demographics$Population.type.label.short[demographics$Population.type=="OOC"] <- "Others of Concern"
demographics$Population.type.label.short[demographics$Population.type=="STA"] <- "Stateless Persons"
#demographics$Population.type.label.short[demographics$Population.type=="VDA"] <- "Venezuelans Abroad"
demographics$Population.type.label.short[demographics$Population.type=="OIP"] <- "In need of int. protect."
demographics$Population.type.label.short[demographics$Population.type=="HCO"] <- "Host community" 
demographics$Population.type.label.short[demographics$Population.type=="RET"] <- "Refugee returns"
demographics$Population.type.label.short[demographics$Population.type=="RDP"] <- "IDP returns"

# names(demographics)
# table(demographics$location, useNA = "ifany")
# table(demographics$urbanRural, useNA = "ifany")
# table(demographics$accommodationType, useNA = "ifany")
# table(demographics$Population.type.label.short, useNA = "ifany")

save(demographics, file =  here::here("data","demographics.RData"))
# Note: significantly better compression could be obtained
#by using R CMD build --resave-data 
tools::resaveRdaFiles(here::here("data","demographics.RData"),compress="bzip2")

## RSD Application ########## 
asylum_applications_residing <- read_sans_hxl(file =  here::here("data-raw","asylum_applications_residing_world.csv"))

sinew::makeOxygen(asylum_applications_residing, add_fields = "source")

# Rename column to have proper Variable names
asylum_applications <- plyr::rename(asylum_applications_residing, c("Country of Origin Code"="CountryOriginCode",
                                                                    "Country of Asylum Code"="CountryAsylumCode", 
                                                                    "Country of Origin Name"="CountryOriginName",
                                                                    "Country of Asylum Name"="CountryAsylumName", 
                                                                    "Procedure Type"="ProcedureType",                      
                                                                    "Procedure Name"="ProcedureName",                      
                                                                    "Application Type Code"="ApplicationTypeCode",               
                                                                    "Application Type"="ApplicationType",                    
                                                                    "Application Data Type"="ApplicationDataType",               
                                                                    "Application Data"="ApplicationData",                    
                                                                    "Application Average Persons Per Case"="ApplicationAveragePersonsPerCase",
                                                                    "Number of Applications"="NumberApplications" 
)
)

asylum_applications$ApplicationType[asylum_applications$ApplicationTypeCode == "V"] <- "Various"
asylum_applications$ApplicationTypeCode[asylum_applications$ApplicationType == "New and appeal"] <- "NA"

#View(unique(asylum_applications[ ,c("ApplicationTypeCode","ApplicationType")]))

# View(unique(asylum_applications[ ,c("ProcedureType",  "ProcedureName")]))
# 
# View(unique(asylum_applications[ ,c("ApplicationDataType","ApplicationData")]))

save(asylum_applications, file =  here::here("data","asylum_applications.RData"))
# Note: significantly better compression could be obtained
#by using R CMD build --resave-data
tools::resaveRdaFiles(here::here("data","asylum_applications.RData"),compress="bzip2")

## RSD Decision ##########
asylum_decisions_residing <- read_sans_hxl(file =  here::here("data-raw","asylum_decisions_residing_world.csv"))

sinew::makeOxygen(asylum_decisions_residing, add_fields = "source")
# Rename column to have proper Variable names
asylum_decisions <- plyr::rename(asylum_decisions_residing, c("Country of Origin Code"="CountryOriginCode",
                                                               "Country of Asylum Code"="CountryAsylumCode", 
                                                               "Country of Origin Name"="CountryOriginName",
                                                               "Country of Asylum Name"="CountryAsylumName", 
                                                               "Procedure Type"="ProcedureType",                    
                                                               "Procedure Name"="ProcedureName",                    
                                                               "Decision Type Code"="DecisionTypeCode",                
                                                               "Decision Data Type"="DecisionDataType",                
                                                               "Decision Data"="DecisionData",                     
                                                               "Decisions Average Persons Per Case"= "DecisionsAveragePersonsPerCase",
                                                               "Complementary Protection"="ComplementaryProtection",          
                                                               "Otherwise Closed" ="OtherwiseClosed",                
                                                               "Total Decided" = "TotalDecided"
                                                               )
)


# View(unique(asylum_decisions[ ,c("ProcedureType",  "ProcedureName")]))
# View(unique(asylum_decisions[ ,c("DecisionTypeCode")]))

asylum_decisions$DecisionTypeName <- ""
asylum_decisions$DecisionTypeCode[is.na(asylum_decisions$DecisionTypeCode) ] <- "NA"
asylum_decisions$DecisionTypeName[asylum_decisions$DecisionTypeCode == "FI"] <- "First instance"
asylum_decisions$DecisionTypeName[asylum_decisions$DecisionTypeCode == "AR"] <- "Re-opened/repeat"
asylum_decisions$DecisionTypeName[asylum_decisions$DecisionTypeCode == "FA"] <- "First instance and appeal"
asylum_decisions$DecisionTypeName[asylum_decisions$DecisionTypeCode == "BL"] <- "BL"
asylum_decisions$DecisionTypeName[asylum_decisions$DecisionTypeCode == "NA"] <- "New applications"
asylum_decisions$DecisionTypeName[asylum_decisions$DecisionTypeCode == "RA"] <- "Repeat/reopened applications"
asylum_decisions$DecisionTypeName[asylum_decisions$DecisionTypeCode == "CA"] <- "CA"
asylum_decisions$DecisionTypeName[asylum_decisions$DecisionTypeCode == "EO"] <- "US Executive Office of Immigration Review"
asylum_decisions$DecisionTypeName[asylum_decisions$DecisionTypeCode == "IN"] <- "US Citizenship and Immigration Services"
asylum_decisions$DecisionTypeName[asylum_decisions$DecisionTypeCode == "TR"] <- "TR"
asylum_decisions$DecisionTypeName[asylum_decisions$DecisionTypeCode == "JR"] <- "Judicial Review "
asylum_decisions$DecisionTypeName[asylum_decisions$DecisionTypeCode == "SP"] <- "Subsidiary protection"
asylum_decisions$DecisionTypeName[asylum_decisions$DecisionTypeCode == "TA"] <- "Temporary asylum"
asylum_decisions$DecisionTypeName[asylum_decisions$DecisionTypeCode == "TP"] <- "Temporary Protection" 

#View(unique(asylum_decisions[ ,c("DecisionTypeCode","DecisionTypeName")])) 
sinew::makeOxygen(asylum_decisions, add_fields = "source")
save(asylum_decisions, file =  here::here("data","asylum_decisions.RData"))
# Note: significantly better compression could be obtained
#by using R CMD build --resave-data
tools::resaveRdaFiles(here::here("data","asylum_decisions.RData"),compress="bzip2")


## RDS Decision Long format ########

#names(asylum_decisions)

asylum_decisions_long <- reshape2::melt(asylum_decisions,
                                                  # ID variables - all the variables to keep but not split apart on
                                                  id.vars=c("Year", "CountryOriginCode","CountryAsylumCode",
                                                            "CountryOriginName","CountryAsylumName",
                                                            "ProcedureType",  "ProcedureName",
                                                            "DecisionTypeCode","DecisionTypeName",
                                                            "DecisionData","DecisionsAveragePersonsPerCase"),
                                                  # The source columns
                                                  measure.vars=c("Recognized","ComplementaryProtection","OtherwiseClosed","Rejected"),
                                                  # Name of the destination column that will identify the original
                                                  # column that the measurement came from
                                                  variable.name="Decision.output",
                                                  value.name="Value")

asylum_decisions_long <- asylum_decisions_long[asylum_decisions_long$Value > 0, ]

sinew::makeOxygen(asylum_decisions_long, add_fields = "source")
save(asylum_decisions_long, file =  here::here("data","asylum_decisions_long.RData"))
# Note: significantly better compression could be obtained
#by using R CMD build --resave-data
tools::resaveRdaFiles(here::here("data","asylum_decisions_long.RData"),compress="xz")


## merge RSD processing ##############
# asylum <- dplyr::left_join( x= asylum_applications, y = asylum_decisions, by = c("Year",
#                                                                                 "CountryOriginCode",
#                                                                                 "CountryAsylumCode", 
#                                                                                 "CountryOriginName",
#                                                                                 "CountryAsylumName",
#                                                                                 "ProcedureType" ,
#                                                                                 "ProcedureName"  ))
# 
# ## Difference between applied and processed
# #names(asylum)
# asylum$gapapplieddecided <- asylum$TotalDecided - asylum$NumberApplications
# table(asylum$gapapplieddecided, useNA = "ifany")






#### Check IDMC Colombia
# ckanr::ckanr_setup("https://data.humdata.org")
# 
# ckanr::package_search("name:idmc-idp-data-for-colombia", as = "table") %>% 
#   purrr::pluck("results", "resources", 1, "url") %>% 
#   purrr::walk(~ckanr::ckan_fetch(., store = "disk", path = fs::path("data-raw", fs::path_file(.))))
# 
# read_sans_hxl <- function(file, ...) {
#   hdrs <- readr::read_csv(file, n_max = 0) %>% names()
#   
#   readr::read_csv(file, col_names = hdrs, skip = 2, ...)
# }
# displacement_data_colombia <- read_sans_hxl(file =  here::here("data-raw","displacement_data_colombia.csv"))

# Note: significantly better compression could be obtained
#by using R CMD build --resave-data
#tools::resaveRdaFiles(here::here("data","migrants.RData"),compress="xz") 



### Add WB data 

wb_data <- WDI::WDI(#country = c(country_asylum_iso3c ) ,
                    country = "all",
                    indicator=c("SP.POP.TOTL", "NY.GDP.MKTP.CD", "NY.GDP.PCAP.CD", "NY.GNP.PCAP.CD"),
                    start = 1990, 
                    end = 2023,
                    extra = TRUE)   
# Renaming variables for further matching
names(wb_data)[3] <- "iso_3"
names(wb_data)[4] <- "Year"
wb_data$Year <- as.numeric(wb_data$Year)

sinew::makeOxygen(wb_data, add_fields = "source")
save(wb_data, file =  here::here("data","wb_data.RData"))
# Note: significantly better compression could be obtained
#by using R CMD build --resave-data
tools::resaveRdaFiles(here::here("data","wb_data.RData"),compress="xz")