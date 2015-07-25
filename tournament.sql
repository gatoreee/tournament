-- Table definitions for the tournament project.
--
-- Put your SQL 'create table' statements in this file; also 'create view'
-- statements if you choose to use it.
--
-- You can write comments in this file by starting them with two dashes, like
-- these lines here.

-- Drop database 'tournament'
	DROP DATABASE IF EXISTS tournament; 
-- Create database 'tournament'
	CREATE DATABASE tournament;

-- Create tables for players and matches
	CREATE TABLE tournaments(tournament_id serial PRIMARY KEY, tournament_name text);
	CREATE TABLE players (player_id serial PRIMARY KEY, player_name text);
	CREATE TABLE matches (tournament_id integer REFERENCES tournaments(tournament_id), match_id serial PRIMARY KEY, match_winner integer REFERENCES players(player_id), match_loser integer REFERENCES players(player_id));
	CREATE TABLE player_tourney_map (player_id serial REFERENCES players(player_id) ON DELETE CASCADE, tournament_id serial REFERENCES tournaments(tournament_id) ON DELETE CASCADE);
	CREATE VIEW won AS SELECT matches.tournament_id, player_tourney_map.player_id, count(match_winner) AS matches_won FROM player_tourney_map LEFT JOIN matches ON player_tourney_map.player_id = match_winner GROUP BY player_tourney_map.player_id, matches.tournament_id ORDER BY matches.tournament_id, player_tourney_map.player_id;
	CREATE VIEW played AS SELECT player_id, count(match_id) AS matches_played FROM players LEFT JOIN matches ON player_id = match_winner OR player_id = match_loser GROUP BY player_id ORDER BY player_id;
	CREATE VIEW standings AS SELECT player_id, player_name, count(match_winner) AS matches_won, (SELECT count(*) FROM matches WHERE player_id = match_winner OR player_id = match_loser) AS matches_played FROM players LEFT JOIN matches ON player_id = match_winner GROUP BY player_id ORDER BY player_id;
	CREATE VIEW omw AS SELECT player AS player_id, sum(opponent_wins) AS opponents_wins FROM (SELECT match_winner AS player, match_loser AS opponent, matches_won AS opponent_wins FROM matches, won WHERE match_loser = player_id union SELECT match_loser AS player, match_winner AS opponent, matches_won AS opponent_wins FROM matches, won WHERE match_winner = player_id ORDER BY player) AS opponents GROUP BY player;
	CREATE VIEW standings AS SELECT players.player_id, player_name, matches_won, matches_played, opponents_wins FROM players LEFT JOIN matches ON player_id = match_winner JOIN won on players.player_id = won.player_id JOIN played on players.player_id = played.player_id JOIN omw ON players.player_id = omw.player_id GROUP BY players.player_id, matches_won, matches_played, opponents_wins ORDER BY matches_won DESC, opponents_wins DESC;
	SELECT player_id, player_name, count(match_winner) AS matches_won, (SELECT count(*) FROM matches WHERE player_id = match_winner OR player_id = match_loser) AS matches_played FROM players LEFT JOIN matches ON player_id = match_winner GROUP BY player_id ORDER BY matches_won DESC;