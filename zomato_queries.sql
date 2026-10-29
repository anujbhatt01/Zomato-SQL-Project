CREATE DATABASE zomato_db;

-- Data Importing
COPY zomato_restaurants(
    RestaurantID,
    RestaurantName,
    CountryCode,
    City,
    Address,
    Locality,
    LocalityVerbose,
    Cuisines,
    Currency,
    Has_Table_booking,
    Has_Online_delivery,
    Is_delivering_now,
    Switch_to_order_menu,
    Price_range,
    Votes,
    Average_Cost_for_two,
    Rating
)
FROM 'C:/Users/Lenovo/Music/zomato sql project.csv'
WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',');

USE zomato_db;
select city , RestaurantID from zomato_restaurants;

-- Top 10 Highest Rated Restaurants:
SELECT RestaurantName, City, Rating, Votes 
FROM zomato_restaurants 
ORDER BY Rating DESC, Votes DESC 
LIMIT 10;

-- City-wise Total Restaurants Count:
SELECT City, COUNT(RestaurantID) AS Total_Restaurants 
FROM zomato_restaurants 
GROUP BY City 
ORDER BY Total_Restaurants DESC;

-- Restaurants with Online Delivery and Table Booking:
SELECT RestaurantName, City, Average_Cost_for_two 
FROM zomato_restaurants 
WHERE Has_Online_delivery = 'Yes' AND Has_Table_booking = 'Yes';

-- Average Cost for Two by Price Range:
SELECT Price_range, ROUND(AVG(Average_Cost_for_two), 2) AS Avg_Cost 
FROM zomato_restaurants 
GROUP BY Price_range 
ORDER BY Price_range;

-- Top Cuisines:
SELECT Cuisines, COUNT(*) AS Count 
FROM zomato_restaurants 
GROUP BY Cuisines 
ORDER BY Count DESC 
LIMIT 10;

USE zomato_db;
-- Basic analysis
-- 1. Total restaurants
SELECT COUNT(*) AS Total_Restaurants
FROM zomato_restaurants;

-- 2. Total unique cities
SELECT COUNT(DISTINCT City) AS Total_Cities
FROM zomato_restaurants;

-- 3. Total unique cuisines
SELECT COUNT(DISTINCT Cuisines) AS Unique_Cuisines
FROM zomato_restaurants;

-- 4. Restaurants with rating above 4
SELECT RestaurantName, City, Rating, Votes
FROM zomato_restaurants
WHERE Rating > 4
ORDER BY Rating DESC;

-- 5. Restaurants without online delivery
SELECT RestaurantName, City
FROM zomato_restaurants
WHERE Has_Online_delivery = 'No';

-- Rating and customer analysis
-- 6. Average rating by city
SELECT City, ROUND(AVG(Rating), 2) AS Average_Rating
FROM zomato_restaurants
WHERE Rating > 0
GROUP BY City
ORDER BY Average_Rating DESC;

-- 7. Top 10 most voted restaurants
SELECT RestaurantName, City, Votes, Rating
FROM zomato_restaurants
ORDER BY Votes DESC
LIMIT 10;

-- 8. Restaurants with zero votes
SELECT RestaurantName, City, Rating, Votes
FROM zomato_restaurants
WHERE Votes = 0;

-- 9. Rating category analysis
SELECT
    CASE
        WHEN Rating >= 4.5 THEN 'Excellent'
        WHEN Rating >= 4.0 THEN 'Very Good'
        WHEN Rating >= 3.0 THEN 'Good'
        WHEN Rating > 0 THEN 'Average'
        ELSE 'Not Rated'
    END AS Rating_Category,
    COUNT(*) AS Total_Restaurants
FROM zomato_restaurants
GROUP BY Rating_Category
ORDER BY Total_Restaurants DESC;

-- 10. Restaurants rated below 3
SELECT RestaurantName, City, Cuisines, Rating
FROM zomato_restaurants
WHERE Rating > 0 AND Rating < 3
ORDER BY Rating;

