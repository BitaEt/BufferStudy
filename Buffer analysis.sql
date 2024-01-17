\
CREATE SCHEMA IF NOT EXISTS final
    AUTHORIZATION etaati_admin;





create table final.crashes (

    CASE_ID text,
    ACCIDENT_YEAR text,
    PROC_DATE timestamp,
    JURIS text,
    COLLISION_DATE timestamp,
    COLLISION_TIME text,
    OFFICER_ID text,
    REPORTING_DISTRICT text,
    DAY_OF_WEEK numeric,
    CHP_SHIFT numeric,
    POPULATION numeric,
    CNTY_CITY_LOC numeric,
    SPECIAL_COND numeric,
    BEAT_TYPE numeric,
    CHP_BEAT_TYPE text,
    CITY_DIVISION_LAPD text,
    CHP_BEAT_CLASS numeric,
    BEAT_NUMBER text,
    PRIMARY_RD text,
    SECONDARY_RD text,
    DISTANCE numeric,
    DIRECTION text,
    INTERSECTION text,
    WEATHER_1 text,
    WEATHER_2 text,
    STATE_HWY_IND text,
    CALTRANS_COUNTY text,
    CALTRANS_DISTRICT text,
    STATE_ROUTE text,
    ROUTE_SUFFIX text,
    POSTMILE_PREFIX text,
    POSTMILE text,
    LOCATION_TYPE text,
    RAMP_INTERSECTION text,
    SIDE_OF_HWY text,
    TOW_AWAY text,
    COLLISION_SEVERITY numeric,
    NUMBER_KILLED numeric,
    NUMBER_INJURED numeric,
    PARTY_COUNT numeric,
    PRIMARY_COLL_FACTOR text,
    PCF_CODE_OF_VIOL text,
    PCF_VIOL_CATEGORY text,
    PCF_VIOLATION text,
    PCF_VIOL_SUBSECTION text,
    HIT_AND_RUN text,
    TYPE_OF_COLLISION text,
    MVIW text,
    PED_ACTION text,
    ROAD_SURFACE text,
    ROAD_COND_1 text,
    ROAD_COND_2 text,
    LIGHTING text,
    CONTROL_DEVICE text,
    CHP_ROAD_TYPE text,
    PEDESTRIAN_ACCIDENT text,
    BICYCLE_ACCIDENT text,
    MOTORCYCLE_ACCIDENT text,
    TRUCK_ACCIDENT text,
    NOT_PRIVATE_PROPERTY text,
    ALCOHOL_INVOLVED text,
    STWD_VEHTYPE_AT_FAULT text,
    CHP_VEHTYPE_AT_FAULT text,
    COUNT_SEVERE_INJ text,
    COUNT_VISIBLE_INJ text,
    COUNT_COMPLAINT_PAIN text,
    COUNT_PED_KILLED text,
    COUNT_PED_INJURED text,
    COUNT_BICYCLIST_KILLED text,
    COUNT_BICYCLIST_INJURED text,
    COUNT_MC_KILLED text,
    COUNT_MC_INJURED text,
    PRIMARY_RAMP text,
    SECONDARY_RAMP text,
    LATITUDE numeric,
    LONGITUDE numeric,
    COUNTY text,
    CITY text,
    POINT_X DOUBLE PRECISION,
    POINT_Y DOUBLE PRECISION );


    create table final.victims(
    CASE_ID text,
    PARTY_NUMBER numeric,
    VICTIM_NUMBER numeric,
    VICTIM_ROLE numeric,
    VICTIM_SEX text,
    VICTIM_AGE numeric,
    VICTIM_DEGREE_OF_INJURY numeric,
    VICTIM_SEATING_POSITION text,
    VICTIM_SAFETY_EQUIP_1 text,
    VICTIM_SAFETY_EQUIP_2 text,
    VICTIM_EJECTED text,
    COUNTY text,
    CITY text,
    ACCIDENT_YEAR numeric
    );


    create table final.parties(
    CASE_ID text,
    PARTY_NUMBER numeric,
    PARTY_TYPE text,
    AT_FAULT text,
    PARTY_SEX text,
    PARTY_AGE numeric,
    PARTY_SOBRIETY text,
    PARTY_DRUG_PHYSICAL text,
    DIR_OF_TRAVEL text,
    PARTY_SAFETY_EQUIP_1 text,
    PARTY_SAFETY_EQUIP_2 text,
    FINAN_RESPONS text,
    SP_INFO_1 text,
    SP_INFO_2 text,
    SP_INFO_3 text,
    OAF_VIOLATION_CODE text,
    OAF_VIOL_CAT text,
    OAF_VIOL_SECTION text,
    OAF_VIOLATION_SUFFIX text,
    OAF_1 text,OAF_2 text,
    PARTY_NUMBER_KILLED numeric,
    PARTY_NUMBER_INJURED numeric,
    MOVE_PRE_ACC text,
    VEHICLE_YEAR numeric,
    VEHICLE_MAKE text,
    STWD_VEHICLE_TYPE text,
    CHP_VEH_TYPE_TOWING text,
    CHP_VEH_TYPE_TOWED text,
    RACE text,
    INATTENTION text,
    SPECIAL_INFO_F text,
    SPECIAL_INFO_G text,
    ACCIDENT_YEAR numeric
    );

    alter table final.crashes add primary key (case_id);
    alter table final.parties add foreign key (case_id) REFERENCES final.crashes(case_id);
    alter table final.victims add foreign key (case_id) REFERENCES final.crashes(case_id);


 create table final.schools (

   School_Name text,
   Latitude	float,
   Longitude float
 )


 ###Adding shapefiles

 shp2pgsql -s 2230 /Users/bitaetaati/Desktop/ShapeFile/BIKE_ROUTES/BIKE_ROUTES.shp final.bike_routes | /Library/PostgreSQL/13/bin/psql -h 130.191.118.187 -U etaati_admin Etaati
 shp2pgsql -s 2230 /Users/bitaetaati/Desktop/ShapeFile/street_lights/street_lights.shp final.street_light | /Library/PostgreSQL/13/bin/psql -h 130.191.118.187 -U etaati_admin Etaati
 shp2pgsql -s 2230 /Users/bitaetaati/Desktop/ShapeFile/streets/streets.shp final.streets | /Library/PostgreSQL/13/bin/psql -h 130.191.118.187 -U etaati_admin Etaati
 shp2pgsql -s 2230 /Users/bitaetaati/Desktop/ShapeFile/Roads_Intersection/Roads_Intersection.shp final.Roads_Intersection | /Library/PostgreSQL/13/bin/psql -h 130.191.118.187 -U etaati_admin Etaati


