import src.cards.*
import src.charas.*


const nextTruco = new Dictionary()
const nextEnvido = new Dictionary()
const puntosPorEnvido = new Dictionary()
// ↑ CUANDO SE INICIA UN MATCH, SE AGREGAN LOS VALORES ↑ TODO: mover a otro lado?


class EnvidoHandler {

    const match
    var property nivelEnvido = 0
    var property puntosEnvido = 0
    var property rivalEsperaRtaEnvido = false
    var property nivelCantadoPorRival = 0
    var property esCantorUltimoEnvidoPlayer = false
    var property cantEnvidoPlayer = 0
    var property cantEnvidoRival = 0

    method reset() {
        nivelEnvido = 0 nivelCantadoPorRival = 0 puntosEnvido = 0 esCantorUltimoEnvidoPlayer = false rivalEsperaRtaEnvido = false
        cantEnvidoPlayer = 0 cantEnvidoRival = 0
    }

    // esto chequearlo en ejecutarTurnoRival(), automáticamente decide en su turno
    method puedeCantarEnvidoRival() = !rivalEsperaRtaEnvido && match.mano() == 1 && puntosEnvido == 0 && nivelEnvido == 0 && !match.trucoHandler().rivalEsperaRtaTruco() && match.trucoHandler().nivelTruco() == 0

    method cantarEnvidoRival(nivelCantado) { // TODO: el rival.decideCantarEnvido estará arriba como con el truco 
        esCantorUltimoEnvidoPlayer = false
        console.println("Rival canta " + nextEnvido.get(nivelCantado-1))
        nivelCantadoPorRival = nivelCantado // se guarda el nivel cantado para si, al rechazarlo y si nivelEnvido=0, suma 1
        rivalEsperaRtaEnvido = true
        // IMPORTANTE: los puntosEnvido se suman cuando PLAYER acepta, no cuando RIVAL canta!
    }
    
    // --------------- PLAYER ---------------

    method puedeAceptarEnvidoPlayer() = rivalEsperaRtaEnvido && !esCantorUltimoEnvidoPlayer

    method puedeCantarEnvidoPlayer(nivelCantado) { return
        nivelCantado > nivelCantadoPorRival && (!esCantorUltimoEnvidoPlayer || rivalEsperaRtaEnvido) && match.mano() == 1
        && nivelEnvido == 0 && puntosEnvido == 0 // quizas redundante, pero por las dudas
        && !match.trucoHandler().rivalEsperaRtaTruco() && match.trucoHandler().nivelTruco() == 0 && ((nivelCantado == 2 && nivelCantadoPorRival == 1) || nivelCantado != 2)
    }

    // ACCIÓN DEL PLAYER
    method aceptarEnvidoPlayer(acepta) { // acepta el envido cantado
        if (self.puedeAceptarEnvidoPlayer()) {
            rivalEsperaRtaEnvido = false
            if (acepta) {
                nivelEnvido = nivelCantadoPorRival
                console.println("Player acepta " + nextEnvido.get(nivelEnvido-1))
                 // SÓLO SE SUMAN CUANDO PLAYER ACEPTA
                puntosEnvido += puntosPorEnvido.get(nivelEnvido) // acá se suman, no cuando canta RIVAL
                self.compararPuntosEnvido() // ← ya retorna suma los puntos y retorna el flujo
            } else {
                console.println("Player rechaza " + nextEnvido.get(nivelEnvido))
                if (nivelEnvido == 0) puntosEnvido = 1 // si PLAYER rechaza el primer canto, es 1 punto
                self.asignarPuntosEnvido(false) // no compara
                if (!match.checkVictoria()) match.retornarFlujo()
            }
        }
    }

