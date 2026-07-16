# 🎬 Netflix Content Analysis — SQL Project

A structured SQL project exploring the Netflix dataset to uncover insights about content distribution, ratings, genres, directors, actors, and more.

---

## 📁 Dataset Schema

```sql
CREATE TABLE netflix (
    show_id      VARCHAR(6),
    type         VARCHAR(20),
    title        VARCHAR(150),
    director     VARCHAR(230),
    casts        VARCHAR(1000),
    country      VARCHAR(150),
    date_added   VARCHAR(50),
    release_year INT,
    rating       VARCHAR(10),
    duration     VARCHAR(15),
    listed_in    VARCHAR(79),
    description  VARCHAR(250)
);
```

---

## 🧩 Business Problems & Solutions

### 1. Count the Number of Movies vs TV Shows
Aggregates content by type to understand the split between Movies and TV Shows on the platform.

---

### 2. Find the Most Common Rating for Movies and TV Shows
Uses a **CTE + RANK()** window function to identify the most frequently assigned rating for each content type.

---

### 3. List All Movies Released in a Specific Year
Filters content by type and `release_year` to retrieve all movies from a given year (e.g., 2021).

---

### 4. Find the Top 5 Countries with the Most Content
Uses `unnest(string_to_array())` to split multi-value country fields and ranks countries by total content count.

---

### 5. Identify the Longest Movie
Finds the movie with the maximum duration using a subquery on the `duration` column.

---

### 6. Find Content Added in the Last 5 Years
Converts the `date_added` string column to a proper date using `to_date()` and filters with an interval comparison.

---

### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'
Uses `LIKE` pattern matching on the `director` column to handle cases where multiple directors are listed.

---

### 8. List All TV Shows with More Than 5 Seasons
Uses `split_part()` to extract the numeric season count from the `duration` field and casts it for comparison.

---

### 9. Count the Number of Content Items in Each Genre
Uses `unnest(string_to_array())` to split comma-separated genres in `listed_in` and counts each genre individually.

---

### 10. Average Content Released per Year in India
Uses `to_date()` with `EXTRACT(YEAR)` to group Indian content by year, and calculates each year's share as a percentage of total Indian content.

---

### 11. List All Movies that are Documentaries
Filters the `listed_in` column using `LIKE` to find all documentary content.

---

### 12. Find All Content Without a Director
Retrieves all rows where the `director` field is `NULL`.

---

### 13. Movies Actor 'Salman Khan' Appeared in (Last 10 Years)
Filters the `casts` column with `LIKE` and compares `release_year` against a dynamic 10-year window using `EXTRACT(YEAR FROM current_date)`.

---

### 14. Top 10 Actors in Indian Movies
Splits the `casts` column using `unnest(string_to_array())` to count individual actor appearances in Indian movies, ranked by frequency.

---

### 15. Categorize Content by 'Kill' and 'Violence' Keywords
Uses a **CTE + CASE WHEN** with `ILIKE` to label content descriptions as `'Bad'` (contains kill/violence) or `'Good'`, then aggregates the counts.

---

## 🛠️ Key SQL Concepts Used

| Concept | Used In |
|---|---|
| `GROUP BY` + `COUNT` | Q1, Q3, Q9, Q14 |
| Window Functions (`RANK`, `AVG OVER`) | Q2, Q10 |
| CTEs (`WITH`) | Q2, Q15 |
| `unnest` + `string_to_array` | Q4, Q9, Q14 |
| `split_part` | Q8 |
| `to_date` + `INTERVAL` | Q6, Q10 |
| `EXTRACT` | Q10, Q13 |
| `ILIKE` / `LIKE` | Q7, Q11, Q13, Q15 |
| Subqueries | Q5, Q10 |
| `CASE WHEN` | Q15 |
| `IS NULL` | Q12 |

---

## ⚙️ How to Run

1. Create the database and table using the schema above
2. Import the Netflix dataset (CSV) into the `netflix` table
3. Run any query from the `Netflix_P4.sql` file

> **Note:** The `date_added` column is stored as `VARCHAR`. Use `to_date(date_added, 'DD-Mon-YY')` for date operations. If your data was imported differently, a `CASE WHEN ... LIKE '%-%'` format check may be needed.

---

## 📌 Notes

- Multi-value fields like `country`, `casts`, and `listed_in` store comma-separated values — `unnest` + `string_to_array` is used to normalize them for analysis
- `release_year` is stored as `INT`, so avoid using `INTERVAL` directly on it — use arithmetic instead (e.g., `release_year >= EXTRACT(YEAR FROM current_date) - 10`)
