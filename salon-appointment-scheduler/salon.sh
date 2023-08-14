#!/bin/bash/

PSQL="psql --username=postgres --dbname=salon -t --no-align -c"

MENU() {
    SERVICE_TABLE=$($PSQL "SELECT * FROM services")
    echo "$SERVICE_TABLE" | while IFS="|" read SERVICE_ID SERVICE_NAME
    do
        echo "$SERVICE_ID) $SERVICE_NAME"
    done
}

NOT_EXIST() {
    echo -e '\nI could not find that service. What would you like today?'
    MENU
}

CHECK_NUMBER() {
    while [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    do
        NOT_EXIST
        read SERVICE_ID_SELECTED
    done
}


# ----------START PROGRAM----------
echo 'Welcome to My Salon, how can I help you?'
MENU
read SERVICE_ID_SELECTED

# check whether input is number
CHECK_NUMBER

# check whether id is exist
# get service name
SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
# check exist
while [[ -z $SERVICE_NAME ]]
do
    NOT_EXIST
    read SERVICE_ID_SELECTED
    CHECK_NUMBER
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
done

# get infos
echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE
# get customer name
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
# if not found
if [[ -z $CUSTOMER_NAME ]]
then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    
    # insert into customers
    INSERT_INTO_CUSTOMERS_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
fi

echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
read SERVICE_TIME

echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."

# insert into appointments
# get customer id (to use for insert)
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

INSERT_INTO_APPOINTMENTS_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
echo $INSERT_INTO_APPOINTMENTS_RESULT
