
Chess Simulator Bash Script
======================================

Overview
--------

Developed a Bash script `chess_sim.sh` that simulates a chess game using Portable Game Notation (PGN) files. The script will utilize `parse_moves.py`, a provided Python script, to convert PGN moves to Universal Chess Interface (UCI) format for easier manipulation.

Objectives
----------

*   Parse chess games from PGN files.
*   Display and manipulate chess games in the terminal using Bash.
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

*   **chess\_games/**: Contains various `.pgn` files.
*   **parse\_moves.py**: Python script for converting notation.
*   **chess\_sim.sh**: Your Bash script to run the simulation.
