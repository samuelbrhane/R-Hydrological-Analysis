## ----setup, include=FALSE-----------------------------------------------------------------------------------------------
knitr::opts_chunk$set(echo = TRUE)


library(knitr)
library(writexl)
library(readxl)
library(dplyr)
library(ggplot2)
library(corrplot)


## ----echo=FALSE---------------------------------------------------------------------------------------------------------
gauge_stations <- list(
  Luče = list(longitude = 14.7457, latitude = 46.3543, elevation = 513),
  Solčava = list(longitude = 14.6914, latitude = 46.4203, elevation = 639),
  Laško = list(longitude = 15.2341, latitude = 46.1565, elevation = 221),
  GornjiGrad = list(longitude = 14.8077, latitude = 46.2960, elevation = 430),
  Radegunda = list(longitude = 14.9330, latitude = 46.3661, elevation = 794)
)

temp_station <- list(
  CeljeMedlog = list(longitude = 15.2259, latitude = 46.2366, elevation = 242)
)


## ----data_import--------------------------------------------------------------------------------------------------------
# Import dataset from excel file
main_data = read_excel("Savinja-VelikoSirje.xlsx")

# Create dataframe
main_data = as.data.frame(main_data)

# Convert the 'Date' column to Date type
main_data$Date <- as.Date(main_data$Date, format = "%d.%m.%Y")

head(main_data)


## ----cleaning_data------------------------------------------------------------------------------------------------------
# Structure of dataframe
str(main_data)

# Check for missing values
missing_data <- colSums(is.na(main_data))
missing_data


## ----waterlevel_imputation----------------------------------------------------------------------------------------------
sum(is.na(main_data$Waterlevel))

# Fit linear regression model using Discharge
model <- lm(Waterlevel ~ Discharge, data = main_data, na.action = na.exclude)
model

# Predict missing Waterlevel
missing_waterlevel <- which(is.na(main_data$Waterlevel))
predicted_values <- predict(model, newdata = main_data[missing_waterlevel, ])
predicted_values

# Fill missing Waterlevel values
main_data$Waterlevel[missing_waterlevel] <- predicted_values

# Check Waterlevel again
sum(is.na(main_data$Waterlevel))


## ----watertemp_imputation-----------------------------------------------------------------------------------------------
missing_watertemps = which(is.na(main_data$Watertemp))
missing_watertemps

# Loop missing watertemp and fill 
for (i in missing_watertemps){
  current_year <- main_data$Year[i]
  date_without_year <- format(main_data$Date[i], "%m-%d")
  
  # Find Watertemp and Airtemp for same date in previous years
  previous_data <- main_data %>% 
    filter(format(Date, "%m-%d") == date_without_year & Year < current_year) %>% 
    select(Watertemp, Airtemp)
  
  # Calculate mean of Watertemp and Airtemp
  if(nrow(previous_data) > 0){
    watertemp_mean <- mean(previous_data$Watertemp)
    airtemp_mean <- mean(previous_data$Airtemp)
    
    main_data$Watertemp[i] <- watertemp_mean + (main_data$Airtemp[i] - airtemp_mean)
  }
}

# Check Watertemp
sum(is.na(main_data$Watertemp))


## ----fill_p3_lasko------------------------------------------------------------------------------------------------------
missing_lasko <-  which(is.na(main_data$P3_Lasko))

# Fill missing values with average of other stations
for (i in missing_lasko){
  other_prec <- main_data[i, c("P1_Luce", "P2_Solcava", "P4_GornjiGrad", "P5_Radegunda")]
  main_data$P3_Lasko[i] <- mean(as.numeric(other_prec))
}

# Check P3_Lasko
sum(is.na(main_data$P3_Lasko))


## -----------------------------------------------------------------------------------------------------------------------
# Check main_data for any missing values
colSums(is.na(main_data))


## ----discharge_statistics-----------------------------------------------------------------------------------------------
# Calculate descriptive statistics for Discharge
discharge_stats <- data.frame(
  Statistic = c("Mean", "Standard Deviation", "Minimum", "Maximum", "Median"),
  Values = c(
    mean(main_data$Discharge),
    sd(main_data$Discharge),
    min(main_data$Discharge),
    max(main_data$Discharge),
    median(main_data$Discharge))
) 

discharge_stats

# Summary statistics for Discharge
summary(main_data$Discharge)

## ----precipitation_statistics-------------------------------------------------------------------------------------------
# Calculate descriptive statistics for Precipitation 
precipitation_stats <- data.frame(
  Statistic = c("Mean", "Standard Deviation", "Minimum", "Maximum", "Median"),
  Values = c(
    mean(c(main_data$P1_Luce, main_data$P2_Solcava, main_data$P3_Lasko, main_data$P4_GornjiGrad, main_data$P5_Radegunda)),
    sd(c(main_data$P1_Luce, main_data$P2_Solcava, main_data$P3_Lasko, main_data$P4_GornjiGrad, main_data$P5_Radegunda)),
    min(c(main_data$P1_Luce, main_data$P2_Solcava, main_data$P3_Lasko, main_data$P4_GornjiGrad, main_data$P5_Radegunda)),
    max(c(main_data$P1_Luce, main_data$P2_Solcava, main_data$P3_Lasko, main_data$P4_GornjiGrad, main_data$P5_Radegunda)),
    median(c(main_data$P1_Luce, main_data$P2_Solcava, main_data$P3_Lasko, main_data$P4_GornjiGrad, main_data$P5_Radegunda))
  )
)

