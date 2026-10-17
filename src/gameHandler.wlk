import src.matchScene.*

/*
IMPORTANTE IMÁGENES

Cada celda mide 64x64 pixeles
A continuación se pondrán el ancho x alto para cada imagen y luego en pixeles

- FONDOS: 1408 x 960 (22x15)
- CARTAS GRANDES: 256 x 256 (4x4)
- CARTAS CHICAS: 128 x 192 (2x3)
- CARTAS RIVAL (ocultas): 128 x 128 (2x2)
LAS CARTAS YA ESTÁN HECHAS :D FALTA AGREGARLAS


*/



object gameHandler {
    method start() {
        game.width(22)
        game.height(15)
        game.cellSize(64)
        game.title("Truco")

        game.boardGround("bg/placeholder_menu.png")
        self.setMenuScene()
        game.start()
    }

    

    method setMenuScene() {
        game.clear()
        //game.addVisual(menuBg)
        console.println("--- MENU SCENE ---")

        // ESPACIO inicia la escena de selección
        keyboard.space().onPressDo({self.setSelectScene()})
    }

    method setSelectScene() {
        game.clear()
        game.addVisual(selectorBg)
        console.println("--- SELECTOR SCENE ---")

        // SHIFT vuelve a la escena de menu inicial
        keyboard.shift().onPressDo({self.setMenuScene()})

        keyboard.num1().onPressDo({self.setMatchScene(1)})
        keyboard.num2().onPressDo({self.setMatchScene(2)})
        keyboard.num3().onPressDo({self.setMatchScene(3)})
        
    }

    method setMatchScene(dificultad) {
        game.clear()
        var match var rival
        if(dificultad == 1) match = matchEasy else if (dificultad == 2) match = matchMid else {match = matchHard}
        rival = match.rival()
        game.addVisual(match)
        game.addVisual(rival)
        console.println("--- MATCH ("+dificultad+") SCENE ---")

        match.start()
        match.show() // TODO: SACAR EN LA VERSIÓN FINAL?
        keyboard.s().onPressDo({match.show()}) // TODO: SACAR EN LA VERSIÓN FINAL?


        keyboard.num1().onPressDo({match.pedirCartaPlayer(1)})
        keyboard.num2().onPressDo({match.pedirCartaPlayer(2)})
        keyboard.num3().onPressDo({match.pedirCartaPlayer(3)})

        keyboard.t().onPressDo({match.cantarTrucoPlayer()})

        keyboard.e().onPressDo({match.cantarEnvidoPlayer(1)})
        keyboard.d().onPressDo({match.cantarEnvidoPlayer(2)})
        keyboard.r().onPressDo({match.cantarEnvidoPlayer(3)})
        keyboard.f().onPressDo({match.cantarEnvidoPlayer(4)})

        // SHIFT vuelve a la escena de menu inicial
        keyboard.shift().onPressDo({match.cancel() self.setMenuScene()})
    }
}

object selectorBg {
    const property position = game.at(0, 0)
    const property image = "bg/placeholder_selector.png"
}
