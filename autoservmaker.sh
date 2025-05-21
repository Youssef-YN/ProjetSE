option_one() {
    clear
    read -e -p "Source > " source_path
    
    if [[ -n "$source_path" ]]; then
        read -e -p "Destination > " dest_path
        
        if [[ -n "$dest_path" ]]; then
            echo "$source_path" >> cp_source_paths
            echo "$dest_path" >> cp_destination_paths            
            echo "Paths saved to cp_source_paths and cp_destination_paths"
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
            echo "$source_path" >> mv_source_paths.txt
            echo "$dest_path" >> mv_destination_paths.txt
            
            echo "Paths saved to mv_source_paths and mv_destination_paths"
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
	echo "$file_to_delete" >> delete_paths
	echo "File saved to delete delete_paths"
    else
	echo "No paths entered"
    fi
}

option_four() {
    clear
    read -e -p "Scripts to execute > " script_to_run
    if [[ -n "$script_to_run" ]]; then
	echo "$script_to_run" >> script_paths
	echo "File saved to delete scripts"
    else
	echo "No scripts entered"
    fi
    }

# Show the menu
show_menu() {
    echo "Select an option:"
    echo "1) Copy Files & Directories"
    echo "2) Move Files & Directories"
    echo "3) Delete Files & Directories"
    echo "4) Run Scripts"
    echo "5) Exit"
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
        5) echo "Exiting..."; break ;;
        *) echo "Invalid option, try again." ;;
    esac
    echo ""
done
