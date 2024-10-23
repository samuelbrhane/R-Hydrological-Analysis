# R-Hydrological-Analysis

R-based hydrological analysis of the Savinja River catchment (Veliko Širje station), covering data preparation, basic analysis, low-flow and flood frequency analysis, and hydrological modeling using precipitation, discharge, and evapotranspiration data (2010-2022).

## Project Overview

The aim of this project is to perform a comprehensive hydrological analysis of the Savinja River catchment, utilizing historical data to evaluate various hydrological processes and trends.

### Key Analysis Tasks:

1. **Data Preparation**:

   - Import and clean data for discharge, precipitation (from five stations), evapotranspiration, and air temperature.
   - Handle missing precipitation data using data from other stations.

2. **Basic Hydrological Analysis**:

   - Calculate descriptive statistics for discharge, precipitation, evapotranspiration, and air temperature.
   - Plot graphs for these variables over the whole study period and for the year 2022.
   - Calculate correlations between precipitation stations and plot correlograms.
   - Calculate water balance and runoff coefficient for individual years (2010-2022).
   - Calculate yearly ratio between evapotranspiration and average catchment precipitation.

3. **Low-Flow and Trend Analysis**:

   - Perform low-flow analysis using the `lfstat` package and baseflow separation.
   - Plot flow duration curves and calculate key low-flow indexes (BFI, MAM, Q95, Q90).
   - Conduct Mann-Kendall test for trend analysis of discharge, precipitation, air temperature, and evapotranspiration.

4. **Flood Frequency Analysis**:

   - Conduct flood frequency analysis using daily discharge data and peak discharge data.
   - Fit flood frequency distribution models and plot results.
   - Calculate confidence intervals using parametric bootstrap methods.

5. **Multivariate Flood Frequency Analysis**:

   - Analyze relationships between discharge, volume, and hydrograph duration using copula functions.
   - Calculate multivariate return periods (e.g., 10, 50, 100, and 500 years).

6. **Spatial Data Analysis**:

   - Generate stream networks and catchment boundaries using digital terrain models.
   - Calculate terrain statistics and create catchment hypsometric curves.
   - Analyze land-use data using the CLC Corine map.

7. **Hydrological Modeling**:

   - Calibrate and validate hydrological models (GR4J, CemaNeige GR6J, and TUWIEN models).
   - Compare model performance and simulate future scenarios.

8. **Stochastic Climate Simulation**:

   - Fit stochastic models for precipitation and temperature simulation.
   - Simulate future climate scenarios and use these simulations in hydrological models.

9. **IDF and Huff Curves**:

   - Calculate IDF curves and define Huff curves for rainfall duration events.
   - Define a 100-year design storm event and use it in hydrological models.

10. **MODIS and ERA5 Data Analysis**:
    - Download and analyze MODIS snow cover and ERA5 climate data for the catchment.
    - Compare remote sensing data with gauge-based observations.
