-- Libary management system

-- Creating the tables

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

-- Foreign key constraint
ALTER TABLE issued_status
ADD CONSTRAINT fk_mamber
foreign key (issued_member_id)
references members(member_id);

ALTER TABLE issued_status
ADD CONSTRAINT fk_books
foreign key (issued_book_isbn)
references books(isbn);

ALTER TABLE issued_status
ADD CONSTRAINT fk_emp
foreign key (issued_emp_id)
references employees (emp_id);

ALTER TABLE employees
ADD CONSTRAINT fk_branch
foreign key (branch_id)
references branch(branch_id);

ALTER TABLE return_status
ADD CONSTRAINT fk_status
foreign key (issued_id)
references issued_status(issued_id);


-- INSERTING INTO THE COLUMNS

INSERT INTO members(member_id, member_name, member_address, reg_date) 
VALUES
('C101', 'Alice Johnson', '123 Main St', '2021-05-15'),
('C102', 'Bob Smith', '456 Elm St', '2021-06-20'),
('C103', 'Carol Davis', '789 Oak St', '2021-07-10'),
('C104', 'Dave Wilson', '567 Pine St', '2021-08-05'),
('C105', 'Eve Brown', '890 Maple St', '2021-09-25'),
('C106', 'Frank Thomas', '234 Cedar St', '2021-10-15'),
('C107', 'Grace Taylor', '345 Walnut St', '2021-11-20'),
('C108', 'Henry Anderson', '456 Birch St', '2021-12-10'),
('C109', 'Ivy Martinez', '567 Oak St', '2022-01-05'),
('C110', 'Jack Wilson', '678 Pine St', '2022-02-25'),
('C118', 'Sam', '133 Pine St', '2024-06-01'),    
('C119', 'John', '143 Main St', '2024-05-01');
SELECT * FROM members;


-- Insert values into each branch table
INSERT INTO branch(branch_id, manager_id, branch_address, contact_no) 
VALUES
('B001', 'E109', '123 Main St', '+919099988676'),
('B002', 'E109', '456 Elm St', '+919099988677'),
('B003', 'E109', '789 Oak St', '+919099988678'),
('B004', 'E110', '567 Pine St', '+919099988679'),
('B005', 'E110', '890 Maple St', '+919099988680');
SELECT * FROM branch;


-- Insert values into each employees table
INSERT INTO employees(emp_id, emp_name, position, salary, branch_id) 
VALUES
('E101', 'John Doe', 'Clerk', 60000.00, 'B001'),
('E102', 'Jane Smith', 'Clerk', 45000.00, 'B002'),
('E103', 'Mike Johnson', 'Librarian', 55000.00, 'B001'),
('E104', 'Emily Davis', 'Assistant', 40000.00, 'B001'),
('E105', 'Sarah Brown', 'Assistant', 42000.00, 'B001'),
('E106', 'Michelle Ramirez', 'Assistant', 43000.00, 'B001'),
('E107', 'Michael Thompson', 'Clerk', 62000.00, 'B005'),
('E108', 'Jessica Taylor', 'Clerk', 46000.00, 'B004'),
('E109', 'Daniel Anderson', 'Manager', 57000.00, 'B003'),
('E110', 'Laura Martinez', 'Manager', 41000.00, 'B005'),
('E111', 'Christopher Lee', 'Assistant', 65000.00, 'B005');
SELECT * FROM employees;


