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
    write('Select source X coordinate '),
    read(X1),
    write('Select source Z coordinate '),
    read(Z1),
    write('Select destination X coordinate '),
    read(X2),
    write('Select destination Z coordinate '),
    read(Z2),
    write('Select the type of structure to place (colony or trade station) '),
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
    cls,
    write('\n----------- Current Turn: Faction One -----------\n'),
    printboard(Board),
    readPlayerInput(X1, Z1, X2, Z2, Structure),
    validatePlayerInput(factionOne, Board, X1, Z1, X2, Z2, Structure),
    moveShip(factionOne, Board, X1, Z1, X2, Z2, TempBoard),
    placeStructure(Faction, TempBoard, Structure, X2, Z2, NewBoard),!.
playFactionTwo(Board, NewBoard) :-
    repeat,
    cls,
    write('\n----------- Current Turn: Faction Two -----------\n'),
    printboard(Board),
    readPlayerInput(X1, Z1, X2, Z2, Structure),
    validatePlayerInput(factionTwo, Board, X1, Z1, X2, Z2, Structure),
    moveShip(factionTwo, Board, X1, Z1, X2, Z2, TempBoard),
    placeStructure(Faction, TempBoard, Structure, X2, Z2, NewBoard),!.

play(Turn, Board) :-
    Faction is Turn mod 2,
    playerMove(Faction, Board, NewBoard),
    NTurn is Turn+1,
    play(NTurn, NewBoard).

calculatePlanetarySystemPoints(Faction, Board, Points) :-
    calculatePlanetarySystemPoints(Faction, Board, 0, 0, 0, Points),!.
calculatePlanetarySystemPoints(_, Board, X, Z, CurrentPoints, CurrentPoints) :-
    getBoardSize(Board, Size),
    X == Size,
    Z == Size.
calculatePlanetarySystemPoints(Faction, Board, X, Z, CurrentPoints, Points) :-
    getBoardSize(Board, Size),
    X == Size,
    NX is 0,
    NZ is Z+1,
    calculatePlanetarySystemPoints(Faction, Board, NX, NZ, CurrentPoints, Points).
calculatePlanetarySystemPoints(Faction, Board, X, Z, CurrentPoints, Points) :-
    getBoardSize(Board, Size),
    X < Size,
    getStructureLayer(X, Z, Board, Structure),
    owns(Owner, Structure),
    Owner == Faction,
    getMapLayer(X, Z, Board, System),
    onePlanetSystem(System),
    NCurrentPoints is CurrentPoints+1,
    NX is X+1,
    calculatePlanetarySystemPoints(Faction, Board, NX, Z, NCurrentPoints, Points).
calculatePlanetarySystemPoints(Faction, Board, X, Z, CurrentPoints, Points) :-
    getBoardSize(Board, Size),
    X < Size,
    getStructureLayer(X, Z, Board, Structure),
    owns(Owner, Structure),
    Owner == Faction,
    getMapLayer(X, Z, Board, System),
    twoPlanetSystem(System),
    NCurrentPoints is CurrentPoints+2,
    NX is X+1,
    calculatePlanetarySystemPoints(Faction, Board, NX, Z, NCurrentPoints, Points).
calculatePlanetarySystemPoints(Faction, Board, X, Z, CurrentPoints, Points) :-
    getBoardSize(Board, Size),
    X < Size,
    getStructureLayer(X, Z, Board, Structure),
    owns(Owner, Structure),
    Owner == Faction,
    getMapLayer(X, Z, Board, System),
    threePlanetSystem(System),
    NCurrentPoints is CurrentPoints+3,
    NX is X+1,
    calculatePlanetarySystemPoints(Faction, Board, NX, Z, NCurrentPoints, Points). 
calculatePlanetarySystemPoints(Faction, Board, X, Z, CurrentPoints, Points) :-
    getBoardSize(Board, Size),
    X < Size,
    NX is X+1,
    calculatePlanetarySystemPoints(Faction, Board, NX, Z, CurrentPoints, Points).

