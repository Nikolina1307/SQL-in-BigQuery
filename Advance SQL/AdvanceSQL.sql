-- Task 1.1
/*
A detailed overview of all individual customers
Identity information : CustomerId, Firstname, Last Name, FullName (First Name & Last Name).
An Extra column called addressing_title i.e. (Mr. Achong), if the title is missing - Dear Achong.
Contact information : Email, phone, account number, CustomerType.
Location information : City, State & Country, address.
Sales: number of orders, total amount (with Tax), date of the last order.
*/
SELECT
      customer.CustomerID,
      contact.FirstName,
      contact.LastName,
      CONCAT(contact.FirstName,"" "",contact.LastName) as FullName,
      CONCAT(COALESCE(contact.Title, ""Dear""), "" "", contact.LastName) as AddressingTitle,
      contact.EmailAddress,
      contact.Phone,
      customer.AccountNumber,
      customer.CustomerType,
      address.City,
      address.AddressLine1,
      COALESCE(address.AddressLine2,'') as AddressLine2,
      stateprovince.Name as State,
      countryregion.Name as Country,
      COUNT(orders.SalesOrderID) as OrderCount,
      SUM(orders.TotalDue) as TotalAmountPurchases,
      MAX(orders.OrderDate) as LastOrderDate
FROM  `tc-da-1.adwentureworks_db.customer` as customer
  JOIN `tc-da-1.adwentureworks_db.individual` as individual ON (customer.CustomerID = individual.CustomerID AND customer.CustomerType = ""I"")
  JOIN `tc-da-1.adwentureworks_db.contact` as contact ON individual.ContactID = contact.ContactID
  JOIN `tc-da-1.adwentureworks_db.customeraddress` as customeraddress ON (customer.CustomerID = customeraddress.CustomerID AND customeraddress.AddressTypeID = 2)
  JOIN `tc-da-1.adwentureworks_db.address` as address ON customeraddress.AddressID = address.AddressID
  JOIN `tc-da-1.adwentureworks_db.stateprovince` as stateprovince ON address.StateProvinceID = stateprovince.StateProvinceID
  JOIN `tc-da-1.adwentureworks_db.countryregion` as countryregion ON stateprovince.CountryRegionCode = countryregion.CountryRegionCode
  JOIN `tc-da-1.adwentureworks_db.salesorderheader` as orders ON customer.CustomerID = orders.CustomerID
GROUP BY
      customer.CustomerID,
      contact.FirstName,
      contact.LastName,
      FullName,
      AddressingTitle,
      contact.EmailAddress,
      contact.Phone,
      customer.AccountNumber,
      customer.CustomerType,
      address.City,
      address.AddressLine1,
      AddressLine2,
      stateprovince.Name,
      countryregion.Name
ORDER BY
      TotalAmountPurchases DESC
LIMIT 200;

-- Task 1.2
/*
top 200 customers with the highest total amount (with tax) who have not ordered for the last 365 days
*/
SELECT
      customer.CustomerID,
      contact.FirstName,
      contact.LastName,
      CONCAT(contact.FirstName,"" "",contact.LastName) as FullName,
      CONCAT(COALESCE(contact.Title, ""Dear""), "" "", contact.LastName) as AddressingTitle,
      contact.EmailAddress,
      contact.Phone,
      customer.AccountNumber,
      customer.CustomerType,
      address.City,
      address.AddressLine1,
      COALESCE(address.AddressLine2,'') as AddressLine2,
      stateprovince.Name as State,
      countryregion.Name as Country,
      COUNT(orders.SalesOrderID) as OrderCount,
      SUM(orders.TotalDue) as TotalAmountPurchases,
      MAX(orders.OrderDate) as LastOrderDate
FROM   `tc-da-1.adwentureworks_db.customer` as customer
  JOIN `tc-da-1.adwentureworks_db.individual` as individual ON (customer.CustomerID = individual.CustomerID AND customer.CustomerType = ""I"")
  JOIN `tc-da-1.adwentureworks_db.contact` as contact ON individual.ContactID = contact.ContactID
  JOIN `tc-da-1.adwentureworks_db.customeraddress` as customeraddress ON (customer.CustomerID = customeraddress.CustomerID AND customeraddress.AddressTypeID = 2)
  JOIN `tc-da-1.adwentureworks_db.address` as address ON customeraddress.AddressID = address.AddressID
  JOIN `tc-da-1.adwentureworks_db.stateprovince` as stateprovince ON address.StateProvinceID = stateprovince.StateProvinceID
  JOIN `tc-da-1.adwentureworks_db.countryregion` as countryregion ON stateprovince.CountryRegionCode = countryregion.CountryRegionCode
  JOIN `tc-da-1.adwentureworks_db.salesorderheader` as orders ON customer.CustomerID = orders.CustomerID
