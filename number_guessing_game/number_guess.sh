#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guesser -t --no-align -c"

echo "Enter your username:"
read USERNAME

#Input validation (Number)
INPUT_VALIDATION (){
  GUESS=$1
  while [[ $GUESS =~ [^0-9]+ ]]
  do
    echo "That is not an integer, guess again:"
    read GUESS
  done
}

#Welkem message
USER_QUERY=$($PSQL "SELECT * FROM games WHERE username='$USERNAME';")
if [[ -z $USER_QUERY ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INPUT_USER_QUERY=$($PSQL "INSERT INTO games(username) VALUES('$USERNAME');")
  USER_QUERY=$($PSQL "SELECT * FROM games WHERE username='$USERNAME';")
  STRING=$(echo "$USER_QUERY" | sed -r 's/\|/ /g')
  read -r USER_ID USERNAME GAMES_PLAYED BEST_GAME <<< "${STRING}"
else
  STRING=$(echo "$USER_QUERY" | sed -r 's/\|/ /g')
  read -r USER_ID USERNAME GAMES_PLAYED BEST_GAME <<< "${STRING}"
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi


SECRET_NUMBER=$(($RANDOM%1001))
NUMBER_OF_GUESSES=0

echo "Guess the secret number between 1 and 1000:"
read GUESS
INPUT_VALIDATION $GUESS
NUMBER_OF_GUESSES=$((NUMBER_OF_GUESSES+1))
while [[ $GUESS != $SECRET_NUMBER ]]
do
  if (( $GUESS > $SECRET_NUMBER ))
  then
    echo "It's lower than that, guess again:"
    read GUESS
    INPUT_VALIDATION $GUESS
    NUMBER_OF_GUESSES=$((NUMBER_OF_GUESSES+1))
  else
    echo "It's higher than that, guess again:"
    read GUESS
    INPUT_VALIDATION $GUESS
    NUMBER_OF_GUESSES=$((NUMBER_OF_GUESSES+1))
  fi
done

echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"

#increment games_played on db
INPUT_GAMES_PLAYED=$($PSQL "UPDATE games SET games_played = games_played + 1 WHERE user_id=$USER_ID")

#check best game
if (( $NUMBER_OF_GUESSES < $BEST_GAME || $BEST_GAME == 0))
then
  INPUT_BEST_GAME=$($PSQL "UPDATE games SET best_game = $NUMBER_OF_GUESSES WHERE user_id=$USER_ID")
fi
