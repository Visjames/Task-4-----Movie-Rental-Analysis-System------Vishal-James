CREATE DATABASE Movie_Rental;
USE Movie_Rental;

CREATE TABLE rental_data (
    movie_id INT,
    customer_id INT,
    genre VARCHAR(50),
    rental_date DATE,
    return_date DATE,
    rental_fee NUMERIC(6,2)
);

insert into rental_data values
(101, 1, 'Action', '2025-07-10', '2025-07-12', 150.00), -- Sholay
(102, 2, 'Drama', '2025-07-01', '2025-07-03', 120.00),  -- Taare Zameen Par
(103, 1, 'Comedy', '2025-06-20', '2025-06-22', 100.00), -- Hera Pheri
(104, 3, 'Action', '2025-07-05', '2025-07-06', 140.00), -- Dhoom
(105, 2, 'Drama', '2025-05-30', '2025-06-02', 130.00),  -- 3 Idiots
(106, 4, 'Thriller', '2025-06-15', '2025-06-18', 160.00), -- Andhadhun
(107, 5, 'Action', '2025-04-12', '2025-04-14', 155.00), -- War
(108, 3, 'Comedy', '2025-07-09', '2025-07-10', 110.00), -- Welcome
(109, 6, 'Drama', '2025-06-28', '2025-07-01', 125.00), -- Swades
(110, 4, 'Action', '2025-07-11', '2025-07-13', 145.00), -- Singham
(111, 5, 'Comedy', '2025-03-15', '2025-03-17', 90.00);  -- Dhamaal

-- OLAP Operations
-- a) Drill Down: Analyze rentals from genre to individual movie level
select genre, movie_id, count(*) as total_rentals
from rental_data
group by genre, movie_id
order by genre, movie_id;

-- b) Rollup: Summarize total rental fees by genre and then overall
select genre, SUM(rental_fee) AS total_fee
from rental_data
group by genre with rollup;

-- d) Slice: Extract rentals only from the ‘Action’ genre
select *
from rental_data
where genre = 'Action';

-- e) Dice: Extract rentals where GENRE = 'Action' or 'Drama' and RENTAL_DATE is in the last 3 months
select *
from rental_data
where genre in ('Action', 'Drama')
and rental_date >= date_sub(curdate(), interval 3 month);
  
-- c) Cube: Analyze total rental fees across combinations of genre, rental date, and customer
-- (Since MySQL workbench does not suppprt cube function, i am using union all method)
					-- 1. Group by all three
					select genre, rental_date, customer_id, sum(rental_fee) as total_fee
					from rental_data
					group by genre, rental_date, customer_id

					union all

					-- 2. Group by genre and rental_date
					select genre, rental_date, null as customer_id, sum(rental_fee)
					from rental_data
					group by genre, rental_date

					union all

					-- 3. Group by genre and customer_id
					select genre, null as rental_date, customer_id, sum(rental_fee)
					from rental_data
					group by genre, customer_id

					union all

					-- 4. Group by rental_date and customer_id
					select null as genre, rental_date, customer_id, sum(rental_fee)
					from rental_data
					group by rental_date, customer_id

					union all

					-- 5. Group by genre only
					select genre, null, null, sum(rental_fee)
					from rental_data
					group by genre

					union all

					-- 6. Group by rental_date only
					select null, rental_date, null, sum(rental_fee)
					from rental_data
					group by rental_date

					union all

					-- 7. Group by customer_id only
					select null, null, customer_id, sum(rental_fee)
					from rental_data
					group by customer_id

					union all

					-- 8. Grand total
					select null, null, null, sum(rental_fee)
					from rental_data;