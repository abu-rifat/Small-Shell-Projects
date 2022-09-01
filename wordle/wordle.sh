#!/bin/bash
clear
FILE=word-list.txt
NUM=$(wc -l < ${FILE})
let X=${RANDOM}%${NUM}+1
WORD=$(sed -n ${X}p ${FILE})
WORD=$(echo "$WORD" | awk '{print toupper($0)}')

echo -e "
Welcome to Wordle!!!

In this game, I will keep a five letter word on my mind. You have to guess the word with maximum 6 tries.
I won't tell you the word directly. But, I will give you 3 type of clues.
1) Green Box    🟩: Means you places correct letter on that position.
2) Yellow Box   🟨: You placed wrong letter on that position, but that letter exist in the word in another position.
3) Black Box    ⬛️: The letter does not exist in the word.

Now, it's time to play the game, are you ready? If yes, press Enter:
"
read entt
GO_ON=1
TRIES=0
MAXTRY=6
while [ $GO_ON -eq 1 ]
do
    TRIES=$(expr $TRIES + 1)
    echo "Guess the 5 Letter Word: ("$TRIES"/"$MAXTRY")"
    read USER_GUESS
    USER_GUESS=$(echo "$USER_GUESS" | awk '{print toupper($0)}')

    STATE=""
    for i in {0..4}
    do
        if [ "${WORD:i:1}" == "${USER_GUESS:i:1}" ]
        then
        STATE=$STATE"🟩"
        else
            ck=0
            for j in {0..4}
            do
                if [ "${WORD:j:1}" == "${USER_GUESS:i:1}" ]
                then
                    ck=1
                    STATE=$STATE"🟨"
                    break
                fi
            done
            if [ "${ck}" == "0" ]
            then
                STATE=$STATE"⬛️"
            fi
        fi
    done
    echo $STATE
    if [ $USER_GUESS == $WORD ]
    then
        echo -e "You won!"
        GO_ON=0
    elif [ $TRIES == 6 ]
    then
        echo -e "You failed.\nThe word was: "$WORD
        GO_ON=0
    fi
done
