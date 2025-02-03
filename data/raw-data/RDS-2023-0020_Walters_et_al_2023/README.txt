The data pulled directly from the EPA GHG report was
not in the necessary format or unit of analysis (state).

Data pulled directly from the EPA report includes:
  - LULUCF (all tables from the LULCF chapter)

The same data is used in Domke et al. 2021:
https://www.fs.usda.gov/research/treesearch/62418

Appendix 1 of this publication contains the state-level
forest area information, but is in PDF tables not suitable
for analysis.

The paper provides a link to a published research dataset
by Walters et al. 2021 which contains CSVs of the forest
area data from the EPA GHG analysis.

Analysis in R showed that the Walters et al. 2021 data
is a match for the EPA_forested data in tables from Drive.

Direct communication with data author Brian Walters on 1/17/2024
confirmed that all forest in the lower 48 states is "managed"
and it is appropriate to use the state land area when calculating
percent forest with Walters et al 2021 forest area estimates.

As of 2023, there is new data that goes through 2021 instead of 2019.
Associated with this publication:
U.S. Environmental Protection Agency [U.S. EPA]. 2023. Inventory of U.S. greenhouse gas emissions and sinks: 
1990–2021. U.S. Environmental Protection Agency. 430-R-23-002. Washington, DC: U.S. Environmental Protection Agency. 
Accessed 13 April 2023. https://www.epa.gov/ghgemissions/inventory-us-greenhouse-gas-emissions-and-sinks-1990-2021

In Sept 2024 the 2023 data was incorporated into analysis to replace the 2021 data.
DOI of updated data: https://doi.org/10.2737/RDS-2023-0020