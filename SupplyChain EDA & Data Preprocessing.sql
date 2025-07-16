-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- EDA Exploratory Data Analysis
-------------------------------------------------------------------------------------------------------------------------------------------------------------------

select column_name  , data_type , is_nullable from information_schema.columns where table_name ='orders';
--(order_id PK , product_id , category_name , weight_gm , length_cm , height_cm , width_cm , 
--customer_id , zipcode , city , state_code , seller_id , price , shipping_charges , 
--order_status , purchase_time , approved_time , delivered_time , estimated_delivery_date , 
--payment_sequential , payment_type , payment_installments , payment_value )
 select * from orders ; 
 select distinct city from orders ;  -- this is all in Brazil
 select distinct state_code from orders ;
 -- product id and seller id is not unique ,so it is mean that products and sellers are duplicated
 select max(shipping_charges) as maxi , min(shipping_charges) as mini from orders -- shipping_charges is between 0 : 99.97 
 select order_status , count(*) from orders group by order_status ;
 select year (purchase_time ) , count (*) from orders group by year(purchase_time) ; -- is all at 2016 , 2017 , 2018 

 select purchase_time , approved_time from orders where purchase_time > approved_time ; 
 -- there are 9 blank rows in approved time so we will fill this as the date as in purchase time
 
 select purchase_time , approved_time from orders where approved_time is null; 
 select approved_time , delivered_time from orders where approved_time > delivered_time ; 
 --there are 1923 blank row so we will fill this values same as the approved time 
 
 select delivered_time from orders where delivered_time is null ;
 
 select (delivered_time - estimated_delivery_date ) as difference_date  , count(*) from orders group by (delivered_time - estimated_delivery_date );

 select payment_sequential , count(*) from orders group by payment_sequential  order by payment_sequential desc ; -- the values from 1 : 29 
 select payment_installments , count(*) from orders group by payment_installments  order by payment_installments desc ; -- the values from 0 : 24
  
  select payment_type , count(*) from orders group by payment_type ;
  select payment_value , count (*)  from orders group by payment_value ;
  select * from orders ;

  select (payment_value / price ) as num from orders ;
  
  select price , shipping_charges , payment_value from orders ;
  --we have an issue in column payment value so we will add columns expected payment , discount and discount status to check for correct understanding
  
  select discount_status , count(*) from orders group by discount_status ;
  
 select column_name , data_type , is_nullable from information_schema.columns where table_name ='orders' ;

 select * from orders ;
 -- check for nulls
 select * from orders where expected_payment is null or discount is null or discount_status is null;
 select category_name , count(*) from orders group by category_name ;

 select main_category , count(*) from orders group by main_category; 
 select * from orders ;
 
 select category , count(*) from orders group by category ;
 select sub_category , count(*) from orders group by sub_category ;

 -- there is no null or duplicate values in our table
 select * from orders where category is null or sub_category is null;

 select discount_status, count(*) from orders group by discount_status ;
 ---------------------------------------------------------------------------------------------------------------------------------------------------


---------------------------------------------------------------------------------------------------------------------------------------------------
 --Data Cleaning and Preprocessing
---------------------------------------------------------------------------------------------------------------------------------------------------
select column_name  , data_type , is_nullable from information_schema.columns where table_name ='orders';
--(order_id PK , product_id , category_name , weight_gm , length_cm , height_cm , width_cm , 
--customer_id , zipcode , city , state_code , seller_id , price , shipping_charges , 
--order_status , purchase_time , approved_time , delivered_time , estimated_delivery_date , 
--payment_sequential , payment_type , payment_installments , payment_value )