create index idx_crashes_geom on final.crashes using gist(geom);
create index idx_bikeroutes_geom on public.bike_routes using gist(geom);
create index idx_streetlights_geom on final.street_light using gist(geom);
create index idx_streets_geom on final.streets using gist(geom);
create index idx_intersection_geom on final.Roads_Intersection using gist(geom);


### Adding geom to the dataset

 DELETE FROM final.schools WHERE school_name is null;
 DELETE FROM final.schools WHERE latitude is null;


 ALTER TABLE final.crashes ADD COLUMN geom geometry;
UPDATE final.crashes SET geom = ST_SetSRID(ST_MakePoint(point_x, point_y), 4326);

ALTER TABLE final.schools ADD COLUMN geom geometry;
UPDATE final.schools SET geom = ST_SetSRID(ST_MakePoint(LONGITUDE,latitude), 4326);



######## accidents happened in the radius of 1 miles


select s.school_name, count(*) from final.schools s, final.crashes c
where ST_DWithin((st_transform(s.geom, 2230)), (st_transform(c.geom, 2230)), 5280)
group by s.school_name
order by count desc


######## accidents happened in the radius of 0.5 miles

select s.school_name, count(*) from final.crashes c,
final.schools s
where ST_DWithin((st_transform(s.geom, 2230)), (st_transform(c.geom, 2230)), 2640)
group by s.school_name
order by count desc

