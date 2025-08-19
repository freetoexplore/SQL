-- List the vendor_name, vendor_state, and total amount of business 
-- we’ve conducted with the vendor for the top vendor(s) from each state.
-- list only state No.1 with total greater than 0.
-- like VIEW / materialized table
WITH cte_rank AS
(
SELECT vendor_name, vendor_state, 
	   CASE WHEN SUM(line_item_amt) IS NULL THEN 0
            ELSE SUM(line_item_amt)
		END AS total_business,
	   RANK() OVER (PARTITION BY vendor_state ORDER BY SUM(line_item_amt) DESC) AS vendor_rank
  FROM vendors AS V
  LEFT JOIN invoices AS I USING (vendor_id)
  LEFT JOIN invoice_line_items AS L USING (invoice_id)
 GROUP BY vendor_name
)
SELECT * FROM cte_rank
 WHERE vendor_rank = 1 AND total_business > 0
 ORDER BY vendor_name;

-- cte refer to itself
use adventureworks;

-- List the ProductID, name, color, and quantity of all products 
-- required to build finished ProductId 775.
-- LEVEL
WITH RECURSIVE cte_product as 
(
select P.ProductID, P.Name, P.Color, 1 as lvl -- LEVEL 1
  from BillOfMaterials as B
  join product as P on B.ComponentID = P.ProductID
 where ProductID = 775
union all 	-- join rest 
select P.ProductID, P.Name, P.Color, lvl + 1 as lvl  -- recursion
  from BillOfMaterials as B
  join product as P on B.ComponentID = P.ProductID
  join cte_product as ct on ct.ProductID = B.ProductAssemblyID
 WHERE B.EndDate IS NULL
)
select * from cte_product;

-- + Qty
WITH RECURSIVE cte_product as 
(
select P.ProductID, P.Name, P.Color, 1 as lvl -- LEVEL 1
  from BillOfMaterials as B
  join product as P on B.ComponentID = P.ProductID
 where ProductID = 775
union all 	-- join rest 
select P.ProductID, P.Name, P.Color, lvl + 1 as lvl  -- recursion
  from BillOfMaterials as B
  join product as P on B.ComponentID = P.ProductID
  join cte_product as ct on ct.ProductID = B.ProductAssemblyID
 WHERE B.EndDate IS NULL
)
select * from cte_product;

-- + 名称1\名称2\名称3
WITH RECURSIVE cte_bom AS
(
SELECT P.ProductId, P.Name, P.Color, 1 AS qty, 1 AS bom_lvl, ProductAssemblyId,
	   CAST(P.Name AS CHAR(100)) AS sort
  FROm Product AS P
  JOIN BillOfMaterials AS B ON B.ComponentId = P.ProductId
 WHERE ProductId = 775
UNION ALL
SELECT P.ProductId, P.Name, P.Color, PerAssemblyQty, bom_lvl + 1, C.ProductId,
	   CAST(CONCAT(C.sort, '\\', P.Name) AS CHAR(100)) AS sort
  FROM cte_bom AS C
  JOIN BillOfMaterials AS B ON B.ProductAssemblyId = C.ProductId
  JOIN Product AS P ON P.productId = B.ComponentId
 WHERE B.EndDate IS NULL
)
SELECT * FROM cte_bom;


-- + |--|-- level Name 
WITH RECURSIVE cte_bom AS
(
SELECT P.ProductId, CAST(P.Name AS CHAR(100)) AS Name, P.Color, 1 AS qty, 1 AS bom_lvl, ProductAssemblyId,
	   CAST(P.Name AS CHAR(100)) AS sort
  FROm Product AS P
  JOIN BillOfMaterials AS B ON B.ComponentId = P.ProductId
 WHERE ProductId = 775
UNION ALL
SELECT P.ProductId, cAST(CONCAT(REPEAT('|--', bom_lvl), ' ', P.Name) AS CHAR(100)), P.Color, PerAssemblyQty, bom_lvl + 1, C.ProductId,
	   CAST(CONCAT(C.sort, '\\', P.Name) AS CHAR(100)) AS sort
  FROM cte_bom AS C
  JOIN BillOfMaterials AS B ON B.ProductAssemblyId = C.ProductId
  JOIN Product AS P ON P.productId = B.ComponentId
 WHERE B.EndDate IS NULL
)
SELECT * FROM cte_bom ORDER BY sort;