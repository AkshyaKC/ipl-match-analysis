use ipl;
select * from match_info;

-- Checking if any ipl match has been played outside india --
select season_year,country_name, count(country_name) as Matches 
from match_info
where country_name != 'India'
group by season_year, country_name;

-- Most matches played venue --
select venue_name, city_name, country_name, count(venue_name) as Count
from match_info
group by venue_name, city_name, country_name
order by Count desc;

-- Changing different labeling for Bangalore to Bangalore --
select venue_name, 
case
when city_name in ('Bangalore', 'Bengaluru') then 'Bangalore'
else city_name
end as city_name2, 
country_name, count(venue_name) as Count 
from match_info
group by venue_name, city_name2, country_name
order by Count desc;

-- Is there any difference between number of matches thoroughout the different season ?--
select season_year, count(season_year) as Count
from match_info
group by season_year
order by  Count desc; 

-- Let's see which team has won the toss most.--
select toss_winner, count(toss_winner) as Count
from match_info
group by toss_winner
order by Count desc;

/* Since the chances of winning toss increase as the number of games played by a team increase. Mumbai Indians and KKR
being at the top of the list may be because of they qualified for the knockout games more. Let's check if this is true */

with team_cte as(
	select team1 as team_played
	from match_info
	union all
	select team2 as team_played
	from match_info
)
select team_played, count(team_played) as Count
from team_cte
group by team_played
order by Count desc;

-- ORRRRRRRRR --
 
select team_played, count(team_played) as team_count
from (
    SELECT team1 AS team_played
    FROM match_info
    UNION ALL
    SELECT team2 AS team_played
    FROM match_info
) AS combined_count
group by team_played
order by team_count desc;


-- Let's merge these two tables to calculate the toss win percentage for each team. -- 
with play_count as (
	select team_played, count(team_played) as play_count
	from (
		SELECT team1 AS team_played
		FROM match_info
		UNION ALL
		SELECT team2 AS team_played
		FROM match_info
	) AS combined_count
	group by team_played),
toss_win_count as (
	select toss_winner, count(toss_winner) as toss_win_count
	from match_info
	group by toss_winner)
select team_played, play_count, toss_win_count, round((toss_win_count / play_count)*100,2) as toss_win_percentage
from play_count as pc
left join toss_win_count as twc on twc.toss_winner=pc.team_played
order by toss_win_percentage desc;

-- Analyzing the most preferred choice for an IPL captain after winning the toss. --
select toss_name, count(toss_name) as Count
from match_info
group by toss_name;

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
with toss_win as(
	select toss_winner, count(*) as Toss_Win
    from match_info
    group by toss_winner ),
    toss_match_win as(
	select match_winner, count(*) as Toss_Match_Win
	from match_info
	where toss_winner = match_winner
	group by match_winner)
select toss_winner, 
Toss_Win, Toss_Match_Win, 
round((Toss_Match_Win/Toss_Win)*100, 2) as Percentage
from toss_win as tw
join toss_match_win as tmw on tmw.match_winner=tw.toss_winner
order by Percentage desc;

-- Let's examine the result type when a match is scheduled --
select outcome_type, count(outcome_type) as Count
from match_info
group by outcome_type
order by Count desc;

-- Most man of the match --
select manofmach, count(manofmach) as Count
from match_info
group by manofmach
order by Count desc;

/* The man of the match is most probably given to the players from winning team. 
For this we'll need to select the manofmatch from match_info table and join the result Let's see if this is true or not */
