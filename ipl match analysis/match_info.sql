use ipl;
SELECT * FROM match_info;

-- Checking if any ipl match has been played outside india --
SELECT season_year,country_name, COUNT(country_name) AS Matches 
FROM match_info
WHERE country_name != 'India'
GROUP BY season_year, country_name;

-- Most matches played venue --
SELECT venue_name, city_name, country_name, COUNT(venue_name) AS Count
FROM match_info
GROUP BY venue_name, city_name, country_name
ORDER BY Count DESC ;

-- Changing different labeling for Bangalore to Bangalore --
SELECT venue_name, 
CASE
	WHEN city_name IN ('Bangalore', 'Bengaluru') THEN 'Bangalore'
	ELSE city_name
END AS city_name2, 
country_name, COUNT(venue_name) AS Count 
FROM match_info
GROUP BY venue_name, city_name2, country_name
ORDER BY Count DESC ;

-- Is there any difference between number of matches thoroughout the different season ?--
SELECT season_year, COUNT(season_year) AS Count
FROM match_info
GROUP BY season_year
ORDER BY  Count DESC ; 

-- Let's see which team has won the toss most.--
SELECT toss_winner, COUNT(toss_winner) AS Count
FROM match_info
GROUP BY toss_winner
ORDER BY Count DESC ;

/* Since the chances of winning toss increase as the number of games played by a team increase. Mumbai Indians and KKR
being at the top of the list may be because of they qualified for the knockout games more. Let's check if this is true */

WITH team_cte AS(
	SELECT team1 AS team_played
	FROM match_info
	UNION ALL
	SELECT team2 AS team_played
	FROM match_info
)
SELECT team_played, COUNT(team_played) AS Count
FROM team_cte
GROUP BY team_played
ORDER BY Count DESC ;

-- ORRRRRRRRR --
 
SELECT team_played, count(team_played) as team_count
FROM (
    SELECT team1 AS team_played
    FROM match_info
    UNION ALL
    SELECT team2 AS team_played
    FROM match_info
) AS combined_count
GROUP BY team_played
ORDER BY team_count DESC ;


-- Let's merge these two tables to calculate the toss win percentage for each team. -- 
WITH play_count AS (
	SELECT team_played, count(team_played) AS play_count
	FROM (
		SELECT team1 AS team_played
		FROM match_info
		UNION ALL
		SELECT team2 AS team_played
		FROM match_info
	) AS combined_count
	GROUP BY team_played),
toss_win_count AS (
	SELECT toss_winner, COUNT(toss_winner) AS toss_win_count
	FROM match_info
	GROUP BY toss_winner)
SELECT team_played, play_count, toss_win_count, round((toss_win_count / play_count)*100,2) as toss_win_percentage
FROM play_count AS pc
LEFT JOIN toss_win_count AS twc ON twc.toss_winner=pc.team_played
ORDER BY toss_win_percentage DESC ;

-- Analyzing the most preferred choice for an IPL captain after winning the toss. --
SELECT toss_name, count(toss_name) as Count
FROM match_info
GROUP BY toss_name;

-- What are the chances of winning match after winning the toss ? --
         -- Overall win percentage after winning the toss --
SELECT 
    total_matches.Total_Match, 
    match_wins.Match_Win, 
    ROUND((match_wins.Match_Win / total_matches.Total_Match) * 100, 2) AS Win_Percentage
FROM 
    (SELECT COUNT(*) AS Total_Match FROM match_info) AS total_matches,
    (SELECT COUNT(*) AS Match_Win FROM match_info WHERE toss_winner = match_winner) AS match_wins;

-- Team's win percentage after winning the toss --
WITH toss_win AS(
	SELECT toss_winner, COUNT(*) AS Toss_Win
    FROM match_info
    GROUP BY toss_winner ),
    toss_match_win as(
	SELECT match_winner, count(*) AS Toss_Match_Win
	FROM match_info
	WHERE toss_winner = match_winner
	GROUP BY match_winner)
SELECT toss_winner, 
Toss_Win, Toss_Match_Win, 
round((Toss_Match_Win/Toss_Win)*100, 2) AS Percentage
FROM toss_win AS tw
join toss_match_win AS tmw ON tmw.match_winner=tw.toss_winner
ORDER BY Percentage DESC ;

-- Let's examine the result type when a match is scheduled --
SELECT outcome_type, COUNT(outcome_type) as Count
FROM match_info
GROUP BY outcome_type
ORDER BY Count DESC ;

-- Most man of the match --
SELECT manofmach, COUNT(manofmach) AS Count
FROM match_info
GROUP BY manofmach
ORDER BY Count DESC ;

/* The man of the match is most probably given to the players FROM winning team. 
For this we'll need to SELECT the manofmatch FROM match_info table and join the result Let's see if this is true or not */
