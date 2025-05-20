option_one() {
    clear
    read -e -p "Source > " source_path
    
    if [[ -n "$source_path" ]]; then
        echo "Enter a DESTINATION file path (use tab for autocompletion):"
        read -e -p "Destination > " dest_path
        
        if [[ -n "$dest_path" ]]; then
            echo "Source: $source_path"
            echo "Destination: $dest_path"
            
            # Save to separate files
            echo "$source_path" >> copy_source_paths.txt
            echo "$dest_path" >> copy_destination_paths.txt
            
            echo "Paths saved to copy_source_paths.txt and copy_destination_paths.txt"
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
            echo "Source: $source_path"
            echo "Destination: $dest_path"
            
            # Save to separate files
            echo "$source_path" >> move_source_paths.txt
            echo "$dest_path" >> move_destination_paths.txt
            
            echo "Paths saved to move_source_paths.txt and move_destination_paths.txt"
        else
            echo "No destination path entered."
        fi
    else
        echo "No source path entered."
    fi
}

option_three() {
    echo "You selected Option three"
}

option_four() {
    echo "You selected Option four"
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
