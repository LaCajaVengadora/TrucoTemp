[Chara|cartas:Dictionary|initialize();asignarCartas(listaCarta);limpiarMano();removeCarta(numCarta);jugarCarta(numCarta);envidoEntre(carta1, carta2); cantEnvido();]


[Chara]->[≪object≫;mainPlayer]

[Chara]^[Rival|image:string;position:Position;nombre:string;msgVictoria:string;msgDerrota:string;dificultad:int|mensaje(ganoRival);decideCantarTruco(nivelTruco);respuestaTruco(nivelTruco);decideCantarEnvido(nivelEnvido);respuestaEnvido(nivelEnvido)]

[Rival]->[≪object≫;rivalEasy| |decideCantarTruco(nivelTruco);respuestaTruco(nivelTruco);decideCantarEnvido(nivelEnvido);respuestaEnvido(nivelEnvido)]

[Rival]->[≪object≫;rivalMid| |decideCantarTruco(nivelTruco);respuestaTruco(nivelTruco);decideCantarEnvido(nivelEnvido);respuestaEnvido(nivelEnvido)]

[Rival]->[≪object≫;rivalHard| |decideCantarTruco(nivelTruco);respuestaTruco(nivelTruco);decideCantarEnvido(nivelEnvido);respuestaEnvido(nivelEnvido)]

[Match|image:string;position:Position;20millonesdeproperties|start();cancel();repartir();end(ganoPlayer);checkVictoria();resetRonda();avanzarTurno();avanzarMano();avanzarRonda(ganoPlayer);ejecutarTurnoRival();pedirCartaRival();pedirCartaPlayer();irseMazo();retornarFlujo();compararCartas();asignarPuntosEnvido(ganoPlayer);asignarPuntosTruco(ganoPlayer);puedeCantarTrucoRival();cantarTrucoRival();puedeAceptarTrucoPlayer();puedeCantarTrucoPlayer();aceptarTrucoPlayer(acepta);cantarTrucoPlayer();puedeCantarEnvidoRival();cantarEnvidoRival();puedeAceptarEnvidoPlayer();puedeCantarEnvidoPlayer(nivelCantado);aceptarEnvidoPlayer(acepta);cantarEnvidoPlayer(nivelCantado);sumarPuntosEnvido();calcularFaltaEnvido(ganoPlayer);compararPuntosEnvido();show()]

[Match]->[≪object≫;matchEasy]
[Match]->[≪object≫;matchMid]
[Match]->[≪object≫;matchHard]

[≪interfaz≫;Positionable| |image(); position()]

[≪object≫;gameHandler| |start();setMenuScene();setSelectScene();setMatchScene(dificultar)]



[Positionable]^-.-[Rival]
[Positionable]^-.-[Match]
[Positionable]^-.-[≪object≫;selectorBg| |image(); position()]
