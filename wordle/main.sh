#!/bin/bash

loggedin=false
activeUser=""


if [ ! -d "userpass" ]
then
  mkdir "userpass"
fi

if [ ! -d "scores" ]
then
  mkdir "scores"
fi

if [ ! -f "top-score.rec" ]
then
    echo "No. Score Username Word" > top-score.rec
fi

header () {
    clear
    echo ""
    echo "🅆 🄾 🅁 🄳 🅼 🅸 🅽 🅸 🅽 🅶"
    echo ""
}

authentication () {
    header
    echo "1. SignUp"
    echo "2. SignIn"
    echo "3. Quit"
    echo ""
    read -p "Enter the Choice No: " option
    case $option in
        1)
            signUp
        ;;
        2)
            signIn
        ;;
        3)
        clear
        exit
        ;;
        *)
        read -p "Invalid Choice, Press Anykey to Continue.. " hold
        ;; 
    esac
}

signUp () {
    header
    echo "𝕊 𝕚 𝕘 𝕟 𝕌 𝕡"
    echo ""
    while : ; do
        read -p "Username(Example: abcd or abcd123): " username
        dir="./userpass/$username.usr"
        scho="./scores/$username.sco"
        REGEX='^[a-z][a-z0-9]+$'
        if [[ ! $username =~ $REGEX ]]
        then
            read -p "Invalid username..."
        elif [[ -f "$dir" ]]
        then
            read -p "The username: $username is not available, try another one..."
        else
            break
        fi
    done

    while : ; do
        read -p "Enter new password(max-length: 5):" password
        REGEX='^.{1,5}$'
        if [[ ! $password =~ $REGEX ]]
        then
            echo "Password length must be between 1 to 5..."
        else
            break
        fi
    done
    
    while : ; do
        read -p "Re-enter the password:" rePassword
        if [[ ! $password == $rePassword ]]
        then
            read -p "Passwords didn't match..."
        else
            echo "$(md5sum <<<$password)" > $dir
            echo "No. Score Word" > $scho
            loggedin=true
            activeUser=$username
            read -p "SignUp successfull, press any key to continue..." hold
            break;
        fi
    done
}

signIn () {
    header
    echo "𝕊 𝕚 𝕘 𝕟 𝕀 𝕟"
    echo ""
    while : ; do
        read -p "Username: " username
        dir="./userpass/$username.usr"
        REGEX='^[a-z][a-z0-9]+$'
        if [[ ! $username =~ $REGEX ]]
        then
            read -p "Invalid username..."
        elif [[ -f "$dir" ]]
        then
            while : ; do
                savedPass=""
                while read -r line; do
                    savedPass=$line
                    break
                done < $dir
                read -p "Password: " password
                passHash=$(md5sum <<<$password)
                if [[ $passHash = $savedPass ]]
                then
                    loggedin=true
                    activeUser=$username
                    read -p "SignIn successfull, press any key to continue..." hold
                    return;
                else
                    read -p "Wrong password, want to try again? [Y/N]: " tryagain
                    case $tryagain in
                    N | n)
                        return
                        ;;
                    esac
                fi
            done
        else
            read -p "Not a valid user..."
            break;
        fi
    done
}

gameMenu () {
    header
    echo "Hay $username, welcome to WordMining!"
    echo ""
    echo "1 - Play Now"
    echo "2 - My Scores"
    echo "3 - Top Scores"
    echo "4 - SignOut"
    echo "5 - Quit"
    echo ""
    read -p "Enter the Choice No: " option
    case $option in
        1)
            wordMining
        ;;
        2)
            myScore
        ;;
        3)
            leaderBoard
        ;;
        4)
            logOut
        ;;
        5)
            clear
            exit
        ;;
        *)
            read -p "Invalid Choice, Press Any key to Continue.. " hold
            read hold
        ;; 
    esac
}

myScore () {
    header
    dir="./scores/$username.sco"
    echo "My Scores: "
    echo ""
    column $dir -tc2
    echo ""
    read -p "Press Any key to Continue.. " hold
}

leaderBoard () {
    header
    dir="./top-score.rec"
    echo "Top Scores:"
    echo ""
    column $dir -tc2
    echo ""
    read -p "Press Any key to Continue.. " hold
}