GROUP BY
      customer.CustomerID,
      contact.FirstName,
      contact.LastName,
      FullName,
      AddressingTitle,
      contact.EmailAddress,
      contact.Phone,
      customer.AccountNumber,
      customer.CustomerType,
      address.City,
      address.AddressLine1,
      AddressLine2,
      stateprovince.Name,
      countryregion.Name
HAVING
  MAX(OrderDate) < CAST(
    DATETIME_SUB(
      CAST(
        (
          SELECT
            MAX(OrderDate)
          FROM
            `tc-da-1.adwentureworks_db.salesorderheader`
        ) AS DATETIME
      ),
      INTERVAL 1 year
    ) AS TIMESTAMP
  )
ORDER BY
      TotalAmountPurchases DESC
LIMIT 200;

-- Task 1.3
/*
Enrich the original query by creating a new column in the view that marks active & inactive customers based on whether they have ordered anything during the last 365 days.
*/
SELECT
      customer.CustomerID,
      contact.FirstName,
      contact.LastName,
      CONCAT(contact.FirstName,"" "",contact.LastName) as FullName,
      CONCAT(COALESCE(contact.Title, ""Dear""), "" "", contact.LastName) as AddressingTitle,
      contact.EmailAddress,
      contact.Phone,
      customer.AccountNumber,
      customer.CustomerType,
      address.City,
      address.AddressLine1,
      COALESCE(address.AddressLine2,'') as AddressLine2,
      stateprovince.Name as State,
      countryregion.Name as Country,
      COUNT(orders.SalesOrderID) as OrderCount,
      SUM(orders.TotalDue) as TotalAmountPurchases,
      MAX(orders.OrderDate) as LastOrderDate,
      CASE WHEN MAX(orders.OrderDate) > CAST(DATETIME_SUB(CAST((SELECT MAX(OrderDate) FROM `tc-da-1.adwentureworks_db.salesorderheader`) AS DATETIME), INTERVAL 1 year) AS TIMESTAMP) THEN 'Active' ELSE 'Inactive' END as UserStatus
FROM
       `tc-da-1.adwentureworks_db.customer` as customer
  JOIN `tc-da-1.adwentureworks_db.individual` as individual ON (customer.CustomerID = individual.CustomerID AND customer.CustomerType = ""I"")
  JOIN `tc-da-1.adwentureworks_db.contact` as contact ON individual.ContactID = contact.ContactID
  JOIN `tc-da-1.adwentureworks_db.customeraddress` as customeraddress ON (customer.CustomerID = customeraddress.CustomerID AND customeraddress.AddressTypeID = 2)
  JOIN `tc-da-1.adwentureworks_db.address` as address ON customeraddress.AddressID = address.AddressID
  JOIN `tc-da-1.adwentureworks_db.stateprovince` as stateprovince ON address.StateProvinceID = stateprovince.StateProvinceID
  JOIN `tc-da-1.adwentureworks_db.countryregion` as countryregion ON stateprovince.CountryRegionCode = countryregion.CountryRegionCode
  JOIN `tc-da-1.adwentureworks_db.salesorderheader` as orders ON customer.CustomerID = orders.CustomerID
GROUP BY
      customer.CustomerID,
      contact.FirstName,
      contact.LastName,
      FullName,
      AddressingTitle,
      contact.EmailAddress,
      contact.Phone,
      customer.AccountNumber,
      customer.CustomerType,
      address.City,
      address.AddressLine1,
      AddressLine2,
      stateprovince.Name,
      countryregion.Name
ORDER BY
      customer.CustomerID DESC
LIMIT 500;

-- Task 1.4
/* Business would like to extract data on all active customers from North America. Only customers that have either ordered 2500 in total amount (with Tax) or ordered 5 + times should be presented.

In the output for these customers divide their address line into two columns, i.e.:

AddressLine1 address_no Address_st
8603 Elmhurst Lane' 8603 Elmhurst Lane
Order the output by country, state and date_last_order.
*/
SELECT
      customer.CustomerID,
      contact.FirstName,
      contact.LastName,
      CONCAT(contact.FirstName,"" "",contact.LastName) as FullName,
      CONCAT(COALESCE(contact.Title, ""Dear""), "" "", contact.LastName) as AddressingTitle,
      contact.EmailAddress,
      contact.Phone,
      customer.AccountNumber,
      customer.CustomerType,
      address.City,
      address.AddressLine1,
      LEFT(address.AddressLine1, STRPOS(address.AddressLine1, ' ') -1 ) as AddressNo,
      RIGHT(address.AddressLine1, LENGTH(address.AddressLine1) - STRPOS(address.AddressLine1, ' '))as AddressStreet,
      COALESCE(address.AddressLine2,'') as AddressLine2,
      stateprovince.Name as State,
      countryregion.Name as Country,
      COUNT(orders.SalesOrderID) as OrderCount,
      SUM(orders.TotalDue) as TotalAmountPurchases,
      MAX(orders.OrderDate) as LastOrderDate,
      CASE WHEN MAX(orders.OrderDate) > CAST(DATETIME_SUB(CAST((SELECT MAX(OrderDate) FROM `tc-da-1.adwentureworks_db.salesorderheader`) AS DATETIME), INTERVAL 1 year) AS TIMESTAMP) THEN 'Active' ELSE 'Inactive' END as UserStatus
