#!/bin/bash

PSQL="psql --username=freecodecamp --tuples-only --dbname=salon -c "

echo -e '\n~~~~~ MY SALON ~~~~~'
echo -e '\nWelcome to My Salon, how can I help you?'

# list salon service
SERVICE_LIST=$($PSQL "SELECT service_id, name FROM services")
# if service isn't empty
if [[ ! -z $SERVICE_LIST ]]
then
  while true
  do  
    # list service
    echo "$SERVICE_LIST" | while read SERVICE_ID SERVICE_NAME
    do
      echo "$SERVICE_ID) $SERVICE_NAME" | sed 's/ | / /'
    done

    # get user input
    read SERVICE_ID_SELECTED
    
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    if [[ -z $SERVICE_NAME  ]] 
    then
      echo -e '\nI could not find that service. What would you like today?'
    else
      break
    fi
  done
fi

# get customer information
echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE

CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
if [[ -z $CUSTOMER_NAME ]]
then
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  ADD_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
fi
CUSTOMER_ID=$($PSQL "SELECT customer_id from customers WHERE phone = '$CUSTOMER_PHONE'")

# take reservation
echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
read SERVICE_TIME
TAKE_SERVICE_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID , $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
