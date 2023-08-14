#!/bin/bash/

PSQL="psql --username=postgres --dbname=salon -t --no-align -c"

MENU() {
    SERVICE_TABLE=$($PSQL "SELECT * FROM services")
    echo "$SERVICE_TABLE" | while IFS="|" read SERVICE_ID SERVICE_NAME
    do
        echo "$SERVICE_ID) $SERVICE_NAME"
    done
}

