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
--------------------------------------------------------------------------------------------------

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
--------------------------------------------------------------------------------------------------

/*
***Q5. Find the average number of strikeouts per game by decade since 1920. 
Round the numbers you report to 2 decimal places. 
Do the same for home runs per game. Do you see any trends?
*/

-- Will need to use aggregate and a group by. Wrapped in a round function.

SELECT *
FROM pitching

SELECT 	FLOOR(yearid/10)*10 AS decade, 																--This floor function takes any year divided by 10 and rounds down. Then multiplies to get the decade. EX. 1936/10=193.6, the floor would be 193. Then multiple by 10, you get 1930 which is the decade. 
		ROUND(SUM(CAST(so AS numeric(100,2)))/SUM(CAST(g AS numeric(100,2))),2) AS avg_strikeout, 	-- To get the average of strikeouts per game, divide SUM of 'so' by SUM of 'g'. I casted them as numeric for the rounding function to work. 
		ROUND(SUM(CAST(hr AS numeric(100,2)))/SUM(CAST(g AS numeric(100,2))),2) AS avg_homerun
FROM pitching
WHERE yearid >= 1920
GROUP BY decade
ORDER by decade;
--------------------------------------------------------------------------------------------------



