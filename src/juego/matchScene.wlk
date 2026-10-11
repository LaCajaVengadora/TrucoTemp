import src.juego.cards.*
import src.juego.charas.*

class MatchScene {
    const player = mainPlayer
    const rival
    const dificultad = rival.dificultad()
    var property puntosWin = 5

    var property puntosPlayer = 0 // resetear al FINAL
    var manosFavorPlayer = 0 // resetear con RONDA
    var property cartaPlayer = joker // resetear con RONDA
    var numsCartasJugadasPlayer = [] // resetear con RONDA
    var property puntosRival = 0 // resetear al FINAL
    var manosFavorRival = 0 // resetear con RONDA
    var property cartaRival = joker // resetear con RONDA
    var numsCartasJugadasRival = [] // resetear con RONDA

    // despues vemos bien por el truco y siguientes
    var property nivelTruco = 0 // comprueba tanto el nivel como los puntos resetear con RONDA
    var property esCantorTrucoPlayer = false // resetear con RONDA

    var property mano = 1 // resetear con RONDA
    var turno = 1 // resetear con RONDA

    var property rivalEsperaRtaTruco = false // resetear con RONDA

    // controla quien es mano en una ronda (para alternar)
    var property esManoPlayer = [true, false].anyOne() // resetear con RONDA 
    // indica de quien es el turno (false rival, true jugador)
    var property esTurnoPlayer = esManoPlayer // resetear al FINAL

    const nextTruco = new Dictionary()
    const nextEnvido = new Dictionary()
    var puntosPorEnvido = new Dictionary()
    override method initialize() {
        nextTruco.put(-1, "NADA")
        nextTruco.put(0, "TRUCO")
        nextTruco.put(1, "RETRUCO")
        nextTruco.put(2, "VALECUATRO")
        nextEnvido.put(-1, "NADA")
        nextEnvido.put(0, "ENVIDO")
        nextEnvido.put(1, "ENVIDO")
        nextEnvido.put(2, "REALENVIDO")
        nextEnvido.put(3, "FALTAENVIDO")
        nextEnvido.put(1, 2)
        nextEnvido.put(2, 2)
        nextEnvido.put(3, 3)
        nextEnvido.put(4, 0) // TODO: VER CÓMO CALCULAR PUNTOS DE FALTAENVIDO
    }

    // inicia la partida
    method start() {
        self.repartir()
    }

    // reparte las cartas
    method repartir() {
        var mazoAux = mazoEntero.randomized()
        player.asignarCartas(mazoAux.subList(0,2))
        rival.asignarCartas(mazoAux.subList(3,5))
        // si es el turno del rival (esTurnoPlayer == false), juega automáticamente
        if (!esManoPlayer) self.ejecutarTurnoRival()
    }

    // finaliza la partida (resetea todo)
    method end(ganoPlayer) {
        console.println(rival.mensaje(!ganoPlayer))
        puntosPlayer = 0 puntosRival = 0
        self.resetRonda()
        esManoPlayer = [true, false].anyOne() // sobreescribo lo de resetRonda()
        esTurnoPlayer = esManoPlayer
    }

    // devuelve si alguien ganó; en tal caso finaliza la partida y devuelve true
    method checkVictoria() {
        if (puntosPlayer >= puntosWin || puntosRival >= puntosWin) {
            self.end(puntosPlayer >= puntosWin) // TODO: simplificar?
            return true
        } else return false
    }

    // resetea la ronda (una ronda consiste de 3 manos y 6 turnos)
    method resetRonda() {
        numsCartasJugadasPlayer.clear() numsCartasJugadasRival.clear()
        player.limpiarMano() rival.limpiarMano()
        cartaPlayer = joker cartaRival = joker
        manosFavorPlayer = 0 manosFavorRival = 0
        nivelTruco = 0 esCantorTrucoPlayer = false
        rivalEsperaRtaTruco
        mano = 1 turno = 1

        esManoPlayer = !esManoPlayer // usar negate()?
        esTurnoPlayer = esManoPlayer
    }

    // ------------------------------ MÉTODOS DE AVANZAR (progresan la partida turno a turno) ------------------------------

