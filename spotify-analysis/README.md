# 🎵 Spotify Tracks SQL Analysis

## Project Overview

This project explores a Spotify + YouTube dataset using PostgreSQL to uncover insights about track performance, audio features, and platform engagement. The dataset combines Spotify audio features with YouTube metrics for over 20,000 tracks across 2,000+ artists.

---

## Dataset

| Property | Detail |
|----------|--------|
| Source | Spotify + YouTube combined dataset |
| Rows | 20,594 |
| Columns | 24 |
| Unique Artists | 2,074 |
| Unique Tracks | 17,717 |

### Schema

```sql
CREATE TABLE spotify (
    Artist          VARCHAR,
    Track           VARCHAR,
    Album           VARCHAR,
    Album_type      VARCHAR,        -- album / single / compilation
    Danceability    FLOAT,
    Energy          FLOAT,
    Loudness        FLOAT,
    Speechiness     FLOAT,
    Acousticness    FLOAT,
    Instrumentalness FLOAT,
    Liveness        FLOAT,
    Valence         FLOAT,
    Tempo           FLOAT,
    Duration_min    FLOAT,
    Title           VARCHAR,
    Channel         VARCHAR,
    Views           BIGINT,
    Likes           BIGINT,
    Comments        BIGINT,
    Licensed        BOOLEAN,
    official_video  BOOLEAN,
    Stream          BIGINT,
    EnergyLiveness  FLOAT,
    most_played_on  VARCHAR         -- Spotify / Youtube
);
```

---

## Business Problems & SQL Solutions

### 🟢 Easy Level

---

**1. Retrieve the names of all tracks that have more than 1 billion streams.**

```sql
SELECT Track
FROM spotify
WHERE Stream > 1000000000;
```

---

**2. List all albums along with their respective artists.**

```sql
SELECT DISTINCT
    Album,
    Artist
FROM spotify;
```

> `DISTINCT` is applied to return unique album-artist pairs, since multiple tracks per album exist in the dataset.

---

**3. Get the total number of comments for tracks where `licensed = TRUE`.**

```sql
SELECT
    SUM(Comments) AS total_comments
FROM spotify
WHERE Licensed = TRUE;
```

> `SUM` is used instead of `COUNT` — `COUNT` would count rows, not total the comment numbers.

---

**4. Find all tracks that belong to the album type `single`.**

```sql
SELECT
    Track,
    Album_type
FROM spotify
WHERE Album_type = 'single'
ORDER BY 1;
```

---

**5. Count the total number of tracks by each artist.**

```sql
SELECT
    Artist,
    COUNT(Track) AS total_tracks
FROM spotify
GROUP BY 1
ORDER BY 2 DESC;
```

---

### 🟡 Medium Level

---

**6. Calculate the average danceability of tracks in each album.**

```sql
SELECT
    Album,
    AVG(Danceability) AS avg_danceability
FROM spotify
GROUP BY 1
ORDER BY 2 DESC;
```

---

**7. Find the top 5 tracks with the highest energy values.**

```sql
SELECT
    Track,
    Energy
FROM spotify
ORDER BY 2 DESC
LIMIT 5;
```

---

**8. List all tracks along with their views and likes where `official_video = TRUE`.**

```sql
SELECT DISTINCT
    Track,
    Views,
    Likes
FROM spotify
WHERE official_video = TRUE
ORDER BY Views DESC;
```

> `DISTINCT` is applied because the dataset contains duplicate track entries. Without it, the same track can appear multiple times inflating results.

---

**9. Retrieve the track names that have been streamed on Spotify more than YouTube.**

```sql
SELECT Track
FROM (
    SELECT
        Track,
        COALESCE(SUM(CASE WHEN most_played_on = 'Youtube' THEN Stream END), 0) AS streamed_on_youtube,
        COALESCE(SUM(CASE WHEN most_played_on = 'Spotify' THEN Stream END), 0) AS streamed_on_spotify
    FROM spotify
    GROUP BY 1
) AS t1
WHERE streamed_on_spotify > streamed_on_youtube;
```

