#!/bin/bash

# Options
if [[ $1 == "-h" ]]; then
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
fi


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
    # Phase 1: hna on va faire des choses pour faciliter les travaux d'autoserv
    echo "#COPY SECTION" >> $autoserv_path
    if [ -f "./$copy_source" ]; then
        tar -czf "$copy_tar" -T $copy_source
        xargs -n1 basename < $copy_source > $basenames
        echo "Created $copy_tar"

        echo 'tar -xzf "./out/copied_files.tar.gz"' >> $autoserv_path
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


    # Phase 2:
    # echo 'tar -xzf "$copy_tar"' > $autoserv_path
    # paste "$basenames" "$copy_dest" | while read -r src dst; do
    #     echo "cp \"$src\" \"$dst\""
    # done > $autoserv_path


    

    chmod +x $autoserv_path
}

clear_option(){
    clear
    rm -rf ./autoserv
    rm -rf ./out
    mkdir -p "./autoserv"
    mkdir -p "./out"
    echo "Files removed, you can start over now"
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

# Main loop
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
