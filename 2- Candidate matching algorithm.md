# Project - Candidate matching algorithm

## 1. Core Matching Score

The core matching score is calculated based on various factors, each with a specific weight to reflect its importance. These factors include work type compatibility, position match, technology alignment, industry similarity, time sensitivity, and skill rarity.

### 1.1 Work Type Compatibility (Weight: 25%)

- Hours per week compatibility
- Contract duration match

```sql
SELECT
    CASE
        WHEN ua.hours_per_week >= c.hours_per_week THEN 1
        WHEN ua.hours_per_week >= c.hours_per_week * 0.75 THEN 0.5
        ELSE 0
    END AS work_type_score
FROM user_account ua
JOIN application a ON a.user_id = ua.id
JOIN project p ON p.id = a.project_id
JOIN contract c ON c.id = p.contract_id
WHERE p.id = {project_id} AND ua.id = {user_id};
```

### 1.2 Position Match Score (Weight: 30%)

\*\*\* I assume that each specialization(be-fe-fullstack) has its own seniority level for the position.

Experience Level Mapping

- Junior: 0-2 years (level 1)
- Mid: 2-3 years (level 2)
- Mid+: 3-5 years (level 3)
- Senior: 5+ years (level 4)

```sql
SELECT
    CASE
        -- Exact match or one level higher
        WHEN us.experience_level = p.experience_level OR us.experience_level = p.experience_level + 1 THEN 1.0
        -- Candidate is two levels higher than required
        WHEN us.experience_level = p.experience_level + 2 THEN 0.75
        -- Candidate is one level below the required level
        WHEN us.experience_level = p.experience_level - 1 THEN 0.5
        -- Candidate is either significantly under qualified or too overqualified (3 levels difference)
        ELSE 0.0
    END AS position_score
FROM user_specialization us
JOIN position p ON p.specialization_type = us.specialization_type
JOIN application a ON a.user_id = us.user_id
WHERE a.project_id = {project_id} AND us.user_id = {user_id};
```

### 1.3 Technology Match Score (Weight: 25%)

\*\*\* I assume that each position(specialization) has its own/separate technologies with already defined synonyms.

```json
{
  "frontend": {
    "primary": ["TypeScript", "React"],
    "synonyms": ["TS", "HTML", "CSS", "JavaScript", "JS", "ReactJs"]
  },
  "backend": {
    "primary": ["Spring", "Node.js"],
    "synonyms": ["Spring Boot", "java", "Node", "Express"]
  }
}
```

```sql
-- CTE to get the user's technologies and experience levels
WITH user_tech AS (
    SELECT
        ut.technology_id,
        ut.experience_level AS user_experience_level,
        t.name
    FROM user_technology ut
    JOIN technology t ON t.id = ut.technology_id
    WHERE ut.user_id = {user_id}
),
-- CTE to get the position's required technologies, experience levels, and synonyms (if any)
position_tech AS (
    SELECT
        pt.technology_id,
        pt.experience_level AS required_experience_level,
        t.name AS primary_name,
        s.name AS synonym_name
    FROM position_technology pt
    JOIN technology t ON t.id = pt.technology_id
    LEFT JOIN synonyms s ON s.technology_id = pt.technology_id
    WHERE pt.position_id = {position_id}
)

SELECT
    -- Calculate the percentage of required technologies that the user has
    (CAST(COUNT(DISTINCT ut.technology_id) AS FLOAT) / NULLIF(COUNT(DISTINCT pt.technology_id), 0)) *

    -- Calculate the average experience level for the matching technologies
    (SELECT AVG(ut2.user_experience_level)
     FROM user_tech ut2
     WHERE ut2.user_experience_level >= pt.required_experience_level) / 10.0 AS tech_score  -- Normalize by dividing by 10

FROM position_tech pt
LEFT JOIN user_tech ut
    ON (ut.technology_id = pt.technology_id OR ut.name = pt.synonym_name)  -- Match on technology ID or synonym name
    AND ut.user_experience_level >= pt.required_experience_level           -- Ensure user's experience level meets or exceeds the required level
```

