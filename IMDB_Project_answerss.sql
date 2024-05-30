SELECT * FROM imdb_movies_project.movies;
select * from director_mapping;
select * from genre;
select * from movies;
select * from names;
select * from ratings;
select * from role_mapping;

#-----------------------------------Segment 1---------------------------------------------------

#Segment 1: Database - Tables, Columns, Relationships
#	What are the different tables in the database and how are they connected to each other in the database?
 
different tables in Database are director_mapping, genre, movies, names, ratings, role_mapping
genre table 
    FOREIGN KEY (movie_id) REFERENCES movies(id)
director_mapping table
    FOREIGN KEY (movie_id) REFERENCES movies(id),
    FOREIGN KEY (name_id) REFERENCES names(id)
role_mapping table
	FOREIGN KEY (movie_id) REFERENCES movies(id),
    FOREIGN KEY (name_id) REFERENCES names(id)
names table
    PRIMARY KEY (id)
ratings table
	FOREIGN KEY (movie_id) REFERENCES movies(id)
movies table
    PRIMARY KEY (id)

#	Find the total number of rows in each table of the schema.

select count(*) as number_of_rows_in_director_mapping_table from director_mapping;
select count(*) as number_of_rows_in_genre_table from genre;
select count(*) as number_of_rows_in_movies_table from movies;
select count(*) as number_of_rows_in_names_table from names;
select count(*) as number_of_rows_in_ratings_table from ratings;
select count(*) as number_of_rows_in_role_mapping_table from role_mapping;

#	Identify which columns in the movie table have null values.

update movies set id = null where id = ' ';
update movies set title = null where title = '';
update movies set year = null where year = '';
update movies set date_published = null where date_published = '';
update movies set duration = null where duration = '';
update movies set country = null where country = '';
update movies set worlwide_gross_income = null where worlwide_gross_income = '';
update movies set languages = null where languages = '';
update movies set production_company = null where production_company = '';
update genre set movie_id = null where movie_id = '';
update genre set genre = null where genre = '';
update director_mapping set movie_id = null where movie_id = '';
update director_mapping set name_id = null where name_id = '';
update role_mapping set movie_id = null where movie_id = '';
update role_mapping set name_id = null where name_id = '';
update role_mapping set category = null where category = '';
update names set id = null where id = '';
update names set name = null where name = '';
update names set height = null where height = '';
update names set date_of_birth = null where date_of_birth = '';
update names set known_for_movies = null where known_for_movies = '';
update ratings set movie_id = null where movie_id = '';
update ratings set avg_rating = null where avg_rating = '';
update ratings set total_votes = null where total_votes = '';
update ratings set median_rating = null where median_rating = '';

SET SQL_SAFE_UPDATES = 0;

#----------------------------------------Segment 2:----------------------------------------------------------------------------


#Segment 2: Movie Release Trends

#-	Determine the total number of movies released each year and analyse the month-wise trend.

select year, count(*) as number_of_movies from movies group by year;
select month(date_published) as month, count(*) as number_of_movies from movies 
group by month(date_published) order by number_of_movies desc;
 

 # -    Calculate the number of movies produced in the USA or India in the year 2019

select count(*) as no_of_movies_produced from movies
 where year = 2019 and 
 (lower(country) like "%usa%" or lower(country) like "%India%") ;

#--------------------------------------Segment 3-----------------------------------------------------------------------

#Segment 3: Production Statistics and Genre Analysis

# -	Retrieve the unique list of genres present in the dataset.

select distinct(genre) from genre;

#-	Identify the genre with the highest number of movies produced overall.

select genre, count(movie_id) as movie_count from genre
group by genre order by movie_count desc;

#-	Determine the count of movies that belong to only one genre.

select count(*) from
(select movie_id, count(genre) as no_of_genre
from genre group by movie_id
having no_of_genre = 1) t ;

#-	Calculate the average duration of movies in each genre.

select genre, avg(duration) as avg_duration from movies m 
right join genre g on g.movie_id = m.id
group by g.genre 
order by 2 desc;

#-	Find the rank of the 'thriller' genre among all genres in terms of the number of movies produced. 

select * from
(select genre, count(movie_id) as no_of_movies, 
rank() over (order by count(movie_id) desc) as genre_rank
from genre group by genre) t where genre =  'Thriller'

#------------------------------------Segment 4------------------------------------------------------------------

#Segment 4: Ratings Analysis and Crew Members

#-	Retrieve the minimum and maximum values in each column of the ratings table (except movie_id).

SELECT 
    MIN(avg_rating) AS min_avg_rating,
    MAX(avg_rating) AS max_avg_rating,
    MIN(total_votes) AS min_total_votes,
    MAX(total_votes) AS max_total_votes,
    MIN(median_rating) AS min_median_rating,
    MAX(median_rating) AS max_median_rating
FROM 
    ratings;

#-	Identify the top 10 movies based on average rating.

select m.title, r.avg_rating from movies m
left join ratings r on r.movie_id = m.id
order by avg_rating desc limit 10;