    method avanzarTurno() {
        if (mano == 1 && estadoEnvido > 0) self.asignarPuntosEnvido()
        if (!self.checkVictoria()) { // si al asignar los puntos del envido alguien ganó, no entra
            esTurnoPlayer = !esTurnoPlayer
            turno += 1
            if (turno.even()) { // turno del otro jugador
                if (!esTurnoPlayer) self.ejecutarTurnoRival()
                // si es el turno del PLAYER, el flujo va a él
            }
            else self.avanzarMano() // esTurnoPlayer dependerá de quién haya ganado esta mano
            //else if (turno.odd())
        }
    }

    method avanzarMano() {
        mano += 1 // no quiero que se sume al final porque sino al avanzarRonda se arrancaría con una mano más
        if (self.compararCartas() == 1) {
            manosFavorPlayer += 1
            esTurnoPlayer = true
        }
        else if (self.compararCartas() == -1) {
            manosFavorRival += 1
            esTurnoPlayer = false
        }
        else { 
            manosFavorPlayer += 1
            manosFavorRival += 1
            esTurnoPlayer = esManoPlayer
        }

        var difFavor = (manosFavorPlayer - manosFavorRival).abs()
        if (difFavor == 2) self.avanzarRonda(manosFavorPlayer > manosFavorRival) // ← iguales ↓
        else if (difFavor == 1 && mano >= 3) self.avanzarRonda(manosFavorPlayer > manosFavorRival)
        else if (difFavor == 0 && mano == 4) self.avanzarRonda(esManoPlayer)
        else if (!esTurnoPlayer) self.ejecutarTurnoRival() // nueva mano, flujo al RIVAL
        // else: nueva mano, flujo al PLAYER
    }

    // true si ganó PLAYER, false si ganó RIVAL
    method avanzarRonda(ganoPlayer) {
        self.asignarPuntosTruco(ganoPlayer)
        if (!self.checkVictoria()) { // si al asignar los puntos del truco alguien ganó, no entra
            console.println("--- NUEVA RONDA ---")
            self.resetRonda() // resetRonda ya alterna esManoPlayer
            self.repartir()
        }
    }

    // ------------------------------ MÉTODOS DE TURNO ------------------------------

    // --------------- RIVAL ---------------

    // llamado tanto si es su turno como si PLAYER aceptaTruco algo (le devuelve el flujo al RIVAL)
    method ejecutarTurnoRival() {
        if (!esTurnoPlayer) {
            // para simplificar, RIVAL sólo puede cantar en su turno
            if (self.puedeCantarTrucoRival() && rival.decideCantarTruco(nivelTruco))
                self.cantarTrucoRival() // TODO: ver qué más le pasamos al RIVAL para que decida
            // ↑ si RIVAL cantó, entonces espera una respuesta de PLAYER
            // ↓ si no cantó, evalúa si al sumar puntos por rechazo alguien ganó; sino, juega su carta
            if (!rivalEsperaRtaTruco) {
                if (!self.checkVictoria()) {
                    self.pedirCartaRival()
                    self.avanzarTurno()
                }
            }
        } else console.println("No es el turno del rival")
    }

    method pedirCartaRival() {
        const cartas = [1, 2, 3] // cartas posibles a elegir
        cartas.removeAll(numsCartasJugadasRival) // saca las que ya tiró
        var numCarta = cartas.anyOne() // elige una dentro de las posibles
        cartaRival = rival.jugarCarta(numCarta) // juega esa carta (la retorna) y se guarda

        numsCartasJugadasRival.add(numCarta) // la añade a las jugadas por RIVAL
        console.println("Rival tira: " + cartaRival)
    }

    // --------------- PLAYER ---------------

    // ACCIÓN DEL PLAYER: sólo posible si es el turno del PLAYER y RIVAL no espera respuesta (alternativa a irseMazoPlayer())
    method pedirCartaPlayer(numCarta) {
        if (esTurnoPlayer && !rivalEsperaRtaTruco) { // lógica similar a pedirCartaRival pero numCarta se pasa por param
            if ([1, 2, 3].contains(numCarta) && !numsCartasJugadasPlayer.contains(numCarta)) {
                cartaPlayer = player.jugarCarta(numCarta)
                numsCartasJugadasPlayer.add(numCarta)
                console.println("Player tira: " + cartaPlayer)
                self.avanzarTurno()
            } console.println("No es posible tirar esa carta")
        } else console.println("No es el turno del player o el rival espera respuesta")
    }

