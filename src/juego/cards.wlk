/*
JERARQUÍAS (E, B, O, C)
1 - 1E
2 - 1B
3 - 7E
4 - 7O

5 - 3's
6 - 2's
7 - 1O / 1C

8 - 12's
9 - 11's
10 - 10's
11 - 7B / 7C
12 - 6's
13 - 5's
14 - 4's

*/
class Carta {
    const property num
    const property palo
    const property valorEnvido = if ([10, 11, 12].contains(num)) 0 else num
    const property jerarquia
    const property imagen = ""


    // -1 si es peor, 0 si es igual, 1 si es mejor
    method mejorQue(otraCarta) { return 
        if (self.jerarquia() < otraCarta.jerarquia()) 1
        else if (self.jerarquia() == otraCarta.jerarquia()) 0
        else -1
    }
    override method toString() = num.toString() + " de " + palo 
}

const espada1 = new Carta (num = 1, palo = "E", jerarquia = 1)
const basto1 = new Carta (num = 1, palo = "B", jerarquia = 2)
const espada7 = new Carta (num = 7, palo = "E", jerarquia = 3)
const oro7 = new Carta (num = 7, palo = "O", jerarquia = 4)

const espada3 = new Carta (num = 3, palo = "E", jerarquia = 5)
const basto3 = new Carta (num = 3, palo = "B", jerarquia = 5)
const oro3 = new Carta (num = 3, palo = "O", jerarquia = 5)
const copa3 = new Carta (num = 3, palo = "C", jerarquia = 5)
const espada2 = new Carta (num = 2, palo = "E", jerarquia = 6)
const basto2 = new Carta (num = 2, palo = "B", jerarquia = 6)
const oro2 = new Carta (num = 2, palo = "O", jerarquia = 6)
const copa2 = new Carta (num = 2, palo = "C", jerarquia = 6)
const oro1 = new Carta (num = 1, palo = "O", jerarquia = 7)
const copa1 = new Carta (num = 1, palo = "C", jerarquia = 7)

const espada12 = new Carta (num = 12, palo = "E", jerarquia = 8)
const basto12 = new Carta (num = 12, palo = "B", jerarquia = 8)
const oro12 = new Carta (num = 12, palo = "O", jerarquia = 8)
const copa12 = new Carta (num = 12, palo = "C", jerarquia = 8)
const espada11 = new Carta (num = 11, palo = "E", jerarquia = 9)
const basto11 = new Carta (num = 11, palo = "B", jerarquia = 9)
const oro11 = new Carta (num = 11, palo = "O", jerarquia = 9)
const copa11 = new Carta (num = 11, palo = "C", jerarquia = 9)
const espada10 = new Carta (num = 10, palo = "E", jerarquia = 10)
const basto10 = new Carta (num = 10, palo = "B", jerarquia = 10)
const oro10 = new Carta (num = 10, palo = "O", jerarquia = 10)
const copa10 = new Carta (num = 10, palo = "C", jerarquia = 10)

const basto7 = new Carta (num = 7, palo = "B", jerarquia = 11)
const copa7 = new Carta (num = 7, palo = "C", jerarquia = 11)
const espada6 = new Carta (num = 6, palo = "E", jerarquia = 12)
const basto6 = new Carta (num = 6, palo = "B", jerarquia = 12)
const oro6 = new Carta (num = 6, palo = "O", jerarquia = 12)
const copa6 = new Carta (num = 6, palo = "C", jerarquia = 12)
const espada5 = new Carta (num = 5, palo = "E", jerarquia = 13)
const basto5 = new Carta (num = 5, palo = "B", jerarquia = 13)
const oro5 = new Carta (num = 5, palo = "O", jerarquia = 13)
const copa5 = new Carta (num = 5, palo = "C", jerarquia = 13)
const espada4 = new Carta (num = 4, palo = "E", jerarquia = 14)
const basto4 = new Carta (num = 4, palo = "B", jerarquia = 14)
const oro4 = new Carta (num = 4, palo = "O", jerarquia = 14)
const copa4 = new Carta (num = 4, palo = "C", jerarquia = 14)


const mazoEntero = [
    espada1, espada2, espada3, espada4, espada5, espada6, espada7, espada10, espada11, espada12,
    basto1, basto2, basto3, basto4, basto5, basto6, basto7, basto10, basto11, basto12,
    oro1, oro2, oro3, oro4, oro5, oro6, oro7, oro10, oro11, oro12,
    copa1, copa2, copa3, copa4, copa5, copa6, copa7, copa10, copa11, copa12
]
object joker inherits Carta (num = -1, palo = "J", jerarquia = 0) {
    override method toString() = "void"
}