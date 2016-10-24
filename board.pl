board([[[' ',v,' '],[' ',v,' '],[' ',v,' '],['A',g,' '],['A',g,' '],[' ',2,' '],[' ',0,' '],[' ',v,' '],[' ',v,' ']],
       [[' ',v,' '],[' ',v,' '],['A',g,' '],['A',g,' '],[' ',1,' '],[' ',b,' '],[' ',1,' '],[' ',2,' '],[' ',1,' ']],
       [[' ',v,' '],[' ',v,' '],[' ',0,' '],[' ',1,' '],[' ',3,' '],[' ',n,' '],[' ',3,' '],[' ',w,' '],[' ',0,' ']],
       [[' ',v,' '],[' ',1,' '],[' ',w,' '],[' ',2,' '],[' ',1,' '],[' ',2,' '],[' ',1,' '],[' ',1,' '],[' ',v,' ']],
       [[' ',v,' '],[' ',3,' '],[' ',1,' '],[' ',1,' '],[' ',n,' '],[' ',1,' '],[' ',1,' '],[' ',0,' '],[' ',v,' ']],
       [[' ',v,' '],[' ',0,' '],[' ',1,' '],[' ',1,' '],[' ',2,' '],[' ',1,' '],[' ',w,' '],[' ',3,' '],[' ',v,' ']],
       [[' ',3,' '],[' ',b,' '],[' ',2,' '],[' ',3,' '],[' ',1,' '],[' ',1,' '],[' ',2,' '],[' ',v,' '],[' ',v,' ']],
       [[' ',1,' '],[' ',0,' '],[' ',n,' '],[' ',w,' '],[' ',1,' '],['B',h,' '],['B',h,' '],[' ',v,' '],[' ',v,' ']],
       [[' ',v,' '],[' ',v,' '],[' ',1,' '],[' ',0,' '],['B',h,' '],['B',h,' '],[' ',v,' '],[' ',v,' '],[' ',v,' ']]]).

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
