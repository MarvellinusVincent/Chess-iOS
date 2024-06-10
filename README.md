# Chess-iOS
A single player, and pass &amp; play chess game for iOS mobile devices. Whether you're a chess enthusiast or a casual player, this app provides an excellent platform to play and improve your chess skills. The app supports both single-player mode against an AI opponent and pass & play mode to enjoy chess with friends on the same device. Feel free to fork and submit pull requests to improve the app!

## To-Do List
- [x] Label (A-H, 1-8) colors should be different for odd and even tiles. It should also differ based on the board theme chosen
- [x] Implement AI game engine for single player using a minimax algorithm or a monte carlo tree
- [x] Implement the undo functionality
- [x] Implement optional show legal moves, highlight moves, and sound 
- [x] Promoting a pawn should have its choices to be smaller on the screen with the text label beside it
- [x] Implement different levels for AI
- [x] Implement functionality to start with black against AI
- [x] Change board theme highlights and board theme colors to make it look better
- [x] Detect draw conditions such as repetition (3X) and insufficient material (eg. king v king, minor piece and king vs king)
- [x] Add piece moves on top of the board for users to be able to copy and paste their moves and check it in an engine
- [ ] Add piece movement for if there can be 2 knights going to the same position as well as 2 rooks
- [ ] Implement functionality for users to set time (bullet, blitz, rapid)
- [x] Have a resign button
- [ ] Implement multiplayer functionality for users within the same wifi network

## Needs fixing
- [ ] Highlight piece color depending on board theme
- [ ] AI game engine nowhere near perfect even though it works for now (roughly 600 elo)
- [ ] The single player piece movemenet history view needs to be updated as it currently shows all the moves for the minimax instead of just the final one
