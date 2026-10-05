#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=periodic_table --no-align --tuples-only -c"

if [[ ! -z $1 ]]
then
  if [[ $1 =~ ^[0-9]+$ ]] 
  then
    QUERY_RESULT=$($PSQL "SELECT atomic_number, atomic_mass, symbol, name, type, melting_point_celsius, boiling_point_celsius FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING(type_id) WHERE atomic_number=$1")
  else
    QUERY_RESULT=$($PSQL "SELECT atomic_number, atomic_mass, symbol, name, type, melting_point_celsius, boiling_point_celsius FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING(type_id) WHERE symbol='$1' OR name='$1'")
  fi

  if [[ ! -z $QUERY_RESULT ]]
  then
    IFS='|' read -r NUMBER MASS SYMBOL NAME TYPE MELTING_POINT BOILING_POINT <<< "$QUERY_RESULT"
    echo "The element with atomic number $NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
  else
    echo -e 'I could not find that element in the database.'  
  fi  
else
  echo 'Please provide an element as an argument.'
fi