#-	Summarise the ratings table based on movie counts by median ratings.

select median_rating, count(movie_id) as movie_count from ratings
group by median_rating
order by median_rating;

#-	Identify the production house that has produced the most number of hit movies (average rating > 8).

select * from
(select production_company, count(id) as no_of_movies,
 rank() over (order by count(id) desc) as cnt
from movies m 
join rating r on m.id = r.movie_id
where avg_rating > 8 and production_company is not null
group by production_company
order by no_of_movies desc) t
where cnt = 1;

#-	Determine the number of movies released in each genre during March 2017 in the USA with more than 1,000 votes.

select genre, count(g.movie_id) as no_of_movies
from genre g
inner join movies m on m.id = g.movie_id
inner join ratings r on r.movie_id = g.movie_id
where year = 2017 and 
month(date_published) = 3 and
lower(country) like "%usa%" and
total_votes > 1000
group by genre
order by no_of_movies desc;

#-	Retrieve movies of each genre starting with the word 'The' and having an average rating > 8.

select genre, m.title, r.avg_rating as no_of_movies 
from genre g
inner join movies m on m.id = g.movie_id
inner join ratings r on r.movie_id = g.movie_id
where lower(title) like "%the%" and
r.avg_rating > 8;

#---------------------------------------Segment 5:----------------------------------------------------------------------

#Segment 5: Crew Analysis

#-	Identify the columns in the names table that have null values.

select 
count(case when id is null then id end) as names_null_val,
count(case when name is null then id end) as name,
count(case when height is null then id end) as height,
count(case when date_of_birth is null then id end) as date_of_birth,
count(case when known_for_movies is null then id end) as known_for_movies
from names;

#-	Determine the top three directors in the top three genres with movies having an average rating > 8.

with top_genre as 
(select genre, count(g.movie_id) as total_movies from genre g
inner join ratings r on r.movie_id = g.movie_id
where avg_rating > 8
group by genre
order by total_movies desc limit 3)
select 
n.name as top_directors, count(m.id) as movie_count from names n
inner join director_mapping dm on dm.name_id = n.id
inner join movies m on m.id = dm.movie_id
inner join genre g on g.movie_id = m.id
inner join ratings r on r.movie_id = m.id
where avg_rating > 8 and genre in 
(select genre from top_genre)
group by 1
order by movie_count desc
limit 3

# james Mangold can be hired as director..

#-	Find the top two actors whose movies have a median rating >= 8.

select name as actor_name, count(n.id) as movie_count from names n 
inner join role_mapping rm on rm.name_id = n.id
inner join movies m on m.id = rm.movie_id
inner join ratings r on r.movie_id = m.id
where median_rating >= 8 and category = 'actor'
group by 1
order by movie_count desc
limit 2;

# Mammootty and Mohanlal are the top actors

#-	Identify the top three production houses based on the number of votes received by their movies.

select production_company, sum(total_votes) as votes from movies m 
join ratings r on m.id = r.movie_id
where production_company is not null 
group by production_company
order by votes desc limit 3;

# Marvel Studios is the top production house

#-	Rank actors based on their average ratings in Indian movies released in India.

with actr_avg_rating as 
(select n.name as actor_name,
sum(r.total_votes) as total_votes,
count(m.id) as movie_count,
round(
sum(r.avg_rating*r.total_votes)
/
sum(r.total_votes),2) as actor_avg_rating
from names as n
inner join role_mapping as a on n.id = a.name_id
inner join movies m on a.movie_id = m.id
inner join ratings r on m.id = r.movie_id
where category = 'actor' and lower(country) like '%india%'
group by actor_name)
select *, rank() over(order by actor_avg_rating desc, total_votes desc) as avg_rank
from actr_avg_rating
where movie_count >= 5
limit 1

#  Vijay Sethupathi

#-	Identify the top five actresses in Hindi movies released in India based on their average ratings.

with actr_avg_rating as 
(select n.name as actor_name,
sum(r.total_votes) as total_votes,
count(m.id) as movie_count,
round(
sum(r.avg_rating*r.total_votes)
/
sum(r.total_votes),2) as actress_avg_rating
from names as n
inner join role_mapping as a on n.id = a.name_id
inner join movies m on a.movie_id = m.id
inner join ratings r on m.id = r.movie_id
where category = 'actress' and lower(languages) like '%hindi%'
group by actor_name)
select *, rank() over(order by actress_avg_rating desc, total_votes desc) as avg_rank
from actr_avg_rating
where movie_count >= 3
limit 5

# Taapsee Pannu

#---------------------------------------------Segment 6----------------------------------------------------------------------------------
#Segment 6: Broader Understanding of Data

#-	Classify thriller movies based on average ratings into different categories.

select m.title as movie_name,
case
    when r.avg_rating > 8 then 'Superhit'
    when r.avg_rating between 7 and 8 then 'Hit'
    when r.avg_rating between 5 and 7 then 'One time watch'
    else 'Flop'