-- there are 9 blank rows in approved time so we will fill this as the date as in purchase time
 update orders  set approved_time = purchase_time where purchase_time > approved_time ;

 --there are 1923 blank row so we will fill this values same as the approved time 
 update orders set delivered_time = approved_time where approved_time > delivered_time ;

 -- handling columns for being converted from varchar to integer data type
  update orders set 
  weight_gm = cast(replace(weight_gm, '.0', '') as int),
  length_cm = cast(replace(length_cm, '.0', '') as int), 
  width_cm = cast(replace(width_cm, '.0', '') as int),
  height_cm = cast(replace(height_cm, '.0', '') as int);

  -- handling data types
  alter table orders alter column weight_gm int ;
  alter table orders alter column length_cm int ;
  alter table orders alter column height_cm int ;
  alter table orders alter column width_cm int ;
  alter table orders alter column zipcode int not null ;
  alter table orders alter column price float not null ;
  alter table orders alter column shipping_charges float not null ;
  alter table orders alter column purchase_time date not null;
  alter table orders alter column approved_time date not null;
  alter table orders alter column delivered_time date not null;
  alter table orders alter column estimated_delivery_date date not null;
  alter table orders alter column payment_sequential int not null ;
  alter table orders alter column payment_type varchar(50) not null;
  alter table orders alter column payment_installments int not null;
  alter table orders alter column payment_value float not null ;
  alter table orders alter column order_id varchar (50) not null ;
  alter table orders alter column product_id varchar (50) not null ;
  alter table orders alter column customer_id varchar (50) not null ;
  alter table orders alter column seller_id varchar (50) not null ;
  alter table orders alter column category_name varchar (50) not null ;
  alter table orders alter column city varchar (50) not null ;
  alter table orders alter column state_code varchar (50) not null ;
  alter table orders alter column order_status varchar (50) not null ;


  --we have an issue in column payment value so we will add columns expected payment , discount and discount status to check for correct understanding
  alter table orders add expected_payment as (price + shipping_charges );
  alter table orders add discount float ;
  update orders set discount = case
  when expected_payment = 0 then 0
  else round ((( expected_payment - payment_value)/expected_payment)*100,2)
  end ;

  alter table orders add  discount_status varchar(50) ;
  update orders set discount_status = case
  when expected_payment = 0 then 'Un Defined'
  when payment_value < expected_payment then 'Discount'
  when payment_value > expected_payment then 'Overpaid'
  else 'No Discount'
  end;

  -- handling data types
  alter table orders alter column discount float not null;
  alter table orders alter column discount_status varchar(50) not null ;

   -- add primary key constraint
  alter table orders add constraint order_id_pk primary key (order_id);

  -- handling character and spaces issues
  update orders set payment_type =
  upper(left(trim(payment_type),1)) + 
  lower(substring(trim(payment_type) , 2 , len (payment_type))) ;

  update orders set category_name =
  upper(left(trim(category_name),1)) + 
  lower(substring(trim(category_name) , 2 , len (category_name))) ;

  update orders set discount_status =
  upper(left(trim(discount_status),1)) + 
  lower(substring(trim(discount_status) , 2 , len (discount_status))) ;

  update orders set city =
  upper(left(trim(city),1)) + 
  lower(substring(trim(city) , 2 , len (city))) ;

  update orders set order_status =
  upper(left(trim(order_status),1)) + 
  lower(substring(trim(order_status) , 2 , len (order_status))) ;

  update orders set state_code = upper ( trim (state_code));

  --add a new column to generalize category name column and then we will replace the new column to category and the old to sub category 
 alter table orders add main_category varchar(100) ;

 -- set category column manually 
 update orders
