# tournament
Project: Tournament Results  - [Enrique B]
================================

Required Libraries and Dependencies
-----------------------------------
The project uses a postgres database named tournament. Development was done using a Vagrant VM provided by the Udacity team. In order to replicate the development and test environment, this Vagrant VM should be installed.


How to Run Project
------------------
The project repository can be found at https://github.com/gatoreee/tournament. Save all files to a local folder named 'tournament' inside the Vagrant VM folder. 
In order to run the application, open a command prompt and follow the instructions below:
1) From the command prompt, run the 'vagrant up' command. This should launch the Vagrant VM.
2) From the command prompt, run the 'vagrant ssh' command. This will connect and log you into the Vagrant VM.
3) From the vagrant command prompt, run the command 'cd /vagrant/tournament' to take you to the folder where the files are saved.
4) From the vagrant command prompt, run the 'psql' command. This will connect you to the psql command line.
5) From the psql command line, run the 'CREATE DATABASE tournament' command.
6) From the psql command line, run the '\c tournament'. This will connect you to the tournament database.
7) From the psql command line, run the '\i tournament.sql' command. This will create all the tables and views needed.
8) From the psql command line, run the '\q' command. This will take you back to the vagrang command line.
9) From the vagrant command line, run the 'python tournament_test.py' command. Verify all tests have passed. 


Extra Credit Description
------------------------
For this project I added support for more than one tournament in the database. This required adding functions to create tournaments and register players into a tournament. It also required created tables for tournaments and a tournament player map. As well as modifying the standings, matches, won and omw views. 

Also added 'opponent match wins' as a way to break ties when players have the same number of wins. This metric is calculated into the omw view and reflected in the standings. 

