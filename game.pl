/*joga(+TipoDeJogo, +Dificuldade) :-
    inicializacao(+TipoDeJogo),
    repeat,
        joga(+Dificuldade), % final do joga por um cut (!.) para evitar backtracking
        testaTermina,       % alternativamente usar once()
    mostraResultado.

% Guardar o histórico da jogada
assert(+NumDeJogada, +Tabuleiro).

avaliaPosicao(+Tabuleiro, +Jogador, -Valor).

geraMelhorTabuleiro(+Tabuleiro, +Jogador, -MelhorTabuleiro) :-
    geraTabuleiro(+Tabuleiro, -possiveisTabuleiros),
    avaliaTabuleiros(+PossiveisTabuleiros, -MelhorTabuleiro).*/

readPlayerInput(X1, Z1, X2, Z2, Structure) :-
    write('Select source X coordinate: '),
    read(X1),
    write('Select source Z coordinate: '),
    read(Z1),
    write('Select destination X coordinate: '),
    read(X2),
    write('Select destination Z coordinate: '),
    read(Z2),
    write('Select the type of structure to place (colony or trade station): '),
    read(Structure).

validatePlayerInput(Faction, Board, X1, Z1, X2, Z2, Structure) :-
    getBoardSize(Board, Size),
    X1 < Size,
    Z1 < Size,
    X2 < Size,
    Z2 < Size,
    (Structure == 'colony'; Structure == 'trade station').

processPlayerInput(Faction, Board, X1, Z1, X2, Z2, Structure) :-
    repeat,
    readPlayerInput(X1, Z1, X2, Z2, Structure),
    validatePlayerInput(Faction, Board, X1, Z1, X2, Z2, Structure).

playerMove(0, Board, NewBoard) :- playFactionOne(Board, NewBoard).
playerMove(1, Board, NewBoard) :- playFactionTwo(Board, NewBoard).

playFactionOne(Board, NewBoard) :-
    repeat,
    write('\n----------Current Turn: Faction One----------\n'),
    printboard(Board),
    readPlayerInput(X1, Z1, X2, Z2, Structure),
    validatePlayerInput(factionOne, Board, X1, Z1, X2, Z2, Structure),
    moveShip(factionOne, Board, X1, Z1, X2, Z2, TempBoard),
    placeStructure(Faction, TempBoard, Structure, X2, Z2, NewBoard).
playFactionTwo(Board, NewBoard) :-
    repeat,
    write('\n----------Current Turn: Faction Two----------\n'),
    printboard(Board),
    readPlayerInput(X1, Z1, X2, Z2, Structure),
    validatePlayerInput(factionTwo, Board, X1, Z1, X2, Z2, Structure),
    moveShip(factionTwo, Board, X1, Z1, X2, Z2, TempBoard),
    placeStructure(Faction, TempBoard, Structure, X2, Z2, NewBoard).

play(Turn, Board) :-
    Faction is Turn mod 2,
    playerMove(Faction, Board, NewBoard),
    NTurn is Turn+1,
    play(NTurn, NewBoard).
    
