CREATE database mentor;
USE mentor;
-- SQL Mentor User Performance

-- DROP TABLE user_submissions; 

CREATE TABLE user_submissions (
    id INT PRIMARY KEY AUTO_INCREMENT,  -- Unique identifier for each submission
    user_id BIGINT NOT NULL,            -- ID of the user making the submission
    question_id INT NOT NULL,           -- ID of the question being answered
    points INT DEFAULT 0,               -- Points awarded for the submission (default is 0)
    submitted_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, -- Date and time of submission
    username VARCHAR(50) NOT NULL       -- Username of the submitting user
);



SELECT * FROM user_submissions;


-- Q.1 List all distinct users and their stats (return user_name, total_submissions, points earned)
-- Q.2 Calculate the daily average points for each user.
-- Q.3 Find the top 3 users with the most positive submissions for each day.
-- Q.4 Find the top 5 users with the highest number of incorrect submissions.
-- Q.5 Find the top 10 performers for each week.


-- Please note for each questions return current stats for the users
-- user_name, total points earned, correct submissions, incorrect submissions no


-- -------------------
-- My Solutions
-- -------------------

-- Q.1 List all distinct users and their stats (return user_name, total_submissions, points earned)

-- SELECT 
-- 	COUNT(DISTINCT username)
-- FROM user_submissions


SELECT 
	username,
	COUNT(id) as total_submissions,
	SUM(points) as points_earned
FROM user_submissions
GROUP BY username
ORDER BY total_submissions DESC


-- -- Q.2 Calculate the daily average points for each user.
-- each day
-- each user and their daily avg points
-- group by day and user

SELECT * FROM user_submissions;

SELECT 
	-- EXTRACT(DAY FROM submitted_at) as day,
	TO_CHAR(submitted_at, 'DD-MM') as day,
	username,
	AVG(points) as daily_avg_points
FROM user_submissions
GROUP BY 1, 2
ORDER BY username;


-- Q.3 Find the top 3 users with the most correct submissions for each day.

-- each day
-- most correct submissions


SELECT * FROM user_submissions;



WITH daily_submissions
AS
(
	SELECT 
		-- EXTRACT(DAY FROM submitted_at) as day,
		TO_CHAR(submitted_at, 'DD-MM') as daily,
		username,
		SUM(CASE 
			WHEN points > 0 THEN 1 ELSE 0
		END) as correct_submissions
	FROM user_submissions
	GROUP BY 1, 2
),
users_rank
as
(SELECT 
	daily,
	username,
	correct_submissions,
	DENSE_RANK() OVER(PARTITION BY daily ORDER BY correct_submissions DESC) as rank
FROM daily_submissions
)

SELECT 
	daily,
	username,
	correct_submissions
FROM users_rank
WHERE rank <= 3;

-- Q.4 Find the top 5 users with the highest number of incorrect submissions.

SELECT 
	username,
	SUM(CASE 
		WHEN points < 0 THEN 1 ELSE 0
	END) as incorrect_submissions,
	SUM(CASE 
			WHEN points > 0 THEN 1 ELSE 0
		END) as correct_submissions,
	SUM(CASE 
		WHEN points < 0 THEN points ELSE 0
	END) as incorrect_submissions_points,
	SUM(CASE 
			WHEN points > 0 THEN points ELSE 0
		END) as correct_submissions_points_earned,
	SUM(points) as points_earned
FROM user_submissions
GROUP BY 1
ORDER BY incorrect_submissions DESC


-- Q.5 Find the top 10 performers for each week.


SELECT *  
FROM
(
	SELECT 
		-- WEEK()
		EXTRACT(WEEK FROM submitted_at) as week_no,
		username,
		SUM(points) as total_points_earned,
		DENSE_RANK() OVER(PARTITION BY EXTRACT(WEEK FROM submitted_at) ORDER BY SUM(points) DESC) as rank
	FROM user_submissions
	GROUP BY 1, 2
	ORDER BY week_no, total_points_earned DESC
)
WHERE rank <= 10
 -- end -- 
 