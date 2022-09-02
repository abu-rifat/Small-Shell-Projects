#!/bin/bash
#ban="figlet"
#sudo dpkg -s $ban &> /dev/null
#if [ $? -eq 0 ];
#then
#    ok=1;
#else
#    sudo apt install figlet
#fi

validUser=false
curruser=""


if [ ! -d "userpass" ]
then
  mkdir "userpass"
fi

gameBanner () {
    clear
    echo ""
    figlet -f smblock "    8-Puzzle Game"
    echo ""
}

mainMenu () {
    gameBanner
    echo "    N - New User SignUp"
    echo "    L - Existing User Login"
    echo "    E - Exit"
    echo ""
    read -p "    Enter your choice: " option
    case $option in
        N | n)
            signUp
        ;;
        L | l)
            login
        ;;
        E | e)
        exit
        ;;
        *)
        echo "Invalid Choice, Press Anykey to Continue..\n"
        read hold
        ;; 
    esac
}

userMenu () {
    gameBanner
    echo "    Welcome, $username"
    echo "    N - Start New Game"
    echo "    M - My Scoreboard"
    echo "    L - Leaderboard"
    echo "    X - Logout"
    echo "    E - Exit"
    echo ""
    read -p "    Enter your choice: " option
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
            exit
        ;;
        *)
            echo "Invalid Choice, Press Anykey to Continue..\n"
            read hold
        ;; 
    esac
}



signUp () {
    gameBanner
    echo "    New User SignUp:"
    echo ""
    while : ; do
        read -p "    Enter username(Only lowercase English letters): " username
        dir="./userpass/$username.usr"
        REGEX='^[a-z]+$'
        if [[ ! $username =~ $REGEX ]]
        then
            read -p "    Invalid username, want to try again? [Y/N]: " tryagain
            case $tryagain in
            N | n)
                return
                ;;
            esac
        elif [[ -f "$dir" ]]
        then
            read -p "    The username: $username is taken, want to try again? [Y/N]: " tryagain
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
        read -p "    Enter new password(length: 6-10):" password
        REGEX='^.{6,10}$'
        if [[ ! $password =~ $REGEX ]]
        then
            read -p "    Password length must be between 6 to 10 characters, want to try again? [Y/N]: " tryagain
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
        read -p "    Enter the password again:" rePassword
        if [[ ! $password == $rePassword ]]
        then
            read -p "    The two passwords didn't matched, want to try again? [Y/N]: " tryagain
            case $tryagain in
            N | n)
                return
                ;;
            esac
        else
            echo $password > $dir
            validUser=true
            curruser=$username
            read -p "    Welcome $username, press anykey to continue:" hold
            break;
        fi
    done
}

login () {
    gameBanner
    echo "    User Login:"
    echo ""
    while : ; do
        read -p "    Enter username(Only lowercase English letters): " username
        dir="./userpass/$username.usr"
        REGEX='^[a-z]+$'
        if [[ ! $username =~ $REGEX ]]
        then
            read -p "    Invalid username, want to try again? [Y/N]: " tryagain
            case $tryagain in
            N | n)
                return
                ;;
            esac
        elif [[ -f "$dir" ]]
        then
            while : ; do
                read -p "    Enter the password(length: 6-10):" password
                REGEX='^.{6,10}$'
                if [[ ! $password =~ $REGEX ]]
                then
                    read -p "    Password length must be between 6 to 10 characters, want to try again? [Y/N]: " tryagain
                    case $tryagain in
                    N | n)
                        return
                        ;;
                    esac
                else
                    savedPass=$(head -n 1 $dir)
                    if [[ $password = $savedPass ]]
                    then
                        validUser=true
                        curruser=$username
                        read -p "    Welcome $username, press anykey to continue:" hold
                        return;
                    else
                        read -p "    Wrong password, want to try again? [Y/N]: " tryagain
                        case $tryagain in
                        N | n)
                            return
                            ;;
                        esac
                    fi
                fi
            done
            
            
        else
            read -p "    User doesn't exist, want to try again? [Y/N]: " tryagain
            case $tryagain in
            N | n)
                break
                ;;
            esac
        fi
    done
}

logOut() {
    validUser=false
    curruser=""
    read -p "    See you soon, press anykey to continue:" hold
    break;
}

#Game Code

board=( {1..8} "" )
target=( "${board[@]}" )
empty=8
last=0
A=0 B=1 C=2 D=3

fmt="$nocursor$topleft
     %2s  %2s   %2s
     %2s  %2s   %2s
     %2s  %2s   %2s
"

fmt="\t┏━━━━┳━━━━┳━━━━┓
\t┃    ┃    ┃    ┃
\t┃ %2s ┃ %2s ┃ %2s ┃
\t┃    ┃    ┃    ┃
\t┣━━━━╋━━━━╋━━━━┫
\t┃    ┃    ┃    ┃
\t┃ %2s ┃ %2s ┃ %2s ┃
\t┃    ┃    ┃    ┃
\t┣━━━━╋━━━━╋━━━━┫
\t┃    ┃    ┃    ┃
\t┃ %2s ┃ %2s ┃ %2s ┃
\t┃    ┃    ┃    ┃
\t┗━━━━┻━━━━┻━━━━┛\n\n"

print_board()
{
    gameBanner
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
    trap 'printf "$normal"' EXIT
    clear
    print_board
    echo
    printf "
    Use the cursor keys to move the tiles around.
    The game is finished when you return to the
    position shown above.
    Try to complete the puzzle in as few moves
    as possible.
            Press \e[1mENTER\e[0m to continue
    "
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
            printf "\tCompleted in %d moecho "SignUp Working!"ves\n\n" "$moves"
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