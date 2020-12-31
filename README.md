# mips-tac-toe

The program begins by prompting the user for _n_, used to create an _n_ by _n_ board.
The opponent (O) starts the game by placing O as close the center as possible.
The game continues until there is a winner or a draw.  

The opponent will use the following strategy:
1. Attempt a winning move in the order of:
>* win by row
>* win by column
>* win by left to right diagonally
>* win by right to left diagonally
2. If no winning moves, it then prevents a win for the player by blocking:
>* row block
>* column block
>* left to right block
>* right to left block
3. If none of the above, it will then take the first space available (top to bottom, left to right).