hasEnemyStructure(Faction, Board, X, Z, Result) :-
    getStructureLayer(X, Z, Board, Structure),
    (colony(Structure) ; tradeStation(Structure)),
    \+ owns(Faction, Structure),
    Result is 1,!.
hasEnemyStructure(Faction, Board, X, Z, Result) :-
    getMapLayer(X, Z, Board, System),
    baseSystem(System),
    \+ owns(Faction, System),
    Result is 1,!.

hasEnemyStructureLeft(Faction, Board, 0, Z, Result) :-
    Result is 0,!.
hasEnemyStructureLeft(Faction, Board, X, Z, Result) :-
    X > 0,
    X1 is X-1,
    hasEnemyStructure(Faction, Board, X1, Z, Result),!.

hasEnemyStructureRight(Faction, Board, X, Z, Result) :-
    getBoardSize(Board, Size),
    NSize is Size-1,
    X == NSize,
    Result is 0,!.
hasEnemyStructureRight(Faction, Board, X, Z, Result) :-
    getBoardSize(Board, Size),
    NSize is Size-1,
    X < NSize,
    X1 is X+1,
    hasEnemyStructure(Faction, Board, X1, Z, Result),!.

hasEnemyStructureTop(Faction, Board, X, 0, Result) :-
    Result is 0,!.
hasEnemyStructureTop(Faction, Board, X, Z, Result) :-
    Z < 0,
    Z1 is Z-1,
    hasEnemyStructure(Faction, Board, X, Z1, Result),!.

hasEnemyStructureBottom(Faction, Board, X, Z, Result) :-
    getBoardSize(Board, Size),
    NSize is Size-1,
    Z == NSize,
    Result is 0,!.
hasEnemyStructureBottom(Faction, Board, X, Z, Result) :-
    getBoardSize(Board, Size),
    NSize is Size-1,
    Z < NSize,
    Z1 is Z+1,
    hasEnemyStructure(Faction, Board, X, Z1, Result),!.

hasEnemyStructureBottomLeft(Faction, Board, 0, Z, Result) :-
    Result is 0,!.
hasEnemyStructureBottomLeft(Faction, Board, X, Z, Result) :-
    getBoardSize(Board, Size),
    NSize is Size-1,
    Z == NSize,
    Result is 0,!.
hasEnemyStructureBottomLeft(Faction, Board, X, Z, Result) :-
    X > 0,
    getBoardSize(Board, Size),
    NSize is Size-1,
    Z < NSize,
    X1 is X-1,
    Z1 is Z+1,
    hasEnemyStructure(Faction, Board, X1, Z1, Result),!.

hasEnemyStructureTopRight(Faction, Board, X, 0, Result) :-
    Result is  0,!.
hasEnemyStructureTopRight(Faction, Board, X, Z, Result) :-
    getBoardSize(Board, Size),
    NSize is Size-1,
    X == NSize,
    Result is 0,!.
hasEnemyStructureTopRight(Faction, Board, X, Z, Result) :-
    Z > 0,
    getBoardSize(Board, Size),
    NSize is Size-1,
    X < NSize,
    X1 is X+1,
    Z1 is Z-1,
    hasEnemyStructure(Faction, Board, X, Z, Result),!.
    
countAdjacentEnemyStructures(Faction, Board, X, Z, Result) :-
    Current is 0,
    hasEnemyStructureLeft(Faction, Board, X, Z, Left),
    Current1 is Current+Left,
    hasEnemyStructureRight(Faction, Board, X, Z, Right),
    Current2 is Current1+Right,
    hasEnemyStructureTop(Faction, Board, X, Z, Top),
    Current3 is Current2+Top,
    hasEnemyStructureBottom(Faction, Board, X, Z, Bottom),
    Current4 is Current3+Bottom,
    hasEnemyStructureTopRight(Faction, Board, X, Z, TopRight),
    Current5 is Current4+TopRight,
    hasEnemyStructureBottomLeft(Faction, Board, X, Z, BottomLeft),
    Result is Current5+BottomLeft.

