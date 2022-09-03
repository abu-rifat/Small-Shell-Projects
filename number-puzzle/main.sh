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
    tput setaf 3
    echo ""
    echo "8-Puzzle Game"
    echo ""
    tput sgr0
}

mainMenu () {
    gameBanner
    tput rev
    echo "Signup / Login:"
    echo ""
    tput sgr0
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
    tput rev
    echo "Signup:"
    echo ""
    tput sgr0
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
    tput rev
    echo "Login:"
    echo ""
    tput sgr0
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
                    #savedPass=$(head -n 1 $dir)
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
    tput rev
    echo "Welcome, $username!"
    echo ""
    tput sgr0
    echo "N - Start New Game"
    echo "M - My Scoreboard"
    echo "L - Leaderboard"
    echo "X - Logout"
    echo "E - Exit"
    echo ""
    read -p "Enter your choice: " option
    case $option in
        N | n)
            newGame
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
    tput rev
    echo "Your Scoreboard:"
    echo ""
    tput sgr0
    column $dir -tc2
    echo ""
    read -p "Press Anykey to Continue.. " hold
}

leaderBoard () {
    gameBanner
    dir="./leaderboard.score"
    tput rev
    echo "Leaderboard:"
    echo ""
    tput sgr0
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

#Game Code

board=( {1..8} "" )
target=( "${board[@]}" )
empty=8
last=0
A=0 B=1 C=2 D=3
nocursor='\e[?25l'

fmt="$nocursor
     %2s  %2s   %2s
     %2s  %2s   %2s
     %2s  %2s   %2s
"

fmt="$nocursor┏━━━━┳━━━━┳━━━━┓
┃    ┃    ┃    ┃
┃ %2s ┃ %2s ┃ %2s ┃
┃    ┃    ┃    ┃
┣━━━━╋━━━━╋━━━━┫
┃    ┃    ┃    ┃
┃ %2s ┃ %2s ┃ %2s ┃
┃    ┃    ┃    ┃
┣━━━━╋━━━━╋━━━━┫
┃    ┃    ┃    ┃
┃ %2s ┃ %2s ┃ %2s ┃
┃    ┃    ┃    ┃
┗━━━━┻━━━━┻━━━━┛\n\n"

print_board()
{
    gameBanner
    tput rev
    echo "Play:"
    echo ""
    tput sgr0
    printf "$fmt" "${board[@]}"
}

borders()
{
  local x=$(( ${empty:=0} % 3 )) y=$(( $empty / 3 ))
  unset bordering
  [ $y -lt 2 ] && bordering[$A]=$(( $empty + 3 ))
  [ $y -gt 0 ] && bordering[$B]=$(( $empty - 3 ))
  [ $x -gt 0 ] && bordering[$C]=$(( $empty - 1 ))
  [ $x -lt 2 ] && bordering[$D]=$(( $empty + 1 ))
}


move()
{
  movelist="$empty $movelist"
  moves=$(( $moves + 1 ))
  board[$empty]=${board[$1]}
  board[$1]=""
  last=$empty
  empty=$1
}

random_move()
{
  local sq
  while :
  do
     sq=$(( $RANDOM % $# + 1 ))
     sq=${!sq}
     [ $sq -ne ${last:-666} ] &&
        break
  done
  move "$sq"
}

shuffle() 
{
  local n=0 max=$(( $RANDOM % 2 + 2 ))
  while [ $(( n += 1 )) -lt $max ]
  do
     borders
     random_move "${bordering[@]}"
  done
}

newGame() {
    print_board
    echo "Game Rules:"
    echo "1. Use Arrow Keys to Move the Tiles."
    echo "2. Target of This Game is to Make the Tiles Sorted like Above."
    echo "3. Try to Minimize the Number of Moves to Solve the Game."
    echo ""
    echo "Are you ready? Press Enter to Start the Game... "
    shuffle
    moves=0
    read -s
    clear
    while :
        do
        borders
        print_board
        printf "\t%d move" "$moves"
        [ $moves -ne 1 ] && printf "s"
        if [ "${board[*]}" = "${target[*]}" ]
        then
            print_board
            led="./leaderboard.score"
            dir="./scores/$username.sco"
            linesled=$(wc -l < $led)
            echo "$linesled $moves $username" >> $led
            linesdir=$(wc -l < $dir)
            echo "$linesdir $moves" >> $dir
            sortLeaderboard
            #sortScore
            printf "Congratulations, Completed in %d moves! Press Anykey to Continue... " "$moves"
            read hold
            break
        fi
        read -sn1 -p $'        \e[K' key

        case $key in
            A) [ -n "${bordering[$A]}" ] && move "${bordering[$A]}" ;;
            B) [ -n "${bordering[$B]}" ] && move "${bordering[$B]}" ;;
            C) [ -n "${bordering[$C]}" ] && move "${bordering[$C]}" ;;
            D) [ -n "${bordering[$D]}" ] && move "${bordering[$D]}" ;;
            q) echo; break ;;
        esac
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
    #sort -k1,1 -k2,2 $tmpdir > $tmp2dir
    sort $tmpdir > $tmp2dir
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

#Game Code End

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


