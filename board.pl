% Initial Board Definition

board([[[' ',v,' '],[' ',v,' '],[' ',v,' '],['A',g,' '],['A',g,' '],[' ',2,' '],[' ',0,' '],[' ',v,' '],[' ',v,' ']],
       [[' ',v,' '],[' ',v,' '],['A',g,' '],['A',g,' '],[' ',1,' '],[' ',b,' '],[' ',1,' '],[' ',2,' '],[' ',1,' ']],
       [[' ',v,' '],[' ',v,' '],[' ',0,' '],[' ',1,' '],[' ',3,' '],[' ',z,o],[' ',3,' '],[' ',w,' '],[' ',0,' ']],
       [[' ',v,' '],[' ',1,' '],[' ',w,' '],[' ',2,' '],[' ',1,' '],[' ',2,' '],[' ',1,' '],[' ',1,' '],[' ',v,' ']],
       [[' ',v,' '],[' ',3,' '],[' ',1,' '],[' ',1,' '],[' ',z,' '],[' ',1,' '],[' ',1,' '],[' ',0,' '],[' ',v,' ']],
       [[' ',v,' '],[' ',0,' '],[' ',1,' '],[' ',1,' '],[' ',2,' '],[' ',1,' '],[' ',w,' '],[' ',3,' '],[' ',v,' ']],
       [[' ',3,' '],[' ',b,' '],[' ',2,' '],[' ',3,' '],[' ',1,' '],[' ',1,' '],[' ',2,' '],[' ',v,' '],[' ',v,' ']],
       [[' ',1,' '],[' ',0,' '],[' ',z,' '],[' ',w,' '],[' ',1,' '],['B',h,' '],['B',h,' '],[' ',v,' '],[' ',v,' ']],
       [[' ',v,' '],[' ',v,' '],[' ',1,' '],[' ',0,' '],['B',h,' '],['B',h,' '],[' ',v,' '],[' ',v,' '],[' ',v,' ']]]).

% Getters
	
getBoardCell(Px,0,[X|_],Cell) :-
    Px >= 0,
    getBoardCell(Px,X,Cell).
getBoardCell( Px, Pz, [_|Ys], Cell) :-
    Px >= 0,
    Pz > 0,
    NPz is Pz - 1,
    getBoardCell(Px,NPz,Ys,Cell).
getBoardCell(0,[Cell|_],Cell).
getBoardCell(Px,[_|Ys], Cell) :-
    Px > 0,
    NPx is Px - 1,
    getBoardCell(NPx,Ys,Cell).

getCellLayer(0, [Value|_], Value).
getCellLayer(Index, [_|Ys], Value) :-
    Index > 0,
    Index < 3,
    NIndex is Index-1,
    getCellLayer(NIndex, Ys, Value).

getMovementLayer(Px, Pz, Board, Value) :-
    getBoardCell(Px, Pz, Board, Cell),
    getCellLayer(0, Cell, Value).

getMapLayer(Px, Pz, Board, Value) :-
    getBoardCell(Px, Pz, Board, Cell),
    getCellLayer(1, Cell, Value).

getStructureLayer(Px, Pz, Board, Value) :-
    getBoardCell(Px, Pz, Board, Cell),
    getCellLayer(2, Cell, Value).

getBoardSize(Board, Size) :-
    getBoardSize(Board, 0, Size).
getBoardSize([], Index, Size) :-
    Size is Index.
getBoardSize([_|Ys], Index, Size) :-
    NIndex is Index+1,
    getBoardSize(Ys, NIndex, Size).

% Setters

setBoardCellAux([],_,[],_).
setBoardCellAux([X|Ys], NewCell, [NX|NYs], Elem) :-
    ( (Elem = 0) -> NX = NewCell ; NX = X ),
    NElem is Elem-1,
    setBoardCellAux(Ys,NewCell,NYs, NElem).

setBoardCellAux(_,_,[],_,[],_).
setBoardCellAux(Px,Pz,[X|Ys], NewCell, [NX|NYs], Elem) :-
    ( (Px = 0, Pz = 0) -> setBoardCellAux(X,NewCell,NX,Elem) ; NX = X ),
    NPz is Pz-1,
    setBoardCellAux(Px,NPz,Ys,NewCell,NYs,Elem).


setBoardCell(_,_,[],_,[],_).
setBoardCell( Px, Pz, [X|Ys], NewCell, [NX|NYs], Elem) :-
    setBoardCellAux(Px,Pz,X,NewCell,NX,Elem),
    NPx is Px-1,
    setBoardCell(NPx,Pz,Ys,NewCell,NYs,Elem).

setMovementLayer(Px, Pz, Board, Value, NewBoard) :-
    setBoardCell(Pz, Px, Board, Value, NewBoard, 0).

setMapLayer(Px, Pz, Board, Value, NewBoard) :-
    setBoardCell(Pz, Px, Board, Value, NewBoard, 1).

setStructureLayer(Px, Pz, Board, Value, NewBoard) :-
    setBoardCell(Pz, Px, Board, Value, NewBoard, 2).

% Movement

