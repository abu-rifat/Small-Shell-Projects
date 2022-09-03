#!/bin/bash

validUser=false
curruser=""


if [ ! -d "userpass" ]
then
  mkdir "userpass"
fi

if [ ! -d "scores" ]
then
  mkdir "scores"
fi

if [ ! -f "leaderboard.score" ]
then
    echo "No. Score Username" > leaderboard.score
fi

gameBanner () {
    tput clear
    #tput setaf 8
    echo ""
    echo "🅆 🄾 🅁 🄳 🅼 🅸 🅽 🅴 🆁"
    echo ""
    tput sgr0
}

mainMenu () {
    gameBanner
    echo "Signup / Login:"
    echo ""
    echo "N - New User SignUp"
    echo "L - Existing User Login"
    echo "E - Exit"
    echo ""
    read -p "Enter your choice: " option
    case $option in
        N | n)
            signUp
        ;;
        L | l)
            login
        ;;
        E | e)
        clear
        exit
        ;;
        *)
        read -p "Invalid Choice, Press Anykey to Continue.. " hold
        ;; 
    esac
}

signUp () {
    gameBanner
    echo "Signup:"
    echo ""
    while : ; do
        read -p "Enter username(Only lowercase English letters): " username
        dir="./userpass/$username.usr"
        scho="./scores/$username.sco"
        REGEX='^[a-z]+$'
        if [[ ! $username =~ $REGEX ]]
        then
            read -p "Invalid username, want to try again? [Y/N]: " tryagain
            case $tryagain in
            N | n)
                return
                ;;
            esac
        elif [[ -f "$dir" ]]
        then
            read -p "The username: $username is taken, want to try again? [Y/N]: " tryagain
            case $tryagain in
            N | n)
                return
                ;;
            esac
        else
            break
        fi
    done

    while : ; do
        stty -echo
        read -p "Enter new password(length: 6-10):" password
        stty echo
        echo ""
        REGEX='^.{6,10}$'
        if [[ ! $password =~ $REGEX ]]
        then
            read -p "Password length must be between 6 to 10 characters, want to try again? [Y/N]: " tryagain
            case $tryagain in
            N | n)
                return
                ;;
            esac
        else
            break
        fi
    done
    
    while : ; do
        stty -echo
        read -p "Enter the password again:" rePassword
        stty echo
        echo ""
        if [[ ! $password == $rePassword ]]
        then
            read -p "The two passwords didn't matched, want to try again? [Y/N]: " tryagain
            case $tryagain in
            N | n)
                return
                ;;
            esac
        else

            echo "$(md5sum <<<$password)" > $dir
            echo "No. Score" > $scho
            validUser=true
            curruser=$username
            read -p "Welcome $username! Press Anykey to Continue.. " hold
            break;
        fi
    done
}

login () {
    gameBanner
    echo "Login:"
    echo ""
    while : ; do
        read -p "Enter username(Only lowercase English letters): " username
        dir="./userpass/$username.usr"
        REGEX='^[a-z]+$'
        if [[ ! $username =~ $REGEX ]]
        then
            read -p "Invalid username, want to try again? [Y/N]: " tryagain
            case $tryagain in
            N | n)
                return
                ;;
            esac
        elif [[ -f "$dir" ]]
        then
            while : ; do
                stty -echo
                read -p "Enter the password(length: 6-10):" password
                stty echo
                echo ""
                REGEX='^.{6,10}$'
                if [[ ! $password =~ $REGEX ]]
                then
                    read -p "Password length must be between 6 to 10 characters, want to try again? [Y/N]: " tryagain
                    case $tryagain in
                    N | n)
                        return
                        ;;
                    esac
                else
                    savedPass=""
                    while read -r line; do
                        savedPass=$line
                        break
                    done < $dir
                    passHash=$(md5sum <<<$password)
                    if [[ $passHash = $savedPass ]]
                    then
                        validUser=true
                        curruser=$username
                        read -p "Welcome $username! Press Anykey to Continue.. " hold
                        return;
                    else
                        read -p "Wrong password, want to try again? [Y/N]: " tryagain
                        case $tryagain in
                        N | n)
                            return
                            ;;
                        esac
                    fi
                fi
            done
            
            
        else
            read -p "User doesn't exist, want to try again? [Y/N]: " tryagain
            case $tryagain in
            N | n)
                break
                ;;
            esac
        fi
    done
}

userMenu () {
    gameBanner
    echo "Welcome, $username!"
    echo ""
    echo "N - Start New Game"
    echo "M - My Scoreboard"
    echo "L - Leaderboard"
    echo "X - Logout"
    echo "E - Exit"
    echo ""
    read -p "Enter your choice: " option
    case $option in
        N | n)
            wordle
        ;;
        M | m)
            myScore
        ;;
        L | l)
            leaderBoard
        ;;
        X | x)
            logOut
        ;;
        E | e)
            clear
            exit
        ;;
        *)
            read -p "Invalid Choice, Press Anykey to Continue.. " hold
            read hold
        ;; 
    esac
}

myScore () {
    gameBanner
    dir="./scores/$username.sco"
    echo "Your Scoreboard:"
    echo ""
    column $dir -tc2
    echo ""
    read -p "Press Anykey to Continue.. " hold
}

leaderBoard () {
    gameBanner
    dir="./leaderboard.score"
    echo "Leaderboard:"
    echo ""
    column $dir -tc2
    echo ""
    read -p "Press Anykey to Continue.. " hold
}

logOut() {
    validUser=false
    curruser=""
    read -p "See you soon, Press Anykey to Continue.. " hold
    break;
}

wordle() {
    gameBanner
    FILE=word-list-2.txt
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
    echo "$WORD"
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
            led="./leaderboard.score"
            dir="./scores/$username.sco"
            linesled=$(wc -l < $led)
            TRIES=$(expr $TRIES + 1)
            echo "$linesled $TRIES $username" >> $led
            linesdir=$(wc -l < $dir)
            echo "$linesdir $TRIES" >> $dir
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
    while read -r no score; do
        echo "$score" >> $tmpdir
    done < $tmp2dir
    sort -n $tmpdir > $tmp2dir
    no=1
    >$dir
    echo "No. Score" > $dir
    while read -r score; do
        echo "$no $score" >> $dir
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
    dir="./leaderboard.score"
    tmp2dir="./.tmp2"
    tmpdir="./.tmp"
    tail -n +2 $dir > $tmp2dir
    >$tmpdir
    while read -r no score thisuser; do
        echo "$score $thisuser" >> $tmpdir
    done < $tmp2dir
    sort -n $tmpdir > $tmp2dir
    no=1
    >$dir
    echo "No. Score Username" > $dir
    while read -r score nowuser; do
        echo "$no $score $nowuser" >> $dir
        no=$(( $no + 1 ))
    done < $tmp2dir
    rm $tmpdir
    rm $tmp2dir
}

while true; 
do
    gameBanner
    if [ $validUser = true ]
    then
        userMenu
    else
        mainMenu
    fi
    
done