### 1.4 Industry Similarity Score (Weight: 10%)

- Measures how closely the candidate’s past industries align with the job’s industry.

```sql
WITH user_industries AS (
    SELECT DISTINCT industry
    FROM experience
    WHERE user_id = {user_id}
)
SELECT
    CASE
        -- Exact match
        WHEN p.industry = ui.industry THEN 1.0
        -- Partial match
        WHEN p.industry LIKE ui.industry || '%' THEN 0.5
        -- No match
        ELSE 0
    END AS industry_score
FROM project p
LEFT JOIN user_industries ui ON p.industry = ui.industry OR p.industry LIKE ui.industry || '%'
WHERE p.id = {project_id}
LIMIT 1;
```

### 1.5 Time Sensitivity (Weight: 10%)

Gives higher scores to more recent or urgent job postings.

Priority Level mapping

- Low Priority: Level 1
- Medium Priority: Level 2
- High Priority: Level 3

```sql
SELECT
    CASE
        -- High priority, posted within the last week
        WHEN p.priority_level = 3 AND CURRENT_DATE - p.created_at <= 7 THEN 1.0
        -- High priority, posted within the last month
        WHEN p.priority_level = 3 AND CURRENT_DATE - p.created_at <= 30 THEN 0.8

        -- Medium priority, posted within the last week
        WHEN p.priority_level = 2 AND CURRENT_DATE - p.created_at <= 7 THEN 0.7
        -- Medium priority, posted within the last month
        WHEN p.priority_level = 2 AND CURRENT_DATE - p.created_at <= 30 THEN 0.5

        -- Low priority, posted within the last week
        WHEN p.priority_level = 1 AND CURRENT_DATE - p.created_at <= 7 THEN 0.4
        -- Low priority, posted within the last month
        WHEN p.priority_level = 1 AND CURRENT_DATE - p.created_at <= 30 THEN 0.2

        -- Older posts or posts with low priority
        ELSE 0.0
    END AS time_sensitivity_score
FROM project p
WHERE p.id = {project_id};
```

## 2. Final Score Calculation

```
    work_type_score * 0.25
    position_score  * 0.30
    tech_score      * 0.25
    industry_score  * 0.10
 +  time_urgency    * 0.10
===========================
                match_score
```

# 3. Extras

## 3.1 Admin panel

For evaluating candidates in the admin panel, additional scoring factors can be considered:

- Total Experience Score: Based on the candidate’s exp_start_date.
- User Rating: Ratings from previous jobs.
- Offer Score: Evaluates candidate’s expected hourly rate and estimated completion time.
- Skill Rarity Score: Highlights candidates with unique or less common skills.

## 3.2 A/B testing

We can implement A/B testing with different matching score algorithms to gather feedback from HR on which one performs best.

## 3.3 Performance Optimization

- We can use Materialized Views for frequently accessed queries.
- We can integrate Elasticsearch for full-text search capabilities.

## 3.4 Machine Learning Integration

- Analyze previous job applications and outcomes.
- Increase the score for candidates who were hired in similar positions.
- Decrease the score for candidates who applied to similar positions but were not considered.

So basically we can check previous job application and result to mach with the current application.

## 3.5 Potential Challenges

Currently all the positions are created static so there is no change to mismatch but in the future the platform can be expand and became a freelancer platform like fiverr and upwork. In that case we should consider some possible problems

- Keyword Misinterpretation: Avoiding matches due to keyword ambiguity (e.g., "dental assistant" vs. "assistant with dental benefits").
- Uncommon Job Titles: Many job titles are not standardized (e.g., "SWE," "PM," "Sr. ScrumMaster").

A solution would be to develop an algorithm that understands seniority, job content, and possible title variations using NLP techniques to improve matching accuracy.