    // ACCIÓN DEL PLAYER
    method cantarEnvidoPlayer(nivelCantado) { // si se pasa 1, se pide el envido1
        if (self.puedeCantarEnvidoPlayer(nivelCantado)) {
            esCantorUltimoEnvidoPlayer = true
            match.trucoHandler().rivalEsperaRtaTruco(false) // si es primera ronda, puede "bloquear" un truco con un envido, no parece generar problemas con los puntos
            rivalEsperaRtaEnvido = false

            puntosEnvido += puntosPorEnvido.get(nivelCantadoPorRival) // si RIVAL cantó, esto cuenta como aceptarlo
            nivelEnvido = nivelCantadoPorRival // si RIVAL no cantó, sigue en 0

            console.println("Player canta " + nextEnvido.get(nivelCantado-1))

            // 0 → NO QUIERE, 1 → SI QUIERE, 2 → SUBE A ENVIDO (2), 3 → SUBE A REALENVIDO, 4 → SUBE A FALTAENVIDO (1→NADA)
            const rtaRival = match.rival().respuestaEnvido(nivelCantado) // TODO: evaluar cómo decide
            // IMPORTANTE: asumimos que RIVAL no va a responder un nivel anterior

            if (rtaRival == 0) {
                console.println("Rival rechaza " + nextEnvido.get(nivelCantado-1))
                if (nivelEnvido == 0) puntosEnvido = 1 // si es el primer canto (sea cual sea), al rechazarlo se da un punto
                self.asignarPuntosEnvido(true) // no compara
                if (!match.checkVictoria()) match.retornarFlujo()
            } else if (rtaRival == 1) { // SÓLO SE SUMAN CUANDO RIVAL ACEPTA
                console.println("Rival acepta " + nextEnvido.get(nivelCantado-1))
                nivelEnvido = nivelCantado
                puntosEnvido += puntosPorEnvido.get(nivelEnvido)
                self.compararPuntosEnvido() // ya retorna flujo
            }
            else if (rtaRival > 1) {
                puntosEnvido += puntosPorEnvido.get(nivelCantado)  // si RIVAL canta, esto cuenta como aceptar el del PLAYER
                nivelEnvido = nivelCantado
                self.cantarEnvidoRival(rtaRival) // se sigue como si el rival cantara
            }
        }
    }

    // ver MÉTODOS DE ENVIDO
    method asignarPuntosEnvido(ganoPlayer) { // el 1 de si se rechaza el primer canto ya está incorporado
        if (ganoPlayer) match.sumarPuntosPlayer(puntosEnvido)
        else match.sumarPuntosRival(puntosEnvido)
    } // IMPORTANTE: SIEMPRE luego de asignar, consultar checkVictoria()

    // --- OTROS ---
    method sumarPuntosEnvido() { // todavía nadie tiró, por eso lo tengo que guardar, no me puedo confiar de Chara().cantEnvido()
        cantEnvidoPlayer = match.player().cantEnvido()
        cantEnvidoRival = match.rival().cantEnvido()
    }
    
    method calcularFaltaEnvido(ganoPlayer) {
        if (ganoPlayer) return match.puntosWin() - match.puntosRival()
        else return match.puntosWin() - match.puntosPlayer()
    }

    method compararPuntosEnvido() { // los puntos de envido se suman al inicio de la ronda
        var ganaPlayer
        if (cantEnvidoPlayer > cantEnvidoRival) ganaPlayer = true
        else if (cantEnvidoPlayer < cantEnvidoRival) ganaPlayer = false
        else { ganaPlayer = match.esManoPlayer() }
        if (nivelEnvido == 4) puntosEnvido = self.calcularFaltaEnvido(ganaPlayer) // si estamos en falta envido, calcula los puntosEnvido
        self.asignarPuntosEnvido(ganaPlayer)
        if (!match.checkVictoria()) match.retornarFlujo()
    }

}

class TrucoHandler {

    const match
    var property nivelTruco = 0
    var property esCantorTrucoPlayer = false
    var property rivalEsperaRtaTruco = false

    method reset() {
        nivelTruco = 0 esCantorTrucoPlayer = false rivalEsperaRtaTruco = false
    }
    
    // ver MÉTODOS DE TRUCO
    method asignarPuntosTruco(ganoPlayer) {
        const neto = 1 + nivelTruco // automáticamente, sin importar si hubo Truco o no, se suma 1 punto a quien gane
        // nivelTruco contiene los puntos
        if (ganoPlayer) match.sumarPuntosPlayer(neto)
        else match.sumarPuntosRival(neto)
    } // IMPORTANTE: SIEMPRE luego de asignar, consultar checkVictoria()

