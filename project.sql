use zepto_sql_project;

create table zepto(
	sku_id serial primary key,
	category varchar(120),
    name varchar(150) not null,
    mrp numeric(8,2),
    discountPercent numeric(5,2),
    availableQuantity integer,
    discountedSellingPrice numeric(8,2),
    weightInGms integer,
    outOfStock boolean,
    quantity integer
);

select * from zepto;

-- DATA EXPLORATION

-- count of rows
 select count(*) from zepto;
 
 select * from zepto;
 
-- null values 

select * from zepto
where name is null or 
category is null or
mrp is null or
discountPercent is null or 
availablequantity is null or 
discountedsellingprice is null or 
weightingms is null or 
outofstock is null or quantity is null;

-- different product categories
select distinct category from zepto
order by category;

-- products in stock vs outof stock 
select outofstock,count(sku_id)
from zepto
group by outofstock;

-- product names multiple times
select name,count(sku_id) as Number_of_SkUs
from zepto
group by name
having count(sku_id)>1
order by count(sku_id) desc;

-- DATA CLEANING 

-- products with price =0
select * from zepto
where mrp=0 or discountedSellingprice=0;

-- DELETE FROM ZEPTO WHERE MRP =0

delete from zepto
where mrp=0;
-- Step 1: Find affected rows
SELECT sku_id
FROM zepto
WHERE mrp = 0;

-- Step 2: Delete using key column
DELETE FROM zepto
WHERE sku_id IN (
    SELECT sku_id
    FROM (
        SELECT sku_id
        FROM zepto
        WHERE mrp = 0
    ) t
);

-- “While performing data cleaning, 
-- I encountered MySQL safe update restrictions. 
-- I resolved it by deleting records using primary keys instead of disabling safety checks."

-- convert paise to rupees
-- “The dataset stored prices in paise,
 -- so I normalized them to rupees using controlled UPDATE statements that comply with MySQL safe update mode.
 
SET SQL_SAFE_UPDATES = 0;

UPDATE zepto
SET mrp = mrp / 100.0,
    discountedsellingprice = discountedsellingprice / 100.0;

SET SQL_SAFE_UPDATES = 1;

-- Before
SELECT MIN(mrp), MAX(mrp) FROM zepto;

-- After
SELECT MIN(mrp), MAX(mrp) FROM zepto;

select mrp,discountedsellingprice from zepto;


-- find the top 10 best value products based on the discount percentage.

select distinct name,mrp,discountpercent
from zepto
order by discountpercent desc
limit 10;

-- what are the products with high mrp but out of stock

select distinct name,mrp
from zepto
where outofstock=0 and mrp>300
order by mrp desc;

-- Calculate estimated revenue for each category

select category,sum(discountedsellingprice*availablequantity) as total_revenue
from zepto
group by category
order by total_revenue;

-- find all products where MRP is greater than 500 and discount is less than 10%

select name,mrp,discountpercent
from zepto
where mrp>500 and discountpercent<10
order by mrp desc,discountpercent desc;

-- identify the top 5 categories offering the highest average discount percenatge.

select category,avg(discountpercent) as avg_discountpercent
from zepto
group by category 
order by avg_discountpercent desc
limit 5;

-- find the price per gram for products above 100 g and sort by best value.
select distinct name,weightingms,discountedsellingprice,
	round(discountedsellingprice/weightingms,2) as price_per_gram
from zepto
where weightingms>=100
order by price_per_gram ;

-- group the products into categories like Low,Medium,Bulk
select distinct name,weightingms,
	case when weightingms<1000 then'Low'
         when weightingms<5000 then 'Medium'
         else 'Bulk'
	end as weight_category
from zepto;


-- what is the total inventory weight per category
select category,sum(weightingms*availablequantity) as total_weight
from zepto
group by category
order by total_weight;