calculateTradeStationPoints(Faction, Board, X, Z, Points) :-
    getBoardSize(Board, Size),
    X < Size,
    getStructureLayer(X, Z, Board, Structure),
    tradeStation(Structure),
    owns(Owner, Structure),
    Owner == Faction,
    countAdjacentEnemyStructures(Faction, Board, X, Z, Points),!.

countNebulae(Faction, Board, Colour, Number) :-
    countNebulae(Faction, Board, 0, 0, Colour, 0, Number), !.
countNebulae(Faction, Board, X, Z, Colour, CurrentNumber, CurrentNumber) :-
    getBoardSize(Board, Size),
    X == Size,
    Z == Size.
countNebulae(Faction, Board, X, Z, Colour, CurrentNumber, Number) :-
    getBoardSize(Board, Size),
    X == Size,
    NX is 0,
    NZ is Z+1,
    countNebulae(Faction, Board, NX, NZ, Colour, CurrentNumber, Number).
countNebulae(Faction, Board, X, Z, 'red', CurrentNumber, Number) :-
    getBoardSize(Board, Size),
    X < Size,
    getMapLayer(X, Z, Board, System),
    redNebulaeSystem(System),
    getStructureLayer(X, Z, Board, Structure),
    owns(Owner, Structure),
    Faction == Owner,
    NCurrentNumber is CurrentNumber+1,
    NX is X+1,
    countNebulae(Faction, Board, NX, Z, 'red', NCurrentNumber, Number).
countNebulae(Faction, Board, X, Z, 'green', CurrentNumber, Number) :-
    getBoardSize(Board, Size),
    X < Size,
    getMapLayer(X, Z, Board, System),
    greenNebulaeSystem(System),
    getStructureLayer(X, Z, Board, Structure),
    owns(Owner, Structure),
    Faction == Owner,
    NCurrentNumber is CurrentNumber+1,
    NX is X+1,
    countNebulae(Faction, Board, NX, Z, 'green', NCurrentNumber, Number).
countNebulae(Faction, Board, X, Z, 'blue', CurrentNumber, Number) :-
    getBoardSize(Board, Size),
    X < Size,
    getMapLayer(X, Z, Board, System),
    blueNebulaeSystem(System),
    getStructureLayer(X, Z, Board, Structure),
    owns(Owner, Structure),
    Faction == Owner,
    NCurrentNumber is CurrentNumber+1,
    NX is X+1,
    countNebulae(Faction, Board, NX, Z, 'blue', NCurrentNumber, Number).
countNebulae(Faction, Board, X, Z, Colour, NCurrentNumber, Number) :-
    getBoardSize(Board, Size),
    X < Size,
    NX is X+1,
    countNebulae(Faction, Board, NX, Z, Colour, NCurrentNumber, Number).

nebulaePointsMultiplier(0, Points) :-
    Points is 0.
nebulaePointsMultiplier(1, Points) :-
    Points is 2.
nebulaePointsMultiplier(2, Points) :-
    Points is 5.
nebulaePointsMultiplier(_, Points) :-
    Points is 8.

calculateNebulaePoints(Faction, Board, Points) :-
    countNebulae(Faction, Board, 'red', RedNumber),
    nebulaePointsMultiplier(RedNumber, RedPoints),
    countNebulae(Faction, Board, 'green', GreenNumber),
    nebulaePointsMultiplier(GreenNumber, GreenPoints),
    CurrentTotal is RedPoints + GreenPoints,
    countNebulae(Faction, Board, 'blue', BlueNumber),
    nebulaePointsMultiplier(BlueNumber, BluePoints),
    Points is CurrentTotal + BluePoints,!.
    
    

    
    

	