precipitation_stats

# Summary statistics for Precipitation
summary(c(main_data$P1_Luce, main_data$p2_Solcava, main_data$P3_Lasko, main_data$P4_GornjiGrad, main_data$P5_Radegunda))

## ----precipiation_stations----------------------------------------------------------------------------------------------
# P1_Luce
mean(main_data$P1_Luce)
sd(main_data$P1_Luce)
min(main_data$P1_Luce)
max(main_data$P1_Luce)
median(main_data$P1_Luce)

# P2_Solcava
mean(main_data$P2_Solcava)
sd(main_data$P2_Solcava)
min(main_data$P2_Solcava)
max(main_data$P2_Solcava)
median(main_data$P2_Solcava)

# P3_Lasko
mean(main_data$P3_Lasko)
sd(main_data$P3_Lasko)
min(main_data$P3_Lasko)
max(main_data$P3_Lasko)
median(main_data$P3_Lasko)

# P4_GornjiGrad
mean(main_data$P4_GornjiGrad)
sd(main_data$P4_GornjiGrad)
min(main_data$P4_GornjiGrad)
max(main_data$P4_GornjiGrad)
median(main_data$P4_GornjiGrad)

# P5_Radegunda
mean(main_data$P5_Radegunda)
sd(main_data$P5_Radegunda)
min(main_data$P5_Radegunda)
max(main_data$P5_Radegunda)
median(main_data$P5_Radegunda)


## ----airtemp_statistics-------------------------------------------------------------------------------------------------
# Calculate descriptive statistics for Air Temperature
airtemp_stats <- data.frame(
  Statistic = c("Mean", "Standard Deviation", "Minimum", "Maximum", "Median"),
  Values = c(
    mean(main_data$Airtemp),
    sd(main_data$Airtemp),
    min(main_data$Airtemp),
    max(main_data$Airtemp),
    median(main_data$Airtemp)
  )
)

airtemp_stats

# Summary statistics for Air Temperature
summary(main_data$Airtemp)


## ----evapotrans_statistics----------------------------------------------------------------------------------------------
# Calculate descriptive statistics for Evapotranspiration
evapotrans_stats <- data.frame(
  Statistic = c("Mean", "Standard Deviation", "Minimum", "Maximum", "Median"),
  Values = c(
    mean(main_data$Evapotrans),
    sd(main_data$Evapotrans),
    min(main_data$Evapotrans),
    max(main_data$Evapotrans),
    median(main_data$Evapotrans)
  )
)

evapotrans_stats

# Summary statistics for Evapotranspiration
summary(main_data$Evapotrans)


## ----plot_discharge-----------------------------------------------------------------------------------------------------
# Plot Discharge over the whole period
plot(main_data$Date, main_data$Discharge, type = "l",
     xlab = "Date", ylab = "Discharge (m^3/s)", main = "Discharge Over Whole Period")

# Plot Discharge for year 2022
data_2022 <- main_data[format(main_data$Date, "%Y") == "2022",]
plot(data_2022$Date, data_2022$Discharge, type = "l",
     xlab = "Date", ylab = "Discharge (m^3/s)", main = "Discharge For Year 2022")


## ----plot_precipitation-------------------------------------------------------------------------------------------------
# Plot Precipitation over whole period for all stations
plot(main_data$Date, main_data$P1_Luce, type = "l", col = "blue",
     xlab = "Date", ylab = "Precipitation (mm)", main = "Precipitation Over Whole Period")

# All lines for other stations
lines(main_data$Date, main_data$P2_Solcava, col = "red")
lines(main_data$Date, main_data$P3_Lasko, col = "green")
lines(main_data$Date, main_data$P4_GornjiGrad, col = "purple")
lines(main_data$Date, main_data$P5_Radegunda, col = "orange")

# Add legend
legend("topright", legend = c("P1_Luce", "P2_Solcava", "P3_Lasko", "P4_GornjiGrad", "P5_Radegunda"),
       col = c("blue", "red", "green", "purple", "orange"), lty = 1)


# Plot Precipitation for year 2022 
plot(data_2022$Date, data_2022$P1_Luce, type = "l", col = "blue",
     xlab = "Date", ylab = "Precipitation (mm)", main = "Precipitation for Year 2022")

# Add lines for other stations
lines(data_2022$Date, data_2022$p2_Solcava, col = "red")
lines(data_2022$Date, data_2022$P3_Lasko, col = "green")
lines(data_2022$Date, data_2022$P4_GornjiGrad, col = "purple")
lines(data_2022$Date, data_2022$P5_Radegunda, col = "orange")

