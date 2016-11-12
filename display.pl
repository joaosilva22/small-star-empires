% Board Drawing

printspacing(0).
printspacing(N) :-
    write('   '),
    N > 0,
    N1 is N-1,
    printspacing(N1).

printboard :-
    nl,
    board(X),
    write(' '),
    printcolindexes(X, 0),
    printboard(X, 0).

printboard(Board) :-
    nl,
    write(' '),
    printcolindexes(Board, 0),
    printboard(Board, 0), !.

printboard([], _).
printboard([X|Ys], N) :-
    write(' '),
    printspacing(N),
    printcelltop(X, N),
    write(N),
    printspacing(N),
    printline(X, N),
    write(' '),
    printspacing(N),
    printcellbot(X, N),
    N1 is N+1,
    printboard(Ys, N1).

printcell([]).
printcell([X|Ys]) :-
    write(X),
    printcell(Ys).

printline([], _) :- nl.
printline([X|Ys], N) :-
    getelem(X, 1, V),
    =(V, v),
    write('  +  '),
    printline(Ys, N).
printline([X|Ys], N) :-
    write('|'),
    printcell(X),
    write('|'),
    printline(Ys, N).

printcelltop([], _) :- nl.
printcelltop([X|Ys], N) :-
    getelem(X, 1, V),
    =(V, v),
    write('     '),
    printcelltop(Ys, N).
printcelltop([_|Ys], N) :-
    write('/  \\ '),
    printcelltop(Ys, N).

printcellbot([], _) :- nl.
printcellbot([X|Ys], N) :-
    getelem(X, 1, V),
    =(V, v),
    write('     '),
    printcellbot(Ys, N).
printcellbot([_|Ys], N) :-
    write('\\   /'),
    printcellbot(Ys, N).

getelem([X|_], 0, Value) :-
    Value = X.
getelem([_|Ys], Index, Value) :-
    Index > 0,
    Index1 is Index-1,
    getelem(Ys, Index1, Value).
    
printcolindexes([], _) :- nl.
printcolindexes([_|Ys], N) :-
    write('  '),
    write(N),
    write('  '),
    N1 is N+1,
    printcolindexes(Ys, N1).

cls :- write('\33[H\33\[2J'). %write('\e[H\e[2J').
