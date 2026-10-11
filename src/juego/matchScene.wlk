import src.juego.cards.*
import src.juego.charas.*

class MatchScene {
    const player = mainPlayer
    const rival
    const dificultad = rival.dificultad()
    var property puntosWin = 5

    var property puntosPlayer = 0 // resetear al FINAL
    var manoFavorPlayer = 0 // resetear con RONDA
    var property cartaPlayer = joker // resetear con RONDA
    var numsCartasJugadasPlayer = [] // resetear con RONDA
    var property puntosRival = 0 // resetear al FINAL
    var manoFavorRival = 0 // resetear con RONDA
    var property cartaRival = joker // resetear con RONDA
    var numsCartasJugadasRival = [] // resetear con RONDA

    // despues vemos bien por el truco y siguientes
    var property estadoTruco = 0 // resetear con RONDA
    var property playerCantor = false // resetear con RONDA

    var property mano = 1 // resetear con RONDA
    var turno = 1 // resetear con RONDA

    var property puntosPorEnvido = 2
    var property rivalEsperaRespuesta = false // resetear con RONDA

    // controla quien es mano en una ronda (para alternar)
    var property playerMano = [true, false].anyOne() // resetear con RONDA 
    // indica de quien es el turno (false rival, true jugador)
    var property playerTurno = playerMano // resetear al FINAL

    const nextTruco = new Dictionary()
    override method initialize() {
        nextTruco.put(-1, "NADA")
        nextTruco.put(0, "TRUCO")
        nextTruco.put(1, "RETRUCO")
        nextTruco.put(2, "VALECUATRO")
    }

    // inicia la partida
    method start() {
        self.repartir()
    }

    // finaliza la partida (resetea todo)
    method end(ganoPlayer) {
        console.println(rival.mensaje(!ganoPlayer))
        puntosPlayer = 0 puntosRival = 0
        self.resetRonda()
        playerMano = [true, false].anyOne() // sobreescribo lo de resetRonda()
        playerTurno = playerMano
    }

    // resetea la ronda (una ronda consiste de 3 manos y 6 turnos)
    method resetRonda() {
        numsCartasJugadasPlayer.clear() numsCartasJugadasRival.clear()
        player.limpiarMano() rival.limpiarMano()
        cartaPlayer = joker cartaRival = joker
        manoFavorPlayer = 0 manoFavorRival = 0
        estadoTruco = 0 playerCantor = false
        rivalEsperaRespuesta
        mano = 1 turno = 1

        playerMano = !playerMano // usar negate()?
        playerTurno = playerMano
    }

    // reparte las cartas
    method repartir() {
        var mazoAux = mazoEntero.randomized()
        player.asignarCartas(mazoAux.subList(0,2))
        rival.asignarCartas(mazoAux.subList(3,5))

        // si es el turno del rival (playerTurno == false), juega automáticamente
        if (!playerMano) self.ejecutarTurnoRival()
        // mostrar msg para indicar eso ↑ según quien sea mano
    }

    method ejecutarTurnoRival() { // TAMBIÉN LLAMADO LUEGO DE QUE EL PLAYER ACEPTE Y ENTONCES YA rivalEsperaRespuesta = false
        if (!playerTurno) {
            // considerar las opciones de truco y coso
            if (self.puedeCantarRival() && rival.decideCantarTruco(estadoTruco))
                self.rivalCantaTrucoActual() // ver qué más le pasamos al rival
            // AHORA EL RIVAL ESPERA UNA RESPUESTA DEL PLAYER ↑
            // EL RIVAL SOLO PUEDE CANTAR EN SU TURNO
            if (!rivalEsperaRespuesta) {
                if (!self.checkVictoria()) {
                    self.pedirCartaRival()
                    self.avanzarTurno()
                }
            }
        } else console.println("No es el turno del rival")
    }

    // pide una carta al rival
    method pedirCartaRival() {
        const cartas = [1, 2, 3]
        cartas.removeAll(numsCartasJugadasRival)
        var numCarta = cartas.anyOne()
        cartaRival = rival.jugarCarta(numCarta)

        numsCartasJugadasRival.add(numCarta)
        console.println("Rival tira: "+cartaRival) // acá la lógica para ver la carta que tiró el rival
    }
    // pide la carta `numCarta` al player
    // ACCIÓN DEL PLAYER
    method pedirCartaPlayer(numCarta) {
        if (playerTurno && !rivalEsperaRespuesta) {
            if ([1, 2, 3].contains(numCarta) && !numsCartasJugadasPlayer.contains(numCarta)) {
                cartaPlayer = player.jugarCarta(numCarta)
                numsCartasJugadasPlayer.add(numCarta)
                console.println("Player tira: "+cartaPlayer) // idem
                self.avanzarTurno()
            }
        } else console.println("No es el turno del player o el rival espera respuesta")
    }
    // ACCIÓN DEL PLAYER
    method irseMazo() {
        if (playerTurno && !rivalEsperaRespuesta) self.avanzarRonda(false)
        else console.println("No es el turno del player o el rival espera respuesta")
    }

