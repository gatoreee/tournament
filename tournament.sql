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
	CREATE TABLE tournaments(tournament_id serial PRIMARY KEY, tournament_name text UNIQUE);
	CREATE TABLE players (player_id serial PRIMARY KEY, player_name text);
	CREATE TABLE matches (tournament_id integer REFERENCES tournaments(tournament_id), match_id serial PRIMARY KEY, match_winner integer REFERENCES players(player_id), match_loser integer REFERENCES players(player_id));
	CREATE TABLE tournament_player_map (tournament_id serial REFERENCES tournaments(tournament_id) ON DELETE CASCADE, player_id serial REFERENCES players(player_id) ON DELETE CASCADE);
	CREATE VIEW played AS SELECT tournament_player_map.tournament_id, player_id, count(match_id) AS matches_played FROM tournament_player_map LEFT JOIN matches ON (player_id = match_winner OR player_id = match_loser) AND tournament_player_map.tournament_id = matches.tournament_id GROUP BY player_id, tournament_player_map.tournament_id ORDER BY tournament_player_map.tournament_id, player_id;
	CREATE VIEW won AS SELECT tournament_player_map.tournament_id, player_id, count(match_winner) AS matches_won FROM tournament_player_map LEFT JOIN matches ON player_id = match_winner AND tournament_player_map.tournament_id = matches.tournament_id GROUP BY player_id, tournament_player_map.tournament_id ORDER BY tournament_player_map.tournament_id, player_id;
	CREATE VIEW omw AS SELECT won.tournament_id, won.player_id, sum(opponent_wins) AS opponents_wins FROM (SELECT matches.tournament_id, match_winner AS player, match_loser AS opponent, matches_won AS opponent_wins FROM won, matches WHERE match_loser = player_id AND matches.tournament_id = won.tournament_id UNION SELECT matches.tournament_id, match_loser AS player, match_winner AS opponent, matches_won AS opponent_wins FROM won, matches WHERE match_winner = player_id AND matches.tournament_id = won.tournament_id) AS opponents, won WHERE opponents.tournament_id = won.tournament_id AND player = won.player_id GROUP BY player, won.player_id, won.tournament_id ORDER BY tournament_id, opponents_wins desc;
	CREATE VIEW standings AS SELECT won.tournament_id, players.player_id, player_name, count(matches_won), matches_played, opponents_wins FROM players LEFT JOIN won ON players.player_id = won.player_id LEFT JOIN played ON won.player_id = played.player_id AND won.tournament_id = played.tournament_id LEFT JOIN omw ON played.player_id = omw.player_id AND played.tournament_id = omw.tournament_id ORDER BY omw.tournament_id, matches_won DESC, omw.opponents_wins DESC;