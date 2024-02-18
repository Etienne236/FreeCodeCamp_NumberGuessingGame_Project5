#!/bin/bash

# Function to generate a random number between 1 and 1000
GENERATE_RANDOM_NUMBER() {
    echo $((1 + RANDOM % 1000))
}

# Function to check if the input is an integer
IS_INTEGER() {
    [[ $1 =~ ^[0-9]+$ ]]
}

# Set up PSQL command
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Generate a random number
SECRET=$(GENERATE_RANDOM_NUMBER)

echo "Enter your username:"
read NAME

USER=$($PSQL "SELECT username, games_played, best_game FROM users WHERE username = '$NAME';")
if [[ -z "$USER" ]]
then
  echo "Welcome, $NAME! It looks like this is your first time here."
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users (username) VALUES ('$NAME');")
else
  echo "$USER" | while IFS="|" read USERNAME GAMES BEST
  do
    echo "Welcome back, $USERNAME! You have played $GAMES games, and your best game took $BEST guesses."
  done
fi

echo "Guess the secret number between 1 and 1000:"
read NUMBER

GUESSES=1
while ! IS_INTEGER "$NUMBER"
do
  echo "That is not an integer, guess again:"
  read NUMBER
done
while [[ $NUMBER -ne $SECRET ]]
do
  if [[ $NUMBER -lt $SECRET ]]
  then
    echo "It's higher than that, guess again:"
  else
    echo "It's lower than that, guess again:"
  fi
  read NUMBER
        
  while ! IS_INTEGER "$NUMBER" 
  do
    echo "That is not an integer, guess again:"
    read NUMBER
  done

  ((GUESSES++))
done

echo "You guessed it in $GUESSES tries. The secret number was $SECRET. Nice job!"

# Update the result at the end
UPDATE_RESULT=$($PSQL "UPDATE users SET games_played = games_played + 1, best_game = LEAST(best_game, $GUESSES) WHERE username = '$NAME';")