create database Neflix_P4;

create table netflix 
(
	show_id	varchar(6),
	type	varchar (20),
	title	varchar (150),
	director	varchar(230),
	casts	varchar(1000),
	country	varchar(150),
	date_added	varchar(50),
	release_year	int,
	rating	varchar(10),
	duration	varchar(15),
	listed_in	varchar(79),
	description varchar (250)
);

select *
from netflix;

/*
	1. Count the Number of Movies vs TV Shows
	2. Find the Most Common Rating for Movies and TV Shows
	3. List All Movies Released in a Specific Year (e.g., 2020)
	4. Find the Top 5 Countries with the Most Content on Netflix
	5. Identify the Longest Movie
	6. Find Content Added in the Last 5 Years
	7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'
	8. List All TV Shows with More Than 5 Season
	9. Count the Number of Content Items in Each Genre
	10.Find each year and the average numbers of content release in India on netflix.
	11. List All Movies that are Documentaries
	12. Find All Content Without a Director
	13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years
	14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India
	15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
*/

-- 1. Count the Number of Movies vs TV Shows
select type,
	count(type)
from netflix
group by type;

-- 	2. Find the Most Common Rating for Movies and TV Shows
with common_rating as
(
	select 
		type,
		rating,
		count(*) as total_rating,
		rank() over (partition by type order by count(*) desc) as ranking
	from netflix
	group by type,rating
	order by type,total_rating desc
)
	select * 
	from common_rating 
	where ranking = 1;

-- 3. List All Movies Released in a Specific Year (e.g., 2020)
select *
from netflix
where type = 'Movie'
	and release_year = 2021 ;

-- 4. Find the Top 5 Countries with the Most Content on Netflix
select 
	unnest(string_to_array( country,',')) as new_country,
	count(*) as total_count
from netflix
where 1 is not null
group by 1
order by 2 desc
limit 5;

-- 5. Identify the Longest Movie
select *
from netflix
where type = 'Movie'
	and duration = (select max(duration) from netflix);

-- 6. Find Content Added in the Last 5 Years
select 	
	*	
from netflix
WHERE to_date(date_added, 'DD-Mon-YY') >= current_date - INTERVAL '5 years';

/* incase you didn't import the data correctly 
		SELECT *
	FROM netflix
	WHERE 
	  CASE 
	    WHEN date_added LIKE '%-%' THEN to_date(date_added, 'DD-Mon-YY')
	    ELSE to_date(date_added, 'Month DD, YYYY')
	  END >= current_date - INTERVAL '5 years';
*/

-- 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'
select 
	*
from netflix
where director like '%Rajiv C%';

-- 8. List All TV Shows with More Than 5 Season
select 
	*
from netflix
where type = 'TV Show'
	and
		split_part(duration, ' ', 1)::numeric > 5 ;

/* select 
	split_part('Apple Banana Cherry', ' ', 1);*/

-- 9. Count the Number of Content Items in Each Genre
select
	unnest(string_to_array(listed_in, ',')) as genres,
	count(*) as total_count
from netflix
group by 1
order by 2;

-- 10. Find each year and the average numbers of content release in India on netflix.
select 
	extract (year from to_date(date_added,'DD-Mm-YY')),
	count(*),
	round (count(*)::numeric/(select count(*) from netflix where country = 'India')::numeric * 100, 2)
from netflix
where country ='India'
group by 1;

-- 11. List All Movies that are Documentaries
select 
*
from netflix
where listed_in like '%Documen%';

--	12. Find All Content Without a Director
select *
from netflix
where director is null;

-- 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years
SELECT 
  *
FROM netflix
WHERE casts LIKE '%Salman Khan%'
    AND release_year > EXTRACT(YEAR FROM current_date) - 10;

-- 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India
select 
	unnest(string_to_array(casts, ',')) as actor,
	count(*)
from netflix
where type = 'Movie'
	and country = 'India'
group by 1
order by 2 DESC
limit 10;

-- 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
with t1
as (
	select 
		*,
		case 
			when description ILIKE '%kill%' or description ILIKE '%violence%' then 'Bad'
			else 'Good'
		end as category
	from netflix
)
select 
	category,
	count(*)
	from t1
group by category;