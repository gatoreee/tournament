#!/usr/bin/env python
#
# tournament.py -- implementation of a Swiss-system tournament
#

import psycopg2


def connect():
    """Connect to the PostgreSQL database.  Returns a database connection."""
    return psycopg2.connect("dbname=tournament")


def deleteMatches():
    """Remove all the match records from the database."""
    db = psycopg2.connect("dbname=tournament")
    db_cursor = db.cursor()
    db_cursor.execute("DELETE FROM matches CASCADE")
    db.commit()
    db.close()


def deletePlayers():
    """Remove all the player records from the database."""
    db = psycopg2.connect("dbname=tournament")
    db_cursor = db.cursor()
    db_cursor.execute("DELETE FROM players CASCADE")
    db.commit()
    db.close()


def deleteTournaments():
    """Remove all the tournament records from the database."""
    db = psycopg2.connect("dbname=tournament")
    db_cursor = db.cursor()
    db_cursor.execute("DELETE FROM tournaments CASCADE")
    db.commit()
    db.close()


def countPlayers():
    """Returns the number of players currently registered."""
    db = psycopg2.connect("dbname=tournament")
    db_cursor = db.cursor()
    db_cursor.execute("SELECT count(*) FROM players")
    for row in db_cursor:
        count = row[0]
    db.close()
    return count


def registerPlayer(name):
    """Adds a player to the tournament database.

    The database assigns a unique serial id number for the player.  (This
    should be handled by your SQL database schema, not in your Python code.)

    Args:
      name: the player's full name (need not be unique).
    """
    db = psycopg2.connect("dbname=tournament")
    db_cursor = db.cursor()
    db_cursor.execute("INSERT INTO players (player_name) VALUES (%s)", (name,))
    db.commit()
    db.close()


def registerTournament(tournament):
    """Adds a tournament to the tournaments table.
       Retuns the tournament id

    Args:
        name: name of the tournament
    """
    db = psycopg2.connect("dbname=tournament")
    db_cursor = db.cursor()
    db_cursor.execute("INSERT INTO tournaments (tournament_name) \
        VALUES (%s)", (tournament,))
    db.commit()
    db_cursor.execute("SELECT tournament_id from tournaments \
        WHERE tournament_name = %s", (tournament,))
    for row in db_cursor:
        id = row[0]
    db.close()
    return id


def enterPlayerInTournament(tournament_name, player_name, player_id=-1):
    """Enters a player in a tournament. Allows passing of id in case player
        or tournament name isn't unique

    Args:
        player_name: name of player to be added
        tournament_name: name of tournament
        player_id: optional argument to specify id of player since
                    player names are not unique
    """
    db = psycopg2.connect("dbname=tournament")
    db_cursor = db.cursor()
    if(player_id >= 0):
        db_cursor.execute("INSERT INTO tournament_player_map (tournament_id, player_id) VALUES \
                          ((SELECT tournament_id FROM tournaments \
                            WHERE tournament_name = %s), %s)",
                          (tournament_name, player_id))
    else:
        db_cursor.execute("INSERT INTO tournament_player_map (tournament_id, player_id) VALUES \
                         ((SELECT tournament_id FROM tournaments \
                            WHERE tournament_name = %s), \
                          (SELECT player_id FROM players \
                            WHERE player_name = %s))",
                          (tournament_name, player_name))
    db.commit()
    db.close()


def playerStandings():
    """Returns a list of the players and their win records, sorted by wins.

    The first entry in the list should be the player in first place, or a
    player tied for first place if there is currently a tie.

    Returns:
      A list of tuples, each of which contains (id, name, wins, matches):
        id: the player's unique id (assigned by the database)
        name: the player's full name (as registered)
        wins: the number of matches the player has won
        matches: the number of matches the player has played
    """
    db = psycopg2.connect("dbname=tournament")
    db_cursor = db.cursor()
    db_cursor.execute("SELECT * FROM standings")
    standings = db_cursor.fetchall()
    db.close
    return standings


def reportMatch(tournament, winner, loser):
    """Records the outcome of a single match between two players.

    Args:
      tournament: the id of the tournament for this match
      winner:  the id number of the player who won
      loser:  the id number of the player who lost
    """
    db = psycopg2.connect("dbname=tournament")
    db_cursor = db.cursor()
    db_cursor.execute("INSERT INTO matches (tournament_id, match_winner, match_loser) \
        VALUES (%s, %s, %s)", (tournament, winner, loser))
    db.commit()
    db.close()


def swissPairings():
    """Returns a list of pairs of players for the next round of a match.

    Assuming that there are an even number of players registered, each player
    appears exactly once in the pairings.  Each player is paired with another
    player with an equal or nearly-equal win record, that is, a player adjacent
    to him or her in the standings.

    Returns:
      A list of tuples, each of which contains (id1, name1, id2, name2)
        id1: the first player's unique id
        name1: the first player's name
        id2: the second player's unique id
        name2: the second player's name
    """
    pairings = []
    db = psycopg2.connect("dbname=tournament")
    db_cursor = db.cursor()
    db_cursor.execute("SELECT * FROM standings")
    tourney, ids, names, wins, played, omw = zip(*db_cursor)
    first_ids = ids[::2]
    second_ids = ids[1::2]
    first_names = names[::2]
    second_names = names[1::2]
    pairings = zip(first_ids, first_names, second_ids, second_names)

    db.close()
    return pairings
