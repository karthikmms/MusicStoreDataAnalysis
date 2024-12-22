create database MusicDB;
use MusicDB;

--select * from INFORMATION_SCHEMA.TABLES;

select * from album;
select * from artist;
select * from customer;
select * from employee;
select * from genre;
select * from invoice;
select * from invoice_line;
select * from media_type;
select * from playlist;
select * from playlist_track;
select * from track;

-- 1. Who is Senior Most Employee based on the Employee level

with seniorEmployee as(
select last_name
	  , first_name
	  , title
      , rank() over(order by levels desc) EmployeeLevel
	  from employee
)
select last_name
	  , first_name
	  , title
	  from seniorEmployee
	  where EmployeeLevel = 1;

-- The Senior most Employee in the music Store is MADAN MOHAN (Senior General Manager)

-- 2.Countries and their total Invoices
with CTE as 
(select billing_country
      , count(billing_country) TotalInvoiceCount
	  from invoice 
	  group by billing_country
)

select * from CTE
order by TotalInvoiceCount desc

-- USA, Candam Brazil and France has over 50 Invoices

-- 3. What are top 3 values of total invoice?

with HighestCount as(
select invoice_id
      , customer_id
	  , invoice_date
	  , billing_address
	  , billing_city
	  , billing_state
	  , billing_country
	  , billing_postal_code
	  , total
      , row_number() over(order by total desc) as HighestTotal 
	  from invoice 
)

select invoice_id
      , customer_id
	  , invoice_date
	  , billing_address
	  , billing_city
	  , billing_state
	  , billing_country
	  , billing_postal_code
	  , total
	  from HighestCount where HighestTotal <=3

-- The Top Three Billing Countries of the Music Store are France and Canada( It has two Invoice with $19.79)

/*4.Which city has the best customers? We would like to throw a promotional Music Festival in the city 
we made the most money. Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals.*/
with HighestTotalAmmount as (
select billing_city
      ,sum(total) as TotalAmmount
	  , rank() over(order by sum(total) desc) HighestTotal
	  from invoice
	  group by billing_city
	  --order by sum(total) desc;
)

select billing_city
       , TotalAmmount
	   from HighestTotalAmmount
	   where HighestTotal = 1

/* 5. Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

select * from customer;
select * from invoice;

with HighestCount as (
select customer_id
       , sum(Total) as HighestTotal
	   , rank() over(order by sum(Total) desc) as RepeatedCount
	   from invoice
	   group by customer_id
),
highlyorderedcustomer as
(select customer_id
      , HighestTotal
	  from HighestCount
	  where RepeatedCount = 1
)
select HT.customer_id, c.first_name, c.last_name, c.country , HT.HighestTotal from highlyorderedcustomer as HT
inner join customer as c
on c.customer_id = HT.customer_id;

/* 6. Write a query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A.*/

with trackname as (
select track_id 
       , genre_id
	   from track
),
genrename as(
select g.genre_id
      , g.name
	  , t.track_id
	  from genre g
	  inner join trackname t
	  on t.genre_id = g.genre_id
	  where g.name = 'Rock'
),
invoice_li as(
select i.invoice_id
       , i.track_id
	   , g.name
	   from invoice_line i
	   inner join genrename g
	   on g.track_id = i.track_id
),
invoice_i as (
select i.invoice_id
       , i.customer_id
	   , il.name as genre_name
	   from invoice as i
	   inner join invoice_li as il
	   on i.invoice_id = il.invoice_id
),
customer_info as (
       select c.email
	          , c.first_name
			  , c.last_name
			  from customer as c
			  inner join invoice_i as i
			  on c.customer_id = i.customer_id
)

select distinct * from customer_info order by email

/*7. Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands.*/


with topN as (
SELECT artist.artist_id, artist.name, COUNT(track.track_id) AS num_of_songs, rank() over(order by COUNT(track.track_id) desc) RankedData
FROM artist
JOIN album ON album.artist_id = artist.artist_id
JOIN track ON track.album_id = album.album_id
WHERE genre_id 
    IN (SELECT genre_id 
        FROM genre
        WHERE name LIKE 'Rock')
GROUP BY artist.artist_id, artist.name
)

select artist_id, name, num_of_songs
from topN 
where RankedData<=10;

