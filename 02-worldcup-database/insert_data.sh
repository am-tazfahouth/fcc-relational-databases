#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi


# Do not change code above this line. Use the PSQL variable above to query your database.

GET_TEAM_ID () {
  RESULT=$($PSQL "SELECT team_id FROM teams WHERE name = '$1'")
  echo $RESULT
}

cat games.csv | while IFS="," read -r YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # Skip first ligne
  if [[ $YEAR =~ ^[0-9]+$ ]] 
  then
    #echo "year: $YEAR | round: $ROUND | winner: $WINNER | opponent: $OPPONENT | win_g: $WINNER_GOALS | op_g: $OPPONENT_GOALS"    

    # insert team
    teams=("$WINNER" "$OPPONENT")
    for team in "${teams[@]}"
    do
      GET_TEAM_RESULT=$($PSQL "SELECT * FROM teams WHERE name = '$team'")
      # If result is empty
      if [[ -z $GET_TEAM_RESULT ]]
      then
        # insert new teams
        INSERT_TEAMS_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$team')")
      fi
    done

    # get winner and opponent id
    WINNER_ID=$(GET_TEAM_ID "$WINNER")
    OPPONENT_ID=$(GET_TEAM_ID "$OPPONENT")

    # if winner and opponent id isn't empty
    if [[ ! -z $WINNER_ID  && ! -z $OPPONENT_ID ]]
    then
      # insert games
      INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_goals, opponent_goals, winner_id, opponent_id) VALUES($YEAR, '$ROUND', $WINNER_GOALS, $OPPONENT_GOALS, $WINNER_ID, $OPPONENT_ID)")
    fi

  fi 
done
