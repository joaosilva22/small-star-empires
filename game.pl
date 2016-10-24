joga(+TipoDeJogo, +Dificuldade) :-
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
    avaliaTabuleiros(+PossiveisTabuleiros, -MelhorTabuleiro).
