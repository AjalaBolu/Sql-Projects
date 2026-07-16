# Library Management System using SQL Project --P2


This project demonstrates the implementation of a Library Management System using SQL. It includes creating and managing tables, performing CRUD operations, and executing advanced SQL queries. The goal is to showcase skills in database design, manipulation, and querying.

## Objectives

1. **Set up the Library Management System Database**: Create and populate the database with tables for branches, employees, members, books, issued status, and return status.
2. **CRUD Operations**: Perform Create, Read, Update, and Delete operations on the data.
3. **CTAS (Create Table As Select)**: Utilize CTAS to create new tables based on query results.
4. **Advanced SQL Queries**: Develop complex queries to analyze and retrieve specific data.

## Project Structure

### 1. Database Setup


- **Database Creation**: Created a database named `library_db`.
- **Table Creation**: Created tables for branches, employees, members, books, issued status, and return status. Each table includes relevant columns and relationships.

```sql
drop table if exists branch;

create table branch (
	branch_id varchar (10) primary key,
	manager_id varchar (10), 
	branch_address varchar (50),
	contact_no varchar (10)
);

alter table branch 
alter column contact_no type varchar (20); 

drop table if exists employees;
create table employees
	(
		emp_id varchar (10),
		emp_name varchar (25),
		position varchar (15),
		salary decimal (8,2),
		branch_id varchar (25) 
	);

ALTER TABLE employees
ADD CONSTRAINT pk_employee PRIMARY KEY (emp_id);


drop table if exists books;
create table books
	(
		isbn varchar (20) primary key,
		book_title varchar (60),
		category varchar (20),
		rental_price decimal (4,2),
		status boolean,
		author varchar (25),
		publisher varchar (25)
	);
	
drop table if exists members;
create table members
	(
		member_id varchar (10) primary key,
		member_name	varchar (16),
		member_address	varchar (15),
		reg_date date
	);

drop table if exists issued_status;
create table issued_status
	(
		issued_id varchar (10) primary key,
		issued_member_id varchar (10),
		issued_book_name varchar (60),
		issued_date	date,
		issued_book_isbn varchar (17),	
		issued_emp_id varchar (10)
	);
	
drop table if exists return_status;
create table return_status
	(
		return_id varchar (10),
		issued_id varchar(10),
		return_book_name varchar(60),
		return_date	Date,
		return_book_isbn varchar (20)
	);
```

### 2. CRUD Operations

- **Create**: Inserted sample records into the `books` table.
- **Read**: Retrieved and displayed data from various tables.
- **Update**: Updated records in the `employees` table.
- **Delete**: Removed records from the `members` table as needed.

**Task 1. Create a New Book Record**
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

```sql
insert into books 
values (
	'978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.'
);
```
**Task 2: Update an Existing Member's Address**

```sql
select *
from members;

update members
set member_address = '142 main st'
where member_id = 'C101';

```

**Task 3: Delete a Record from the Issued Status Table**
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

```sql
delete from issued_status
where issued_id = 'IS121';
select *
from issued_status;
```

**Task 4: Retrieve All Books Issued by a Specific Employee**
-- Objective: Select all books issued by the employee with emp_id = 'E101'.
```sql
SELECT *
FROM Employees e
LEFT JOIN issued_status i
ON e.emp_id = i.issued_emp_id
WHERE e.emp_id = 'E101';
```

**Task 5: Delete a Record from the Issued Status Table**
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.
```sql
delete from issued_status
where issued_id = 'IS121';
```

**Task 6: Retrieve All Books Issued by a Specific Employee**
-- Objective: Select all books issued by the employee with emp_id = 'E101'.
```sql
select *
from issued_status
where issued_emp_id = 'E101';
```

**Task 7: List Members Who Have Issued More Than One Book**
-- Objective: Use GROUP BY to find members who have issued more than one book.

```sql
SELECT
    issued_emp_id,
    COUNT(*)
FROM issued_status
GROUP BY 1
HAVING COUNT(*) > 1
```

### 3. CTAS (Create Table As Select)

- **Task 8: Create Summary Tables**: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt

