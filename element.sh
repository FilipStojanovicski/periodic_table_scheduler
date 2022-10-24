#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only -c"

# Check if an element is provided
if [[ -z $1 ]]
then 
  echo "Please provide an element as an argument."
else
  # Get the element information
  # If we have a number as an input we check for the atominc number
  # Otherwise we check for the symbol and name
  if [[ "$1" =~ ^[0-9]+$ ]]
  then
    ELEMENT_INFO=$($PSQL "SELECT atomic_number, symbol, name FROM elements WHERE atomic_number=$1;")
  else
    ELEMENT_INFO=$($PSQL "SELECT atomic_number, symbol, name FROM elements WHERE symbol='$1' OR name='$1';")
  fi

  # If we can't find the element exit
  if [[ -z $ELEMENT_INFO ]]
  then
    echo "I could not find that element in the database."
  else
    # Split up the columns into symbol, name
    IFS="|" read ATOMIC_NUMBER SYMBOL NAME <<< $ELEMENT_INFO
    # Remove any whitespace
    ATOMIC_NUMBER=$(echo $ATOMIC_NUMBER | sed -r 's/^ *| *$//g')
    SYMBOL=$(echo $SYMBOL | sed -r 's/^ *| *$//g')
    NAME=$(echo $NAME | sed -r 's/^ *| *$//g')

    # Get the element properties
    PROPERTIES_INFO=$($PSQL "SELECT type_id, atomic_mass, melting_point_celsius, boiling_point_celsius FROM properties WHERE atomic_number=$ATOMIC_NUMBER;")
    IFS="|" read TYPE_ID ATOMIC_MASS MELTING_POINT_CELSIUS BOILING_POINT_CELSIUS <<< $PROPERTIES_INFO
    TYPE_ID=$(echo $TYPE_ID | sed -r 's/^ *| *$//g')
    ATOMIC_MASS=$(echo $ATOMIC_MASS | sed -r 's/^ *| *$//g')
    MELTING_POINT_CELSIUS=$(echo $MELTING_POINT_CELSIUS | sed -r 's/^ *| *$//g')
    BOILING_POINT_CELSIUS=$(echo $BOILING_POINT_CELSIUS | sed -r 's/^ *| *$//g')

    # Get the element type
    TYPE=$($PSQL "SELECT type FROM types WHERE type_id=$TYPE_ID;")
    TYPE=$(echo $TYPE | sed -r 's/^ *| *$//g')

    echo -e "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT_CELSIUS celsius and a boiling point of $BOILING_POINT_CELSIUS celsius."
  fi
fi