    // compara cartaPlayer con cartaRival (retorna -1, 0 o 1 si carta menor, igual o mayor)
    method compararCartas() = cartaPlayer.mejorQue(cartaRival)

    var estadoEnvido = 0 // despues vemos bien por el envido y siguientes
    // QUE EL ESTADO ENVIDO CONTENGA LOS PUNTOS? y como evaluo entonces donde estoy?
    method avanzarTurno() {
        if (mano == 1 && estadoEnvido > 0) self.asignarPuntosEnvido() // dependiendo del estado, asigna puntos (1=envido, 2=EE, ...)
        // ACÁ VER LO DE TRUCO ?
        if (!self.checkVictoria()) {
            playerTurno = !playerTurno
            turno += 1
            if (turno.even()) {  // turno del otro jugador
                if (!playerTurno) self.ejecutarTurnoRival()
            }
            else self.avanzarMano() // el turno depende de quien haya ganado
            //else if (turno.odd())
        }
    }

    method avanzarMano() {
        mano += 1 // no quiero que se sume al final porque sino al avanzarRonda se arrancaría con una mano más
        if (self.compararCartas() == 1) {
            manoFavorPlayer += 1
            playerTurno = true
        }
        else if (self.compararCartas() == -1) {
            manoFavorRival += 1
            playerTurno = false
        }
        else { 
            manoFavorPlayer += 1
            manoFavorRival += 1
            playerTurno = playerMano
        }

        var difFavor = (manoFavorPlayer - manoFavorRival).abs()
        if (difFavor == 2) self.avanzarRonda(manoFavorPlayer > manoFavorRival) // ← iguales ↓
        else if (difFavor == 1 && mano >= 3) self.avanzarRonda(manoFavorPlayer > manoFavorRival)
        else if (difFavor == 0 && mano == 4) self.avanzarRonda(playerMano)
        else if (!playerTurno) self.ejecutarTurnoRival() // nueva mano juega rival
        // else: nueva mano juega player
    }

    // aca asigno los puntos de truco y eso
    method avanzarRonda(ganoPlayer) { // true si ganó player, false si ganó rival
        self.asignarPuntosTruco(ganoPlayer) // hacerlo luego del truco?
        if (!self.checkVictoria()) {
            console.println("--- NUEVA RONDA ---")
            self.resetRonda() // resetRonda ya alterna playerMano
            self.repartir()
        }
    }

    method asignarPuntosEnvido() {
        // revisar estadoEnvido
    }
    
    method asignarPuntosTruco(ganoPlayer) {
        var neto = 1 + estadoTruco // estadoTruco contiene los puntos?
        if (ganoPlayer) puntosPlayer += neto
        else puntosRival += neto
    }

    method checkVictoria() {
        if (puntosPlayer >= puntosWin || puntosRival >= puntosWin) {
            self.end(puntosPlayer >= puntosWin)
            return true
        } else return false
    }

    

    method puedeAceptarPlayer() = rivalEsperaRespuesta && ((estadoTruco == 0 && !playerCantor) ||
                                                          (estadoTruco == 1 && playerCantor) ||
                                                          (estadoTruco == 2 && !playerCantor))
    method puedeCantarPlayer() {
        if (rivalEsperaRespuesta && estadoTruco < 3) {
            estadoTruco += 1
            return true
        } // si rivalEsperaRespuesta, siempre puedo cantar, tengo que sumarle que si esperaba respuesta, entonces estamos en un nivel de truco más
        else if (playerTurno && estadoTruco < 3) return ((estadoTruco == 0) || (estadoTruco == 1 && !playerCantor) || (estadoTruco == 2 && playerCantor)) // si es mi turno, sólo puedo cantar si nadie cantó o si me corresponde por ser o no cantor
        else return false
        // sino no :P
    }