```sql
create table book_counts
as
select 
	b.isbn,
	b.book_title,
	count(*) 
from books b
join issued_status i
	on b.isbn = i.issued_book_isbn
group by 1,2;

select *
from book_counts;
```


### 4. Data Analysis & Findings

The following SQL queries were used to address specific questions:

**Task 9. Retrieve All Books in a Specific Category**:

```sql
select *
from books
where category = 'Classic';


select 
category,
count(*)
from books
group by category;
```

8. **Task 10: Find Total Rental Income by Category**:

```sql
select 
	b.category,
	sum(b.rental_price),
	count(*) 
from books b
join issued_status i
	on b.isbn = i.issued_book_isbn
group by 1;
```

**Task 11 List Members Who Registered in the Last 800 Days**:
```sql
select *
from members
where reg_date >= current_date - interval '800 days';
```

**Task 12 List Employees with Their Branch Manager's Name and their branch details**:

```sql
select 
	e.emp_id as supervisee_id,
	e.emp_name as supervise_name,
	e2.emp_name as manager_name,
	e2.emp_id as Manager_id,
	b.branch_address,
	b.branch_id
from employees e
	join branch b
	on e.branch_id = b.branch_id
		join employees e2
		on b.manager_id = e2.emp_id;
```

**Task 13 Create a Table of Books with Rental Price Above a Certain Threshold**:
```sql
create table expensive_books as
	select *
	from books
	where rental_price >= 5;
```

**Task 14 Retrieve the List of Books Not Yet Returned**
```sql
SELECT * FROM issued_status as ist
LEFT JOIN
return_status as rs
ON rs.issued_id = ist.issued_id
WHERE rs.return_id IS NULL;
```

## Advanced SQL Operations

**Task 15: Identify Members with Overdue Books**  
Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.

```sql
select 
	ist.issued_member_id,
	m.member_name, 
	b.book_title, 
	ist.issued_date,
	-- rs.return_date,
	current_date - ist.issued_date days_overdue
from members m
join 
issued_status ist
	on m.member_id = ist.issued_member_id
left join 
return_status rs
	ON rs.issued_id = ist.issued_id
join 
books b
	on b.isbn = ist.issued_book_isbn
where
	rs.return_date is null
	and
	current_date - ist.issued_date > 30
order by 1;

```

**Task 16: Update Book Status on Return**  
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).


```sql
CREATE OR REPLACE PROCEDURE add_returned_books(
    p_return_id VARCHAR(10),
    p_issued_id VARCHAR(10),
    p_book_quality VARCHAR(15)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_isbn VARCHAR(17);
    v_book_title VARCHAR(60);
BEGIN
    -- Insert into return_status
    INSERT INTO return_status (return_id, issued_id, return_date, book_quality)
    VALUES (p_return_id, p_issued_id, CURRENT_DATE, p_book_quality);

    -- Get book details from issued_status
    SELECT
        issued_book_isbn,
        issued_book_name
    INTO
        v_isbn,
        v_book_title
    FROM issued_status
    WHERE issued_id = p_issued_id;

    -- Update book status
    UPDATE books
    SET status = 'true'
    WHERE isbn = v_isbn;

    -- Confirmation message
    RAISE NOTICE 'Thank you for returning the book: %', v_book_title;
END;
$$;

-- Testing 
CALL add_returned_books('RS138', 'IS135', 'Good');
CALL add_returned_books('RS148', 'IS140', 'Good');

select *
from books

```

**Task 17: Branch Performance Report**  
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.

```sql
create table branch_report
as
select 
	b.branch_id,
	count(ist.issued_id) books_issued,
	count(rs.return_id) books_returned,
	sum(bk.rental_price) profit
from branch b
join employees e
	on b.branch_id = e.branch_id
join issued_status ist
	on e.emp_id = ist.issued_emp_id
join books bk
	on ist.issued_book_isbn = bk.isbn
left join return_status rs
	on ist.issued_id = rs.issued_id
group by 
	b.branch_id
order by 
	b.branch_id;

select * from branch_report;
```

**Task 18: CTAS: Create a Table of Active Members**  
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.

