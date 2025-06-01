#!/bin/bash

MODE="normal"
LOG_ENABLED=false

case $1 in
    -h)
        cat <<EOF
Usage ./autoservmaker.sh [options]

Options:
 -h Show this help message.
 -f Runs this script as a fork.
 -t Runs this script as a thread.
 -s Runs this script as a subshell.
 -l Logs the output of this script.
 -r Restores settings back to default.

How the program works:
You select files to copy and ensure that the destination path is a relative path.
It then zips the files and copies them to your destination.

You may also move, rename or delete files, though this would not include zipping
for obvious reasons.

After you're done with file management you can choose scripts to run such as:
> npm install
> mvn install
> ./your-own-script

That concludes all the possible actions, afterwards you may also check the status
of this script to verify if everything is okay, otherwise you can restart.

After everything is said and done you can select create autoserv option to create
an autoserv.sh script according to your needs.
EOF
        exit 0
        ;;
    -f) MODE="fork" ;;
    -t) MODE="thread" ;;
    -s) MODE="subshell" ;;
    -l) LOG_ENABLED=true ;;
    -r)
        if [[ $EUID -ne 0 ]] && ! groups | grep -q 'sudo\|wheel'; then
            echo "Error: -r option requires admin privileges"
            exit 1
        fi
        rm -rf ./autoserv ./out
        echo "Settings restored to default"
        exit 0
        ;;
    "") 
        ;;
    *) 
        echo "Unknown option: $1"
        exit 1 
        ;;
esac

log_msg() {
    if [[ "$LOG_ENABLED" == true ]]; then
        echo "[$(date)] $1" >> "out/history.log"
    fi
}

main_program() {
    clear
    mkdir -p "./autoserv"
    mkdir -p "./out"

    copy_source="./autoserv/cp_source_paths.as"
    copy_dest="./autoserv/cp_dest_paths.as"
    mv_source="./autoserv/mv_source_paths.as"
    mv_dest="./autoserv/mv_dest_paths.as"
    del_path="./autoserv/delete_paths.as"
    script_path="./autoserv/script_paths"
    autoserv_path="./out/autoserv.sh"
    copy_tar="./out/copied_files.tar.gz"
    basenames="./autoserv/basenames.as"
    autoserv_dir="./autoserv"
    output_dir="./out"

    copy_option() {
        clear
        read -e -p "Source > " source_path
        
        if [[ -n "$source_path" ]]; then
            read -e -p "Destination > " dest_path
            
            if [[ -n "$dest_path" ]]; then
                echo "$source_path" >> $copy_source
                echo "$dest_path" >> $copy_dest            
                echo "Paths saved to $copy_source and $copy_dest"
                log_msg "Copy: $source_path -> $dest_path"
            else
                echo "No destination path entered."
            fi
        else
            echo "No source path entered."
        fi
    }

    move_option() {
        clear
        read -e -p "Source > " source_path
        
        if [[ -n "$source_path" ]]; then
            read -e -p "Destination > " dest_path
            
            if [[ -n "$dest_path" ]]; then
                echo "$source_path" >> $mv_source
                echo "$dest_path" >> $mv_dest
                
                echo "Paths saved to $mv_source and $mv_dest"
                log_msg "Move: $source_path -> $dest_path"
            else
                echo "No destination path entered."
            fi
        else
            echo "No source path entered."
        fi
    }

    delete_option() {
        clear
        read -e -p "File path to delete > " file_to_delete
        if [[ -n "$file_to_delete" ]]; then
            echo "$file_to_delete" >> $del_path
            echo "File saved to delete $del_path"
            log_msg "Delete: $file_to_delete"
        else
            echo "No paths entered"
        fi
    }

    script_option() {
        clear
        read -e -p "Scripts to execute > " script_to_run
        if [[ -n "$script_to_run" ]]; then
            echo "$script_to_run" >> $script_path
            echo "Script saved."
            log_msg "Script: $script_to_run"
        else
            echo "No scripts entered"
        fi
    }

    status_option() {
        clear
        if [ -f "./$copy_source" ]; then
            less "./$copy_source"
            less "./$copy_dest"
        else
            echo "No copy paths"
        fi

        if [ -f "./$mv_source" ]; then
            less "./$mv_source"
            less "./$mv_dest"
        else
            echo "No move paths"
        fi

        if [ -f "./$del_path" ]; then
            less "./$del_path"
        else
            echo "No delete paths"
        fi

        if [ -f "./$script_path" ]; then
            less "./$script_path"
        else
            echo "No script paths"
        fi
    }

    create_autoserv(){
        clear
        echo "#COPY SECTION" >> $autoserv_path
        if [ -f "./$copy_source" ]; then
            tar -czf "$copy_tar" -T $copy_source
            xargs -n1 basename < $copy_source > $basenames
            echo "Created $copy_tar"

            echo 'tar -xzf "./copied_files.tar.gz"' >> $autoserv_path
            paste "$basenames" "$copy_dest" | while read -r src dst; do
                echo "cp \"$src\" \"$dst\""
            done >> $autoserv_path
        else
            echo "No copy paths, skipping..."
        fi

        echo >> $autoserv_path
        echo "#MOVE SECTION" >> $autoserv_path
        if [ -f "./$mv_source" ]; then
            paste "$mv_source" "$mv_dest" | while read -r src dst; do
                echo "mv \"$src\" \"$dst\""
            done >> $autoserv_path
        fi
        
        echo >> $autoserv_path
        echo "#DELETE SECTION" >> $autoserv_path
        if [ -f "./$del_path" ]; then
            paste "$del_path" | while read -r src; do
            echo "rm -rf \"$src\""
            done >> $autoserv_path
        fi

        echo >> $autoserv_path
        echo "#SCRIPT SECTION" >> $autoserv_path
        if [ -f "./$script_path" ]; then
            paste "$script_path" | while read -r src; do
            echo "\"$src\""
            done >> $autoserv_path
        fi

        chmod +x $autoserv_path
        log_msg "autoserv.sh created"
    }

    clear_option(){
        clear
        rm -rf ./autoserv
        rm -rf ./out
        mkdir -p "./autoserv"
        mkdir -p "./out"
        echo "Files removed, you can start over now"
        log_msg "Files cleared"
    }

    show_menu() {
        echo "=============================="
        echo "= Select an option:          ="
        echo "= 1) Add files to copy       ="
        echo "= 2) Add files to move       ="
        echo "= 3) Add files to remove     ="
        echo "= 4) Run Scripts             ="
        echo "= 5) Status                  ="
        echo "= 6) Create autoserv.sh      ="
        echo "= 9) Start over              ="
        echo "= 0) Exit                    ="
        echo "=============================="
    }

    while true; do
        show_menu
        read -p "Enter your choice: " choice
        case $choice in
            1) copy_option ;;
            2) move_option ;;
            3) delete_option ;;
            4) script_option ;;
            5) status_option ;;
            6) create_autoserv ;;
            9) clear_option ;;
            0) echo "Exiting..."; break ;;
            *) echo "Invalid option, try again." ;;
        esac
        echo ""
    done
}

case $MODE in
    fork)
        main_program "$@" &
        echo "Running in fork mode (PID: $!)"
        log_msg "Fork mode started"
        wait
        ;;
    thread)
        (main_program "$@") &
        echo "Running in thread mode (PID: $!)"
        log_msg "Thread mode started"
        wait
        ;;
    subshell)
        echo "Running in subshell mode"
        log_msg "Subshell mode started"
        (main_program "$@")
        ;;
    *)
        main_program "$@"
        ;;
esac
