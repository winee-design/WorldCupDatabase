#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo "$( $PSQL "TRUNCATE TABLE games, teams;" )"

cat games.csv | while IFS=',' read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # Filling out teams table
  if [[ $WINNER != 'winner' && $OPPONENT != 'opponent' ]]
  then
    # Check if Team is in list
    if [[ -z $( $PSQL "SELECT name FROM teams WHERE name='$WINNER';" ) ]]
    then
      # Add Team row based on WINNER
      INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER');")
      if [[ $INSERT_TEAM_RESULT = "INSERT 0 1" ]]
      then
        echo "Inserted $WINNER."
      fi
    fi
    # Check if Team is in list
    if [[ -z $( $PSQL "SELECT name FROM teams WHERE name='$OPPONENT';") ]]
    then
      # Add Team row based on OPPONENT
      INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT');")
      if [[ $INSERT_TEAM_RESULT = "INSERT 0 1" ]]
      then
        echo "Inserted $OPPONENT."
      fi
    fi
  fi

  # Filling out games table

  # Check if not first line
  if [[ $YEAR != 'year' ]]
  then
    # Get IDs
    WINNER_ID=$( $PSQL "SELECT team_id FROM teams WHERE name='$WINNER';" )
    OPPONENT_ID=$( $PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';" )

    # Insert game row
    $PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS);"
  fi
done