logOut() {
    loggedin=false
    activeUser=""
    read -p "SignOut Successfull, press any key to continue... " hold
    break;
}
WORD=""
selectlevel() {
    while : ; do
        header
        echo "Select your level!"
        echo ""
        echo "1 - Easy(most common English words with distinct letters)"
        echo "2 - Medium(medium common English words with distinct letters)"
        echo "3 - Medium Hard(medium common English words, may contain duplicate letters)"
        echo "4 - Hard(less common English words, may contain duplicate letters)"
        echo ""
        read -p "Enter the Choice No: " option
        case $option in
            1)
                FILE=word-list-easy.txt
                NUM=$(wc -l < ${FILE})
                let X=${RANDOM}%${NUM}+1
                WORD=$(sed -n ${X}p ${FILE})
                WORD=$(echo "$WORD" | awk '{print toupper($0)}')
                return
            ;;
            2)
                FILE=word-list-medium.txt
                NUM=$(wc -l < ${FILE})
                let X=${RANDOM}%${NUM}+1
                WORD=$(sed -n ${X}p ${FILE})
                WORD=$(echo "$WORD" | awk '{print toupper($0)}')
                return
            ;;
            3)
                FILE=word-list-medium-hard.txt
                NUM=$(wc -l < ${FILE})
                let X=${RANDOM}%${NUM}+1
                WORD=$(sed -n ${X}p ${FILE})
                WORD=$(echo "$WORD" | awk '{print toupper($0)}')
                return
            ;;
            4)
                FILE=word-list-hard.txt
                NUM=$(wc -l < ${FILE})
                let X=${RANDOM}%${NUM}+1
                WORD=$(sed -n ${X}p ${FILE})
                WORD=$(echo "$WORD" | awk '{print toupper($0)}')
                return
            ;;
            *)
                read -p "Invalid Choice, Press Any key to Continue.. " hold
            ;; 
        esac
    done
}

wordMining() {
    selectlevel
    header
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
    #echo "$WORD"
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
            led="./top-score.rec"
            dir="./scores/$username.sco"
            linesled=$(wc -l < $led)
            #TRIES=$(expr $TRIES + 1)
            echo "$linesled $TRIES $username $WORD" >> $led
            linesdir=$(wc -l < $dir)
            echo "$linesdir $TRIES $WORD" >> $dir
            sortLeaderboard
            sortScore
            printf "You won! Press Anykey to Continue... " "$moves"
            read hold
            break
            GO_ON=0
        elif [ $TRIES == 6 ]
        then
            read -p "You failed! The word was: $WORD, Press Anykey to Continue..." hold
            GO_ON=0
        fi
    done
}

sortScore () {
    if [[ ! -f "./.tmp" ]]
    then
        touch .tmp
    fi
    if [[ ! -f "./t.mp2" ]]
    then
        touch .tmp2
    fi
    dir="./scores/$username.sco"
    tmp2dir="./.tmp2"
    tmpdir="./.tmp"
    tail -n +2 $dir > $tmp2dir
    >$tmpdir
    while read -r no score word; do
        echo "$score $word" >> $tmpdir
    done < $tmp2dir
    sort -n $tmpdir > $tmp2dir
    no=1
    >$dir
    echo "No. Score Word" > $dir
    while read -r score; do
        echo "$no $score $word" >> $dir
        no=$(( $no + 1 ))
    done < $tmp2dir
    rm $tmpdir
    rm $tmp2dir
}

sortLeaderboard () {
    if [[ ! -f "./.tmp" ]]
    then
        touch .tmp
    fi
    if [[ ! -f "./t.mp2" ]]
    then
        touch .tmp2
    fi
    dir="./top-score.rec"
    tmp2dir="./.tmp2"
    tmpdir="./.tmp"
    tail -n +2 $dir > $tmp2dir
    >$tmpdir
    while read -r no score thisuser word; do
        echo "$score $thisuser $word" >> $tmpdir
    done < $tmp2dir
    sort -n $tmpdir > $tmp2dir
    no=1
    >$dir
    echo "No. Score Username Word" > $dir
    while read -r score nowuser; do
        echo "$no $score $nowuser $word" >> $dir
        no=$(( $no + 1 ))
    done < $tmp2dir
    rm $tmpdir
    rm $tmp2dir
}

while true; 
do
    header
    if [ $loggedin = true ]
    then
        gameMenu
    else
        authentication
    fi
    
done