isStraightLine(X1, Z1, X2, Z2) :-
    X1==X2;
    Z1==Z2;
    (Y1 is -X1-Z1,
     Y2 is -X2-Z2,
     Y1==Y2),!.

canMoveIntoCell(Board, X, Z) :-
    getMapLayer(X, Z, Board, System),
    canMoveInto(System),
    getStructureLayer(X, Z, Board, Structure),
    canMoveInto(Structure).

canPassThroughCell(Faction, Board, X, Z) :-
    getMapLayer(X, Z, Board, System),
    canPassThrough(Faction, System),
    getStructureLayer(X, Z, Board, Structure),
    canPassThrough(Faction, Structure).

isUnobstructed(_, _, X, Z, X, Z).
isUnobstructed(Faction, Board, X1, Z1, X2, Z2) :-
    X1 == X2,
    Z1 =\= Z2,
    canMoveIntoCell(Board, X2, Z2),
    canPassThroughCell(Faction, Board, X1, Z1),
    (Z1 < Z2 -> NZ1 is Z1+1; NZ1 is Z1-1),			    
    isUnobstructed(Faction, Board, X1, NZ1, X2, Z2).
isUnobstructed(Faction, Board, X1, Z1, X2, Z2) :-
    Z1 == Z2,
    X1 =\= X2,
    canMoveIntoCell(Board, X2, Z2),
    canPassThroughCell(Faction, Board, X1, Z1),
    (X1 < X2 -> NX1 is X1+1; NX1 is X1-1),
    isUnobstructed(Faction, Board, NX1, Z1, X2, Z2).
isUnobstructed(Faction, Board, X1, Z1, X2, Z2) :-
    Y1 is -X1-Z1,
    Y2 is -X2-Z2,
    Y1 == Y2,
    X1 =\= X2,
    Z1 =\= Z2,
    canMoveIntoCell(Board, X2, Z2),
    canPassThroughCell(Faction, Board, X1, Z1),
    (X1 < X2 -> NX1 is X1+1; NX1 is X1-1),
    (Z1 < Z2 -> NZ1 is Z1+1; NZ1 is Z2-1),
    isUnobstructed(Faction, Board, NX1, NZ1, X2, Z2).

isAdjacentToWormhole(X, Z, Board) :-
    NX is X+1,
    getMapLayer(NX, Z, Board, System),
    wormholeSystem(System).
isAdjacentToWormhole(X, Z, Board) :-
    NX is X-1,
    getMapLayer(NX, Z, Board, System),
    wormholeSystem(System).
isAdjacentToWormhole(X, Z, Board) :-
    NZ is Z+1,
    getMapLayer(X, NZ, Board, System),
    wormholeSystem(System).
isAdjacentToWormhole(X, Z, Board) :-
    NZ is Z-1,
    getMapLayer(X, NZ, Board, System),
    wormholeSystem(System).
isAdjacentToWormhole(X, Z, Board) :-
    NX is X+1,
    NZ is Z-1,
    getMapLayer(NX, NZ, Board, System),
    wormholeSystem(System).
isAdjacentToWormhole(X, Z, Board) :-
    NX is X-1,
    NZ is Z+1,
    getMapLayer(NX, NZ, Board, System),
    wormholeSystem(System).

moveShip(Faction, Board, X1, Z1, X2, Z2, NewBoard) :-
    getMovementLayer(X1, Z1, Board, Value),
    ship(Faction, Ship),
    Value == Ship,
    isStraightLine(X1, Z1, X2, Z2),
    isUnobstructed(Faction, Board, X1, Z1, X2, Z2),
    setMovementLayer(X1, Z1, Board, ' ', TempBoard),
    setMovementLayer(X2, Z2, TempBoard, Ship, NewBoard).
moveShip(Faction, Board, X1, Z1, X2, Z2, NewBoard) :-
    getMovementLayer(X1, Z1, Board, Value),
    ship(Faction, Ship),
    Value == Ship,
    isAdjacentToWormhole(X1, Z1, Board),
    isAdjacentToWormhole(X2, Z2, Board),
    getMapLayer(X2, Z2, Board, System),
    canMoveInto(System),
    getStructureLayer(X2, Z2, Board, Structure),
    canMoveInto(Structure),
    setMovementLayer(X1, Z1, Board, ' ', TempBoard),
    setMovementLayer(X2, Z2, TempBoard, Ship, NewBoard).

placeColony(Faction, Board, X, Z, NewBoard) :-
    colony(Colony),
    owns(Faction, Colony),
    setStructureLayer(X, Z, Board, Colony, NewBoard).

placeTradeStation(Faction, Board, X, Z, NewBoard) :-
    tradeStation(TradeStation),
    owns(Faction, TradeStation),
    setStructureLayer(X, Z, Board, TradeStation, NewBoard).

placeStructure(Faction, Board, 'colony', X, Z, NewBoard) :-
    placeColony(Faction, Board, X, Z, NewBoard).
placeStructure(Faction, Board, 'trade station', X, Z, NewBoard) :-
    placeTradeStation(Faction, Board, X, Z, NewBoard).


    
