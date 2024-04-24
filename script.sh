#!/bin/bash

mapfile -t Mylist < <( awk -F: '$3>=1000 && $1 != "nobody" {print $1}' /etc/passwd)
#for item in "${Mylist[@]}"; do
#    echo "$item"
#done
declare -i x=1
declare -i y=1
declare -i interval=5
options=("list running process" "process Info" "Kill" "Process Statistics" "Real time Monitoring" "search and filter" "Quit")
options2=("Process Name" "Username" "Resource usage" "Return to main menu")


Interactive_menu()
{

while (( "$x" > 0)); do
    echo "Please Choose an Option:"
    select choices in "${options[@]}"; do
        case $choices in
        "list running process")
            ps -o pid,user,ppid,%cpu,%mem,time,cmd,start 
            echo ""
            break;
            ;;
        "process Info")
            echo "Please Enter the PID"
            read PID
            ps -o pid,user,ppid,%cpu,%mem,time,cmd,start -p $PID
            echo ""
            break;
            ;;
        "Kill")
            echo "Please Enter the PID"
            read PID
            kill -9 $PID
            echo "Process is killed successufuly"
            echo ""
            break;
            ;;
        "Process Statistics")
            echo "Total number of processes: $(ps aux | wc -l)"
            echo ""
            echo "Memory usage"
            free -m
            echo ""
            echo "CPU Usage"
            uptime
            echo ""
            break;
            ;;
        "search and filter")
            echo ""
            echo "Please Choose How do you want to filter your search"
            select choice in "${options2[@]}"; do
                case $choice in 
                "Process Name")
                echo "Please Enter The process name"
                read p_name
                mapfile -t pidList < <(pidof $p_name)
                for item in "${pidList[@]}"; do
                    ps -o pid,user,ppid,%cpu,%mem,time,cmd,start -p ${item}
                    echo ""
                done
                break;
                ;;
                "Return to main menu")
                echo ""
                break;
                ;;
                "Username")
                echo ""
                echo "Please Choose a user"
                select item in "root" "${Mylist[@]}"; do
                    echo ""
                    case $item in
                    "root")
                        ps -l -F -u root
                        echo ""
                        break;
                        ;;
                    "${Mylist[0]}")
                        ps -l -F -u ${Mylist[0]}
                        echo ""
                        break;
                        ;;
                    "${Mylist[1]}")
                        ps -l -F -u ${Mylist[1]}
                        echo ""
                        break;
                        ;;
                    esac
                done
                break;
                ;;
                esac
            done
            break;
            ;;

        "Quit")
            x=0
            echo "Exiting"
            break;
            ;;
        *)
        esac
    done
done
}

print_process_info()
{
    top -n 1 -b | head -n 35
}

while true; do
    echo "Real Time Process Monitor"
    echo "----------------------------------"
    print_process_info
    echo ""
    echo ""
    if read -t "$interval" -p "Press e to enter Interaction menu or x to exit:" input;then
        if [[ "$input" == "e" ]]; then
            Interactive_menu
        #fi
        elif [[ "$input" == "x" ]]; then
            echo "Thank you"
            break;
            
        fi
    fi
done