# Add a legend
legend("topright", legend = c("P1_Luce", "P2_Solcava", "P3_Lasko", "P4_GornjiGrad", "P5_Radegunda"),
       col = c("blue", "red", "green", "purple", "orange"), lty = 1)

## ----average_precipiation-----------------------------------------------------------------------------------------------
# Calculate the average precipitation across all stations
main_data$Avg_Precipitation <- rowMeans(main_data[, c("P1_Luce", "P2_Solcava", "P3_Lasko", "P4_GornjiGrad", "P5_Radegunda")])

# Plot Average Precipitation over the whole period
plot(main_data$Date, main_data$Avg_Precipitation, type = "l",
     xlab = "Date", ylab = "Average Precipitation (mm)", main = "Average Precipitation Over Whole Period")

# Plot Average Precipitation for year 2022
data_2022 <- main_data[format(main_data$Date, "%Y") == "2022",]
plot(data_2022$Date, data_2022$Avg_Precipitation, type = "l",
     xlab = "Date", ylab = "Average Precipitation (mm)", main = "Average Precipitation For Year 2022")


## ----plot_evapotranspiration--------------------------------------------------------------------------------------------
# Plot Evapotranspiration over whole period
plot(main_data$Date, main_data$Evapotrans, type = "l", col = "blue",
     xlab = "Date", ylab = "Evapotranspiration (mm)", main = "Evapotranspiration Over Whole Period")

# Plot Evapotranspiration for year 2022
data_2022 <- main_data[format(main_data$Date, "%Y") == "2022",]
plot(data_2022$Date, data_2022$Evapotrans, type = "l", col = "blue",
     xlab = "Date", ylab = "Evapotranspiration (mm)", main = "Evapotranspiration For Year 2022")


## ----plot_airtemprature-------------------------------------------------------------------------------------------------
# Plot Air Temperature over the whole period
plot(main_data$Date, main_data$Airtemp, type = "l", col = "red",
     xlab = "Date", ylab = "Air Temperature (°C)", main = "Air Temperature Over Whole Period")

# Plot Air Temperature for year 2022
plot(data_2022$Date, data_2022$Airtemp, type = "l", col = "red",
     xlab = "Date", ylab = "Air Temperature (°C)", main = "Air Temperature For Year 2022")


## ----plot_correlation---------------------------------------------------------------------------------------------------
# Precipitation columns
precipitation_data <- main_data[, c("P1_Luce", "P2_Solcava", "P3_Lasko", "P4_GornjiGrad", "P5_Radegunda")]

# Calculate correlation matrix
cor_matrix <- cor(precipitation_data)

cor_matrix

# Plot correlogram
corrplot(cor_matrix, method = "shade", type = "full", 
         tl.col = "orange", tl.srt = 45,
         title = "Correlogram of Precipitation Stations", 
          mar = c(0, 0, 2, 0)
)


## ----water_balance------------------------------------------------------------------------------------------------------
# Catchment area in m²
catchment_area <- 1847000000

# Calculate Runoff
main_data$Runoff <- (main_data$Discharge * 3600 * 24 * 1000) / catchment_area

# Calculate the water balance
main_data$Water_Balance <- main_data$Avg_Precipitation - main_data$Evapotrans - main_data$Runoff

# Save main_data to an Excel file
# write_xlsx(main_data, "main_data_output.xlsx")


## ----runoff_coeffiecient------------------------------------------------------------------------------------------------
# Group data by Year and calculate total runoff and total precipitation
annual_runoff <- main_data %>%
  group_by(Year) %>%
  summarise(
    Total_Runoff = sum(Runoff),             
    Total_Precipitation = sum(Avg_Precipitation)
  )

# Calculate the runoff coefficient for each year
annual_runoff$Runoff_Coefficient <- annual_runoff$Total_Runoff / annual_runoff$Total_Precipitation

annual_runoff

# Plot the runoff coefficient over the years
plot(as.numeric(annual_runoff$Year), annual_runoff$Runoff_Coefficient, type = "b", col = "blue",
     xlab = "Year", ylab = "Runoff Coefficient", main = "Runoff Coefficient Values")



## ----evapotrans_prec_ratio----------------------------------------------------------------------------------------------
# Group data by Year and calculate total evapotranspiration and total precipitation
evapotrans_prec <- main_data %>% 
  group_by(Year) %>% 
  summarise(
    Avg_Evapotrans = sum(Evapotrans),
    Avg_Precipitation = sum(Avg_Precipitation))

# Calculate evapotranspiration to precipitation ratio
evapotrans_prec$Ratio <- evapotrans_prec$Avg_Evapotrans / evapotrans_prec$Avg_Precipitation

evapotrans_prec

# Plot evapotranpitation to precipitation ratio
plot(evapotrans_prec$Year, evapotrans_prec$Ratio, type = "b", col = "orange",
     xlab = "Year", ylab = "Ratio", main = "Evapotranspiration to Precipitation Ratio")