```sql

CREATE TABLE active_members
AS
SELECT * FROM members
WHERE member_id IN (SELECT 
                        DISTINCT issued_member_id   
                    FROM issued_status
                    WHERE 
                        issued_date >= CURRENT_DATE - INTERVAL '2 month'
                    )
;

SELECT * FROM active_members;

```


**Task 19: Find Employees with the Most Book Issues Processed**  
Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.

```sql
select 
	e.emp_name,
	b.branch_address,
	e.branch_id,
	count(ist.issued_id) books_issued
from employees e
join branch b
	on e.branch_id = b.branch_id
join issued_status ist
	on e.emp_id = ist.issued_emp_id
group by 1,2,3
order by 4 desc
limit 3;
```

**Task 20: Identify Members Issuing High-Risk Books**  
Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. Display the member name, book title, and the number of times they've issued damaged books.    
```sql
select 
    m.member_name,
    b.book_title,
    count(ist.issued_id) as damaged_count
from members m
join issued_status ist
    on m.member_id = ist.issued_member_id
join return_status rs
    on ist.issued_id = rs.issued_id
join books b
    on ist.issued_book_isbn = b.isbn
where rs.book_quality = 'Damaged'
group by 
    m.member_name,
    b.book_title
```

**Task 21: Stored Procedure**
Objective:
Create a stored procedure to manage the status of books in a library system.
Description:
Write a stored procedure that updates the status of a book in the library based on its issuance. The procedure should function as follows:
The stored procedure should take the book_id as an input parameter.
The procedure should first check if the book is available (status = 'yes').
If the book is available, it should be issued, and the status in the books table should be updated to 'no'.
If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.

```sql
CREATE OR REPLACE PROCEDURE issue_book(
    p_issued_id VARCHAR(10),
    p_issued_member_id VARCHAR(10),
    p_issued_book_name VARCHAR(60),
    p_issued_book_isbn VARCHAR(17),
    p_issued_emp_id VARCHAR(10)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_status BOOLEAN;
BEGIN

    SELECT status
    INTO v_status
    FROM books
    WHERE isbn = p_issued_book_isbn;

    IF v_status = TRUE THEN

        INSERT INTO issued_status (
            issued_id,
            issued_member_id,
            issued_book_name,
            issued_date,
            issued_book_isbn,
            issued_emp_id
        )
        VALUES (
            p_issued_id,
            p_issued_member_id,
            p_issued_book_name,
            CURRENT_DATE,
            p_issued_book_isbn,
            p_issued_emp_id
        );

      
        UPDATE books
        SET status = FALSE
        WHERE isbn = p_issued_book_isbn;

        RAISE NOTICE 'Book issued successfully. ISBN: %', p_issued_book_isbn;

    ELSE
        RAISE NOTICE 'Sorry, the requested book is not available. ISBN: %',
                     p_issued_book_isbn;
    END IF;

END;
$$;


```



**Task 22: Create Table As Select (CTAS)**
Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.

Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. The table should include:
    The number of overdue books.
    The total fines, with each day's fine calculated at $0.50.
    The number of books issued by each member.
    The resulting table should show:
    Member ID
    Number of overdue books
    Total fines
```sql
CREATE TABLE overdue_books_summary AS
SELECT
    ist.issued_member_id,
    COUNT(*) AS overdue_books,
    SUM((CURRENT_DATE - ist.issued_date - 30) * 0.50) 
        AS total_fine 
FROM issued_status ist
JOIN books b
    ON b.isbn = ist.issued_book_isbn

WHERE b.status = FALSE
AND CURRENT_DATE - ist.issued_date > 30

GROUP BY ist.issued_member_id;
```


## Reports

- **Database Schema**: Detailed table structures and relationships.
- **Data Analysis**: Insights into book categories, employee salaries, member registration trends, and issued books.
- **Summary Reports**: Aggregated data on high-demand books and employee performance.

## Conclusion

This project demonstrates the application of SQL skills in creating and managing a library management system. It includes database setup, data manipulation, and advanced querying, providing a solid foundation for data management and analysis.
