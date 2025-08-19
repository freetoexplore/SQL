use departments;

-- list all employees and their level in org
WITH RECURSIVE cte_employees as 
(
select employee_id, first_name, last_name, manager_id, 1 as lvl -- LEVEL 1
  from employees
 where manager_id is null
union all 	-- join rest 
select E.employee_id, E.first_name, E.last_name, E.manager_id, lvl + 1 as lvl  -- recursion
  from employees as E
  join cte_employees as C on C.employee_id = E.manager_id
)
select * from cte_employees;

-- name of emplolyees report directly or indirectly to Paulo (金字塔下所有)
WITH RECURSIVE cte_employees as 
(
select employee_id, first_name, last_name, manager_id, 1 as lvl -- LEVEL 1
  from employees
 where first_name ='Paulo'
union all
select E.employee_id, E.first_name, E.last_name, E.manager_id, lvl +1 as lvl -- LEVEL 1
  from employees as E
  join cte_employees as C on C.employee_id = E.manager_id
  )
  select * from cte_employees;
  
  
use adventureworks;
select * from product;
select * from BillOfMaterials where ProductAssemblyId=775; -- component parts to bikes
select * from BillOfMaterials where ProductAssemblyId=807;
-- Q1
WITH RECURSIVE cte_bom as 
(
select P.ProductId, P.name, P.color, 1 as qty, 1 as bom_lvl, ProductAssemblyId -- LEVEL 1
  from Product as P
  join BillOfMaterials as B on B.ComponentId=P.ProductId
  where ProductId=775  -- CEO
union all
select P.ProductId, P.name, P.color, PerAssemblyQty, bom_lvl + 1, C. ProductId
  from cte_bom as C
  join BillOfMaterials as B on B.ProductAssemblyId=C.ProductId
  join Product as P on B.ComponentId=P.ProductId
  where B.EndDate is null -- current component
)
select * from cte_bom;

-- Q2
-- Union tables, same cols and same types
WITH RECURSIVE cte_bom as 
(
select P.ProductId, CAST(P.name AS CHAR(100)) as Name, 
	   P.color, 1 as qty, 1 as bom_lvl, ProductAssemblyId, -- LEVEL 1
	   CAST(P.name AS CHAR(100)) as sort
  from Product as P
  join BillOfMaterials as B on B.ComponentId=P.ProductId
  where ProductId=775  -- CEO
union all
select P.ProductId, cast(concat(repeat('|--', bom_lvl), ' ', P.name) as CHAR(100)), 
  P.color, PerAssemblyQty, bom_lvl + 1, C. ProductId,
  CAST(CONCAT(C.sort, '\\',p.Name) AS CHAR(100)) as sort
  from cte_bom as C
  join BillOfMaterials as B on B.ProductAssemblyId=C.ProductId
  join Product as P on B.ComponentId=P.ProductId
  where B.EndDate is null -- current component
)
select * from cte_bom order by sort;