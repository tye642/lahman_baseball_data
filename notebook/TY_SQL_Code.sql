/*
Q1. What range of years for baseball games played does the provided database cover?
1871-2016
*/

SELECT MIN(yearid) as EarliestYear, MAX(yearid) as LatestYear
FROM appearances;

/*
***Q2. Find the name and height of the shortest player in the database. 
"Eddie Gaedel" is the shortest. I used limit 3 in case there were a tie for the shortest player
*/

SELECT namefirst, namelast, height
FROM people
WHERE height IS NOT NULL
ORDER BY height ASC
LIMIT 3;

/*
***Q2a. How many games did he play in? What is the name of the team for which he played? 
Breaking this question down, let's find his playerid. Join his ID to the 'appearances' table to find how many games he played.
To find his team, use the teamid from appearances and join it to 'teams' to find the name.
*/

-- Reusing some of my code from before, this returns the playerid for the shortest player. 
SELECT playerid
FROM people
WHERE height IS NOT NULL
ORDER BY height
LIMIT 1;
 

SELECT  p.namefirst, 		-- This returns the player's name, team name, and number of games played. 
		p.namelast, 
		t.name, 
		COUNT(*) as numgames
FROM appearances as a 		-- It uses the 'appearances' table for the number of games
JOIN people as p 			-- 'people' table for the playerid, name, and height
	ON a.playerid = p.playerid
JOIN teams as t 			-- 'teams' table for the team name. All joined together
	ON a.teamid = t.teamid
							-- The WHERE clause is used to show only the shortest player's info
WHERE a.playerid IN (SELECT playerid 
					 FROM people
					 WHERE height IS NOT NULL
					 ORDER BY height
					 LIMIT 1
					)
GROUP BY p.namefirst, p.namelast, t.name

/*
Q3. Find all players in the database who played at Vanderbilt University.
Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. 
Sort this list in descending order by the total salary earned.
Which Vanderbilt player earned the most money in the majors? 'David Price'
*/

SELECT CONCAT(p.namefirst, ' ',p.namelast) AS full_name, SUM(s.salary) AS total_salary
FROM (SELECT DISTINCT playerid, schoolname 
	  FROM collegeplaying
	  JOIN schools
	  USING (schoolid)
	  WHERE schoolname = 'Vanderbilt University'
	 ) AS c
JOIN people AS p
USING (playerid)
JOIN salaries AS s
USING (playerid)
GROUP BY full_name
ORDER BY total_salary DESC;

/*
***Q4. Using the fielding table, group players into three groups based on their position: 
label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", 
and those with position "P" or "C" as "Battery". 
Determine the number of putouts made by each of these three groups in 2016.
*/

-- Will need to use CASE WHEN for this question.

SELECT  CASE
			WHEN pos = 'OF' THEN 'Outfield'
			WHEN pos IN ('SS','1B','2B','3B') THEN 'Infield'
			WHEN pos IN ('P','C') THEN 'Battery'
			END AS pos_groups,
		SUM(po) AS num_putouts
FROM fielding
WHERE yearid = 2016
GROUP by pos_groups;

/*
***Q5. Find the average number of strikeouts per game by decade since 1920. 
Round the numbers you report to 2 decimal places. 
Do the same for home runs per game. Do you see any trends?
*/

-- Will need to use aggregate and a group by. Wrapped in a round function.

SELECT *
FROM pitching

SELECT 	FLOOR(yearid/10)*10 AS decade, --This floor function takes any year divided by 10 and rounds down. Then multiplies to get the decade. EX. 1936/10=193.6, the floor would be 193. Then multiple by 10, you get 1930 which is the decade. 
		ROUND(SUM(CAST(so AS numeric(100,2)))/SUM(CAST(g AS numeric(100,2))),2) AS avg_strikeout, -- To get the average of strikeouts per game, divide SUM of 'so' by SUM of 'g'. I casted them as numeric for the rounding function to work. 
		ROUND(SUM(CAST(hr AS numeric(100,2)))/SUM(CAST(g AS numeric(100,2))),2) AS avg_homerun
FROM pitching
WHERE yearid >= 1920
GROUP BY decade
ORDER by decade;

/*
Q6. Find the player who had the most success stealing bases in 2016, 
where success is measured as the percentage of stolen base attempts which are successful. 
(A stolen base attempt results either in a stolen base or being caught stealing.) 
Consider only players who attempted at least 20 stolen bases.
*/

SELECT *
FROM batting

SELECT  playerid,
		ROUND((SUM(CAST(sb AS numeric(100,2))))/(SUM(CAST(sb AS numeric(100,2)))+SUM(CAST(cs AS numeric(100,2))))*100,2) AS perc_stolen
FROM batting
WHERE yearid = 2016 AND sb >= 20
GROUP BY playerid
ORDER BY perc_stolen DESC

-- Same as Q5, needed to cast to numeric as originally the date type is int. This cause issues when dividing.

/*
Q7. From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? 
What is the smallest number of wins for a team that did win the world series? 
Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. 
Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? 
What percentage of the time?
*/
















