El Snake es un videojuego creado para los celulares Nokia en 1976. Desde entonces se realizaron incontables versiones del mismo. Hoy vamos a realizar una más para aprender de Wollok Game.

------------

Cada vez que aparezca un ➡️, es un paso que tienen que hacer.

-----------

Lo primero que tenemos que saber para hacer un juego en Wollok Game, es:
- Para ejecutar un programa de wollok, hay que crear un archivo con una nueva extensión: `.wpgm` (por wollok program) y dentro de ese archivo escribir un programa, que se define así:

    ```wollok
    program miJuego {
        console.println("¡Hola Mundo!")
    }
    ```

    Cada línea dentro del programa se evalua en orden una después de la otra.

- Wollok Game nos da algunos objetos útiles que debemos usar para configurar el juego:
    - `game` es el principal objeto de wollok game con el que vamos a interactuar, sabe contestar cosas como:
        - `.cellSize(pixeles)`, que configura el tamaño de una celda.
        - `.width(cantidad)` y `.height(cantidad)`, que configuran la cantidad horizontal y vertical de celdas respectivamente.
        - `.ground(rutaAUnaImagen)`, que configura la imagen de cada celda.
        - `.start()`, que comienza el juego (debe mandarse después de los anteriores).
        - `.addVisual(visual)`, que agrega un objeto "visual" al juego.
        - ...etc, pueden encontrar más acá: https://www.wollok.org/documentation/wollok_game/
    - `keyboard` sirve para obtener objetos que representan a las teclas del teclado, por ej:
        - `.enter()`, `.a()`, `.b()`, `.up()`, `.right()`, etc.
        - Esos objetos saben contestar mensajes para configurar que sucede cuando se presionan o sueltan esas teclas.


------------

### Juego vacío

- ➡️ Crear un archivo con extensión `.wpgm`.
- ➡️ Importar todos los contenidos de la librería `wollok.game`:
    ```wollok
    import wollok.game.*
    ```
- ➡️ Definir un programa en el que se le mande el mensaje `start()` al objeto `game`.
- ➡️ Para probar que funciona, hacer click en `Run program`
    - En la terminal va a aparecer un texto diciendo que el juego está corriendo en una url, abrir esa url.

------------

### Definiendo el nivel

- ➡️ Configurar el nivel para que sea de 7 celdas de ancho por 11 de alto.
- ➡️ Definir que como imagen de celda (`ground`) use `celda.png` (el archivo está dentro de la carpeta `assets`).
- ➡️ Para probar si funcionó, correr de nuevo `Run program` y recargar o reabrir la página.

------------

### Agregar un personaje

Para agregar un objeto al juego, se le manda el mensaje `addVisual(visual)` a `game`.

Sin embargo, no cualquier objeto puede ser un visual: para poder mostrarlo en pantalla, `game` va a mandarle continuamente a nuestros objetos los siguientes mensajes:
- `.position()`: debe devolver un objeto que sepa contestar `.x()` e `.y()`. Las instancias de la clase Position nos sirven para esto.
- `.image()`: debe devolver un string que representa la ruta a una imagen desde la carpeta `assets`.
- `.text()`: debe devolver un string que representa un texto a mostrar por pantalla.

El objeto que agreguemos en pantalla va a tener que minimamente poder contestar `.position()`.
Si además sabe contestar `.image()` se va a dibujar una imagen en esa posición.
Y si además sabe contestar `.text()` se va a dibujar también un texto en esa posición.

- ➡️ Crear un objeto que represente a la viborita. Ese objeto debe saber responder a `.position()`, devolviendo el centro de la pantalla, y a `.image()`, devolviendo `viborita_cabeza_arriba.png`.
- ➡️ Agregar ese objeto como visual al juego.
- ➡️ Corregir el `cellSize` de `game` para que la cada celda sea del tamaño de la imagen que dibujamos.

-----------

### Moviendo al personaje

La viborita debería moverse sola cada cierto tiempo.

Para este primer paso, hagamos que se mueva solo para arriba.

Wollok Game nos provee una manera de hacer que una acción se ejecute continuamente cada cierto tiempo, así que, por ahora preocupémosnos en como hacer que la viborita se mueva **una vez**.

Primero, pensemos lo siguiente:

    - ¿Qué mensaje habría que mandarle a qué objeto para que la viborita se mueva una vez?
    - ¿Si ya mandé una vez ese mensaje, cuál debería ser ahora la posición de la vibora?
    - ¿Cómo puedo saber si esto que hice funciona?

Una vez contestadas esas preguntas,
- ➡️ implementar el código necesario para que la viborita se pueda mover.

Ahora, lo que queremos es que esa acción (moverse) ocurra cada cierta cantidad de tiempo. El objeto `game` sabe contestar el mensaje `.onTick(milisegundos, nombreDeAccion, accion)` que configura una acción que sucede cada una cantidad de milisegundos.