set main_category = case
    when category_name = 'Watches_gifts' then 'Others'
    when category_name = 'Diapers_and_hygiene' then 'Baby & Kids'
    when category_name = 'Dvds_blu_ray' then 'Media & Books'
    when category_name = 'Bed_bath_table' then 'Home & Furniture'
    when category_name = 'Small_appliances' then 'Home & Kitchen'
    when category_name = 'Home_construction' then 'Home & Kitchen'
    when category_name = 'Garden_tools' then 'Construction & Tools'
    when category_name = 'Home_confort' then 'Home & Kitchen'
    when category_name = 'Industry_commerce_and_business' then 'Others'
    when category_name = 'La_cuisine' then 'Home & Kitchen'
    when category_name = 'Construction_tools_construction' then 'Construction & Tools'
    when category_name = 'Office_furniture' then 'Office & Stationery'
    when category_name = 'Computers_accessories' then 'Electronics & Tech'
    when category_name = 'Home_appliances' then 'Home & Kitchen'
    when category_name = 'Tablets_printing_image' then 'Electronics & Tech'
    when category_name = 'Fashion_male_clothing' then 'Fashion'
    when category_name = 'Music' then 'Media & Books'
    when category_name = 'Musical_instruments' then 'Media & Books'
    when category_name = 'Home_comfort_2' then 'Home & Kitchen'
    when category_name = 'Security_and_services' then 'Others'
    when category_name = 'Drinks' then 'Food & Drinks'
    when category_name = 'Cool_stuff' then 'Others'
    when category_name = 'Flowers' then 'Others'
    when category_name = 'Home_appliances_2' then 'Home & Kitchen'
    when category_name = 'Costruction_tools_tools' then 'Construction & Tools'
    when category_name = 'Audio' then 'Electronics & Tech'
    when category_name = 'Fashion_sport' then 'Fashion'
    when category_name = 'Food' then 'Food & Drinks'
    when category_name = 'Market_place' then 'Marketplace'
    when category_name = 'Fixed_telephony' then 'Electronics & Tech'
    when category_name = 'Furniture_mattress_and_upholstery' then 'Home & Furniture'
    when category_name = 'Small_appliances_home_oven_and_coffee' then 'Home & Kitchen'
    when category_name = 'Art' then 'Media & Books'
    when category_name = 'Pet_shop' then 'Pets'
    when category_name = 'Signaling_and_security' then 'Others'
    when category_name = 'Perfumery' then 'Health & Beauty'
    when category_name = 'Fashion_bags_accessories' then 'Fashion'
    when category_name = 'Furniture_bedroom' then 'Home & Furniture'
    when category_name = 'Costruction_tools_garden' then 'Construction & Tools'
    when category_name = 'Consoles_games' then 'Electronics & Tech'
    when category_name = 'Computers' then 'Electronics & Tech'
    when category_name = 'Books_general_interest' then 'Media & Books'
    when category_name = 'Fashion_underwear_beach' then 'Fashion'
    when category_name = 'Agro_industry_and_commerce' then 'Others'
    when category_name = 'Housewares' then 'Home & Kitchen'
    when category_name = 'Kitchen_dining_laundry_garden_furniture' then 'Home & Kitchen'
    when category_name = 'Fashio_female_clothing' then 'Fashion'
    when category_name = 'Luggage_accessories' then 'Others'
    when category_name = 'Books_technical' then 'Media & Books'
    when category_name = 'Arts_and_craftmanship' then 'Media & Books'
    when category_name = 'Furniture_decor' then 'Home & Furniture'
    when category_name = 'Toys' then 'Baby & Kids'
    when category_name = 'Fashion_childrens_clothes' then 'Fashion'
    when category_name = 'Party_supplies' then 'Party & Events'
    when category_name = 'Telephony' then 'Electronics & Tech'
    when category_name = 'Furniture_living_room' then 'Home & Furniture'
    when category_name = 'Christmas_supplies' then 'Party & Events'
    when category_name = 'Construction_tools_lights' then 'Construction & Tools'
    when category_name = 'Books_imported' then 'Media & Books'
    when category_name = 'Cine_photo' then 'Media & Books'
    when category_name = 'Sports_leisure' then 'Sports & Outdoors'
    when category_name = 'Air_conditioning' then 'Home & Kitchen'
    when category_name = 'Fashion_shoes' then 'Fashion'
    when category_name = 'Electronics' then 'Electronics & Tech'
    when category_name = 'Baby' then 'Baby & Kids'
    when category_name = 'Stationery' then 'Office & Stationery'
    when category_name = 'Auto' then 'Automotive'
    when category_name = 'Health_beauty' then 'Health & Beauty'
    when category_name = 'Construction_tools_safety' then 'Construction & Tools'
    when category_name = 'Food_drink' then 'Food & Drinks'
    else 'Others'
end;

 --rename tables as right as possible
 EXEC sp_rename 'orders.category_name', 'sub_category', 'column';
 EXEC sp_rename 'orders.main_category', 'category', 'column';

 -- there is no null or duplicate values in our table
 select * from orders where category is null or sub_category is null;

 alter table orders alter column category varchar(50) not null ;
 --------------------------------------------------------------------------------------------------------------------------------------------------------