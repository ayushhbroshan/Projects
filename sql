use swiggy;

select * from restaurants;
# 1. how many resturants listed in swiggy?
select count(*) from restaurants;
#2. Top 5 most expensice resturants
select * from restaurants
	order by cost desc, rating desc
		limit 5;
#3. no. of restaurants with different cuisines
select city, cuisine, count(*) from restaurants
	group by city, cuisine
    order by count(*) desc;
    
#4. cities with average cost > 350
select city, avg(cost) from restaurants
	group by city having avg(cost)>350
    order by count(*) desc;
#5. Top 5 restaurants based on rating count
create table rankings as	
    (select *, 
		row_number() over(partition by city order by rating_count desc) as 'ranking'
        from restaurants
	);
    
select * from rankings where ranking <=5 ;
-- or 
select * from	
    (select *, 
		row_number() over(partition by city order by rating_count desc) as 'ranking'
        from restaurants
		) t1
        where ranking <=5;
# 6. Top 5 cities with maimum revenue
select city, sum(rating_count*cost) as revenue from	
    (select *, 
		row_number() over(partition by city order by rating_count desc) as 'ranking'
        from restaurants
		) t1
        where ranking <=5
			group by city 
				order by revenue  desc
					limit 5;
#7.create a temporary table storing only the restaurants of banglore chinese
create temporary table if not exists banglore_chinese as	
    (select * from restaurants
	where city='Bangalore' and  cuisine= 'chinese'
    );
select * from banglore_chinese;
#8. 
create view pizza_view as
(
    select * from restaurants  where name like 'Pizza%'
    );
select * from pizza_view;
#9. clean data
-- city (lowercase, trim)
-- link remove
-- rating _count<=10 x
create table cleaned_rest_data as
(
select id, name, trim(lower(city)) , rating, rating_count, cuisine, cost 
	from restaurants where rating_count>=10
    );
    
select * from cleaned_rest_data;

#10. total revenue
select sum(rating_count*cost) from restaurants;
#11. top 20% restaurants revenue
select round((0.2*count(*)),0) from restaurants;
select sum(revenue) from 
	(select * , rating_count*cost as revenue from restaurants
		order by revenue desc
			limit 12285
        )t2;
with q1 as
			(
				select sum(rating_count*cost) as 'total_revenue' from restaurants
			),
q2 as 
	(
	select sum(revenue) as 'top_20_revenue' from 
	(select * , rating_count*cost as revenue from restaurants
		order by revenue desc
			limit 12285)t2
	) 
select total_revenue, top_20_revenue ,(top_20_revenue/total_revenue)*100 from q1, q2 ;
