import src.juego.cards.joker
class Chara {
    var property cartas = new Dictionary()

    override method initialize() { // automaticamente cartas es {1:joker, 2:joker, 3:joker}
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

    method decideCantarTruco() {return true}
    method decideCantarRetruco() {return true}
    method decideCantarValecuatro() {return true}
    method decideAceptarTruco(estadoTruco) {return true}

}
const mainPlayer = new Chara()
// LAS CARTAS SON 0, 1, 2, DESPUÉS EN LOS CONTROLES LO VEMOS

class Rival inherits Chara {
    const property nombre
    const property imagen = ""
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
}

const rivalEasy = new Rival(nombre = "easiest", dificultad = 1,
    msgVictoria = "JA, PERDISTE CONTRA MÍ, SOS RE BOBO", msgDerrota = "Y bue, era obvio")
const rivalMid = new Rival(nombre = "midest", dificultad = 2,
    msgVictoria = "Jeje, no contabas con mi astucia 🤓", msgDerrota = "Hmm... bien jugado")
const rivalHard = new Rival(nombre = "hardest", dificultad = 3,
    msgVictoria = "No te calentés, ni tenías chance...", msgDerrota = "I-IMPOSIBLE!!! * se pega un tiro *")