    // ACCIÓN DEL PLAYER: sólo posible si es el turno del PLAYER y RIVAL no espera respuesta (alternativa a pedirCartaPlayer())
    method irseMazo() {
        if (esTurnoPlayer && !rivalEsperaRtaTruco) self.avanzarRonda(false)
        else console.println("No es el turno del player o el rival espera respuesta")
    }

    // ------------------------------ MÉTODOS DE ASIGNAR Y COMPARAR CARTAS ------------------------------

    // compara cartaPlayer con cartaRival (retorna -1, 0 o 1 si carta menor, igual o mayor)
    method compararCartas() = cartaPlayer.mejorQue(cartaRival) // usado en avanzarMano()

    // ver MÉTODOS DE ENVIDO
    method asignarPuntosEnvido(ganoPlayer) {
        // revisar estadoEnvido
    }
    
    // ver MÉTODOS DE TRUCO
    method asignarPuntosTruco(ganoPlayer) {
        var neto = 1 + nivelTruco // automáticamente, sin importar si hubo Truco o no, se suma 1 punto a quien gane
        // nivelTruco contiene los puntos
        if (ganoPlayer) puntosPlayer += neto
        else puntosRival += neto
    }

    // ------------------------------ MÉTODOS DE TRUCO ------------------------------
    // Truco → Retruco → Vale cuatro

    // --------------- RIVAL ---------------

    method puedeCantarTrucoRival() = nivelTruco < 3 && !rivalEsperaRtaTruco
    // puede cantar si no estamos en valecuatro (no compruebo si es turno del RIVAL porque siempre que se llame va a ser en su turno, ver ejecutarTurnoRival())
    // igual por las dudas pongo !rivalEsperaRtaTruco (podría no estar)

    method cantarTrucoRival() {
        if (nivelTruco == 0) esCantorTrucoPlayer = false // si canto truco, entonces PLAYER no es cantor
        // no necesito if(puedeCantarTrucoRival()) porque eso se verifico en ejecutarTurnoRival()
        console.println("Rival canta " + nextTruco.get(nivelTruco))
        rivalEsperaRtaTruco = true
        // IMPORTANTE: no se suma automáticamente el nivelTruco, eso se hace cuando PLAYER acepta (ver aceptarTrucoPlayer())
    }

    // --------------- PLAYER ---------------

    // controla una ACCIÓN DEL PLAYER
    method puedeAceptarTrucoPlayer() = rivalEsperaRtaTruco && ((nivelTruco == 0 && !esCantorTrucoPlayer) ||
                                                          (nivelTruco == 1 && esCantorTrucoPlayer) ||
                                                          (nivelTruco == 2 && !esCantorTrucoPlayer))
    // puede aceptar si RIVAL espera respuesta y si corresponde por ser cantor

    // controla una ACCIÓN DEL PLAYER
    method puedeCantarTrucoPlayer() {
        if (rivalEsperaRtaTruco && nivelTruco < 3) {
            nivelTruco += 1 // IMPORTANTE: si PLAYER responde cantando, es como aceptar automáticamente, por lo que se aumenta el nivel de truco
            return true
        } // si RIVAL espera respuesta, PLAYER siempre puede cantar; si esperaba respuesta, entonces estamos en un nivel de truco más
        else if (esTurnoPlayer && nivelTruco < 3) return ((nivelTruco == 0) || (nivelTruco == 1 && !esCantorTrucoPlayer) || (nivelTruco == 2 && esCantorTrucoPlayer)) // si es turno del PLAYER, sólo puede cantar si nadie cantó o si corresponde por ser o no cantor
        else return false
        // sino no :P
    }

    // ACCIÓN DEL PLAYER: sólo posible si VER puedeAceptarTrucoPlayer()
    method aceptarTrucoPlayer(acepta) { // acepta el último truco cantado
        if (self.puedeAceptarTrucoPlayer()) {
            rivalEsperaRtaTruco = false // acepte o rechaze, es una respuesta para RIVAL
            if (acepta) {
                console.println("Player acepta " + nextTruco.get(nivelTruco))
                nivelTruco += 1
                self.ejecutarTurnoRival()
                // como RIVAL siempre canta en su turno, si PLAYER acepta entonces RIVAL sigue su turno
            } else {
                console.println("Player rechaza " + nextTruco.get(nivelTruco))
                self.avanzarRonda(false) // avanzarRonda suma los puntos de nivelTruco (false porque se suman al RIVAL si PLAYER rechaza)
            }
        } 
    }