Una `acción` es cualquier objeto que entienda el mensaje `.apply()`. Lo que va a hacer `game` es cada esa cantidad de milisegundos que hayamos pasado, enviar el mensaje `.apply()` a la acción que le dimos.

- ➡️ Crear un objeto que representa la acción que queremos ejecutar (hacer que la viborita se mueva).
- ➡️ Mandarle el mensaje `.onTick(milisegundos, nombreDeAccion, accion)` a `game` con unos milisegundos que elijamos y la acción que hará que la viborita se mueva.
- ➡️ Probar si esto funciona.

-----------

### Cambiando la dirección

La viborita no debería ir siempre hacia arriba. Queremos poder hacer que se mueva en una dirección que nosotros indiquemos.

Para esto, podemos mandarle un mensaje a un objeto que representa una tecla, por ejemplo:

`keyboard.right().onPressDo(accion)`

Donde accion debería ser un objeto que nosotros creemos y que (al igual que antes) va a recibir el mensaje `.apply()`, solo que esta vez recibirá ese mensaje cuando apretemos la tecla flecha derecha del teclado.

En este juego, lo que querríamos que ocurra al apretar la tecla derecha **NO** es que la viborita se mueva una posición a la derecha, si no que **mire** hacia la derecha, y por lo tanto la próxima vez que se mueva se moverá en esa dirección.

Esto probablemente signifique cambiar cómo funciona la viborita, que ahora debería soportar lo siguiente (antes de tocar cualquier cosa de `game`):
- ➡️ Debemos poder decirle a la viborita que cambié su dirección.
- ➡️ El "moverse" de la viborita ya no es hacia arriba, si no que debe ser hacia la dirección en la que está mirando.
- ➡️ Discutir: ¿Podemos de alguna forma probar si estos cambios ya funcionan?
- ➡️ Agregar acciones que hagan que la viborita cambie de dirección hacia la derecha, hacia la izquierda, hacia arriba y hacia abajo.
- ➡️ Configurar wollok game para que al presionar cada tecla (up, left, right, down) se ejecute la acción correcta.

-----------

### Bloques

Ya agregamos varias acciones al juego y las usamos como parte de la configuración del juego con los mensajes `.onTick(milisegundos, nombreDeAccion, accion)` de `game` y `.onPressDo(accion)` de las teclas.

Esto funciona perfecto, pero, esta idea de tener un objeto que represente cierta acción o lógica es tan común que muchos lenguajes tienen una forma especial de crear objetos para usar de esta manera.

En Wollok se los llama bloques, y son objetos que se pueden construir escribiendo entre llaves la lógica que querramos que tengan. Por ejemplo, si queremos crear un bloque que escriba algo por la terminal (mandandole el mensaje `println` al objeto `console`) podríamos definir:
```
{ console.println("HOLA") }
```

¡Eso es un objeto!, probemoslo:
- ➡️ Abrir un REPL (se puede ir a cualquier archivo `.wlk`) y clickear en `Run in Repl`.
- ➡️ En la terminal que se abrió, escribir `console.println("HOLA")`, esto le manda el mensaje `println` a `console`. Ver que se imprime HOLA por pantalla.
- ➡️ En la terminal que se abrió, escribir `var miBloque = { console.println("HOLA") }`
- ➡️ Discutir: ¿Por qué no se imprimió HOLA por pantalla?
- ➡️ Discutir: ¿Qué mensaje habría que mandarle a miBloque para que haga su acción? ¿Se puede ejecutar múltiples veces?
- ➡️ Probar lo siguiente en la terminal, `5.times { n => console.println(n) }`
- ➡️ Discutir: ¿Qué hace `times`? ¿Qué objetos lo entienden? ¿Qué diferencia hay entre este bloque y `miBloque`?
- ➡️ Reemplazar las acciones que habíamos creado antes para usar en `.onTick(milisegundos, nombreDeAccion, accion)` y en `.onPressDo(accion)` por bloques.

-----------

### La imagen

La viborita queda mirando para arriba por más de que se mueve en distintas direcciones.

- ➡️ Hacer que la imagen que se dibuja de la viborita refleje en que dirección está mirando. Hay 4 imagenes para las diferentes direcciones en la carpeta `assets`:
    - ![arriba](assets/viborita_cabeza_arriba.png) `viborita_cabeza_arriba.png`
    - ![derecha](assets/viborita_cabeza_derecha.png) `viborita_cabeza_derecha.png`
    - ![izquierda](assets/viborita_cabeza_izquierda.png) `viborita_cabeza_izquierda.png`
    - ![abajo](assets/viborita_cabeza_abajo.png) `viborita_cabeza_abajo.png`
- ➡️ Contestar: ¿Cómo probamos si estos cambios están funcionando?...

-----------

### Tests

Además de probar a mano cada cosa que hacemos, podemos igual que como veníamos haciendo en la materia, hacer pruebas automatizadas que chequeen si nuestro código hace lo esperado.

En Wollok, los tests deben ir en un archivo con extensión `.wtest`.

- ➡️ Crear un archivo para los tests.

