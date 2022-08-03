#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

if [[ -z $1 ]]
then
  echo Please provide an element as an argument.
else
  if [[ $1 =~ [0-9]+$ ]]
  then
    ELEMENT_QUERY=$($PSQL "SELECT * FROM elements WHERE (atomic_number=$1)")
  else
    ELEMENT_QUERY=$($PSQL "SELECT * FROM elements WHERE (symbol='$1' OR name='$1')")
  fi

  #if element not found
  if [[ -z $ELEMENT_QUERY ]]
  then
    echo "I could not find that element in the database."
  else
    echo "$ELEMENT_QUERY" | sed -r 's/(\|)/ /g' | while read ATOMIC_NUMBER SYMBOL NAME
    do
      PROPERTY_QUERY=$($PSQL "SELECT * FROM properties WHERE atomic_number=$ATOMIC_NUMBER")
      echo "$PROPERTY_QUERY" | sed -r 's/(\|)/ /g' | while read ATOMIC_NUMBER2 ATOMIC_MASS MELTING_POINT BOILING_POINT TYPE_ID
      do
      TYPE_QUERY=$($PSQL "SELECT type FROM types WHERE type_id=$TYPE_ID")
      echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE_QUERY, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
      done
    done
  fi
fi