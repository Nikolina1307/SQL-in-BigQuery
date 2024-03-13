-- Task 1.1
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

-- Task 1.2
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

-- Task 1.3
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

-- Task 2.1
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

-- Task 2.2
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

-- Task 2.3
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