Un test en wollok se escribe de la siguiente manera:
```
test "nombre del test" {

}
```

Y podemos agrupar varios tests relacionados de la siguiente manera:
```
describe "viborita" {
    test "al moverse si esta mirando para arriba, aumenta su posicion en 1 en y" {
        ...
    }

    test "si esta mirando para arriba, su imagen es viborita_cabeza_arriba.png" {
        ...
    }
}
```

Dentro de UN test, suelen haber 3 pasos lógicos:
- Arrange (organizar, configurar)
    - Asegurarse que el/los objetos sobre los que queremos testear estén en el estado correcto.
- Act (actuar)
    - Realizar la acción que queremos probar.
- Assert (validar)
    - Verificar que el resultado sea el esperado.

Por ejemplo, en el caso de que si la viborita mira hacia arriba al moverse debería dar un paso en Y, esto sería algo así como:
- Arrange
    - Hacer que la viborita mire hacia arriba.
- Act
    - Hacer que la viborita se mueva.
- Assert
    - Verificar si la posición de la viborita es igual a la que tenía al principio pero con +1 en y (para hacer esto puede ser útil en el primer paso especificar una ubicación a la viborita).

- ➡️ Escribir un test para el movimiento de la viborita en cada dirección (4 en total).
- ➡️ Escribir un test para la imagen de la viborita en cada dirección (4 en total).

------------

Ahora que ya tenemos tests, ¿se puede emprolijar un poco el código que ya teníamos de la viborita?

- ➡️ Si sí, refactorizar* el código.
- ➡️ Verificar que el refactor fue correcto (es decir, no cambio el comportamiento) corriendo de nuevo los tests.

*refactorizar: mejorar un código sin cambiar su funcionamiento.

------------

### Agregando otro objeto

- ➡️ Crear un segundo objeto, una manzana
    - su imagen debe ser "manzana.png"
    - su posición debe ser parametrizable.
- ➡️ Al comenzar el juego, agregar la manzana en una posición aleatoria dentro de la pantalla.
    - Pista: se puede usar `minimo.randomUpTo(maximo).round()` para obtener un número entero al azar (hay que decidir cuál sería mínimo y cuál máximo).
    - Otra pista: hay 2 maneras de crear posiciones:
        - `new Position(x=..., y=...)`
        - `game.at(..., ...)`

------------

### Colisiones

`game` entiende otro mensaje muy útil que nos permite ejecutar una acción cuando un objeto detecta que otro entró en su celda: `.onCollideDo(objeto, accion)`.

La manera en la que funciona es: cuando `objeto` choca con *algun otro*, se le manda el mensaje `.apply()` a acción con ese otro objeto por parámetro.

Por ejemplo:
```
game.onCollideDo(fantasma, { otro => otro.asustarse() })
```
En ese caso, si algún objeto colisionase con `fantasma`, ese otro objeto recibiría el mensaje `asustarse()`.

- ➡️ Usar `.onCollideDo` para que si la viborita choca con la manzana, la manzana reaparezca en otra posición distinta (también al azar).

------------

### Perder

Vamos a agregar paredes al juego, y si la viborita se choca con ellas terminamos el juego (queda como ejercicio para intentar en casa hacer que el juego vuelva a su estado inicial en vez de terminar).

- ➡️ Crear una clase que nos permita crear paredes.
    - Una pared debería tener como imagen "pared.png" y su posición debería ser parametrizable.
- ➡️ Agregar paredes en los bordes de la grilla.
    - Pista: se puede usar `.times(accion)` para ejecutar muchas veces la acción de agregar una pared y con eso construir una línea de paredes.
- ➡️ Usar `.onCollideDo` para que si la viborita choca con una pared, se le mande el mensaje `stop()` a `game`.
- ➡️ ¡También habría que modificar el código que calcula donde ubicar las manzanas para que no aparezcan sobre una pared!

-----------

### Viborita que crece

Cada vez que la viborita come una manzana, lo que ocurre en el juego original es que se hace un poco más larga.

Además, si choca con su propia cola, se pierde el juego.

Una forma en la que podríamos representar esto, es que cada vez que la viborita crece, se agrega un nuevo visual al juego que representa un segmento de la cola de la viborita.

Y ese segmento de viborita tiene que:
- aparecer *después* de que la viborita comió una manzana, podemos hacer que eso ocurra cuando se mueve.
- *seguir* el movimiento de la cabeza de la viborita.

- ➡️ Definir una clase para los segmentos de viborita.
    - Cada segmento debe tener como imagen ![alt text](assets/viborita_segmento.png) `viborita_segmento.png`.
    - Su posición debe ser parametrizable.
- ➡️ Hacer que si la viborita acaba de comer una manzana, *al moverse* agregue un nuevo visual al juego en la posición que dejó atrás.
- ➡️ Hacer que cada vez que la viborita se mueve, la cola de la viborita se mueva siguiendo a la cabeza de la viborita.
- ➡️ Hacer que cada vez que si la viborita choca con su propia cola, se termine el juego.