######## accidents happened in the radius of 0.25 miles

select s.school_name, count(*) from final.crashes c,
final.schools s
where ST_DWithin((st_transform(s.geom, 2230)), (st_transform(c.geom, 2230)), 1320)
group by s.school_name
order by count desc

######### lightening

select c.lighting, count(*) from final.crashes c,
final.schools s
where ST_DWithin((st_transform(s.geom, 2230)), (st_transform(c.geom, 2230)), 1320)
group by c.lighting
order by count desc

--- most accidents happened in daylight

select case when p.party_sobriety = 'A' then 'sober'
else 'drunk'
end as sobriety, count(*)
from final.schools s,
final.parties p
inner join final.crashes c
on p.case_id = c.case_id
where ST_DWithin((st_transform(s.geom, 2230)), (st_transform(c.geom, 2230)), 1320)
group by sobriety

--- in 21% of accidents the driver was under some influence

####accidents per weekday and time

select day_of_week, count(*) from final.crashes
group by day_of_week
order by day_of_week


SELECT LEFT(collision_time, 2) AS hour, count(*) from final.crashes
group by LEFT(collision_time, 2)
order by  LEFT(collision_time, 2)


####### road condition
SELECT ROAD_COND_1, count(*) from final.crashes
group by ROAD_COND_1
order by count desc


SELECT LIGHTING, count(*) ,
case when lighting = 'A' then 'Daylight'
when lighting = 'C' then 'Dark and Street light'
 when lighting = 'B' then 'Dusk - Dawn'
when lighting = 'D' then 'Dark and No Street light' end as light
from final.crashes
group by LIGHTING
order by count desc


SELECT WEATHER_1, count(*),
case when WEATHER_1= 'A' then 'Clear'
when WEATHER_1= 'B' then 'Cloudy'
when WEATHER_1= 'C' then 'raining' end as weather
from final.crashes
group by WEATHER_1
order by count desc



select PED_ACTION,
case when PED_ACTION = 'A' then 'No Pedestrian Involved'
when PED_ACTION = 'B' then 'Crossing in Crosswalk at Intersection'
when PED_ACTION = 'C' then 'Crossing in Crosswalk Not at Intersection'
when PED_ACTION = 'D' then 'Crossing Not in Crosswalk'
when PED_ACTION = 'E' then 'In Road, Including Shoulder'
when PED_ACTION = 'F' then 'Not in Road'
end as pedestrian_action,

count(*)from final.crashes
group by PED_ACTION
order by count desc




######### Accidents happening within 2 feet of the route

--SELECT count(*) from final.crashes c
---inner join public.bike_routes b on St_intersects(ST_Buffer(ST_transform(c.geom,2230), 10), b.geom)

-- 1 feet
SELECT route_clas,count(*) from final.crashes c
inner join public.bike_routes b on St_intersects(ST_Buffer(ST_transform(c.geom,2230), 1), b.geom)
where route_clas not like '%Bikeways Coming Soon%'
group by route_clas

--- 2 feet



SELECT route_clas,count(*) from final.crashes c
inner join public.bike_routes b on St_intersects(ST_Buffer(ST_transform(c.geom,2230), 2), b.geom)
where route_clas not like '%Bikeways Coming Soon%'
group by route_clas



######### Accidents happening at night - street lights

select
case when c.collision_severity = '1' then 'Fatal'
when c.collision_severity = '2' then 'Injury (Severe)'
when c.collision_severity = '3' then 'Injury (Other Visible)'
when c.collision_severity = '4' then 'Injury (Complaint of Pain)'
end as collision_severity, count(*)

from final.crashes c
where c.case_id not in (SELECT c.case_id from final.crashes c
inner join final.street_light b on ST_intersects((St_buffer(ST_transform(c.geom,2230),75)), b.geom)
where ST_intersects((St_buffer(ST_transform(c.geom,2230),75)), b.geom))
and c.lighting not like 'A'
group by  c.collision_severity
order by count desc


