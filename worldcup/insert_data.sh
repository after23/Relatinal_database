#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo $($PSQL "TRUNCATE teams,games")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != year ]]
  then
    #check winner
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    if [[ -z $WINNER_ID ]]
    then
      #insert team_name
      TEAM_NAME_INSERT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
      if [[ $TEAM_NAME_INSERT == "INSERT 0 1" ]]
      then
        echo Winner inserted
      fi
    fi

    #Check opponent
    LOSER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    if [[ -z $LOSER_ID ]]
    then
      #insert team_name
      TEAM_NAME_INSERT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      LOSER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
      if [[ $TEAM_NAME_INSERT == "INSERT 0 1" ]]
      then
        echo Loser inserted
      fi
    fi

    ####table games stuff
    GAMES_INSERT=$($PSQL "INSERT INTO games(year,round,winner_id,opponent_id,winner_goals,opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $LOSER_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
    if [[ $GAMES_INSERT == "INSERT 0 1" ]]
      then
        echo game entry inserted
    fi
  fi
  
done