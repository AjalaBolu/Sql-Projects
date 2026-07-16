DROP TABLE IF EXISTS spotify;
CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);

-- EDA
select * from spotify;

select count(distinct artist) from spotify;
select distinct album_type, count(*) from spotify group by 1;
select distinct most_played_on, count(*) from spotify group by 1;


-- Easy Level
-- Retrieve the names of all tracks that have more than 1 billion streams.
select track
from spotify
where stream > 1000000000
order by 1;


-- List all albums along with their respective artists.
select 	distinct
	album,
	artist
from spotify;

-- Get the total number of comments for tracks where `licensed = TRUE`.
select 
	sum(comments) total_commnts
from spotify
where licensed = 'True';

-- Find all tracks that belong to the album type `single`.
select 
	track,
	album_type
from spotify
where album_type = 'single'
order by 1;

-- Count the total number of tracks by each artist.
select 
	artist,
	count(track)
from spotify
group by 1
order by 2 desc;

-- Medium Level
-- Calculate the average danceability of tracks in each album.
select 
	album,
	avg(danceability) avg_dan
from spotify
group by 1;

-- Find the top 5 tracks with the highest energy values.
select 
	track,
	energy
from spotify
order by 2 desc
limit 5;

-- List all tracks along with their views and likes where `official_video = TRUE`.
select 
	distinct track, views, likes
from spotify
where official_video = TRUE
order by 2 desc;

-- For each album, calculate the total views of all associated tracks.
select 
	sum(views),
	track,
	album
from spotify
group by 3,2
order by 3;

-- Retrieve the track names that have been streamed on Spotify more than YouTube.
select *
from 
(select 
	track,
	coalesce(sum(case when most_played_on = 'Youtube' then stream end),0) as most_played_on_Youtube,
	coalesce(sum(case when most_played_on = 'Spotify' then stream end),0) as most_played_on_spotify
from spotify
group by 1)as t1
where most_played_on_spotify > most_played_on_Youtube
	and most_played_on_Youtube <> 0;

-- Advanced Level
-- Find the top 3 most-viewed tracks for each artist using window functions.
select *
from
(
	select 
		artist,
		track,
		row_number() over(partition by artist order by views desc) as rnk
	from spotify
)as raked_tracks
where rnk <4;

-- Write a query to find tracks where the liveness score is above the average.
select 
	track,
	liveness
from spotify
where liveness > (select avg(liveness) from spotify);

-- Use a `WITH` clause to calculate the difference between the highest and lowest energy values for tracks in each album.
with enery_levels as
(
	select 
		album,
		max(energy) as maximum_energy,
		min(energy) as minimum_energy
	from spotify
	group by 1
)
select 
	album,
	round((maximum_energy - minimum_energy)::numeric,2) as diff
from enery_levels
order by 1;

-- Find tracks where the energy-to-liveness ratio is greater than 1.2.
SELECT 
    Track,
    Energy,
    Liveness,
    ROUND((Energy / Liveness)::NUMERIC, 2) AS energy_liveness_ratio
FROM spotify
WHERE Liveness > 0
    AND (Energy / Liveness) > 1.2;

-- Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.
SELECT 
    Track,
    Views,
    Likes,
    SUM(Likes) OVER (ORDER BY Views DESC, Track) AS cumulative_likes
FROM spotify
ORDER BY Views DESC;