SELECT s.speedlimit, s.fullroadna, count(*) from final.crashes c
inner join final.streets s on ST_DWithin(s.geom, (ST_transform(c.geom,2230)),10)
group by s.speedlimit, s.fullroadna
order by count desc


####### severe accident speed limit
SELECT s.speedlimit, count(*) from final.crashes c
inner join final.streets s on ST_DWithin(s.geom, (ST_transform(c.geom,2230)),10)
where c.collision_severity in (1,2)
group by s.speedlimit
order by s.speedlimit desc



######## Nearest neighbour

with cte as(
			select distinct on (c.geom) c.geom, s.geom, s.school_name,
			ST_intersection(st_buffer((st_transform(s.geom, 2230)),5280), (st_transform(c.geom, 2230))) from final.schools s
			 inner join final.crashes c on ST_intersects(st_buffer((st_transform(s.geom, 2230)),5280), (st_transform(c.geom, 2230)))
group by s.school_name, s.geom, c.geom)
select cte.school_name, count(*) from cte
group by cte.school_name
order by count desc



with cte as (SELECT distinct on (c.geom) c.geom, s.geom, s.speedlimit
 from final.crashes c, final.streets s
where ST_Distance((ST_transform(c.geom,2230)),s.geom) < 50)
select cte.speedlimit, count(*) from cte
group by cte.speedlimit

select distinct AT_FAULT,
case when at_fault = 'Y' then 'Driver at Fault'
else 'Pedestrian or Cyclist at Fault'
end as At_Fault,
Count(*) as number_of_accidents from final.parties
where PARTY_TYPE ilike  '%1%'
group by AT_FAULT


####fatal accidents based on speed
with cte as (SELECT distinct on (c.geom) c.geom, s.geom, s.speedlimit, c.collision_severity
 from final.crashes c, final.streets s
where ST_Distance((ST_transform(c.geom,2230)),s.geom) < 50)
select cte.speedlimit as speed_limit, count(*) as number_of_accidents from cte
where cte.collision_severity in (1,2)
group by cte.speedlimit
order by speed_limit



c


with cte as (select distinct on (s.geom) s.geom, st.geom,
			ST_intersection(s.geom,st.geom) as points from final.streets s
			 inner join final.streets st on st_crosses(st_linemerge(s.geom), st_linemerge(st.geom))
			 where s.gid != st.gid)

select s.school_name, st_distance(cte.points, s.geom)/5280 as distance_in_mile from cte, final.schools s




shapefile of intersection
shp2pgsql -s 2230 /Users/bitaetaati/Desktop/ShapeFile/Roads_Intersection/Roads_Intersection.shp final.Roads_Intersection | /Library/PostgreSQL/13/bin/psql -h 130.191.118.187 -U etaati_admin Etaati



create index idx_intersection_geom on final.Roads_Intersection using gist(geom);

create table final.intersect as (with cte as (select distinct on (i.geom) i.geom, s.school_name, st_distance(st_transform(s.geom,2230), i.geom) as distance
from final.roads_intersection i, final.schools s
			 where st_distance(st_transform(s.geom,2230), i.geom) < 1320 )

select distinct cte.school_name, count(*), s.latitude, s.longitude from cte
inner join final.schools s on s.school_name = cte.school_name
group by cte.school_name, s.latitude, s.longitude
order by count desc)*/

ALTER TABLE final.intersect ADD COLUMN geom geometry;
UPDATE final.intersect SET geom = ST_SetSRID(ST_MakePoint(longitude, latitude), 4326);

with aa as (select i.school_name, count(*) as number_of_accident
from final.intersect i
inner join final.crashes c on ST_DWithin((st_transform(i.geom, 2230)), (st_transform(c.geom, 2230)), 1320)
group by i.school_name, ST_DWithin((st_transform(i.geom, 2230)), (st_transform(c.geom, 2230)), 1320)
order by number_of_accident desc)

select distinct aa.school_name, i.count as number_of_intersection, aa.number_of_accident
from aa inner join final.intersect i
on aa.school_name = i.school_name
order by number_of_intersection desc
