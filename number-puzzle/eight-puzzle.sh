#!/bin/bash

scriptname=${0##*/}

board=( {1..8} "" )
target=( "${board[@]}" )
empty=8
last=0
A=0 B=1 C=2 D=3
topleft='\e[0;0H'
nocursor='\e[?25l'
normal=\e[0m\e[?12l\e[?25h

fmt="$nocursor$topleft
     %2s  %2s   %2s
     %2s  %2s   %2s
     %2s  %2s   %2s
"
# ━ ┏ ┛ ┗ ┓ ┃ ┫ ╋ ┣ ︱ ┻ ┳ , ╭ ╮ ╰ ╯ ╱ and ═ ╔ ╝ ╚ ╗ ║ ╣ ╬ ╠ ─ ╩ ╦
fmt="\e[?25l\e[0;0H\n
\t┏━━━━┳━━━━┳━━━━┓
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

check()
{
  if [ "${board[*]}" = "${target[*]}" ]
  then
     print_board
     printf "\a\tCompleted in %d moves\n\n" "$moves"
     exit
  fi
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
  local n=0 max=$(( $RANDOM % 100 + 150 ))
  while [ $(( n += 1 )) -lt $max ]
  do
     borders
     random_move "${bordering[@]}"
  done
}

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
   printf "\t   %d move" "$moves"
   [ $moves -ne 1 ] && printf "s"
   check

   read -sn1 -p $'        \e[K' key

   case $key in
     A) [ -n "${bordering[$A]}" ] && move "${bordering[$A]}" ;;
     B) [ -n "${bordering[$B]}" ] && move "${bordering[$B]}" ;;
     C) [ -n "${bordering[$C]}" ] && move "${bordering[$C]}" ;;
     D) [ -n "${bordering[$D]}" ] && move "${bordering[$D]}" ;;
     q) echo; break ;;
   esac
done