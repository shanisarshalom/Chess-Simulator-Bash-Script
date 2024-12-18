#!/bin/bash

# Verify that input has one argument.
check_input () {
    if [ "$#" -ne 1 ]; then
        echo "Usage: $0 <path_to_pgn_file>"
        exit 1
    fi
}

# Convert argument to variable.
convert_argument() {
    input_file="$1"
}

# Extract metadata from PGN file.
extract_metadata() {
    metadata=$(grep -E "^\[" "$input_file")
}

# Print metadata of game.
print_metadata() {
    echo "Metadata from PGN file:"
    echo "$metadata"
}

# Convert PGN moves to UCI using the provided Python script.
convert_PGN_to_UCI() {
    # read the PGN file content and save as a string in input_file_string.
    input_file_string=$(cat "$input_file")
    # run the Python script and save the list of moves in UCI format.
    uci_moves=($(python3 parse_moves.py "$input_file_string"))
}

# Initialize the board.
initialize_board() {
    board=(
        "r n b q k b n r"
        "p p p p p p p p"
        ". . . . . . . ."
        ". . . . . . . ."
        ". . . . . . . ."
        ". . . . . . . ."
        "P P P P P P P P"
        "R N B Q K B N R"
    )
}

# Print current game board.
print_board() {
    echo -e "\nMove $current_move_num/$max_moves"
    # print columns headers.
    echo "  a b c d e f g h"
    # print row one by one - row number, board row and row number.
    for ((i=0; i<8; i++)); do
        echo "$((8-i)) ${board[i]} $((8-i))"
    done
    # print columns headers.
    echo "  a b c d e f g h"
}

# Handle spacial move, if it is nmot spacial move call update_regular_move function. 
update_board() {
    local move_to_do="$1"
    if [[ "$move_to_do" == "e1g1" && "${board[7]:8:1}" == "K" && "${board[7]:14:1}" == "R" ]]; then
        # White King-side castling.
        local row_to_edit="${board[7]}"
        row_to_edit=$(echo "$row_to_edit" | sed "s/././$((4 * 2 + 1))") # clear the King from e1.
        row_to_edit=$(echo "$row_to_edit" | sed "s/././$((7 * 2 + 1))") # clear the Rook from h1.
        row_to_edit=$(echo "$row_to_edit" | sed "s/./K/$((6 * 2 + 1))") # place King on g1.
        row_to_edit=$(echo "$row_to_edit" | sed "s/./R/$((5 * 2 + 1))") # place Rook on f1.
        board[7]="$row_to_edit"

    elif [[ "$move_to_do" == "e8g8" && "${board[0]:8:1}" == "k" && "${board[0]:14:1}" == "r" ]]; then
        # Black King-side castling
        local row_to_edit="${board[0]}"
        row_to_edit=$(echo "$row_to_edit" | sed "s/././$((4 * 2 + 1))") # clear the King from e8.
        row_to_edit=$(echo "$row_to_edit" | sed "s/././$((7 * 2 + 1))") # clear the Rook from h8.
        row_to_edit=$(echo "$row_to_edit" | sed "s/./k/$((6 * 2 + 1))") # place King on g8.
        row_to_edit=$(echo "$row_to_edit" | sed "s/./r/$((5 * 2 + 1))") # place Rook on f8.
        board[0]="$row_to_edit"

    elif [[ "$move_to_do" == "e1c1" && "${board[7]:8:1}" == "K" && "${board[7]:0:1}" == "R" ]]; then
        # White Queen-side castling.
        local row_to_edit="${board[7]}"
        row_to_edit=$(echo "$row_to_edit" | sed "s/././$((4 * 2 + 1))") # clear the King from e1.
        row_to_edit=$(echo "$row_to_edit" | sed "s/././$((0 * 2 + 1))") # clear the Rook from a1.
        row_to_edit=$(echo "$row_to_edit" | sed "s/./K/$((2 * 2 + 1))") # place King on c1.
        row_to_edit=$(echo "$row_to_edit" | sed "s/./R/$((3 * 2 + 1))") # place Rook on d1.
        board[7]="$row_to_edit"

    elif [[ "$move_to_do" == "e8c8" && "${board[0]:8:1}" == "k" && "${board[0]:0:1}" == "r" ]]; then
        # Black Queen-side castling.
        local row_to_edit="${board[0]}"
        row_to_edit=$(echo "$row_to_edit" | sed "s/././$((4 * 2 + 1))") # clear the King from e8.
        row_to_edit=$(echo "$row_to_edit" | sed "s/././$((0 * 2 + 1))") # clear the Rook from a8.
        row_to_edit=$(echo "$row_to_edit" | sed "s/./k/$((2 * 2 + 1))") # place King on c8.
        row_to_edit=$(echo "$row_to_edit" | sed "s/./r/$((3 * 2 + 1))") # place Rook on d8.
        board[0]="$row_to_edit"

    else
        # handle regular moves.
        update_regular_move "$move_to_do"
    fi
}