    // ACCIÓN DEL PLAYER, SÓLO CUANDO EL RIVAL ESPERA RESPUESTA
    method playerAceptaTrucoActual(acepta) { // acepta el último truco cantado
        if (self.puedeAceptarPlayer()) {
            rivalEsperaRespuesta = false
            if (acepta) {
                console.println("Player acepta " + nextTruco.get(estadoTruco))
                estadoTruco += 1
                self.ejecutarTurnoRival() // A DÓNDE REDIRIGIR EL FLUJO ???
                // COMO EL RIVAL SIEMPRE CANTA EN SU TURNO, SI PLAYER ACEPTA, SIGUE EN SU TURNO EL RIVAL!
            } else {
                console.println("Player rechaza " + nextTruco.get(estadoTruco))
                self.avanzarRonda(false) // avanzarRonda suma los puntos de estadoTruco
            }
        } 
    }
    // ACCIÓN DEL PLAYER, SÓLO CUANDO EL RIVAL ESPERA RESPUESTA O ES EL TURNO DEL PLAYER
    method playerCantaTrucoActual() { // canta el próximo truco posible
        if (estadoTruco == 0) playerCantor = true
        if (self.puedeCantarPlayer()) {
            rivalEsperaRespuesta = false
            console.println("Player canta " + nextTruco.get(estadoTruco))
            if (rival.decideAceptarTruco(estadoTruco)) {
                console.println("Rival acepta " + nextTruco.get(estadoTruco)) // A DÓNDE REDIRIGIR EL FLUJO ???
                estadoTruco += 1
                // PLAYER PUEDE CANTAR EN SU TURNO O SI LE CANTARON! ENTONCES HAY QUE VER ADÓNDE MANDAMOS EL FLUJO
                // if (playerTurno) ← SIGUE TODO NORMAL, MI TURNO, SIGO EN CTRL
                if (!playerTurno) self.ejecutarTurnoRival()
            } else {
                console.println("Rival rechaza " + nextTruco.get(estadoTruco))
                self.avanzarRonda(true) // avanzarRonda suma los puntos de estadoTruco
            }
        }
    }

    // EL RIVAL PUEDE ACEPTAR SI EL PLAYER LE CANTÓ ALGO
    // method puedeAceptarRival() {
    //     return (playerEsperaRespuesta && (estadoTruco == 0 && playerCantor) ||
    //         (estadoTruco == 1 && !playerCantor) ||
    //         (estadoTruco == 2 && playerCantor))
    // }
    method puedeCantarRival() = estadoTruco < 3 && !rivalEsperaRespuesta
    // NO COMPRUEBO SI ES TURNO DEL RIVAL PORQUE SIEMPRE AL LLAMARSE VA A SER EL TURNO DEL RIVAL
    // POR LAS DUDAS PONGO !rivalEsperaRespuesta
    method rivalCantaTrucoActual() {
        if (estadoTruco == 0) playerCantor = false
        // if (self.puedeCantarPlayer()) { NO LO PONEMOS PORQUE SI ENTRÓ ACÁ, ES PORQUE PUDO, LO DECIDIÓ EN SU TURNO
        console.println("Rival canta " + nextTruco.get(estadoTruco)) // ojo que no se suma automaticamente el estadoTruco
        rivalEsperaRespuesta = true // EL RESTO LO DECIDE EL PLAYER EN playerAceptaTrucoActual()
        // if (self.rivalAceptaTrucoActual()) {
        //     estadoTruco += 1
        //     console.println("Rival acepta "+texto)
        //     // A DÓNDE REDIRIGIR EL FLUJO ???
        // } else {
        //     console.println("Rival rechaza "+texto)
        //     self.avanzarRonda(true) // avanzarRonda suma los puntos de estadoTruco
        // }
    }
    // ACCIÓN DEL RIVAL, SÓLO CUANDO NO ESPERA RESPUESTA    
    // EL RIVAL ACEPTA SI EL PLAYER LE CANTÓ ALGO
    // method rivalAceptaTrucoActual(acepta) { // acepta viene de rival.Aceptarblablabla()
    //     var texto
    //     if (estadoTruco == 0) texto = "truco"
    //     else if (estadoTruco == 1) texto = "retruco"
    //     else if (estadoTruco == 2) {texto = "vale cuatro"}
    //     // if (self.puedeAceptarRival()) { NO LO PONEMOS PORQUE SI ENTRÓ ACÁ, ES PORQUE PUDO, LO DECIDIÓ EN SU TURNO
    //     if (acepta) {
    //         estadoTruco += 1
    //         console.println("Rival acepta "+texto)
    //         // A DÓNDE REDIRIGIR EL FLUJO ???
    //     } else {
    //         console.println("Rival rechaza "+texto)
    //         self.avanzarRonda(true) // avanzarRonda suma los puntos de estadoTruco
    //     }
    // }




    // method envidoPosible = mano == 2

    // muestra información de la partida
    method show() {
        console.println(
            "data    | ------ Player | Rival ------\n" + 
            "cartas  | "+player.cartas()+" | "+rival.cartas()+"\n" +
            "ptos    | "+puntosPlayer+" | "+puntosRival+"\n" +
            "manos F | "+manoFavorPlayer+" | "+manoFavorRival+"\n" +
            "-------------------------------------------\n" +
            "mano = "+mano+" ("+if(playerMano) "player" else {"rival"} +") | turno = "+turno+" ("+if(playerTurno) "player" else {"rival"}+") | estadoTruco ACTUAL = "+estadoTruco+"("+nextTruco.get(estadoTruco-1)+") | rival espera = "+rivalEsperaRespuesta+"\n"
        )
    }
}

const matchEasy = new MatchScene(rival = rivalEasy)

object tester {
    method init() {
        matchEasy.start()
        console.println(rivalEasy.cartas())
        console.println(mainPlayer.cartas())
    }
}