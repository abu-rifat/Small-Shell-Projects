#!/bin/bash

clear
echo "ScoreGame"
echo ""
echo "Welcome to ScoreGame!"
echo "Enter two player's name..."
read -p "Player One: " player1
read -p "Player Two: " player2
echo ""
read -p "Enter anykey for toss.. " hold
tosswinner=$(echo $(( $RANDOM % 2 )))
#echo $tosswinner
fstPlayer=""
secPlayer=""
 case $tosswinner in
    0)
        fstPlayer=$player1
        secPlayer=$player2
    ;;
    1)
        fstPlayer=$player2
        secPlayer=$player1
    ;;
esac
echo "Congratulation, $fstPlayer! You will play first..."
REGEX='^[1-5]{1}$'
while : ; do
    read -p "How many overs(1-5) do you want to play: " overs
    if [[ ! $overs =~ $REGEX ]]
    then
        echo "Please enter the over between 1 to 5..."
    else
        break;
    fi
done

echo $overs
board=( "" "" "" "" "" "" )
values=({0-7})
signs=("." "1" "2" "3" "4" "w" "6")
    fmt="%2s  %2s   %2s   %2s   %2s   %2s"
    fmt="┏━━━━┳━━━━┳━━━━┳━━━━┳━━━━┳━━━━┓
┃    ┃    ┃    ┃    ┃    ┃    ┃
┃ %2s ┃ %2s ┃ %2s ┃ %2s ┃ %2s ┃ %2s ┃
┃    ┃    ┃    ┃    ┃    ┃    ┃
┗━━━━┻━━━━┻━━━━┻━━━━┻━━━━┻━━━━┛\n"


print_box(){
    clear
    echo "ScoreGame"
    echo ""
    printf "$fmt" "${board[@]}"
    echo ""
}

fstScore=$(expr 0)
secScore=$(expr 0)
fstWicket=$(expr 0)
ck=0
print_box
for i in $( eval echo {1..$overs} )
do
    board=( "" "" "" "" "" "" )
    for j in {0..5}
    do
        read -p "Press Enter Key: " hold
        rand=$(echo $(( $RANDOM % 7 )))
        case $rand in
            5)
                fstWicket=$(expr $fstWicket + 1)
            ;;
            *)
                fstScore=$(expr $fstScore + $rand)
            ;;
        esac
        board[$j]=${signs[$rand]}
        print_box
        echo "Player: $fstPlayer, Run: $fstScore, Wicket: $fstWicket"
        echo ""
        case $fstWicket in
            3)
                echo "All out!"
                ck=$(expr 1)
                break
            ;;
            *)
                pass=1
            ;;
        esac
        if [ $ck == 1 ]
        then
            break
        fi
    done
    if [ $ck == 1 ]
    then
        break
    fi
done
target=$(expr $fstScore + 1)
echo "Score for $fstPlayer is $fstScore/$fstWicket."
echo "The target for $secPlayer is $target."
read -p "Enter any key to continue..." hold

secWicket=$(expr 0)
ck=0
board=( "" "" "" "" "" "" )
print_box
for i in $( eval echo {1..$overs} )
do
    board=( "" "" "" "" "" "" )
    for j in {0..5}
    do
        read -p "Press Enter Key: " hold
        rand=$(echo $(( $RANDOM % 7 )))
        case $rand in
            5)
                secWicket=$(expr $secWicket + 1)
            ;;
            *)
                secScore=$(expr $secScore + $rand)
            ;;
        esac
        board[$j]=${signs[$rand]}
        print_box
        echo "Player: $secPlayer, Run: $secScore, Wicket: $secWicket, Target: $target"
        echo ""
        case $secWicket in
            secwicket3)
                read -p "All out! Press any key to continue..." hold
                ck=$(expr 1)
                break
            ;;
            *)
                pass=1
            ;;
        esac
        if [ $secScore -ge $target ]
        then
            ck=$(expr 1)
            break
        fi
        if [ $ck == 1 ]
        then
            break
        fi
    done
    if [ $ck == 1 ]
    then
        break
    fi
done
echo "Score of $fstPlayer: $fstScore/$fstWicket"
echo "Score of $secPlayer: $secScore/$secWicket"
read -p "Enter any key for the match summary..." hold
clear
echo "ScoreGame"
echo ""
echo "Score of $fstPlayer: $fstScore/$fstWicket"
echo "The target was: $target"
echo "Score of $secPlayer: $secScore/$secWicket"
echo ""
if [ $fstScore -gt $secScore ]
then
    echo "Winner is $fstPlayer"
    echo ""
    echo "$secScore, How the looser is feeling now? 😛"
elif [ $fstScore -eq $secScore ]
then
    echo "Match is Draw 😕"
else
    echo "Winner is $secPlayer"
    echo ""
    echo "$fstPlayer, How the looser is feeling now? 😛"
fi
echo ""
echo ""