FROM `tc-da-1.adwentureworks_db.customer` as customer
  JOIN `tc-da-1.adwentureworks_db.individual` as individual ON (customer.CustomerID = individual.CustomerID AND customer.CustomerType = ""I"")
  JOIN `tc-da-1.adwentureworks_db.contact` as contact ON individual.ContactID = contact.ContactID
  JOIN `tc-da-1.adwentureworks_db.customeraddress` as customeraddress ON (customer.CustomerID = customeraddress.CustomerID AND customeraddress.AddressTypeID = 2)
  JOIN `tc-da-1.adwentureworks_db.address` as address ON customeraddress.AddressID = address.AddressID
  JOIN `tc-da-1.adwentureworks_db.stateprovince` as stateprovince ON address.StateProvinceID = stateprovince.StateProvinceID
  JOIN `tc-da-1.adwentureworks_db.countryregion` as countryregion ON stateprovince.CountryRegionCode = countryregion.CountryRegionCode
  JOIN `tc-da-1.adwentureworks_db.salesorderheader` as orders ON customer.CustomerID = orders.CustomerID
  JOIN `tc-da-1.adwentureworks_db.salesterritory` as salesterritory ON customer.TerritoryID = salesterritory.TerritoryID
WHERE
      salesterritory.Group IN ('North America')
GROUP BY
      customer.CustomerID,
      contact.FirstName,
      contact.LastName,
      FullName,
      AddressingTitle,
      contact.EmailAddress,
      contact.Phone,
      customer.AccountNumber,
      customer.CustomerType,
      address.City,
      address.AddressLine1,
      AddressLine2,
      stateprovince.Name,
      countryregion.Name
HAVING
      UserStatus = 'Active' AND (TotalAmountPurchases >= 2500 OR OrderCount > 5)
ORDER BY
      Country,
      State,
      LastOrderDate
LIMIT 200;

-- Task 2.1
/*
Create a query of monthly sales numbers in each Country & region. Include in the query a number of orders, customers and sales persons in each month with a total amount with tax earned. Sales numbers from all types of customers are required.
*/
SELECT
      LAST_DAY(CAST(orders.OrderDate AS DATETIME), month) as order_month,
      salesterritory.CountryRegionCode as country_region_code,
      salesterritory.Name as region_name,
      COUNT(orders.SalesOrderID) as number_orders,
      COUNT(DISTINCT orders.CustomerID) as number_customers,
      COUNT(DISTINCT orders.SalesPersonID) as number_salespersons,
      CAST(SUM(orders.TotalDue) AS INT) as total_w_tax
FROM `tc-da-1.adwentureworks_db.salesorderheader` as orders
JOIN `tc-da-1.adwentureworks_db.salesterritory` as salesterritory ON orders.TerritoryID = salesterritory.TerritoryID
GROUP BY
      order_month,
      country_region_code,
      region_name
ORDER BY
      country_region_code DESC;

-- Task 2.2
/*
Enrich 2.1 query with the cumulative_sum of the total amount with tax earned per country & region.
*/
WITH orders_by_country_region AS (
SELECT
      LAST_DAY(CAST(orders.OrderDate AS DATETIME), month) as order_month,
      salesterritory.CountryRegionCode as country_region_code,
      salesterritory.Name as region_name,
      COUNT(orders.SalesOrderID) as number_orders,
      COUNT(DISTINCT orders.CustomerID) as number_customers,
      COUNT(DISTINCT orders.SalesPersonID) as number_salespersons,
      CAST(SUM(orders.TotalDue) AS INT) as total_w_tax
FROM `tc-da-1.adwentureworks_db.salesorderheader` as orders
JOIN `tc-da-1.adwentureworks_db.salesterritory` as salesterritory ON orders.TerritoryID = salesterritory.TerritoryID
GROUP BY
      order_month,
      country_region_code,
      region_name)

SELECT
      order_month,
      country_region_code,
      region_name,
      number_orders,
      number_customers,
      number_salespersons,
      total_w_tax,
      SUM(total_w_tax) OVER (
                        PARTITION BY region_name,country_region_code
                        ORDER BY order_month
                        ) as cumulative_total
