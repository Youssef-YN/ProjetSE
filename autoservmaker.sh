copy_source="cp_source_paths.as"
copy_dest="cp_dest_paths.as"
mv_source="mv_source_paths.as"
mv_dest="mv_dest_paths.as"
del_path="delete_paths.as"
script_path="script_paths"

option_one() {
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

option_two() {
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

option_three() {
    clear
    read -e -p "File path to delete > " file_to_delete
    if [[ -n "$file_to_delete" ]]; then
	echo "$file_to_delete" >> $del_path
	echo "File saved to delete $del_path"
    else
	echo "No paths entered"
    fi
}

option_four() {
    clear
    read -e -p "Scripts to execute > " script_to_run
    if [[ -n "$script_to_run" ]]; then
	echo "$script_to_run" >> $script_path
	echo "File saved to delete scripts"
    else
	echo "No scripts entered"
    fi
}

option_five() {
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

# Show the menu
show_menu() {
    echo "Select an option:"
    echo "1) Add files to copy"
    echo "2) Add files to move"
    echo "3) Add files to remove"
    echo "4) Run Scripts"
    echo "5) Status"
    echo "6) Create autoserv.sh"
    echo "7) Exit"
}

# Main loop
while true; do
    show_menu
    read -p "Enter your choice [1-5]: " choice
    case $choice in
        1) option_one ;;
        2) option_two ;;
        3) option_three ;;
        4) option_four ;;
	5) option_five ;;
	6) option_six ;;
        7) echo "Exiting..."; break ;;
        *) echo "Invalid option, try again." ;;
    esac
    echo ""
done