    method puedeCantarTrucoRival() = nivelTruco < 3 && !rivalEsperaRtaTruco && !match.rivalEsperaRtaEnvido()
    // puede cantar si no estamos en valecuatro (no compruebo si es turno del RIVAL porque siempre que se llame va a ser en su turno, ver ejecutarTurnoRival())
    // igual por las dudas pongo !rivalEsperaRtaTruco (podría no estar)

    method cantarTrucoRival() {
        if (nivelTruco == 0) esCantorTrucoPlayer = false // si canto truco, entonces PLAYER no es cantor
        // no necesito if(puedeCantarTrucoRival()) porque eso se verifico en ejecutarTurnoRival()
        console.println("Rival canta " + match.nextTruco().get(nivelTruco))
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
        if (rivalEsperaRtaTruco && nivelTruco < 3 && !match.rivalEsperaRtaEnvido()) {
            nivelTruco += 1 // IMPORTANTE: si PLAYER responde cantando, es como aceptar automáticamente, por lo que se aumenta el nivel de truco
            return true
        } // si RIVAL espera respuesta, PLAYER siempre puede cantar; si esperaba respuesta, entonces estamos en un nivel de truco más
        else if (match.esTurnoPlayer() && nivelTruco < 3 && !match.rivalEsperaRtaEnvido()) return ((nivelTruco == 0) || (nivelTruco == 1 && !esCantorTrucoPlayer) || (nivelTruco == 2 && esCantorTrucoPlayer)) // si es turno del PLAYER, sólo puede cantar si nadie cantó o si corresponde por ser o no cantor
        else return false
        // sino no :P
    }

    // ACCIÓN DEL PLAYER: sólo posible si VER puedeAceptarTrucoPlayer()
    method aceptarTrucoPlayer(acepta) { // acepta el último truco cantado
        if (self.puedeAceptarTrucoPlayer()) {
            rivalEsperaRtaTruco = false // acepte o rechaze, es una respuesta para RIVAL
            if (acepta) {
                console.println("Player acepta " + nextTruco.get(nivelTruco))
                nivelTruco += 1 //niveltruco += 1
                match.ejecutarTurnoRival()
                // como RIVAL siempre canta en su turno, si PLAYER acepta entonces RIVAL sigue su turno
            } else {
                console.println("Player rechaza " + nextTruco.get(nivelTruco))
                match.avanzarRonda(false) // avanzarRonda suma los puntos de nivelTruco (false porque se suman al RIVAL si PLAYER rechaza)
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
            if (match.rival().respuestaTruco(nivelTruco)) { // TODO: evaluar cómo decide
                console.println("Rival acepta " + nextTruco.get(nivelTruco))
                nivelTruco += 1
                match.retornarFlujo()
            } else {
                console.println("Rival rechaza " + nextTruco.get(nivelTruco))
                match.avanzarRonda(true) // avanzarRonda suma los puntos de nivelTruco (true porque se suman al PLAYER si RIVAL rechaza)
            }
        }
    }

}

class Match {
    // TODO: CERCA DEL FINAL, REVISAR QUÉ DEBERÍA SER PROPERTY Y QUÉ NO
    const property image
    const property position = game.origin()

    var property trucoHandler = new TrucoHandler(match = self)
    var property envidoHandler = new EnvidoHandler(match = self)

    const property player = mainPlayer
    const property rival
    const property dificultad = rival.dificultad()
    var property puntosWin = 10

    var property puntosPlayer = 0 // resetear al FINAL
    var property manosFavorPlayer = 0 // resetear con RONDA
    var property cartaPlayer = joker // resetear con RONDA
    var property numsCartasJugadasPlayer = [] // resetear con RONDA
    var property puntosRival = 0 // resetear al FINAL
    var property manosFavorRival = 0 // resetear con RONDA
    var property cartaRival = joker // resetear con RONDA
    var property numsCartasJugadasRival = [] // resetear con RONDA