# Move the piece on board literally as expected in UCI.
update_regular_move() {
    local move_to_do="$1"
    local from_col=$(( $(printf "%d" "'${move_to_do:0:1}") - 97 )) # convert column character to index.
    local from_row=$(( 8 - ${move_to_do:1:1} )) # convert row number to index.
    local to_col=$(( $(printf "%d" "'${move_to_do:2:1}") - 97 ))
    local to_row=$(( 8 - ${move_to_do:3:1} ))

    # get the row to be move from.
    local from_row_str="${board[$from_row]}"
    # extract the piece using the column index.
    local piece="${from_row_str:$((from_col * 2)):1}"

    # handle Promotion.
    if [[ ${#move_to_do} -eq 5 ]]; then
        # promotion is indicated by the 5th character in UCI foramt.
        local promoted_piece="${move_to_do:4:1}"
        piece="${promoted_piece}"
    fi

    # update the from_row to with "." instead of piece to move.
    local new_from_row=$(echo "$from_row_str" | sed "s/././$((from_col * 2 + 1))")
    board[$from_row]="$new_from_row"

    # get the row where the piece is to be placed.
    local to_row_str="${board[$to_row]}"
    local new_to_row=$(echo "$to_row_str" | sed "s/./$piece/$((to_col * 2 + 1))")
    board[$to_row]="$new_to_row"
}

# Apply move to board.
apply_move() {
    # get move from array.
    local move_to_do="${uci_moves[$current_move_num]}"
    # call function to update the board.
    update_board "$move_to_do"
}

handle_user_input() {
    # infinite loop to keep reading user input. it will stop if the user ask to exit.
    while true; do
        # Prompt for input.
        echo -n "Press 'd' to move forward, 'a' to move back, 'w' to go to the start, 's' to go to the end, 'q' to quit:"
        # Read the entire user input.
        read -r -s input    
        # extract the first character and assign it to `key`.
        key="${input:0:1}"
        # switch case to handle different inputs.
        case $key in

            # next move from the moves list.
            d) 
                # check there is available move.
                if [ $current_move_num -lt $max_moves ]; then
                    # apply the next move in the list.
                    apply_move
                    ((current_move_num++))
                    print_board
                else # If all moves have been displayed, print message.
                    echo
                    echo "No more moves available."
                fi
                ;;

            # undo the last move, reverting the board to the previous state.
            a)
                if [ $current_move_num -gt 0 ]; then
                    # decrement the move index to undo the last move.
                    ((current_move_num--))
                    # reinitialize the board to the starting position.
                    initialize_board
                    # replay all the moves up to the current move index.
                    for ((i=0; i<$current_move_num; i++)); do
                        local move="${uci_moves[$i]}"
                        update_board "$move"
                    done
                    print_board
                else
                    # if no moves have been made yet, pressing 'a' will have no effect.
                    print_board
                fi
                ;;

            # reset the board to its initial state.
            w)
                current_move_num=0
                initialize_board
                print_board
                ;;

            # apply all moves in sequence until the end of the game is reached.
            s)
                current_move_num=0
                initialize_board
                # loop through all moves and apply them.
                while [ $current_move_num -lt $max_moves ]; do
                    apply_move
                    ((current_move_num++))
                done
                # print the final board state after all moves have been applied.
                print_board
                ;;

            # exit the script and end the session.
            q)
                echo
                echo "Exiting."
                echo "End of game."
                break
                ;;

            # invalid input.
            *)
                echo
                echo "Invalid key pressed: $key"
                ;;
        esac
    done
}

# Script execution.
check_input "$@"
convert_argument "$@"
extract_metadata
print_metadata
convert_PGN_to_UCI
current_move_num=0
max_moves=${#uci_moves[@]}
initialize_board
print_board
handle_user_input
