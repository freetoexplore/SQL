use invoice;
-- rank ————————————————————————————————————————————————————————————————————————————————————————————————
-- by total business (including 0 business)
select vendor_name, vendor_state, sum(line_item_amt) as total,
RANK () OVER (ORDER BY sum(line_item_amt) DESC) as vendor_rank
	from vendors as V
left join invoices as I using (vendor_id)
left join invoice_line_items as L using (invoice_id)
group by vendor_name;

-- row_number ————————————————————————————————————————————————————————————————————————————————————-——————
-- sort by vendor name in each city
select ROW_NUMBER() OVER (ORDER BY vendor_name) AS vendor_no, -- vendor_no is assigned by alphabetic order
		vendor_id, vendor_name, vendor_city, vendor_state 
        from vendors
order by vendor_city, vendor_state; -- presentation order

-- No.1 in each state
select ROW_NUMBER() OVER (partition by vendor_state ORDER BY vendor_name) AS vendor_no, 
		vendor_id, vendor_name, vendor_city, vendor_state from vendors
order by vendor_state, vendor_name; 

select ROW_NUMBER() OVER (partition by vendor_city, vendor_state ORDER BY vendor_name) AS vendor_no, 
		vendor_id, vendor_name, vendor_city, vendor_state from vendors
order by vendor_state, vendor_name; 

-- dense——————————————————————————————————————————————————————————————————————————————————————————
select Dense_rank () OVER (ORDER BY emp_level DESC) emp_level, 
		T.employeeNumber, T.firstName, T.lastName, 
		T.reportsTo, round(T.sum_total,2) as total_sales
from(
WITH RECURSIVE cte_emp as 
(
select e1.employeeNumber, e1.firstname, e1.lastname, e1.reportsTo, 
		e1.total_sales, 1 as emp_level
	from emp_sales_per_person as e1
where employeeNumber not in -- 底层
	(select distinct reportsTo from employees where reportsTo is not null)
union all
select  e2.employeeNumber, e2.firstname, e2.lastname, e2.reportsTo,
		ct.total_sales + e2.total_sales ,ct.emp_level + 1 -- LEVEL 1
  from emp_sales_per_person as e2
  join cte_emp as ct on e2.employeeNumber = ct.reportsTo  -- E.emp = ct.manager
)
select max(emp_level) as emp_level, employeeNumber, firstName, lastName, 
		reportsTo,sum(total_sales) as sum_total from cte_emp
group by employeeNumber, reportsTo
order by emp_level, sum_total desc) as T;