-- Inserting into books table 
INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher) 
VALUES
('978-0-553-29698-2', 'The Catcher in the Rye', 'Classic', 7.00, 'yes', 'J.D. Salinger', 'Little, Brown and Company'),
('978-0-330-25864-8', 'Animal Farm', 'Classic', 5.50, 'yes', 'George Orwell', 'Penguin Books'),
('978-0-14-118776-1', 'One Hundred Years of Solitude', 'Literary Fiction', 6.50, 'yes', 'Gabriel Garcia Marquez', 'Penguin Books'),
('978-0-525-47535-5', 'The Great Gatsby', 'Classic', 8.00, 'yes', 'F. Scott Fitzgerald', 'Scribner'),
('978-0-141-44171-6', 'Jane Eyre', 'Classic', 4.00, 'yes', 'Charlotte Bronte', 'Penguin Classics'),
('978-0-307-37840-1', 'The Alchemist', 'Fiction', 2.50, 'yes', 'Paulo Coelho', 'HarperOne'),
('978-0-679-76489-8', 'Harry Potter and the Sorcerers Stone', 'Fantasy', 7.00, 'yes', 'J.K. Rowling', 'Scholastic'),
('978-0-7432-4722-4', 'The Da Vinci Code', 'Mystery', 8.00, 'yes', 'Dan Brown', 'Doubleday'),
('978-0-09-957807-9', 'A Game of Thrones', 'Fantasy', 7.50, 'yes', 'George R.R. Martin', 'Bantam'),
('978-0-393-05081-8', 'A Peoples History of the United States', 'History', 9.00, 'yes', 'Howard Zinn', 'Harper Perennial'),
('978-0-19-280551-1', 'The Guns of August', 'History', 7.00, 'yes', 'Barbara W. Tuchman', 'Oxford University Press'),
('978-0-307-58837-1', 'Sapiens: A Brief History of Humankind', 'History', 8.00, 'no', 'Yuval Noah Harari', 'Harper Perennial'),
('978-0-375-41398-8', 'The Diary of a Young Girl', 'History', 6.50, 'no', 'Anne Frank', 'Bantam'),
('978-0-14-044930-3', 'The Histories', 'History', 5.50, 'yes', 'Herodotus', 'Penguin Classics'),
('978-0-393-91257-8', 'Guns, Germs, and Steel: The Fates of Human Societies', 'History', 7.00, 'yes', 'Jared Diamond', 'W. W. Norton & Company'),
('978-0-7432-7357-1', '1491: New Revelations of the Americas Before Columbus', 'History', 6.50, 'no', 'Charles C. Mann', 'Vintage Books'),
('978-0-679-64115-3', '1984', 'Dystopian', 6.50, 'yes', 'George Orwell', 'Penguin Books'),
('978-0-14-143951-8', 'Pride and Prejudice', 'Classic', 5.00, 'yes', 'Jane Austen', 'Penguin Classics'),
('978-0-452-28240-7', 'Brave New World', 'Dystopian', 6.50, 'yes', 'Aldous Huxley', 'Harper Perennial'),
('978-0-670-81302-4', 'The Road', 'Dystopian', 7.00, 'yes', 'Cormac McCarthy', 'Knopf'),
('978-0-385-33312-0', 'The Shining', 'Horror', 6.00, 'yes', 'Stephen King', 'Doubleday'),
('978-0-451-52993-5', 'Fahrenheit 451', 'Dystopian', 5.50, 'yes', 'Ray Bradbury', 'Ballantine Books'),
('978-0-345-39180-3', 'Dune', 'Science Fiction', 8.50, 'yes', 'Frank Herbert', 'Ace'),
('978-0-375-50167-0', 'The Road', 'Dystopian', 7.00, 'yes', 'Cormac McCarthy', 'Vintage'),
('978-0-06-025492-6', 'Where the Wild Things Are', 'Children', 3.50, 'yes', 'Maurice Sendak', 'HarperCollins'),
('978-0-06-112241-5', 'The Kite Runner', 'Fiction', 5.50, 'yes', 'Khaled Hosseini', 'Riverhead Books'),
('978-0-06-440055-8', 'Charlotte''s Web', 'Children', 4.00, 'yes', 'E.B. White', 'Harper & Row'),
('978-0-679-77644-3', 'Beloved', 'Fiction', 6.50, 'yes', 'Toni Morrison', 'Knopf'),
('978-0-14-027526-3', 'A Tale of Two Cities', 'Classic', 4.50, 'yes', 'Charles Dickens', 'Penguin Books'),
('978-0-7434-7679-3', 'The Stand', 'Horror', 7.00, 'yes', 'Stephen King', 'Doubleday'),
('978-0-451-52994-2', 'Moby Dick', 'Classic', 6.50, 'yes', 'Herman Melville', 'Penguin Books'),
('978-0-06-112008-4', 'To Kill a Mockingbird', 'Classic', 5.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.'),
('978-0-553-57340-1', '1984', 'Dystopian', 6.50, 'yes', 'George Orwell', 'Penguin Books'),
('978-0-7432-4722-5', 'Angels & Demons', 'Mystery', 7.50, 'yes', 'Dan Brown', 'Doubleday'),
('978-0-7432-7356-4', 'The Hobbit', 'Fantasy', 7.00, 'yes', 'J.R.R. Tolkien', 'Houghton Mifflin Harcourt');
SELECT * FROM books;

-- inserting into issued table
INSERT INTO issued_status(issued_id, issued_member_id, issued_book_name, issued_date, issued_book_isbn, issued_emp_id) 
VALUES
('IS106', 'C106', 'Animal Farm', '2024-03-10', '978-0-330-25864-8', 'E104'),
('IS107', 'C107', 'One Hundred Years of Solitude', '2024-03-11', '978-0-14-118776-1', 'E104'),
('IS108', 'C108', 'The Great Gatsby', '2024-03-12', '978-0-525-47535-5', 'E104'),
('IS109', 'C109', 'Jane Eyre', '2024-03-13', '978-0-141-44171-6', 'E105'),
('IS110', 'C110', 'The Alchemist', '2024-03-14', '978-0-307-37840-1', 'E105'),
('IS111', 'C109', 'Harry Potter and the Sorcerers Stone', '2024-03-15', '978-0-679-76489-8', 'E105'),
('IS112', 'C109', 'A Game of Thrones', '2024-03-16', '978-0-09-957807-9', 'E106'),
('IS113', 'C109', 'A Peoples History of the United States', '2024-03-17', '978-0-393-05081-8', 'E106'),
('IS114', 'C109', 'The Guns of August', '2024-03-18', '978-0-19-280551-1', 'E106'),
('IS115', 'C109', 'The Histories', '2024-03-19', '978-0-14-044930-3', 'E107'),
('IS116', 'C110', 'Guns, Germs, and Steel: The Fates of Human Societies', '2024-03-20', '978-0-393-91257-8', 'E107'),
('IS117', 'C110', '1984', '2024-03-21', '978-0-679-64115-3', 'E107'),
('IS118', 'C101', 'Pride and Prejudice', '2024-03-22', '978-0-14-143951-8', 'E108'),
('IS119', 'C110', 'Brave New World', '2024-03-23', '978-0-452-28240-7', 'E108'),
('IS120', 'C110', 'The Road', '2024-03-24', '978-0-670-81302-4', 'E108'),
('IS121', 'C102', 'The Shining', '2024-03-25', '978-0-385-33312-0', 'E109'),
('IS122', 'C102', 'Fahrenheit 451', '2024-03-26', '978-0-451-52993-5', 'E109'),
('IS123', 'C103', 'Dune', '2024-03-27', '978-0-345-39180-3', 'E109'),
('IS124', 'C104', 'Where the Wild Things Are', '2024-03-28', '978-0-06-025492-6', 'E110'),
('IS125', 'C105', 'The Kite Runner', '2024-03-29', '978-0-06-112241-5', 'E110'),
('IS126', 'C105', 'Charlotte''s Web', '2024-03-30', '978-0-06-440055-8', 'E110'),
('IS127', 'C105', 'Beloved', '2024-03-31', '978-0-679-77644-3', 'E110'),
('IS128', 'C105', 'A Tale of Two Cities', '2024-04-01', '978-0-14-027526-3', 'E110'),
('IS129', 'C105', 'The Stand', '2024-04-02', '978-0-7434-7679-3', 'E110'),
('IS130', 'C106', 'Moby Dick', '2024-04-03', '978-0-451-52994-2', 'E101'),
('IS131', 'C106', 'To Kill a Mockingbird', '2024-04-04', '978-0-06-112008-4', 'E101'),
('IS132', 'C106', 'The Hobbit', '2024-04-05', '978-0-7432-7356-4', 'E106'),
('IS133', 'C107', 'Angels & Demons', '2024-04-06', '978-0-7432-4722-5', 'E106'),
('IS134', 'C107', 'The Diary of a Young Girl', '2024-04-07', '978-0-375-41398-8', 'E106'),
('IS135', 'C107', 'Sapiens: A Brief History of Humankind', '2024-04-08', '978-0-307-58837-1', 'E108'),
('IS136', 'C107', '1491: New Revelations of the Americas Before Columbus', '2024-04-09', '978-0-7432-7357-1', 'E102'),
('IS137', 'C107', 'The Catcher in the Rye', '2024-04-10', '978-0-553-29698-2', 'E103'),
('IS138', 'C108', 'The Great Gatsby', '2024-04-11', '978-0-525-47535-5', 'E104'),
('IS139', 'C109', 'Harry Potter and the Sorcerers Stone', '2024-04-12', '978-0-679-76489-8', 'E105'),
('IS140', 'C110', 'Animal Farm', '2024-04-13', '978-0-330-25864-8', 'E102');
SELECT * FROM issued_status;

-- inserting into return table
INSERT INTO return_status(return_id, issued_id, return_date) 
VALUES
('RS104', 'IS106', '2024-05-01'),
('RS105', 'IS107', '2024-05-03'),
('RS106', 'IS108', '2024-05-05'),
('RS107', 'IS109', '2024-05-07'),
('RS108', 'IS110', '2024-05-09'),
('RS109', 'IS111', '2024-05-11'),
('RS110', 'IS112', '2024-05-13'),
('RS111', 'IS113', '2024-05-15'),
('RS112', 'IS114', '2024-05-17'),
('RS113', 'IS115', '2024-05-19'),
('RS114', 'IS116', '2024-05-21'),
('RS115', 'IS117', '2024-05-23'),
('RS116', 'IS118', '2024-05-25'),
('RS117', 'IS119', '2024-05-27'),
('RS118', 'IS120', '2024-05-29');
SELECT * FROM return_status;

-- Project tasks

SELECT * FROM members;
SELECT * FROM branch;
SELECT * FROM employees;
SELECT * FROM books;
SELECT * FROM issued_status;
SELECT * FROM return_status;

/* Task 1. Create a New Book Record
"978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')" */
insert into books 
values (
	'978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.'
);

-- Task 2: Update an Existing Member's Address
select *
from members;

update members
set member_address = '142 main st'
where member_id = 'C101';

--Task 3: Delete a Record from the Issued Status Table
--Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

delete from issued_status
where issued_id = 'IS121';
select *
from issued_status;

--Task 4: Retrieve All Books Issued by a Specific Employee
-- Objective: Select all books issued by the employee with emp_id = 'E101'.

SELECT *
FROM Employees e
LEFT JOIN issued_status i
ON e.emp_id = i.issued_emp_id
WHERE e.emp_id = 'E101';


-- Task 3: Delete a Record from the Issued Status Table
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

delete from issued_status
where issued_id = 'IS121';

-- Task 4: Retrieve All Books Issued by a Specific Employee
-- Objective: Select all books issued by the employee with emp_id = 'E101'.

select *
from issued_status
where issued_emp_id = 'E101';

-- Task 5: List Members Who Have Issued More Than One Book 
-- Objective: Use GROUP BY to find members who have issued more than one book.

select *
from
	( select 
		issued_emp_id,
		count(*) as total_books_issued
	from issued_status
	group by issued_emp_id
	) as t1
where total_books_issued > 1;

-- CTAS (Create Table As Select)
-- Task 6: Create Summary Tables: Use CTAS to generate new tables based on query results 
-- each book and total book_issued_cnt**

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

-- Task 7. Retrieve All Books in a Specific Category:

select *
from books
where category = 'Classic';


select 
category,
count(*)
from books
group by category;

-- Task 8: Find Total Rental Income by Category:

select 
	b.category,
	sum(b.rental_price),
	count(*) 
from books b
join issued_status i
	on b.isbn = i.issued_book_isbn
group by 1;

-- Task 9: List Members Who Registered in the Last 800 Days:
select *
from members
where reg_date >= current_date - interval '800 days';

-- Task 10: List Employees with Their Branch Manager's Name and their branch details:

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

-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold 5$:
create table expensive_books as
	select *
	from books
	where rental_price >= 5;

-- Task 12: Retrieve the List of Books Not Yet Returned:
SELECT * FROM issued_status as ist
LEFT JOIN
return_status as rs
ON rs.issued_id = ist.issued_id
WHERE rs.return_id IS NULL;

-- ADVANCED QUERIES

-- INSERT INTO book_issued in last 30 days
-- SELECT * from employees;
-- SELECT * from books;
-- SELECT * from members;
-- SELECT * from issued_status
-- SELECT * from return_status


INSERT INTO issued_status(issued_id, issued_member_id, issued_book_name, issued_date, issued_book_isbn, issued_emp_id)
VALUES
('IS151', 'C118', 'The Catcher in the Rye', CURRENT_DATE - INTERVAL '24 days',  '978-0-553-29698-2', 'E108'),
('IS152', 'C119', 'The Catcher in the Rye', CURRENT_DATE - INTERVAL '13 days',  '978-0-553-29698-2', 'E109'),
('IS153', 'C106', 'Pride and Prejudice', CURRENT_DATE - INTERVAL '7 days',  '978-0-14-143951-8', 'E107'),
('IS154', 'C105', 'The Road', CURRENT_DATE - INTERVAL '32 days',  '978-0-375-50167-0', 'E101');

-- Adding new column in return_status

ALTER TABLE return_status
ADD Column book_quality VARCHAR(15) DEFAULT('Good');

UPDATE return_status
SET book_quality = 'Damaged'
WHERE issued_id 
    IN ('IS112', 'IS117', 'IS118');
SELECT * FROM return_status;


/* Task 13: Identify Members with Overdue Books
   Write a query to identify members who have overdue books (assume a 30-day return period).
   Display the member's_id, member's name, book title, issue date, and days overdue.*/

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

/* Task 14: Update Book Status on Return
Write a query to update the status of books in the books 
table to "Yes" when they are returned (based on entries in the return_status table). */
/*
 	POSTGRES STORED PROCEDURE CHEAT SHEET
		CREATE OR REPLACE PROCEDURE name(params)
		LANGUAGE plpgsql
		AS $$
		BEGIN
		    -- logic
		END;
		$$;
*/


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

update books 
set status = 'yes'
where status = 'true';

/*Task 15: Branch Performance Report
Create a query that generates a performance report for each branch,
showing the number of books issued, the number of books returned,
and the total revenue generated from book rentals.*/
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

select * from branch_report

/* Task 16: CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to create a new table
active_members containing members who have issued at least one book in the last 2 months.*/


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

/*
	Task 17: Find Employees with the Most Book Issues Processed
	Write a query to find the top 3 employees who have processed the most book issues.
	Display the employee name, number of books processed, and their branch.
*/

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

/*
	Task 18: Identify Members Issuing High-Risk Books
	Write a query to identify members who have issued books with the status "damaged" in the books table. 
	Display the member name, book title, and the number of times they've issued damaged books.
*/

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

select *
from books

/*
	Task 19: Stored Procedure Objective: Create a stored procedure to manage the status 
	of books in a library system. 
	
	Description: Write a stored procedure that updates the 
	status of a book in the library based on its issuance. 
	
	The procedure should function as follows: The stored procedure should take the book_id as an input parameter. 
	The procedure should first check if the book is available (status = 'yes'). If the book is available,
	it should be issued, and the status in the books table should be updated to 'no'. 
	If the book is not available (status = 'no'), the procedure should return an error message indicating
	that the book is currently not available.
*/
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

/* Task 20: Create Table As Select (CTAS) Objective: 
	Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.

Description: Write a CTAS query to create a new table that lists each 
member and the books they have issued but not returned within 30 days.
The table should include: The number of overdue books. The total fines, 
with each day's fine calculated at $0.50. The number of books issued by each member. 
The resulting table should show: Member ID Number of overdue books Total fines */

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

