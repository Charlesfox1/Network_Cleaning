# RoadLabPro cleaning utilities

Scripts for converting [RoadLabPro](https://github.com/WorldBank-Transport/RoadLab-Pro) CSVs into routable shapefiles, and for conflating the properties into the path.

## Setup

- `pip install -r requirements.txt`, using Python 2
- Place your input RoadLabPro data into the `data/input` directory.

## Running

Run `Network_Prep.py` first. This produces outputs, that contain all input roads and all road quality point-properties. The roads have nearby point-properties conflated to them, so that in addition to geometry they contain summary statistics for IRI and other values.

Then, use those as an input to `Network_Clean.py`, which will make this network routable.
