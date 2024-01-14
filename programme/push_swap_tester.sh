#!/bin/sh
numbers=""
spinner="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
delay=0.1

#fonctions

generate_unique_random()
{
    local num
    while true; do
        num=$((1 + RANDOM % 1000000))
		if [[ ! " ${numbers[*]} " =~ " $num " ]]; then
            numbers+="$num "
            break
        fi
    done
}

generate()
{
	for ((i=0; i<count; i++)); do
    	generate_unique_random
	done
}

loading_animation()
{
	local string=$1
    while true; do
        for char in $(echo "$spinner" | grep -o .); do
            printf "\r\033[96m$char $string\033[0m"
            sleep $delay
        done
    done
}

# scrypt beggening

echo "\033[94m╔════════════════════════════════════════════════════════════════════════╗\033[0m"
echo "\033[94m║\033[0m               \033[95mWelcome to \033[0m\033[32;4mpush_swap\033[0m \033[95mtester, by ilyanar 🌸\033[0m  \033[94m	     	 ║\033[0m"
echo "\033[94m╚════════════════════════════════════════════════════════════════════════╝\033[0m\n"

sleep 0.1

# check push_swap file
(loading_animation "checking files.") &
loading_pid=$!
sleep 1
if ! [ -e "./push_swap" ]; then
	printf "\033[1A\033[K"
	printf "\n \033[31mpush_swap file does not exist.\033[0m"
	kill -TERM "$loading_pid"
	disown "$loading_pid"
	wait "$loading_pid"
	exit
fi
kill -TERM "$loading_pid"
disown "$loading_pid"
wait "$loading_pid"
echo "\033[1A\033[K"
#
#
#
printf "\033[3;1;95mDo you want random numbers?\033[0m \033[32m<y/n>\033[0m \033[95m: \033[0m"
read random
echo "\033[2A\033[K"
if [[ "$random" != "y" && "$random" != "n" ]]
then
	printf "\033[31mBad format.\033[0m"
	exit
fi
printf "\033[3;1;95mwhich checker do you want to use?\033[0m \033[32m<1=original/2=bonus>\033[0m \033[95;1m: \033[0m"
read check
echo "\033[1A\033[K"
echo "\033[2A\033[K"

if [[ "$check" != "1" && "$check" != "2" ]]
then
	printf "\033[31mBad format.\033[0m"
	exit
fi

if ! [ -e "./checker" ]; then
	if [ "$check" != "1" ]; then
		printf "\033[1A\033[K"
		printf "\n\033[31mchecker file does not exist.\033[0m"
		exit
	fi
fi
#
# check if files existe
if ! [ -e "./push_swap" ]; then
	printf "\033[31mBad format.\033[0m"
	exit
fi
#
# grep the random numbers

if [ "$random" == "n" ]
then
	echo "\033[94m════════════\033[0m\033[95mARGUMENTS\033[0m\033[94m════════════"
	printf "\033[95mARG = \033[0m"
	read numbers
	(loading_animation "running push_swap...") &
	loading_pid=$!
	echo "\033[94m════════════\033[0m\033[95mTIME\033[0m\033[94m════════════"
	sleep 1
	LINE=$(time ./push_swap $numbers | wc -l)
	kill -TERM "$loading_pid"
	disown "$loading_pid"
	wait "$loading_pid"
	printf "\033[2A\033[K"
elif [ "$random" == "y" ]
then
	printf "\033[3;1;95mHow many numbers you want : \033[0m"
	read count
	echo "\033[1A\033[K"
	echo "\033[2A\033[K"
	if ! [[ "$count" =~ ^[0-9]+$ ]]; then
		printf "\033[31mBad format.\033[0m"
		exit
	fi
	generate
	(loading_animation "running push_swap...") &
	loading_pid=$!
	echo "\n\033[94m════════════\033[0m\033[95mTIME\033[0m\033[94m════════════"
	sleep 0.5
	LINE=$(time ./push_swap $numbers | wc -l)
	echo "\033[1A\033[K"
	kill -TERM "$loading_pid"
	disown "$loading_pid"
	wait "$loading_pid"
	printf "\033[2A\033[K"
else
	echo "\033[31mError bad format.\033[0m"
	exit
fi
#
# the checker

if [ "$check" == "2" ]
then
	CHECK=$(./push_swap $numbers | ./checker $numbers)
else
	CHECK=$(./push_swap $numbers | ./srcs/checker_Mac $numbers)
fi
#
# grep the time
echo "\033[94m════════════\033[0m\033[95mOPERATIONS\033[0m\033[94m════════════\033[0m"
echo "\033[92m"$LINE"\033[0m \033[32minstructions with $count numbers\033[0m"
echo "\033[94m══════════════════════════════════\033[0m\n"
#
# check for checker

if [ "$CHECK" == "OK" ]
then
	echo "✅  \033[95mChecker say : \033[0m[\033[32mOK\033[0m]\033[95m, Good job ;)\033[0m"
elif [ "$CHECK" == "KO" ]
then
	echo "Checker say : ❌ [\033[31mKO\033[0m], Retry it :("
elif [ "$CHECK" == "Error" ]
then
	echo "\033[95mChecker say : \033[0m⛔️ \033[31;4mError\033[0m"
else
	echo "$CHECK bad format"
fi

echo ""
#
# print the stacks
echo "\033[94m════════════════════════\033[0m"
printf "\033[95mDo you want print the stack A and B?\033[0m \033[92m<y/n>\033[95m : \033[0m"
read prints
ARCH=$(sysctl -a | grep Intel)

if [ "$(./push_swap $numbers)" == "Error" ]
then
	printf "\033[92mError\033[0m\n"
elif [ "$prints" == "y" ]
then
	if [ ! "$ARCH" ]
	then
		./push_swap $numbers | ./srcs/print_stack $numbers
	else
		./push_swap $numbers | ./srcs/print_mac_intel $numbers
	fi
fi
#
# print the instructions

echo "\033[94m════════════════════════\033[0m"
printf "\033[95mWant to see the instructions?\033[0m \033[92m<y/n>\033[95m : \033[0m"
read intr

if [ "$(./push_swap $numbers)" == "Error" ]
then
	printf "\033[92mError\033[0m\n"
elif [ "$intr" == "y" ]
then
	./push_swap $numbers
fi
#
#end
#
echo "\033[94m════════════════════════\033[0m"
echo "\n\033[90mEND\033[0m"
exit
