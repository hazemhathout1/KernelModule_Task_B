#!/bin/bash 

if [ -f process_monitor_config ]; then
    source process_monitor_config
fi

## Get list of the usernames in the system
mapfile -t Mylist < <( awk -F: '$3>=1000 && $1 != "nobody" {print $1}' /etc/passwd)
#for item in "${Mylist[@]}"; do
#    echo "$item"
#done
declare -i x=1
declare -i y=1
declare -i interval=5
options=("list running process" "process Info" "Kill" "Process Statistics"  "search and filter" "Quit")
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

check_cpu_usage()
{
    echo ""
    echo "Alert System"
    #(top -n1 -b | grep -E '^ *PID' )
    top_process_perc=$(top -n 1 -b | grep -E '^ * [0-9]+' | head -n 1 | awk '{print $9}')
    top_process_name=$(top -n 1 -b | grep -E '^ * [0-9]+' | head -n 1 | awk '{print $12}')
    if (( $(echo "${top_process_perc} > ${CPU_THRESHOLD}" | bc -l) )); then
        echo "We have a process Exceeded the Threshold"
        echo $top_process_name
        echo $top_process_perc
        #echo $CPU_THRESHOLD
    else
        echo "There is no issue in the system"
    fi
    
    
    #cpu_usage=$(ps -p "$top_process" -o %cpu=)
    #echo "The highest cpu usage is:"
    #echo $top_process
}

while true; do
    echo "Real Time Process Monitor"
    echo "----------------------------------"
    print_process_info
    check_cpu_usage
    echo ""
    echo ""
    if read -t "$UPDATE_INTERVAL" -p "Press e to enter Interaction menu or x to exit:" input;then
        if [[ "$input" == "e" ]]; then
            Interactive_menu
        #fi
        elif [[ "$input" == "x" ]]; then
            echo "Thank you"
            break;
            
        fi
    fi
done

