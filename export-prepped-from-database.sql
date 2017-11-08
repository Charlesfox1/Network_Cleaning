-- This script creates the files needed by `Network_Clean.py`, drawing
-- upon the ORMA–VN database and schema
-- Specifically: `Original_Intervals.csv`, `Original_Points.csv`, and `Adj_lines.csv`

-- So, instead of building a network form a directory of RoadLabPro runs,
-- you could build one from the ORMA–VN database

BEGIN;

    -- Generating `Original_Intervals.csv`
    CREATE TEMP VIEW original_intervals AS
        SELECT datetime AS time,
            properties ->> 'speed' AS speed,
            properties ->> 'category' AS category,
            ST_X(geom) AS start_lat,
            ST_Y(geom) AS start_lon,
            ST_X(geom) AS end_lat,
            ST_Y(geom) AS end_lon,
            properties ->> 'is_fixed' AS is_fixed,
            properties ->> 'iri' AS iri,
            properties ->> 'distance' AS distance,
            properties ->> 'suspension' AS suspension,
            ST_ASTEXT(geom) AS "Line_Geometry",
            road_id AS "VPROMMS_ID"
        FROM point_properties;

    \copy (SELECT * FROM original_intervals) to data/output/Original_Intervals.csv CSV HEADER


    -- Generating `Original_Points.csv`
    CREATE TEMP VIEW original_points AS
        SELECT datetime AS time,
            ST_X(geom) AS latitude,
            ST_Y(geom) AS longitude,
            ST_ASTEXT(geom) AS "Point_Geometry",
            road_id AS "VPROMMS_ID"
        FROM point_properties;

    \copy (SELECT * FROM original_points) to data/output/Original_Points.csv CSV HEADER


    -- Generating `Adj_lines.csv`
    CREATE TEMP VIEW adj_lines_nodes AS
        SELECT wn.way_id,
            ST_MAKEPOINT(
                n.longitude::FLOAT / 10000000,
                n.latitude::FLOAT / 10000000
            ) AS geom,
            wt.v AS or_vpromms
        FROM current_way_nodes AS wn
        LEFT JOIN current_ways AS w ON wn.way_id = w.id
        LEFT JOIN current_nodes AS n ON wn.node_id = n.id
        LEFT JOIN current_way_tags AS wt ON
            wt.way_id = wn.way_id AND
            wt.k = 'or_vpromms'
        WHERE w.visible IS TRUE AND
            wt.v IS NOT NULL
        ORDER BY wn.way_id,
            wt.v,
            wn.sequence_id;

    CREATE TEMP VIEW adj_lines_roads AS
        SELECT ST_MAKELINE(ARRAY_AGG(geom)) AS geom,
            or_vpromms
        FROM adj_lines_nodes
        GROUP BY way_id,
            or_vpromms;

    CREATE TEMP VIEW adj_lines AS
        SELECT ST_ASTEXT(g.geom) AS "Line_Geometry",
            ROW_NUMBER() OVER () AS "ID",
            p.properties ->> 'iri_mean' AS iri_mean,
            p.properties ->> 'iri_med' AS iri_med,
            p.properties ->> 'iri_min' AS iri_min,
            p.properties ->> 'iri_max' AS iri_max,
            g.or_vpromms AS "VPROMMS_ID",
            ST_LENGTH(g.geom::GEOGRAPHY) / 1000 AS length
        FROM adj_lines_roads AS g
        LEFT JOIN road_properties AS p ON g.or_vpromms = p.id;

    \copy (SELECT * FROM adj_lines) to data/output/Adj_lines.csv CSV HEADER

COMMIT;