FROM orders_by_country_region;

-- Task 2.3
/*
Enrich 2.2 query by adding ‘sales_rank’ column that ranks rows from best to worst for each country based on total amount with tax earned each month. I.e. the month where the (US, Southwest) region made the highest total amount with tax earned will be ranked 1 for that region and vice versa.
*/
WITH orders_by_country_region AS (
SELECT
      LAST_DAY(CAST(orders.OrderDate AS DATETIME), month) as order_month,
      salesterritory.CountryRegionCode as country_region_code,
      salesterritory.Name as region_name,
      COUNT(orders.SalesOrderID) as number_orders,
      COUNT(DISTINCT orders.CustomerID) as number_customers,
      COUNT(DISTINCT orders.SalesPersonID) as number_salespersons,
      CAST(SUM(orders.TotalDue) AS INT) as total_w_tax
FROM `tc-da-1.adwentureworks_db.salesorderheader` as orders
JOIN `tc-da-1.adwentureworks_db.salesterritory` as salesterritory ON orders.TerritoryID = salesterritory.TerritoryID
GROUP BY
      order_month,
      country_region_code,
      region_name)

SELECT
      order_month,
      country_region_code,
      region_name,
      number_orders,
      number_customers,
      number_salespersons,
      total_w_tax,
      RANK() OVER (
                        PARTITION BY  region_name, country_region_code
                        ORDER BY total_w_tax DESC
                        ) as country_sales_rank,
      SUM(total_w_tax) OVER (
                        PARTITION BY region_name,country_region_code
                        ORDER BY order_month
                        ) as cumulative_total
FROM orders_by_country_region
WHERE region_name IN ('France')
ORDER BY country_region_code, country_sales_rank;

-- Task 2.4
/*
Enrich 2.3 query by adding taxes on a country level:

As taxes can vary in country based on province, the needed column is ‘mean_tax_rate’ -> average tax rate in a country.
Also, as not all regions have data on taxes, you also want to be transparent and show the ‘perc_provinces_w_tax’ -> a column representing the percentage of provinces with available tax rates for each country (i.e. If US has 53 provinces, and 10 of them have tax rates, then for US it should show 0,19)
*/
WITH orders_by_country_region AS (
SELECT
      LAST_DAY(CAST(orders.OrderDate AS DATETIME), month) AS order_month,
      salesterritory.CountryRegionCode as country_region_code,
      salesterritory.Name as region_name,
      COUNT(orders.SalesOrderID) as number_orders,
      COUNT(DISTINCT orders.CustomerID) as number_customers,
      COUNT(DISTINCT orders.SalesPersonID) as number_salespersons,
      CAST(SUM(orders.TotalDue) AS INT) as total_w_tax
FROM `tc-da-1.adwentureworks_db.salesorderheader` as orders
JOIN `tc-da-1.adwentureworks_db.salesterritory` as salesterritory ON orders.TerritoryID = salesterritory.TerritoryID
GROUP BY
      order_month,
      country_region_code,
      region_name
),

taxes_table AS (
SELECT
      stateprovince.CountryRegionCode as country_region_code,
      AVG(taxrates.TaxRate)  as mean_tax_rate_country,
      ROUND(COUNT(taxrates.SalesTaxRateID) /COUNT(stateprovince.StateProvinceID), 2) as perc_provinces_w_tax
FROM
      `tc-da-1.adwentureworks_db.stateprovince` stateprovince
LEFT JOIN `tc-da-1.adwentureworks_db.salestaxrate` taxrates on stateprovince.StateProvinceID = taxrates.StateProvinceID
GROUP BY country_region_code
)

SELECT
      orders_by_country_region.order_month,
      orders_by_country_region.country_region_code,
      orders_by_country_region.region_name,
      orders_by_country_region.number_orders,
      orders_by_country_region.number_customers,
      orders_by_country_region.number_salespersons,
      orders_by_country_region.total_w_tax,
      RANK() OVER (
                        PARTITION BY  orders_by_country_region.region_name, orders_by_country_region.country_region_code
                        ORDER BY orders_by_country_region.total_w_tax DESC
                        ) as country_sales_rank,
      SUM(total_w_tax) OVER (
                        PARTITION BY orders_by_country_region.region_name, orders_by_country_region.country_region_code
                        ORDER BY orders_by_country_region.order_month
                        ) as cumulative_total,
      taxes_table.mean_tax_rate_country,
      taxes_table.perc_provinces_w_tax
FROM orders_by_country_region
JOIN taxes_table ON orders_by_country_region.country_region_code=taxes_table.country_region_code
WHERE orders_by_country_region.country_region_code = 'US';
