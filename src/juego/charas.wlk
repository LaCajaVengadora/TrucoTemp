import src.juego.cards.joker
class Chara {
    var property cartas = new Dictionary()

    override method initialize() {
        self.limpiarMano()
    }

    method asignarCartas(listCartas) {
        // usar forEach con [1..3] y listCartas?
        cartas.put(1, listCartas.get(0))
        cartas.put(2, listCartas.get(1))
        cartas.put(3, listCartas.get(2))
    }

    method limpiarMano() {
        [1,2,3].forEach({ n => cartas.put(n, joker) })
        //cartas.put(1, joker)
        //cartas.put(2, joker)
        //cartas.put(3, joker)
    }
    method removeCarta(numCarta) {
        if (numCarta.between(1, 3)) {
            cartas.put(numCarta, joker)
        }
    }

    method jugarCarta(numCarta) {
        if (numCarta.between(1, 3)) {
            const carta = cartas.get(numCarta)
            self.removeCarta(numCarta)
            return carta
        } else return joker
    }

    method envidoEntre(carta1, carta2) { // TODO: pensar si está bien que sea un método del jugador
        if (carta1.palo() == carta2.palo()) return 20 + carta1.valorEnvido() + carta2.valorEnvido()
        else return 0
    }
    method cantEnvido() {
        const carta1 = cartas.get(1) const carta2 = cartas.get(2) const carta3 = cartas.get(3)
        return [carta1.valorEnvido(), carta2.valorEnvido(), carta3.valorEnvido(),
                self.envidoEntre(carta1, carta2), self.envidoEntre(carta1, carta3), self.envidoEntre(carta2, carta3)
        ].max() // guardo todo porque si las 3 son de palos distintos, cantEnvido es la carta de mayor valorEnvido
    }

}
const mainPlayer = new Chara()
// LAS CARTAS SON 0, 1, 2, DESPUÉS EN LOS CONTROLES LO VEMOS

class Rival inherits Chara {
    const property nombre
    const property image
    const property position
    const msgVictoria = "Gana rival placeholder"
    const msgDerrota = "Pierde rival placeholder"
    // var property cargoso QUE SE BURLE?

    const property dificultad
    // var property puntos = 0 QUE EL RIVAL NO CONSIDERE LOS PUNTOS, SINO LA SCENE LOS CONSIDERA
    // method addCarta(carta) {cartas.add(carta)}

    // TODO: IMPLEMENTAR LÓGICA TRUCO Y ENVIDO (poner un "valor envido" al obtener la carta?)

    // TODO: IMPLEMENTAR LÓGICA DECIDIR QUÉ CARTA TIRAR (añadir estados de si gano primera o segunda mano?)

    // method sumarPuntos(pts) {puntos += pts}

    method mensaje(ganoRival) = if (ganoRival) msgVictoria else msgDerrota
    
    // ↓ abstractos ↓ dependen de la dificultad del rival
    method decideCantarTruco(estadoTruco)
    //method decideAceptarTruco(estadoTruco)
    method respuestaTruco(estadoTruco)
    method decideCantarEnvido(estadoEnvido)
    //method decideAceptarEnvido(estadoEnvido)
    method respuestaEnvido(estadoEnvido)
}


object rivalEasy inherits Rival(nombre = "easiest", dificultad = 1,
    msgVictoria = "JA, PERDISTE CONTRA MÍ, SOS RE BOBO", msgDerrota = "Y bue, era obvio",
    position = game.at(3, 11), image = "rival/rivalEasy.png") {
    override method decideCantarTruco(e) = e == 1
    //override method decideAceptarTruco(e) = true
    override method respuestaTruco(e) = true

    override method decideCantarEnvido(e) = 1 // ojo que 2 no puede ser cantado de una
    //override method decideAceptarEnvido(e) = true
    override method respuestaEnvido(e) = 1 // quiero
}


object rivalMid inherits Rival(nombre = "midest", dificultad = 2,
    msgVictoria = "Jeje, no contabas con mi astucia 🤓", msgDerrota = "Hmm... bien jugado",
    position = game.at(3, 11), image = "rival/rivalMid.png") {
    override method decideCantarTruco(e) = e == 1
    //override method decideAceptarTruco(e) = true
    override method respuestaTruco(e) = true

    override method decideCantarEnvido(e) = 1 // ojo que 2 no puede ser cantado de una
    //override method decideAceptarEnvido(e) = true
    override method respuestaEnvido(e) = 1 // quiero
}
object rivalHard inherits Rival(nombre = "hardest", dificultad = 3,
    msgVictoria = "No te calentés, ni tenías chance...", msgDerrota = "I-IMPOSIBLE!!! * se pega un tiro *",
    position = game.at(3, 11), image = "rival/rivalHard.png") {
    override method decideCantarTruco(e) = e == 1
    //override method decideAceptarTruco(e) = true
    override method respuestaTruco(e) = true

    override method decideCantarEnvido(e) = 1 // ojo que 2 no puede ser cantado de una
    //override method decideAceptarEnvido(e) = true
    override method respuestaEnvido(e) = 1 // quiero
}




object rivalCantor inherits Rival(nombre="cantor", dificultad = 0,
    msgVictoria = "perdiste", msgDerrota = "ganaste",
    position = game.at(3, 11), image = "rival/rivalEasy.png") {
    override method decideCantarTruco(e) = true // siempre canta cuando puede
    override method respuestaTruco(e) = false // nunca acepta
    override method decideCantarEnvido(e) = 1 // inmediatamente canta
    override method respuestaEnvido(e) = 0 // nunca acepta
}
object rivalAceptor inherits Rival(nombre="aceptor", dificultad = 0,
    msgVictoria = "perdiste", msgDerrota = "ganaste",
    position = game.at(3, 11), image = "rival/rivalEasy.png") {
    override method decideCantarTruco(e) = false // nunca canta
    override method respuestaTruco(e) = true // pero siempre acepta
    override method decideCantarEnvido(e) = 0 // nunca canta
    override method respuestaEnvido(e) = if (e==4) 1 else e + 1 // siempre acepta y eleva
}
object rivalTodo inherits Rival(nombre="todor", dificultad = 0,
    msgVictoria = "perdiste", msgDerrota = "ganaste",
    position = game.at(3, 11), image = "rival/rivalEasy.png") {
    override method decideCantarTruco(e) = true
    override method respuestaTruco(e) = true
    override method decideCantarEnvido(e) = 1
    override method respuestaEnvido(e) = if (e==4) 1 else e + 1
}