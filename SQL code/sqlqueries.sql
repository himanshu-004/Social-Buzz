SELECT * FROM contents

SELECT * FROM reactions
WHERE user_id IS NULL AND type IS NULL
-- 980 records

DELETE FROM reactions
WHERE user_id IS NULL AND type IS NULL
-- deleting null user_id and also type

SELECT user_id, name, email, count(*) FROM users
GROUP BY user_id, name, email
HAVING count(*) > 1
-- no dublicates in users

-- Left joining the content and reactions using with clause finding the top 5 category
WITH social_buzz as ( 
SELECT DISTINCT r.content_id, r.user_id, category, 
c.type as content_type, r.type as reaction_type,
DATE(r.datetime)as date, r.datetime::timestamp::time as time
FROM reactions r
LEFT JOIN content c ON r.content_id = c.content_id
),

-- calculating scores for each reaction type
scores as (
SELECT *, CASE
     WHEN reaction_type = 'heart' THEN 60 
     WHEN reaction_type = 'want' THEN 70 
     WHEN reaction_type = 'disgust' THEN 0 
     WHEN reaction_type = 'hate' THEN 5 
	 WHEN reaction_type = 'interested' THEN 30 
	 WHEN reaction_type = 'indifferent' THEN 20 
	 WHEN reaction_type = 'love' THEN 65 
	 WHEN reaction_type = 'super love' THEN 75 
	 WHEN reaction_type = 'cherish' THEN 70 
	 WHEN reaction_type = 'adore' THEN 72 
	 WHEN reaction_type = 'like' THEN 50 
	 WHEN reaction_type = 'dislike' THEN 10 
	 WHEN reaction_type = 'intrigued' THEN 45 
	 WHEN reaction_type = 'peeking' THEN 35 
	 WHEN reaction_type = 'scared' THEN 15 
	 WHEN reaction_type = 'worried' THEN 12 
	 ELSE 0 END as score
	 FROM social_buzz
)
-- Top 5 category
SELECT category, SUM(score) as sum_score FROM scores
	GROUP BY category
	ORDER BY sum_score DESC
	LIMIT 5

-- finding what percentile each catogery scores comparing to other categories.
SELECT category, 
-- percent_rank() OVER(ORDER BY sum_score) as percentage,
round(percent_rank() OVER(ORDER BY sum_score)::numeric * 100 , 2) as per
from top_5

-- count of post for each category.
SELECT category, COUNT(*) FROM content c
JOIN reactions r
ON c.content_id = r.content_id
GROUP BY category
ORDER BY COUNT(*) DESC