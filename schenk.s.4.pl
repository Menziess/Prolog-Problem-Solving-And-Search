% PSS Huiswerk #
% <datum>
% Stefan Schenk, 11881798, stefan_schenk@hotmail.com

/*
|-------------------------------------------------------------------------------
| Helper predicates
|-------------------------------------------------------------------------------
*/

% Haalt het nth element op
nth(0, [H|_], H) :-
  !.
nth(N, [_|T], E) :-
  NN is N - 1,
  nth(NN, T, E), !.

% Haalt 3 elementen vanaf index N op
nth3(0, [H1, H2, H3|_], [H1,H2,H3]) :-
  !.
nth3(N, [_|T], L) :-
  NN is N - 1,
  nth3(NN, T, L), !.

% Transposed matrix
transpose([[]|_], []).
transpose(M, [X|T]) :-
  transpose_row(M, X, M1),
  transpose(M1, T).
transpose_row([], [], []).
transpose_row([[X|Xs]|Ys], [X|R], [Xs|Z]) :-
  transpose_row(Ys, R, Z).

/*
|-------------------------------------------------------------------------------
| Opg 1
|-------------------------------------------------------------------------------
*/

% Begintoestand, elke list stelt een kolom voor
beginToestand(State) :-
  State = [
    [1, 2, 0, 0, 6, 0, 0, 0, 0],
    [0, 0, 3, 0, 0, 0, 8, 1, 0],
    [0, 0, 6, 0, 7, 0, 0, 3, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 6, 2, 0, 7, 0, 1],
    [2, 1, 7, 0, 9, 0, 0, 0, 0],
    [7, 0, 0, 8, 0, 0, 3, 5, 0],
    [6, 0, 0, 7, 0, 0, 0, 0, 9],
    [0, 8, 4, 2, 0, 0, 0, 0, 7]
  ].

% Een juiste eindtoestand (om te testen)
eindToestand(State) :-
  State = [
    [1, 9, 8, 4, 3, 2, 7, 6, 5],
    [2, 7, 4, 6, 5, 1, 9, 3, 8],
    [5, 3, 6, 9, 8, 7, 1, 2, 4],
    [3, 4, 9, 1, 6, 5, 8, 7, 2],
    [6, 5, 7, 8, 2, 9, 4, 1, 3],
    [8, 2, 1, 7, 4, 3, 6, 5, 9],
    [9, 8, 2, 5, 7, 6, 3, 4, 1],
    [7, 1, 3, 2, 9, 4, 5, 8, 6],
    [4, 6, 5, 3, 1, 8, 2, 9, 7]
  ].

/*
|-------------------------------------------------------------------------------
| Opg 2
|-------------------------------------------------------------------------------
*/

% Alle indices beginnen met index 0

% Haalt kolom N op.
kolom(0, [H|_], H).
kolom(N, [_|State], List) :-
  NN is N - 1,
  kolom(NN, State, List).

% Haalt kolommen met indices [Start, End] op
kolomrange(Start, End, _, []) :-
  Start > End.
kolomrange(Start, End, State, [Col|Columns]) :-
  Next is Start + 1,
  kolom(Start, State, Col),
  kolomrange(Next, End, State, Columns), !.

% Haalt rij N op
rij(N, State, Row) :-
  findall(Elem, (member(Col, State), nth(N, Col, Elem)), Row).

% Haalt kwadrant op door eerst de juiste kolommen op te halen, en daarna de
% juiste sublijsten uit de kolommen te halen.
kwadrant(N, State, Subs) :-
  Y is N // 3 * 3,
  X is N mod 3 * 3,
  XX is X + 2,
  findall(Col, kolomrange(X, XX, State, Col), [Columns]),
  findall(Sub, (member(Col, Columns), nth3(Y, Col, Sub)), Subs).

/*
|-------------------------------------------------------------------------------
| Opg 3
|-------------------------------------------------------------------------------
*/

% Bepaalt of alle elementen van een lijst uniek zijn, behalve de exception
% elemeenten indien gegeven
unique([]).
unique([H|T]) :-
  unique([H|T], null).
unique([], _).
unique([Exception|T], Exception) :-
  unique(T, Exception).
unique([H|T], Exception) :-
  \+ member(H, T),
  unique(T, Exception), !.

% Bepaalt of er geen lege plekken in een lijst zitten
statenoempty([]).
statenoempty([H|T]) :-
  listnoempty(H),
  statenoempty(T).
listnoempty([]).
listnoempty([H|T]) :-
  \+ 0 = H,
  listnoempty(T).

% Voert unique check uit op alle sublijsten
subUnique([]).
subUnique(L) :-
  subUnique(L, null).
subUnique([], _).
subUnique([H|T], E) :-
  unique(H, E),
  subUnique(T, E).

% Controleert of kwadranten uniek zijn
quadrantsUnique(-1, _).
quadrantsUnique(N, State) :-
  quadrantsUnique(N, State, null).
quadrantsUnique(-1, _, _).
quadrantsUnique(N, State, Exception) :-
  kwadrant(N, State, Subs),
  flatten(Subs, Quadrant),
  unique(Quadrant, Exception),
  NN is N - 1,
  quadrantsUnique(NN, State, Exception).

% Controleert of alle rijen en kolommen uniek zijn, of alle values in de
% rijen en kolommen uniek zijn, of de kwadranten uniek zijn en of er geen
% lege elementen in de sudoku zitten
goal(State) :-
  statenoempty(State),
  transpose(State, TransposedState),
  length(State, NrQuadrants),
  quadrantsUnique(NrQuadrants, State),
  unique(TransposedState),
  unique(State),
  subUnique(TransposedState),
  subUnique(State), !.

test3() :-
  eindToestand(State),
  goal(State).

/*
|-------------------------------------------------------------------------------
| Opg 4
|-------------------------------------------------------------------------------
*/

% Controleert of state in valide staat verkeerd
valid(State) :-
  transpose(State, TransposedState),
  length(State, NrQuadrants),
  % quadrantsUnique(NrQuadrants, State, 0),
  % unique(TransposedState),
  % unique(State),
  subUnique(TransposedState, 0),
  subUnique(State, 0), !.

test4() :-
  beginToestand(State),
  valid(State).

% move(CurrentState, NewState) :-
%   write("..").



/*
|-------------------------------------------------------------------------------
| Opg 5
|-------------------------------------------------------------------------------
*/

% Print rij uit met kwadrant size S
printRow(Row, S) :-
  length(Row, N),
  printRow(Row, N, S).
printRow([], 0, _) :-
  write('|').
printRow([H|T], N, S) :-
  N mod S =:= 0, !,
  write('| '), write(H), write(' '),
  NN is N - 1,
  printRow(T, NN, S).
printRow([H|T], N, S) :-
  write(H), write(' '),
  NN is N - 1,
  printRow(T, NN, S).

% Print sudoku state
printState(State) :-
  length(State, Length),
  sqrt(Length, QuadrantSize),
  round(QuadrantSize, Q),
  printState(Q, State).
printState(_, []) :-
  write(-------------------------), nl, nl.
printState(Q, [H|T]) :-
  length([H|T], L),
  L mod Q =:= 0, !,
  write(-------------------------), nl,
  printRow(H, Q), nl,
  printState(Q, T), !.
printState(Q, [H|T]) :-
  printRow(H, Q), nl,
  printState(Q, T).

test5() :-
  eindToestand(State),
  printState(State).
