# Basic SQL project using BigQuery
In this project, I am exploring [Adventureworks 2005 database](https://i0.wp.com/improveandrepeat.com/wp-content/uploads/2018/12/AdvWorksOLTPSchemaVisio.png?ssl=1).
## Task 1 : An overview of Products
### Task 1.1
You’ve been asked to extract the data on products from the Product table where there exists a product subcategory. And also include the name of the ProductSubcategory.

  * Columns needed: ProductId, Name, ProductNumber, size, color, ProductSubcategoryId, Subcategory name.
  * Order results by SubCategory name.
```
SELECT	
  product.productID AS ProductID,	
  product.Name AS Name,	
  product.ProductNumber AS ProductNumber,	
  product.size AS Size,	
  product.Color AS Color,	
  product_subcategory.ProductSubcategoryID,	
  product_subcategory.name AS SubcategoryName,	
FROM	
  adwentureworks_db.product AS product	
JOIN	
  adwentureworks_db.productsubcategory AS product_subcategory	
ON	
  product.ProductSubcategoryID = product_subcategory.ProductSubcategoryID	
ORDER BY	
  SubcategoryName;
```
### Task 1.2
In 1.1 query you have a product subcategory but see that you could use the category name.

  * Find and add the product category name.
  * Afterwards order the results by Category name.
```
SELECT
  product.productID AS ProductID,
  product.Name AS Name,
  product.ProductNumber AS ProductNumber,
  product.size AS Size,
  product.Color AS Color,
  product_subcategory.ProductSubcategoryID,
  product_subcategory.name AS SubcategoryName,
  product_category.Name AS Category
FROM
  adwentureworks_db.product AS product
JOIN
  adwentureworks_db.productsubcategory AS product_subcategory
ON
  product.ProductSubcategoryID = product_subcategory.ProductSubcategoryID
JOIN
  adwentureworks_db.productcategory AS product_category
ON
  product_subcategory.ProductCategoryID = product_category.productcategoryID
ORDER BY
  Category;
```
### Task 1.3
Use the established query to select the most expensive (price listed over 2000) bikes that are still actively sold (does not have a sales end date)

  * Order the results from most to least expensive bike.
```
SELECT
  product.productID AS ProductID,
  product.Name AS Name,
  product.ProductNumber AS ProductNumber,
  product.size AS Size,
  product.Color AS Color,
  product_subcategory.ProductSubcategoryID,
  product_subcategory.name AS SubcategoryName,
  product_category.Name AS Category
FROM
  adwentureworks_db.product AS product
JOIN
  adwentureworks_db.productsubcategory AS product_subcategory
ON
  product.ProductSubcategoryID = product_subcategory.ProductSubcategoryID
JOIN
  adwentureworks_db.productcategory AS product_category
ON
  product_subcategory.ProductCategoryID = product_category.productcategoryID
WHERE
  ListPrice > 2000
    AND SellEndDate IS NULL
    AND product_category.Name = 'Bikes'
ORDER BY
  ListPrice DESC;
```
## Task 2 : Reviewing work orders
### Task 2.1
Create an aggregated query to select the:

  * Number of unique work orders.
  * Number of unique products.
  * Total actual cost.

For each location Id from the 'workoderrouting' table for orders in January 2004.
```
SELECT 
  workorder_routing.LocationID,
  COUNT(workorder_routing.WorkOrderID) AS no_work_orders,
  COUNT(DISTINCT workorder_routing.ProductID) AS no_unique_product,
  SUM(workorder_routing.ActualCost) AS actual_cost,
FROM
  `adwentureworks_db.workorderrouting` AS workorder_routing
WHERE
  workorder_routing.ActualStartDate >= '2004-01-01' AND workorder_routing.ActualStartDate < '2004-02-01'
GROUP BY
  LocationID
ORDER BY
  no_work_orders DESC;
```
### Task 2.2
Update your 2.1 query by adding the name of the location and also add the average days amount between actual start date and actual end date per each location.
```
SELECT
  workorder_routing.LocationID,
  location.Name AS Location,
  COUNT(DISTINCT workorder_routing.WorkOrderID) AS no_work_orders,
  COUNT(DISTINCT workorder_routing.ProductID) AS no_unique_product,
  SUM(workorder_routing.ActualCost) AS actual_cost,
  ROUND(AVG(TIMESTAMP_DIFF(workorder_routing.ActualEndDate, workorder_routing.ActualStartDate, day)),2) AS avg_days_diff
FROM
  `adwentureworks_db.workorderrouting` AS workorder_routing
JOIN
  `adwentureworks_db.location` AS location
ON
  location.LocationID = workorder_routing.LocationID
WHERE
  workorder_routing.ActualStartDate >= '2004-01-01' AND workorder_routing.ActualStartDate < '2004-02-01'
GROUP BY
  LocationID, 
  Location
ORDER BY
  no_work_orders DESC;
```
### Task 2.3
Select all the expensive work Orders (above 300 actual cost) that happened throught January 2004.
```
SELECT 
  workorder_routing.WorkOrderID,
  SUM(workorder_routing.ActualCost) AS actual_cost
FROM
  `adwentureworks_db.workorderrouting` AS workorder_routing
WHERE
  workorder_routing.ActualStartDate >= '2004-01-01' AND workorder_routing.ActualStartDate < '2004-02-01'
GROUP BY
  workorder_routing.WorkOrderID
HAVING 
  actual_cost > 300;
```
