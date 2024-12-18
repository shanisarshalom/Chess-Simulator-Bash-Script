#!/bin/bash

# Check arguments number, accept exactly two arguments.
check_args_num() {
    if [ "$#" -ne 2 ]; then # "$#" represents the number of arguments.
    # If the number of arguments is incorrect, print message and exit with status 1.
        echo "Usage: $0 <source_pgn_file> <destination_directory>"
        exit 1
    fi
}

# Convert arguments to variables.
convert_arguments() {
    input_file="$1"
    dest_dir="$2"
}

# File existence check.
check_file_exists() {
    # If the source file does not exist, print message and exit with status 1. 
    if [ ! -f "$input_file" ]; then # "[" - test command with f flag to check if the specified file exist.
    # If the destination directory does not exist, create it and print message.
        echo "Error: File '$input_file' does not exist."
        exit 1
    fi
}

# Create the destination directory if it does not exist.
create_dest_dir() {
    if [ ! -d "$dest_dir" ]; then #  [ - test command with d flag to check if the specified path exists and is a directory.
        mkdir -p "$dest_dir"
        echo "Created directory '$dest_dir'."
    fi
}

# Split multiple chess games from the source PGN file into individual files.
split_PGN() {
    # local variables
    local game_count=0 # initializes to 0.
    local game_content="" # initializes as an empty string.
    local origin_file_name=$(basename "$input_file" .pgn) # extract name of file without ".pgn".

    # read line from the input file and assign it to line.
    while IFS= read -r line || [ -n "$line" ]; do # with "IFS" entire line is read as a single string.
        # Check if the current line starts with '[Event ', indicating the start of a new game.
        if [[ "$line" =~ ^\[Event\ .* ]]; then
            # If a new event starts and there is already content, save the previous game
            if [[ -n "$game_content" ]]; then
                # increments game_count.
                game_count=$((game_count + 1))
                # save game to a new file.
                local new_file_name="${origin_file_name}_${game_count}.pgn" # name of the file to be saved.
                echo "$game_content" > "$dest_dir/$new_file_name"
                echo "Saved game to $dest_dir/$new_file_name"
                # reset game_content to the next game.
                game_content=""
            fi
        fi
        # Append the current line to the game content
        game_content+="$line"$'\n'
    done < "$input_file"
    # save the last game if there is any content left
    if [[ -n "$game_content" ]]; then
        # increments game_count
        game_count=$((game_count + 1))
         # save game to a new file.
         local new_file_name="${origin_file_name}_${game_count}.pgn" # name of the file to be saved.
        echo "$game_content" > "$dest_dir/$new_file_name"
        echo "Saved game to $dest_dir/$new_file_name"
    fi
    echo "Total games saved: $game_count"
}

# script execution
check_args_num "$@"
convert_arguments "$@"
check_file_exists
create_dest_dir
split_PGN