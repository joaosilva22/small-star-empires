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

	
getBoardCell(0,Pz,[X|_],Cell) :-
	getBoardCell(Pz,X,Cell).
	
getBoardCell( Px, Pz, [_|Ys], Cell) :-
	NPx is Px - 1,
	getBoardCell(NPx,Pz,Ys,Cell).
	

getBoardCell(0,[Cell|_],Cell).
	
getBoardCell(Pz,[_|Ys], Cell) :-
	NPz is Pz - 1,
	getBoardCell(NPz,Ys,Cell).