end as movie_category
from movies as m
left join 
ratings as r on m.id = r.movie_id
left join genre as g on m.id = g.movie_id
where lower(genre) = 'thriller'
and total_votes > 25000;

#-	analyse the genre-wise running total and moving average of the average movie duration.

with genre_summary as 
(select genre, avg(duration) as avg_duration from genre g
left join movies m on g.movie_id = m.id
group by genre)
select genre, avg_duration,
sum(avg_duration) over (order by avg_duration desc) as running_total,
avg(avg_duration) over (order by avg_duration desc) as moving_avgerage
from genre_summary;

#-	Identify the five highest-grossing movies of each year that belong to the top three genres.

with top_genre as 
(select genre, count(m.id) as movie_count
from genre g left join movies m on g.movie_id= m.id 
group by genre 
order by movie_count desc limit 3)
select * from
(select genre, year, m.title as movie_name,
worlwide_gross_income,
rank() over (partition by genre, year order by 
cast(replace(trim(worlwide_gross_income), "$ ","") as unsigned)
desc) as movie_rank
from movies m 
inner join genre g on g.movie_id = m.id
where g.genre in (select genre from  top_genre)) t
where  movie_rank <= 5         

#-	Determine the top two production houses that have produced the highest number of hits among multilingual movies.

select production_company from
(select m.production_company, count(m.id) as movie_count,
row_number () over (order by count(m.id) desc) as prod_rank
from movies m left join ratings r on r.movie_id = m.id
where m.production_company is not null and median_rating > 8
and languages like '% %'
group by 1) t
where prod_rank <=2


#-	Identify the top three actresses based on the number of Super Hit movies (average rating > 8) in the drama genre.

with actr_avg_rating as 
(select n.name as actress_name,
sum(r.total_votes) as total_votes,
count(m.id) as movie_count,
round(
sum(r.avg_rating * r.total_votes)
/
sum(r.total_votes),2) as actress_avg_rating
from names as n
inner join role_mapping as a on n.id = a.name_id
inner join movies m on a.movie_id = m.id
inner join ratings r on m.id = r.movie_id
inner join genre g on g.movie_id = m.id
where category = 'actress' and lower(genre) like '%drama%' and avg_rating > 8
group by actress_name)

select *, row_number() over(order by actress_avg_rating desc, total_votes desc) as Actress_rank
from actr_avg_rating
limit 3

#-	Retrieve details for the top nine directors based on the number of movies, including average inter-movie duration, ratings, and more.

with top_directors as
( select director_id, director_name from
(select m.id as director_id, n.name as director_name,
count(m.id) as movie_count,
row_number() over (order by count(m.id) desc) as director_rank
from names n
inner join director_mapping d on n.id = d.name_id
inner join movies m on m.id = d.movie_id
group by 1,2) t
where director_rank <= 9),
movie_summary as
(select m.id as director_id, n.name as director_name,
m.id as movie_id,
r.avg_rating, r.total_votes, m.duration, m.date_published,
lead(date_published) over (partition by m.id order by m.date_published) as next_date_published,
datediff(lead(date_published) over (partition by m.id order by m.date_published),
m.date_published) as INTER_MOVIE_DAYS
from names n
inner join director_mapping d on n.id = d.name_id
inner join movies m on m.id = d.movie_id
inner join ratings r on r.movie_id = m.id
where n.id is (select director_id from top_directors))

select director_id, director_name, count(distinct movie_id) as number_of_movies,
avg(INTER_MOVIE_DAYS) as avg_inter_movie_days,
round(
		sum(avg_rating * total_votes) / sum(total_votes),2) as director_avg_rating,
sum(total_votes) as total_votes,
min(avg_rating) as min_rating,
max(avg_rating) as max_rating,
sum(duration) as total_movie_duration

from movie_summary
group by 1,2
order by number_of_movies desc, director_avg_rating desc;         

#-------------------------------------------Segment 7:------------------------------------------------------

#Segment 7: Recommendations

#-	Based on the analysis, provide recommendations for the types of content Bolly movies should focus on producing.

Focus on High-Rating Genres:

Thriller: Create more thrilling movies as they have a strong following and can achieve high ratings.
Drama: Continue producing drama as it consistently performs well, especially in the Indian market.
Invest in Superhit Content:

Focus on producing "Superhit" category movies, which have an average rating above 8. This can be achieved by focusing on quality scripts, talented directors, and high production values.
Hire Proven Directors and Actors:

Consider hiring top directors like James Mangold and actors like Mammootty and Mohanlal, who have a track record of delivering high-rating movies.
Production House Strategy:

Collaborate with top production houses like Marvel Studios that have demonstrated the ability to produce high-grossing and high-rating movies.
Target Specific Markets:

For the Indian market, focus on Hindi and multilingual movies with strong local appeal, and leverage popular actors and actresses in those regions.
Seasonal Releases:

Strategize movie releases during peak seasons like March, which have shown higher engagement and better box office performance.