-- Pricing and business analysis
-- 11. Most expensive restaurants
SELECT RestaurantName, City, Currency,
       Average_Cost_for_two, Rating
FROM zomato_restaurants
ORDER BY Average_Cost_for_two DESC
LIMIT 10;

-- 12. Average cost by city
SELECT City,
       ROUND(AVG(Average_Cost_for_two), 2) AS Avg_Cost
FROM zomato_restaurants
GROUP BY City
ORDER BY Avg_Cost DESC;

-- 13. Restaurants by price range
SELECT Price_range, COUNT(*) AS Total_Restaurants
FROM zomato_restaurants
GROUP BY Price_range
ORDER BY Price_range;

-- 14. Average rating by price range
SELECT Price_range,
       ROUND(AVG(Rating), 2) AS Avg_Rating
FROM zomato_restaurants
WHERE Rating > 0
GROUP BY Price_range
ORDER BY Avg_Rating DESC;

-- 15. High-rated restaurants with low cost
SELECT RestaurantName, City, Rating,
       Average_Cost_for_two
FROM zomato_restaurants
WHERE Rating >= 4
  AND Average_Cost_for_two <= 500
ORDER BY Rating DESC, Average_Cost_for_two;

-- Online delivery and table booking
-- 16. Table booking availability count
SELECT Has_Table_booking,
       COUNT(*) AS Total_Restaurants
FROM zomato_restaurants
GROUP BY Has_Table_booking;

-- 17. Online delivery availability by city
SELECT City,
       COUNT(*) AS Total_Restaurants,
       SUM(CASE
           WHEN Has_Online_delivery = 'Yes' THEN 1
           ELSE 0
       END) AS Delivery_Restaurants
FROM zomato_restaurants
GROUP BY City
ORDER BY Delivery_Restaurants DESC;

-- 18. Restaurants offering both services
SELECT RestaurantName, City, Rating
FROM zomato_restaurants
WHERE Has_Online_delivery = 'Yes'
  AND Has_Table_booking = 'Yes';

-- 19. Delivery availability percentage
SELECT
    ROUND(
        100.0 * SUM(
            CASE WHEN Has_Online_delivery = 'Yes'
                 THEN 1 ELSE 0 END
        ) / NULLIF(COUNT(*), 0), 2
    ) AS Delivery_Percentage
FROM zomato_restaurants;

-- 20. Restaurants currently delivering
SELECT RestaurantName, City, Is_delivering_now
FROM zomato_restaurants
WHERE Is_delivering_now = 'Yes';

-- Advanced SQL — CTE and Window Functions
-- 21. Top 3 restaurants in each city
WITH RankedRestaurants AS (
    SELECT RestaurantName, City, Rating, Votes,
           ROW_NUMBER() OVER (
               PARTITION BY City
               ORDER BY Rating DESC, Votes DESC
           ) AS Row_Num
    FROM zomato_restaurants
    WHERE Rating > 0
)
SELECT RestaurantName, City, Rating, Votes
FROM RankedRestaurants
WHERE Row_Num <= 3;

-- 22. Rank restaurants by votes
SELECT RestaurantName, City, Votes,
       DENSE_RANK() OVER (
           ORDER BY Votes DESC
       ) AS Vote_Rank
FROM zomato_restaurants;

-- 23. Restaurants above the overall average rating
SELECT RestaurantName, City, Rating
FROM zomato_restaurants
WHERE Rating > (
    SELECT AVG(Rating)
    FROM zomato_restaurants
    WHERE Rating > 0
);

-- 24. City-wise restaurant count using CTE
WITH CityCounts AS (
    SELECT City, COUNT(*) AS Total_Restaurants
    FROM zomato_restaurants
    GROUP BY City
)
SELECT City, Total_Restaurants
FROM CityCounts
WHERE Total_Restaurants > 50
ORDER BY Total_Restaurants DESC;