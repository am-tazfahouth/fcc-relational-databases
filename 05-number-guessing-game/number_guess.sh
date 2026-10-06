#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=number_guess --no-align --tuples-only -c"

echo "Enter your username:"
read USER_NAME

# get user info
USER_INFO=$($PSQL "SELECT user_id, COUNT(game_id), MIN(guesses) FROM users LEFT JOIN games USING(user_id) WHERE username='$USER_NAME' GROUP BY user_id")
IFS='|' read -r USER_ID GAMES_PLAYED BEST_GUESS <<< "$USER_INFO"

# check if BEST_GUESS is empty 
if [[ -z $BEST_GUESS ]]
then
  BEST_GUESS=0
fi

# if user exist in db
if [[ ! -z $USER_INFO ]]
then
  echo "Welcome back, $USER_NAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GUESS guesses."

else
  ADD_USER=$($PSQL "INSERT INTO users(username) VALUES('$USER_NAME')")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USER_NAME'")
  echo "Welcome, $USER_NAME! It looks like this is your first time here."
fi

# generate random number
TRY=0
SECRET_NUMBER=$(( (RANDOM % 1000) + 1 ))
echo 'Guess the secret number between 1 and 1000:'

# game loop
while true
do
  (( TRY++ ))
  read USER_INPUT
  
  # the input is note a number
  if [[ ! $USER_INPUT =~ ^[0-9]+$ ]] 
  then
    echo 'That is not an integer, guess again:'
  else
    if [[ $USER_INPUT -gt $SECRET_NUMBER ]]
    then
      echo "It's lower than that, guess again:"
    
    elif [[ $USER_INPUT -lt $SECRET_NUMBER ]]
    then
      echo "It's higher than that, guess again:"
    
    else
      SAVE_RESULT=$($PSQL "INSERT INTO games(user_id, guesses) VALUES($USER_ID, $TRY)")
      echo "You guessed it in $TRY tries. The secret number was $SECRET_NUMBER. Nice job!"
      break
    fi
  fi
done
