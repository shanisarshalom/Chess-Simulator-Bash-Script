
Chess Simulator Bash Script
======================================

Overview
--------

This project includes two Bash scripts designed for working with chess games recorded in Portable Game Notation (PGN) files:
1. `chess_sim.sh`: Simulates chess games by processing PGN files. The script uses a Python utility (parse_moves.py) to convert PGN moves into the Universal Chess Interface (UCI) format. This conversion simplifies the manipulation and analysis of chess games, making it easier to interface with modern chess engines.
2. `split_pgn.sh`: Processes PGN files containing multiple chess games by splitting them into individual game files. Each game is saved as a separate file in a user-specified destination directory, enabling better organization and easier analysis of multiple games.

Objectives
----------

*   Parse chess games from PGN files.
*   Simulate and manipulate chess games directly in the terminal using Bash.
*   Convert chess notation from PGN to UCI using Python.

About PGN and UCI
-----------------

[Portable Game Notation (PGN)](https://en.wikipedia.org/wiki/Portable_Game_Notation) is a standard format for recording chess games, which includes both the moves and metadata about the chess game. PGN files are used to review and replay games.

The [Universal Chess Interface (UCI)](https://en.wikipedia.org/wiki/Universal_Chess_Interface) is a standard protocol for chess engines to communicate with user interfaces. It simplifies chess engine commands and responses, which is beneficial for this project.

The use of `parse_moves.py`
------------------------------

`parse_moves.py` is a Python script that converts chess moves from the PGN format into UCI format.

*   **Input**: A string of chess moves in PGN format.
*   **Output**: A list of moves in UCI format.

**Example Usage**:
`python3 parse_moves.py "1. e4 e5 2. Nf3 Nc6"`

**Output**:
`["e2e4", "e7e5", "g1f3", "b8c6"]`

Repository Contents
-------------------

*   **chess\_game.pgn**: A sample PGN file for testing.
*   **parse\_moves.py**: Python script to convert PGN to UCI notation.
*   **chess\_sim.sh**: Bash script for simulating chess games.
*   **split_pgn.sh**: Bash script to split PGN files into individual games.
*   **pgn_to_split.pgn**: A sample PGN file containing multiple chess games for testing the split_pgn.sh script.