    // despues vemos bien por el truco y siguientes
    // var property nivelTruco = 0 // comprueba tanto el nivel como los puntos resetear con RONDA
    // var property esCantorTrucoPlayer = false // resetear con RONDA

    // var property nivelEnvido = 0 // comprueba el nivel (1, 2, 3, 4)
    // var property puntosEnvido = 0 // comprueba los puntos (va sumando a medida que se acepta)
    // var property rivalEsperaRtaEnvido = false
    // var property nivelCantadoPorRival = 0 // para pasar la data entre métodos (sobre todo para sumar 1 ante el rechazo del primer canto)
    // var property esCantorUltimoEnvidoPlayer = false // TODO: puede hacerse lo mismo en el truco, lo vale?
    // var property cantEnvidoPlayer = 0
    // var property cantEnvidoRival = 0

    var property mano = 1 // resetear con RONDA
    var property turno = 1 // resetear con RONDA

    // var property rivalEsperaRtaTruco = false // resetear con RONDA

    // controla quien es mano en una ronda (para alternar)
    var property esManoPlayer = [true, false].anyOne() // resetear con RONDA 
    // indica de quien es el turno (false rival, true jugador)
    var property esTurnoPlayer = esManoPlayer // resetear al FINAL

    // TODO: ↓ MOVER ESTO A ALGÚN OTRO LADO? ↓
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
        puntosPorEnvido.put(0, 0)
        puntosPorEnvido.put(1, 2)
        puntosPorEnvido.put(2, 2)
        puntosPorEnvido.put(3, 3)
        puntosPorEnvido.put(4, 0)
    }

    // inicia la partida
    method start() {
        self.repartir()
    }

    method cancel() {
        puntosPlayer = 0 puntosRival = 0
        self.resetRonda()
        esManoPlayer = [true, false].anyOne()
        esTurnoPlayer = esManoPlayer
        trucoHandler = new TrucoHandler(match = self)
        envidoHandler = new EnvidoHandler(match = self)
    }

    // reparte las cartas
    method repartir() {
        const mazoAux = mazoEntero.randomized()
        player.asignarCartas(mazoAux.subList(0,2))
        rival.asignarCartas(mazoAux.subList(3,5))
        envidoHandler.sumarPuntosEnvido()
        // si es el turno del rival (esTurnoPlayer == false), juega automáticamente
        if (!esManoPlayer) self.ejecutarTurnoRival()
    }

    // finaliza la partida (resetea todo)
    method end(ganoPlayer) {
        console.println(rival.mensaje(!ganoPlayer))
        self.cancel()
    }

    // devuelve si alguien ganó; en tal caso finaliza la partida y devuelve true
    method checkVictoria() {
        if (puntosPlayer >= puntosWin || puntosRival >= puntosWin) {
            self.end(puntosPlayer >= puntosWin) // TODO: simplificar? no hay manera que los dos sumen puntos a la vez
            return true
        } else return false
    }

    // resetea la ronda (una ronda consiste de 3 manos y 6 turnos)
    method resetRonda() {
        numsCartasJugadasPlayer.clear() numsCartasJugadasRival.clear()
        player.limpiarMano() rival.limpiarMano()
        cartaPlayer = joker cartaRival = joker
        manosFavorPlayer = 0 manosFavorRival = 0
        trucoHandler.reset()
        envidoHandler.reset()
        
        mano = 1 turno = 1

        esManoPlayer = !esManoPlayer // usar negate()?
        esTurnoPlayer = esManoPlayer
    }

    // ------------------------------ MÉTODOS DE AVANZAR (progresan la partida turno a turno) ------------------------------