    // ACCIÓN DEL PLAYER: sólo posible si VER puedeCantarTrucoPlayer()
    method cantarTrucoPlayer() { // canta el próximo truco posible
        if (nivelTruco == 0) esCantorTrucoPlayer = true // si canto truco, entonces es cantor
        if (self.puedeCantarTrucoPlayer()) {
            rivalEsperaRtaTruco = false // si el RIVAL cantó, entonces esta es la respuesta del PLAYER
            console.println("Player canta " + nextTruco.get(nivelTruco))

            // false → NO QUIERE, true → QUIERE
            if (rival.respuestaTruco(nivelTruco)) { // TODO: evaluar cómo decide
                console.println("Rival acepta " + nextTruco.get(nivelTruco))
                nivelTruco += 1
                if (!esTurnoPlayer) self.ejecutarTurnoRival() // si es turno del PLAYER, sigue en control; sino, el flujo pasa al RIVAL
            } else {
                console.println("Rival rechaza " + nextTruco.get(nivelTruco))
                self.avanzarRonda(true) // avanzarRonda suma los puntos de nivelTruco (true porque se suman al PLAYER si RIVAL rechaza)
            }
        }
    }

    // ------------------------------ MÉTODOS DE ENVIDO ------------------------------
    // Envido → (Envido | Real envido | Falta envido)
    // Real envido → Falta envido
    var nivelEnvido = 0 // comprueba el nivel (1, 2, 3, 4)
    var puntosEnvido = 1 // comprueba los puntos
    var rivalEsperaRtaEnvido = false
    var esCantorUltimoEnvidoPlayer = false // TODO: puede hacerse lo mismo en el truco, lo vale?

    method puedeCantarEnvidoPlayer(nivel) = true

    method cantarEnvidoPlayer(nivel) { // si se pasa 1, se pide el envido1
        if (self.puedeCantarEnvidoPlayer(nivel)) {
            esCantorUltimoEnvidoPlayer = true
            rivalEsperaRtaEnvido = false
            console.println("Player canta " + nextEnvido.get(nivel-1))

            // 0 → NO QUIERE, 1 → SI QUIERE, 2 → SUBE A ENVIDO, 3 → SUBE A REALENVIDO, 4 → SUBE A FALTAENVIDO
            var respuestaRival = rival.respuestaEnvido(nivel) // TODO: evaluar cómo decide
            // IMPORTANTE: asumimos que RIVAL no va a responder un nivel anterior
            if (respuestaRival == 0) {
                console.println("Rival rechaza " + nextEnvido.get(nivel-1))
                if (!esTurnoPlayer) self.ejecutarTurnoRival() // si es turno del PLAYER, sigue en control; sino, el flujo pasa al RIVAL
            } else {
                puntosEnvido += puntosPorEnvido.get(respuestaRival)
                console.println("Rival rechaza " + nextTruco.get(nivelTruco))
                self.avanzarRonda(true) // avanzarRonda suma los puntos de nivelTruco (true porque se suman al PLAYER si RIVAL rechaza)
            }
        }

    }





    // method envidoPosible = mano == 2

    // ------------------------------ MÉTODOS ADICIONALES ------------------------------

    // muestra información de la partida
    method show() {
        console.println(
            "data    | ------ Player | Rival ------\n" + 
            "cartas  | "+player.cartas()+" | "+rival.cartas()+"\n" +
            "ptos    | "+puntosPlayer+" | "+puntosRival+"\n" +
            "manos F | "+manosFavorPlayer+" | "+manosFavorRival+"\n" +
            "-------------------------------------------\n" +
            "mano = "+mano+" ("+if(esManoPlayer) "player" else {"rival"} +") | turno = "+turno+" ("+if(esTurnoPlayer) "player" else {"rival"}+") | nivelTruco ACTUAL = "+nivelTruco+"("+nextTruco.get(nivelTruco-1)+") | rival espera = "+rivalEsperaRtaTruco+"\n"
        )
    }
}

const matchEasy = new MatchScene(rival = rivalEasy)

object tester {
    method init() {
        matchEasy.start()
        matchEasy.show()
    }
}