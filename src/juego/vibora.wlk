

object arriba{
    method image()="viborita_cabeza_arriba.png"

    method siguientePosicion(posicionInicial) = posicionInicial.up(1)
}

object izquierda{
    method image()="viborita_cabeza_izquierda.png"
    method siguientePosicion(posicionInicial) = posicionInicial.left(1)


}

object abajo{
    method image()="viborita_cabeza_abajo.png"
    method siguientePosicion(posicionInicial) = posicionInicial.down(1)

}

object derecha{
    method image()="viborita_cabeza_derecha.png"
    method siguientePosicion(posicionInicial) = posicionInicial.right(1)

}
object vibora {
    var position=game.center()
    var direccion = arriba

    // method position() = position
    method position() {
        return position
    }
    method position(nuevaPosicion) {
        position = nuevaPosicion
    }

    method image(){
        
        return direccion.image()
    }

    method moverse(){
        position=direccion.siguientePosicion(position)
    }
        
    method direccion(unaDireccion){
        direccion = unaDireccion
    }
}

object moverVibora {
    method apply() {
      vibora.moverse()
    }
}

object moverDerecha{
    method apply(){
        vibora.direccion(derecha)
    }
}
