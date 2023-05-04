## Course work

Format:

Will be an R markdown file as well as a rendered (HTML) output.

Will demo / document the R markdown setup.

I will grade on the implementation of the code, as well as the interpretation / critical assessment.

Most components can be lifted from the book chapters, but have to be implemented correctly. The process matters.

You might encounter "problems" you need to overcome, but all of them can be found in either the chapters or remote sensing product documentation and or common sense (basic physical geography knowledge).

### 1. The physics of phenology

- Convert the established relationship between altitude and phenology to one which includes temperature
  - i.e. provide an estimate on how many days phenology changes per degrees Celsius change.

### 2.Temporal / Spatial anomalies

For a location centered on the Adirondacks in the Eastern US calculate:

Location center: lat / lon (  43.5 / -74.5)
Gather data for all pixels in 100km around this location.

- Only consider deciduous broadleaf or mixed forest pixels (use a downloaded land cover product, IGBP classes)
 - filter all data accordingly
- calculate a long term mean and standard deviation for the period 2001 - 2009 in the green-up time and canopy maturity phenology metrics
- calculate locations with an early greenup for 2010 (mean - 1 sd) and locations with late maturity (mean + 1 sd)
- calculate all locations with early greenup but late maxima
- describe what this trend means - what can be the underlying reason for this trend
- download a DEM (30s resolution is good enough)
 - crop and resample as needed (motivate choices)
 - plot (as a boxplot) trends according to DEM altitude (describe what you see - speculate on the origin of this pattern)

### 3. Scaling, from pixels to the globe (just more pixels)

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
