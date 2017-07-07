#! /bin/bash

output=/tmp/Aoutput
input=/tmp/Ainput

if [ $# -eq 0 ]; then
    player_name="player A"
elif [ $# -eq 1 ]; then
    player_name="$1"
else
    echo "Usage: `basename $0` [name]" >&2
fi

echo "Player name: $player_name"

echo

if [ ! -p "$output" ]; then
    mkfifo "$output"
fi

if [ ! -p "$input" ]; then
    mkfifo "$input"
fi

## generate the first number.
random=$(shuf -i 1-5000 -n 1)

echo "First random number: $random"

## if the random number generated
## was a 1, game's already over.
if (( random == 1 )); then
    echo
    echo "WINNER: $player_name!"
    echo "done" > "$output"
    exit
fi

## start the interaction
echo "$random" > "$output"

while true; do
    ## read number sent from other player
    read current < "$input"

    ## the literal "done" means the other player has won.
    if [[ "$current" -eq "done" ]]; then
        echo
        echo "Loser: $player_name."
        exit
    fi

    echo "Number received: $current"

    ## find the nearest number
    ## that's divisible by 3.
    if (( current % 3 == 0 )); then
        let "next = ((current / 3))"
    elif (( (current + 1) % 3 == 0 )); then
        let "next = (((current + 1) / 3))"
    elif (( (current - 1) % 3 == 0 )); then
        let "next = (((current - 1) / 3))"
    fi

    echo "Number sent: $next"

    ## next == 1, means we've won!
    if (( next == 1 )); then
        echo
        echo "WINNER: $player_name!"
        echo "done" > "$output"
        exit
    fi

    ## else, send the number to the other player, his turn.
    echo "$next" > "$output"

done
