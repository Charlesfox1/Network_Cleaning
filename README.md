# RoadLabPro cleaning utilities

Scripts for converting [RoadLabPro](https://github.com/WorldBank-Transport/RoadLab-Pro) CSVs into routable shapefiles, and for conflating the properties into the path.

## Setup

`pip install -r requirements.txt`

Then, `pip install` the GDAL bindings for your machine's version of GDAL. [Here are loose instructions.](https://stackoverflow.com/questions/38630474/error-while-installing-gdal#comment70408136_38630941)

Update the `Input` and `Settings` for the two Python scripts.

## Running

Run a directory of raw RoadLabPro data through `Network_Prep.py` first. This produces two files, describing the network as a whole.

Then, use those two files as inputs to `Network_Clean.py`, to create a routable network whose roads have quality properties and road IDs attached.
