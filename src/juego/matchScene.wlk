import src.juego.cards.*
import src.juego.charas.*

class MatchScene {
    const player = mainPlayer
    const rival
    const dificultad = rival.dificultad()

    var property puntosPlayer = 0
    var manoFavorPlayer = 0
    var property cartaPlayer = joker
    var numsCartasJugadasPlayer = []
    var property puntosRival = 0
    var manoFavorRival = 0
    var property cartaRival = joker
    var numsCartasJugadasRival = []

    var property puntosWin = 3
    var property mano = 1
    var turno = 1

    var property puntosPorEnvido = 2

    var property playerTurno = [true, false].anyOne() // indica de quien es el turno (false rival, true jugador)
    var property playerMano = playerTurno // controla quien es mano en una ronda (para alternar)

    // inicia la partida
    method start() {
        self.repartir()
    }

    // finaliza la partida (resetea todo)
    method end(ganoPlayer) {
        console.println(rival.mensaje(!ganoPlayer))
        puntosPlayer = 0 puntosRival = 0
        playerTurno = [true, false].anyOne()
        playerMano = playerTurno
        self.resetRonda()
    }

    // resetea la ronda (una ronda consiste de 3 manos y 6 turnos)
    method resetRonda() {
        numsCartasJugadasPlayer.clear() numsCartasJugadasRival.clear()
        player.limpiarMano() rival.limpiarMano()
        cartaPlayer = joker cartaRival = joker
        manoFavorPlayer = 0 manoFavorRival = 0
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
        if (!playerMano) self.pedirCartaRival()
        // mostrar msg para indicar eso ↑ según quien sea mano
    }

    // pide una carta al rival
    method pedirCartaRival() {
        if (!playerTurno) {

            if (estadoTruco == 0 && rival.decideCantarTruco()) self.cantarTruco()
            else if (estadoTruco == 1 && rival.decideCantarRetruco()) self.cantarRetruco()
            else if (estadoTruco == 2 && rival.decideCantarValecuatro()) { self.cantarValecuatro() }

            if (!self.checkVictoria()) {
                const cartas = [1, 2, 3]
                cartas.removeAll(numsCartasJugadasRival)
                var numCarta = cartas.anyOne()
                cartaRival = rival.jugarCarta(numCarta)

                numsCartasJugadasRival.add(numCarta)
                console.println("Rival tira: "+cartaRival) // acá la lógica para ver la carta que tiró el rival

                self.avanzarTurno()
            }
        } else console.println("No es el turno del rival")
    }
    // pide una carta al player (PARA TESTEAR)
    method pedirCartaPlayer() {
        if (playerTurno) {
            const cartas = [1, 2, 3]
            cartas.removeAll(numsCartasJugadasPlayer)
            var numCarta = cartas.anyOne()
            cartaPlayer = player.jugarCarta(numCarta)

            numsCartasJugadasPlayer.add(numCarta)
            console.println("Player tira: "+cartaPlayer) // idem

            self.avanzarTurno()
        } else console.println("No es el turno del player")
    }
    // pide la carta `numCarta` al player
    method pedirCartaPlayer(numCarta) {
        if (playerTurno) {
            if ([1, 2, 3].contains(numCarta) && !numsCartasJugadasPlayer.contains(numCarta)) {
                cartaPlayer = player.jugarCarta(numCarta)
                numsCartasJugadasPlayer.add(numCarta)
                console.println("Player tira: "+cartaPlayer) // idem
                self.avanzarTurno()
            }
        } else console.println("No es el turno del player")
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
                if (!playerTurno) self.pedirCartaRival()
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
        else if (!playerTurno) self.pedirCartaRival() // nueva ronda juega rival
        // else: nueva ronda juega player
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

    var property estadoTruco = 0 // despues vemos bien por el truco y siguientes
    var property playerCantor = false
    method cantarTruco() {
        if (estadoTruco == 0) {
            if (playerTurno) {
                console.println("Player canta truco")
                playerCantor = true
                if (self.aceptarTrucoRival()) {
                    estadoTruco += 1
                    console.println("Rival acepta truco")
                }
                else {
                    self.avanzarRonda(true)
                    console.println("Rival rechaza truco")
                }
            } else {
                console.println("Rival canta truco")
                playerCantor = false
                if (self.aceptarTrucoPlayer(true)) {
                    estadoTruco += 1
                    console.println("Player acepta truco")
                }
                else {
                    console.println("Player rechaza truco")
                    self.avanzarRonda(false)
                } 
            }
        }
    }
    method cantarRetruco() {
        if (estadoTruco == 1) {
            if (playerTurno && !playerCantor) { // cantó el player sin él haber cantado Truco
                console.println("Player canta retruco")
                if (self.aceptarTrucoRival()) {
                    estadoTruco += 1
                    // TODOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO HACER EL CANTAR Y EL ACEPTAR COMO DOS DISTINTOS? ASÍ PODER LLAMAR AL DEL PLAYER POR SEPARADO
                }
                else self.avanzarRonda(true)
            } else if (!playerTurno && playerCantor) { // cantó el rival sin él haber cantado Truco
                if (self.aceptarTrucoPlayer(true)) estadoTruco += 1
                else self.avanzarRonda(false) // IDEM, MUY IMPORTANTE
            }
        }
    }
    method cantarValecuatro() {
        if (estadoTruco == 2) {
            if (playerTurno && playerCantor) { // cantó el player habiendo él cantado Truco
                if (self.aceptarTrucoRival()) estadoTruco += 1
                else self.avanzarRonda(true)
            } else if (!playerTurno && !playerCantor) { // cantó el rival habiendo él cantado Truco
                if (self.aceptarTrucoPlayer(true)) estadoTruco += 1
                else self.avanzarRonda(false) // IDEM, MUY IMPORTANTE
            }
        }
    }
    // son formas distintas
    method aceptarTrucoRival() = rival.decideAceptarTruco(estadoTruco)
    method aceptarTrucoPlayer(val) = val
    




    // method envidoPosible = mano == 2

    // muestra información de la partida
    method show() {
        console.println(
            "data    | ------ Player | Rival ------\n" + 
            "cartas  | "+player.cartas()+" | "+rival.cartas()+"\n" +
            "ptos    | "+puntosPlayer+" | "+puntosRival+"\n" +
            "manos F | "+manoFavorPlayer+" | "+manoFavorRival+"\n" +
            "-------------------------------------------\n" +
            "mano = "+mano+" ("+if(playerMano) "player" else {"rival"} +") | turno = "+turno+" ("+if(playerTurno) "player" else {"rival"}+")\n"
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