> A `CASE WHEN` pivot inside a subquery separates streams by platform per track. `COALESCE(..., 0)` handles tracks that have no streams on one platform — without it, NULL comparisons would silently drop those rows from results.

---

**10. Find the top 3 most-viewed tracks for each artist using window functions.**

```sql
SELECT
    Artist,
    Track,
    rnk
FROM (
    SELECT
        Artist,
        Track,
        ROW_NUMBER() OVER(PARTITION BY Artist ORDER BY Views DESC) AS rnk
    FROM spotify
) AS ranked_tracks
WHERE rnk < 4;
```

> `ROW_NUMBER()` with `PARTITION BY Artist` resets the ranking for each artist. `ROW_NUMBER` is used over `RANK` to guarantee exactly 3 results per artist — `RANK` would allow ties to produce more than 3 rows.

---

**11. Write a query to find tracks where the liveness score is above the average.**

```sql
SELECT
    Track,
    Liveness
FROM spotify
WHERE Liveness > (SELECT AVG(Liveness) FROM spotify);
```

> The subquery returns a single scalar value — the overall average liveness — which is then used as a dynamic filter threshold.

---

**12. Use a `WITH` clause to calculate the difference between the highest and lowest energy values for tracks in each album.**

```sql
WITH energy_levels AS (
    SELECT
        Album,
        MAX(Energy) AS maximum_energy,
        MIN(Energy) AS minimum_energy
    FROM spotify
    GROUP BY 1
)
SELECT
    Album,
    ROUND((maximum_energy - minimum_energy)::NUMERIC, 2) AS energy_range
FROM energy_levels
ORDER BY 1;
```

> The `::NUMERIC` cast is required for `ROUND()` in PostgreSQL — the function does not accept `FLOAT` directly.

---

**13. Find tracks where the energy-to-liveness ratio is greater than 1.2.**

```sql
SELECT
    Track,
    Energy,
    Liveness,
    ROUND((Energy / Liveness)::NUMERIC, 2) AS energy_liveness_ratio
FROM spotify
WHERE Liveness > 0
    AND (Energy / Liveness) > 1.2;
```

> `Liveness > 0` guards against division by zero. A ratio greater than 1.2 means a track's energy is at least 1.2× its liveness score.

---

**14. Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.**

```sql
SELECT
    Track,
    Views,
    Likes,
    SUM(Likes) OVER (ORDER BY Views DESC, Track) AS cumulative_likes
FROM spotify
ORDER BY Views DESC;
```

> No `PARTITION BY` is used — the cumulative sum runs across all tracks globally. `Track` is added as a tiebreaker in `ORDER BY` to ensure deterministic ordering where multiple tracks share the same view count.
>
> **Key insight:** cumulative likes grow slowly for low-view tracks and accelerate sharply for high-view tracks, confirming a strong correlation between views and engagement.

---

## Key Learnings

- **`COUNT` vs `SUM`** — `COUNT` counts rows; `SUM` totals values. Always check which the question is asking for.
- **`DISTINCT` on combinations** — `DISTINCT` applies to the full row of selected columns, not individual columns. If duplicate tracks differ in views or likes, both rows still appear.
- **Boolean filters** — PostgreSQL boolean columns use `TRUE`/`FALSE` directly, not string `'True'`.
- **`COALESCE` for null safety** — conditional aggregation with `CASE WHEN` produces NULLs for unmatched rows. Wrapping with `COALESCE(..., 0)` prevents NULL comparison failures.
- **`ROW_NUMBER` vs `RANK`** — `ROW_NUMBER` guarantees exactly N rows per partition; `RANK` allows ties to produce more rows than expected.
- **`ROUND()` requires `::NUMERIC`** — PostgreSQL's `ROUND()` does not accept `FLOAT`/`DOUBLE PRECISION` directly; always cast first.
- **Subquery aliases** — PostgreSQL requires every subquery to have an alias, even when the outer query doesn't reference it by name.
- **Debugging window functions** — unexpected results are often a data issue, not a query issue. Always inspect the underlying rows before assuming the logic is wrong.

---

## Tools Used

- **PostgreSQL** — query engine
- **pgAdmin** — query interface
- **Python / Pandas** — data preprocessing
- **GitHub** — project documentation