    method avanzarTurno() {
        if (!self.checkVictoria()) { // compruebo por las dudas
            esTurnoPlayer = !esTurnoPlayer
            turno += 1
            if (turno.even()) { // turno del otro jugador
                self.retornarFlujo()
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

        const difFavor = (manosFavorPlayer - manosFavorRival).abs()
        if (difFavor == 2) self.avanzarRonda(manosFavorPlayer > manosFavorRival) // ← iguales ↓
        else if (difFavor == 1 && mano >= 3) self.avanzarRonda(manosFavorPlayer > manosFavorRival)
        else if (difFavor == 0 && mano == 4) self.avanzarRonda(esManoPlayer)
        else self.retornarFlujo() // nueva mano, sin avanzar de ronda
    }

    // true si ganó PLAYER, false si ganó RIVAL
    method avanzarRonda(ganoPlayer) {
        trucoHandler.asignarPuntosTruco(ganoPlayer)
        if (!self.checkVictoria()) { // si al asignar los puntos del truco alguien ganó, no entra
            console.println("--- NUEVA RONDA ---")
            self.resetRonda() // resetRonda ya alterna esManoPlayer
            self.repartir()
        }
    }

    method sumarPuntosPlayer(puntos) { puntosPlayer += puntos }
    method sumarPuntosRival(puntos) { puntosRival += puntos }

    // ------------------------------ MÉTODOS DE TURNO ------------------------------

    // --------------- RIVAL ---------------

    // llamado tanto si es su turno como si PLAYER aceptaTruco algo (le devuelve el flujo al RIVAL)
    method ejecutarTurnoRival() {
        if (!esTurnoPlayer) {
            // para simplificar, RIVAL sólo puede cantar en su turno
            if (trucoHandler.puedeCantarTrucoRival() && rival.decideCantarTruco(trucoHandler.nivelTruco()))
                trucoHandler.cantarTrucoRival() // TODO: ver qué más le pasamos al RIVAL para que decida
            envidoHandler.nivelCantadoPorRival(rival.decideCantarEnvido(envidoHandler.nivelEnvido())) // 0 si decide no cantar
            if (envidoHandler.puedeCantarEnvidoRival() && envidoHandler.nivelCantadoPorRival() != 0)
                envidoHandler.cantarEnvidoRival(envidoHandler.nivelCantadoPorRival())
            // ↑ si RIVAL cantó cualquier cosa, entonces espera una respuesta de PLAYER

            // ↓ si canto y por algún rechazo se suman puntos, evalúa si al sumarlos alguien ganó; sino, juega su carta y avanza
            if (!trucoHandler.rivalEsperaRtaTruco() && !envidoHandler.rivalEsperaRtaEnvido()) {
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
        const numCarta = cartas.anyOne() // elige una dentro de las posibles
        cartaRival = rival.jugarCarta(numCarta) // juega esa carta (la retorna) y se guarda

        numsCartasJugadasRival.add(numCarta) // la añade a las jugadas por RIVAL
        console.println("Rival tira: " + cartaRival)
    }

    // --------------- PLAYER ---------------

    // ACCIÓN DEL PLAYER: sólo posible si es el turno del PLAYER y RIVAL no espera respuesta (alternativa a irseMazoPlayer())
    method pedirCartaPlayer(numCarta) {
        if (esTurnoPlayer && !trucoHandler.rivalEsperaRtaTruco()) { // lógica similar a pedirCartaRival pero numCarta se pasa por param
            if ([1, 2, 3].contains(numCarta) && !numsCartasJugadasPlayer.contains(numCarta)) {
                cartaPlayer = player.jugarCarta(numCarta)
                numsCartasJugadasPlayer.add(numCarta)
                console.println("Player tira: " + cartaPlayer)
                self.avanzarTurno()
            } else console.println("No es posible tirar esa carta")
        } else console.println("No es el turno del player o el rival espera respuesta")
    }

    // ACCIÓN DEL PLAYER: sólo posible si es el turno del PLAYER y RIVAL no espera respuesta (alternativa a pedirCartaPlayer())
    method irseMazo() {
        if (esTurnoPlayer && !trucoHandler.rivalEsperaRtaTruco()) self.avanzarRonda(false)
        else console.println("No es el turno del player o el rival espera respuesta")
    }

    // --------------- OTROS ---------------

    method retornarFlujo() {
        if (!esTurnoPlayer) self.ejecutarTurnoRival()
    }

    // ------------------------------ MÉTODOS DE SUMAR, ASIGNAR Y COMPARAR CARTAS ------------------------------

    // compara cartaPlayer con cartaRival (retorna -1, 0 o 1 si carta menor, igual o mayor)
    method compararCartas() = cartaPlayer.mejorQue(cartaRival) // usado en avanzarMano()

    // // ver MÉTODOS DE ENVIDO
    // method asignarPuntosEnvido(ganoPlayer) { // el 1 de si se rechaza el primer canto ya está incorporado
    //     if (ganoPlayer) puntosPlayer += envidoHandler.puntosEnvido()
    //     else puntosRival += envidoHandler.puntosEnvido()
    // } // IMPORTANTE: SIEMPRE luego de asignar, consultar checkVictoria()
    
    // ver MÉTODOS DE TRUCO
    // method asignarPuntosTruco(ganoPlayer) {
    //     const neto = 1 + trucoHandler.nivelTruco() // automáticamente, sin importar si hubo Truco o no, se suma 1 punto a quien gane
    //     // nivelTruco contiene los puntos
    //     if (ganoPlayer) puntosPlayer += neto
    //     else puntosRival += neto
    // } // IMPORTANTE: SIEMPRE luego de asignar, consultar checkVictoria()

    // ------------------------------ MÉTODOS DE TRUCO ------------------------------
    // Truco → Retruco → Vale cuatro

    // --------------- RIVAL ---------------

    // method puedeCantarTrucoRival() = nivelTruco < 3 && !rivalEsperaRtaTruco && !rivalEsperaRtaEnvido
    // // puede cantar si no estamos en valecuatro (no compruebo si es turno del RIVAL porque siempre que se llame va a ser en su turno, ver ejecutarTurnoRival())
    // // igual por las dudas pongo !rivalEsperaRtaTruco (podría no estar)

    // method cantarTrucoRival() {
    //     if (nivelTruco == 0) esCantorTrucoPlayer = false // si canto truco, entonces PLAYER no es cantor
    //     // no necesito if(puedeCantarTrucoRival()) porque eso se verifico en ejecutarTurnoRival()
    //     console.println("Rival canta " + nextTruco.get(nivelTruco))
    //     rivalEsperaRtaTruco = true
    //     // IMPORTANTE: no se suma automáticamente el nivelTruco, eso se hace cuando PLAYER acepta (ver aceptarTrucoPlayer())
    // }

    // // --------------- PLAYER ---------------

    // // controla una ACCIÓN DEL PLAYER
    // method puedeAceptarTrucoPlayer() = rivalEsperaRtaTruco && ((nivelTruco == 0 && !esCantorTrucoPlayer) ||
    //                                                       (nivelTruco == 1 && esCantorTrucoPlayer) ||
    //                                                       (nivelTruco == 2 && !esCantorTrucoPlayer))
    // // puede aceptar si RIVAL espera respuesta y si corresponde por ser cantor

    // // controla una ACCIÓN DEL PLAYER
    // method puedeCantarTrucoPlayer() {
        
    //     if (rivalEsperaRtaTruco && nivelTruco < 3 && !rivalEsperaRtaEnvido) {
    //         nivelTruco += 1 // IMPORTANTE: si PLAYER responde cantando, es como aceptar automáticamente, por lo que se aumenta el nivel de truco
    //         return true
    //     } // si RIVAL espera respuesta, PLAYER siempre puede cantar; si esperaba respuesta, entonces estamos en un nivel de truco más
    //     else if (esTurnoPlayer && nivelTruco < 3 && !rivalEsperaRtaEnvido) return ((nivelTruco == 0) || (nivelTruco == 1 && !esCantorTrucoPlayer) || (nivelTruco == 2 && esCantorTrucoPlayer)) // si es turno del PLAYER, sólo puede cantar si nadie cantó o si corresponde por ser o no cantor
    //     else return false
    //     // sino no :P
    // }

    // ACCIÓN DEL PLAYER: sólo posible si VER puedeAceptarTrucoPlayer()
    method aceptarTrucoPlayer(acepta) { trucoHandler.aceptarTrucoPlayer(acepta) }

    // ACCIÓN DEL PLAYER: sólo posible si VER puedeCantarTrucoPlayer()
    method cantarTrucoPlayer() { trucoHandler.cantarTrucoPlayer() }

    // ------------------------------ MÉTODOS DE ENVIDO ------------------------------
    // Envido → (Envido | Real envido | Falta envido)
    // Real envido → Falta envido

    // --------------- RIVAL ---------------

    // // esto chequearlo en ejecutarTurnoRival(), automáticamente decide en su turno
    // method puedeCantarEnvidoRival() = !rivalEsperaRtaEnvido && mano == 1 && puntosEnvido == 0 && nivelEnvido == 0 && !rivalEsperaRtaTruco && nivelTruco == 0

    // method cantarEnvidoRival(nivelCantado) { // TODO: el rival.decideCantarEnvido estará arriba como con el truco 
    //     esCantorUltimoEnvidoPlayer = false
    //     console.println("Rival canta " + nextEnvido.get(nivelCantado-1))
    //     nivelCantadoPorRival = nivelCantado // se guarda el nivel cantado para si, al rechazarlo y si nivelEnvido=0, suma 1
    //     rivalEsperaRtaEnvido = true
    //     // IMPORTANTE: los puntosEnvido se suman cuando PLAYER acepta, no cuando RIVAL canta!
    // }
    
    // // --------------- PLAYER ---------------

    // method puedeAceptarEnvidoPlayer() = rivalEsperaRtaEnvido && !esCantorUltimoEnvidoPlayer

    // method puedeCantarEnvidoPlayer(nivelCantado) { return
    //     nivelCantado > nivelCantadoPorRival && (!esCantorUltimoEnvidoPlayer || rivalEsperaRtaEnvido) && mano == 1
    //     && nivelEnvido == 0 && puntosEnvido == 0 // quizas redundante, pero por las dudas
    //     && !rivalEsperaRtaTruco && nivelTruco == 0 && ((nivelCantado == 2 && nivelCantadoPorRival == 1) || nivelCantado != 2)
    // }

    // ACCIÓN DEL PLAYER
    method aceptarEnvidoPlayer(acepta) { envidoHandler.aceptarEnvidoPlayer(acepta) }

    // ACCIÓN DEL PLAYER
    method cantarEnvidoPlayer(nivelCantado) { envidoHandler.cantarEnvidoPlayer(nivelCantado) }


    // --------------- OTROS ---------------

    // method sumarPuntosEnvido() { // todavía nadie tiró, por eso lo tengo que guardar, no me puedo confiar de Chara().cantEnvido()
    //     cantEnvidoPlayer = player.cantEnvido()
    //     cantEnvidoRival = rival.cantEnvido()
    // }
    
    // method calcularFaltaEnvido(ganoPlayer) {
    //     if (ganoPlayer) return puntosWin - puntosRival
    //     else return puntosWin - puntosPlayer
    // }

    // method compararPuntosEnvido() { // los puntos de envido se suman al inicio de la ronda
    //     var ganaPlayer
    //     if (cantEnvidoPlayer > cantEnvidoRival) ganaPlayer = true
    //     else if (cantEnvidoPlayer < cantEnvidoRival) ganaPlayer = false
    //     else { ganaPlayer = esManoPlayer }
    //     if (nivelEnvido == 4) puntosEnvido = self.calcularFaltaEnvido(ganaPlayer) // si estamos en falta envido, calcula los puntosEnvido
    //     self.asignarPuntosEnvido(ganaPlayer)
    //     if (!self.checkVictoria()) self.retornarFlujo()
    // }

    





    // method envidoPosible = mano == 2

    // ------------------------------ MÉTODOS ADICIONALES ------------------------------

    // muestra información de la partida
    method show() {
        console.println(
            "data    | ------ Player | Rival ------\n" + 
            "cartas  | "+player.cartas()+" | "+rival.cartas()+"\n" +
            "envido  | "+envidoHandler.cantEnvidoPlayer()+" | "+envidoHandler.cantEnvidoRival()+"\n" +
            "ptos    | "+puntosPlayer+" | "+puntosRival+"\n" +
            "manos F | "+manosFavorPlayer+" | "+manosFavorRival+"\n" +
            "-------------------------------------------\n" +
            "mano = "+mano+" ("+if(esManoPlayer) "player" else {"rival"} +") | turno = "+turno+" ("+if(esTurnoPlayer) "player" else {"rival"}+")\n" +
             "nivelTruco ACTUAL = "+trucoHandler.nivelTruco()+"("+nextTruco.get(trucoHandler.nivelTruco()-1)+") | rival esperaTruco = "+trucoHandler.rivalEsperaRtaTruco()+"\n" +
             "nivelEnvido ACTUAL = "+envidoHandler.nivelEnvido()+"("+nextEnvido.get(envidoHandler.nivelEnvido()-1)+") | rival esperaEnvido = "+envidoHandler.rivalEsperaRtaEnvido()
        )
    }
}

// para tests ↓ (rivalTodo acepta y canta todo si se le permite)
object matchCtrl inherits Match(rival = rivalTodo, image = "bg/placeholder_matchEasy.png") {

    var property ganadorFinal = false // para controlar quien gana (false si rival, true si player)

    // "reinicia" valores para hacer los tests
    method setTest() {
        puntosPlayer = 0 puntosRival = 0
        manosFavorPlayer = 0 manosFavorRival = 0
        //nivelTruco = 0 esCantorTrucoPlayer = false rivalEsperaRtaTruco = false
        trucoHandler.reset()
        envidoHandler.reset()

        mano = 1 turno = 1
        esManoPlayer = true esTurnoPlayer = true
        numsCartasJugadasPlayer.clear() numsCartasJugadasRival.clear()
        cartaPlayer = joker cartaRival = joker ganadorFinal = false

        player.limpiarMano() rival.limpiarMano()
    }

    // NO USAR ESTE REPARTIR
    override method repartir() {}
    // ejecutarTurnoRival no hace nada, nosotros lo controlamos, MANUALMENTE HACER EL AVANZARTURNO
    override method ejecutarTurnoRival() {}
    override method retornarFlujo() {}

    // INICIAR CON REPARTIR, NO CON START
    method repartir(cartasP, cartasR) {
        player.asignarCartas(cartasP)
        rival.asignarCartas(cartasR)
        envidoHandler.sumarPuntosEnvido()
    }


    override method end(ganoPlayer) { ganadorFinal = ganoPlayer }

    // override method cantarTrucoRival() {
    //     if (!esTurnoPlayer && self.puedeCantarTrucoRival()) {
    //         if (nivelTruco == 0) esCantorTrucoPlayer = false
    //         console.println("Rival canta " + nextTruco.get(nivelTruco))
    //         rivalEsperaRtaTruco = true
    //     }
    // }
    // override method cantarEnvidoRival(nivelCantado) {
    //     esCantorUltimoEnvidoPlayer = false
    //     console.println("Rival canta " + nextEnvido.get(nivelCantado-1))
    //     nivelCantadoPorRival = nivelCantado
    //     rivalEsperaRtaEnvido = true
    // }
    // method pedirCartaRival(num) {
    //     if (!esTurnoPlayer) {
    //         if ([1, 2, 3].contains(num) && !numsCartasJugadasRival.contains(num)) {
    //             cartaRival = rival.jugarCarta(num)
    //             numsCartasJugadasRival.add(num)
    //             console.println("Rival tira: " + cartaRival)
    //             self.avanzarTurno()
    //         } else console.println("No es posible tirar esa carta")
    //     }
    // }

}

const matchEasy = new Match(rival = rivalEasy, image = "bg/placeholder_matchEasy.png")
const matchMid = new Match(rival = rivalMid, image = "bg/placeholder_matchMid.png")
const matchHard = new Match(rival = rivalHard, image = "bg/placeholder_matchHard.png")


object tester {
    method init() {
        matchEasy.start()
        matchEasy.show()
    }
}