--Q9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.

/*
Let's break this one down. What do I need first? Let's find the Manager of the Year awards. 
*/

--This will UNION all the managers that have gotten the TSN award, first with the NL and then with AL. I think I will need to use a inner join to find managers that won both. 
SELECT *
FROM (
	SELECT *
	FROM awardsmanagers
	WHERE lgid = 'NL' AND awardid = 'TSN Manager of the Year'
	UNION ALL
	SELECT *
	FROM awardsmanagers
	WHERE lgid = 'AL' AND awardid = 'TSN Manager of the Year') sub
;

/*
I will use a CTE to define a table for TSN winners for the NL, and another CTE for TSN winners for AL.
Let's try an INNER JOIN. 
This gives me a list of managers that have won both TSN awards in the NL and the AL. 
I will add a LEFT JOIN to include the manager's full name. I will CONCAT their first name and their last name.
*/

WITH NL AS (
	SELECT *
	FROM awardsmanagers
	WHERE lgid = 'NL' AND awardid = 'TSN Manager of the Year'),
	
	AL AS (
	SELECT *
	FROM awardsmanagers
	WHERE lgid = 'AL' AND awardid = 'TSN Manager of the Year')

SELECT NL.playerid, CONCAT(p.namefirst, ' ', p.namelast) AS manager_name, NL.yearid AS TSN_NL_year, AL.yearid AS TSN_AL_year
FROM NL
INNER JOIN AL
USING (playerid)
LEFT JOIN people AS p
USING (playerid)
;

/*
Now I need the teams they were on during those winning years. Tough. Stuck.
Let's try this with subqueries
Top portion finds all of the NL TSN and bottom finds all the AL. Subqueries limit only to coaches that have won both. 
*/

SELECT DISTINCT NL.playerid, CONCAT(p.namefirst, ' ', p.namelast) AS manager_name, nl.yearid AS year, m.teamid, t.name, 'NL' AS league
FROM (
	SELECT *
	FROM awardsmanagers
	WHERE lgid = 'NL' AND awardid = 'TSN Manager of the Year') AS NL
INNER JOIN (
	SELECT *
	FROM awardsmanagers
	WHERE lgid = 'AL' AND awardid = 'TSN Manager of the Year') AS AL
USING (playerid)
LEFT JOIN people AS p
USING (playerid)
LEFT JOIN managers AS m
ON nl.playerid = m.playerid AND nl.yearid = m.yearid
LEFT JOIN teams AS t
ON m.teamid = t.teamid AND nl.yearid = t.yearid
UNION
SELECT DISTINCT AL.playerid, CONCAT(p.namefirst, ' ', p.namelast) AS manager_name, AL.yearid AS year, m.teamid, t.name, 'AL' AS league
FROM (
	SELECT *
	FROM awardsmanagers
	WHERE lgid = 'NL' AND awardid = 'TSN Manager of the Year') AS NL
INNER JOIN (
	SELECT *
	FROM awardsmanagers
	WHERE lgid = 'AL' AND awardid = 'TSN Manager of the Year') AS AL
USING (playerid)
LEFT JOIN people AS p
USING (playerid)
LEFT JOIN managers AS m
ON al.playerid = m.playerid AND al.yearid = m.yearid
LEFT JOIN teams AS t
ON m.teamid = t.teamid AND al.yearid = t.yearid
ORDER BY league
; 

/*
Q11. Is there any correlation between number of wins and team salary? 
Use data from 2000 and later to answer this question.
As you do this analysis, keep in mind that salaries across the whole league tend to increase together, so you may want to look on a year-by-year basis.
*/

--This gives me a teams yearly wins starting in year 2000.
SELECT teamid, yearid, SUM(w) AS wins_year
FROM teams
WHERE yearid >= 2000
GROUP BY teamid, yearid
ORDER BY teamid, yearid;

--This gives me the yearly salary starting in the year 2000
SELECT teamid, yearid, SUM(salary) AS yearly_salary
FROM salaries
WHERE yearid >= 2000
GROUP BY teamid, yearid
ORDER BY teamid, yearid;

--Let's join them. Added a column for salary per win to help analyze the data. 
SELECT t.teamid, t.yearid, SUM(t.w) AS wins_year, CONCAT(ROUND(CAST(s.yearly_salary/1000000.00 AS numeric),2), 'M') AS salary_mil, ROUND(CAST(s.yearly_salary/1000000 AS numeric)/SUM(t.w),2) AS salary_mil_per_win
FROM teams AS t
LEFT JOIN (
	SELECT teamid, yearid, SUM(salary) AS yearly_salary
	FROM salaries
	WHERE yearid >= 2000
	GROUP BY teamid, yearid
	ORDER BY teamid, yearid) AS s
ON t.teamid = s.teamid AND t.yearid = s.yearid
WHERE t.yearid >= 2000
GROUP BY t.teamid, t.yearid, s.yearly_salary
ORDER BY t.teamid, t.yearid;
--I can also order by wins or the salary per win column to help conceptulize it.









