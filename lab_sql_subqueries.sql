USE sakila;

## 1.How many copies of the film Hunchback Impossible exist in the inventory system?

select * from inventory;
select * from film;

select film_id from film where title = 'Hunchback Impossible';

select film_id , count(inventory_id) as number_of_copies from inventory 
where film_id in (select film_id from film where title = 'Hunchback Impossible')
group by 1;


## 2.List all films longer than the average.
select avg(length) from film;

select * from film where length > (select avg(length) from film) ;


## 3.Use subqueries to display all actors who appear in the film Alone Trip.

/*select * from film where title = 'Alone Trip';
select * from film_actor where film_id = 17;
select * from actor; */

select  actor_id , film_id from film_actor where film_id in (select film_id from film where title = 'Alone Trip');

select  fa.actor_id ,a.first_name , a.last_name , fa.film_id from film_actor fa 
left join actor a on fa.actor_id = a.actor_id
where fa.film_id in (select f.film_id from film f where f.title = 'Alone Trip');


## 4.Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.

select * from film;
select * from film_category;
select * from category;


select f.film_id , f.title , c.name from film f
join film_category fc on f.film_id = fc.film_id
join category c on fc.category_id = c.category_id
where c.name = 'family';


## 5.Get name and email from customers from Canada using subqueries. Do the same with joins.
/*(select * from customer;
select * from address;
select * from city;
select * from country;*/

## with join
select c.first_name , c.last_name ,c.email , cn.country from customer c
join
address a on c.address_id = a.address_id
join
city ct on a.city_id = ct.city_id
join
country cn on ct.country_id = cn.country_id
where cn.country = 'Canada';

## with subqueries
Select concat(first_name, ' ', last_name) as 'Name', email from sakila.customer
where address_id in (
select address_id from sakila.address
where city_id in (
select city_id from sakila.city
where country_id in (select country_id from sakila.country
where country in ('canada'))));


## 6.Which are films starred by the most prolific actor?

/*select * from film_actor;
select * from film;
select * from actor; */


## most prolific actor
select actor_id , count(film_id) as number_of_films , row_number() over (order by count(film_id) desc) as 'xyz' from film_actor
group by 1;

## taking the highest number of films 
select actor_id from (select actor_id , count(film_id) as number_of_films , row_number() over (order by count(film_id) desc) as 'xyz' from film_actor
group by 1) as zzz where xyz = 1;

## checking the film_id with most prolific actor
select film_id from film_actor where actor_id in (select actor_id from (select actor_id , count(film_id) as number_of_films , row_number() over (order by count(film_id) desc) as 'xyz' from film_actor
group by 1) as zzz where xyz = 1);

## subquery with everything
select title from film where film_id in (select film_id from film_actor where actor_id in (select actor_id from (select actor_id , count(film_id) as number_of_films , row_number() over (order by count(film_id) desc) as 'xyz' from film_actor
group by 1) as zzz where xyz = 1));


## 7.Films rented by most profitable customer.
/*select * from customer;
select * from film;
select * from inventory;
select * from rental;
select * from payment;*/

## finding the customer that spent most amount
select customer_id , sum(amount) as most_money_spent , row_number() over (order by sum(amount) desc) as 'xyz'from payment
group by 1;

## finding customer_id with maximum amount spent
select customer_id from (select customer_id , sum(amount) as most_money_spent , row_number() over (order by sum(amount) desc) as 'xyz'from payment
group by 1) as zzz where xyz = 1;

## finding the inventory id
select inventory_id from rental where customer_id in (select customer_id from (select customer_id , sum(amount) as most_money_spent , row_number() over (order by sum(amount) desc) as 'xyz'from payment
group by 1) as zzz where xyz = 1) ;

## finding the film_id
select film_id from inventory where inventory_id in (select inventory_id from rental where customer_id in (select customer_id from (select customer_id , sum(amount) as most_money_spent , row_number() over (order by sum(amount) desc) as 'xyz'from payment
group by 1) as zzz where xyz = 1));

## finding the film
select title from film where film_id in (select film_id from inventory where inventory_id in (select inventory_id from rental where customer_id in (select customer_id from (select customer_id , sum(amount) as most_money_spent , row_number() over (order by sum(amount) desc) as 'xyz'from payment
group by 1) as zzz where xyz = 1)));


## 8.Customers who spent more than the average.

select * from customer;
SET sql_mode=(SELECT REPLACE(@@sql_mode, 'ONLY_FULL_GROUP_BY', ''));

select * from payment group by customer_id;

select avg(amount) as average from payment;

## checking the sum
select customer_id , sum(amount) as abc from payment group by 1;

## checking the avg
select avg(abc) from (select customer_id , sum(amount) as abc from payment group by 1) as xxx ;

## finding the cusotmer_id who spent more than average
select customer_id , sum(amount) as abc from payment
group by customer_id
having sum(amount) > (select avg(abc) from (select customer_id , sum(amount) as abc
 from payment group by 1) as xxx);


