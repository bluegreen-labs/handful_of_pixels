## Course work


### The physics of phenology

- Convert the established relationship between altitude and phenology to one which includes temperature
  - i.e. provide an estimate on how many days phenology changes per degrees Celsius change.

### Temporal / Spatial anomalies

For a location centered on the Adirondacks in the Eastern US calculate:

- Start of season phenology for thresholds of respectively 25 and 85% amplitude for years 2001 - 2010
- Only consider deciduous broadleaf or mixed forest pixels
- calculate a long term mean and standard deviation for the period 2001 - 2009 in the green-up time (time between 25% - 85% amplitude)
- calculate the difference between the long term mean and 2010
  - how different are the results from the previous decade, and could you explain differences if any?

### Scaling, from pixels to the globe (just more pixels)

Download data here:
https://lpdaac.usgs.gov/products/mod13c1v006/

Create login and access data here:
https://e4ftl01.cr.usgs.gov/MOLT/MOD13C1.006/

Create NASA EarthData login

r <- rast(files,  subds = "\"CMG 0.05 Deg 16 days EVI\"")

- download /use MODIS CMG data (climate model grid at 5 km)
  - downloaded from the LP DAAC (might provide the data - although it would be a good exercise in data acquisition)
- apply the algorithm to the globe for the EVI (enhanced vegetation index)
- assess the performance and consistency across the globe
  - where does it fail?
  - how does it fail?
  - can you address it?


- Intercept (0 m) is 54: few leaf-out events before DOY 54
- change of 0.04 days per meter increase in altitude (or 4 days per 100m)

Phenology is driven by temperature, increasing altitude causes a [lapse rate in temperature](https://en.wikipedia.org/wiki/Lapse_rate). What is shown above is the sensitivity to temperatures as imposed by the physical geography of the landscape (topography), which causes a decline in temperature when forced upwards. The lapse rate of dry air is 9.8 degrees C per 1000m. Or 0.98 degrees per 100m.

Using this knowledge we can, roughly, infer that the temperature sensitivity of (landscape) phenology is roughly 4 days per degree C change. Meaning, a change of one degree leading up to the leaf out event will cause delay (when 1 degree colder) or advancing of (when 1 degree warmer) of (landscape) vegetation phenology. This observation reflects, in part, Hopkin's Bioclimatic Law which hypothesized that phenological  events shifted  by four days for every 1° latitude north, 5° longitude west, and 120 m of elevation change (Hopkins, 1900, 1920a, b -- FIX REFERENCE). These observations still hold a 100 years on, as demonstrated by spatial analysis and changes observed under climate change (REFERENCES).
