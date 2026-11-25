# Helbreath para Ubuntu 26.04 LTS · Modo jugador

## Jugar por primera vez

Extrae el archivo y abre una terminal en la carpeta `helbreath-ciudades`.

```bash
./helbreath jugar
```

La primera ejecución descarga y comprueba por SHA-256 los 791 archivos de mapas, sonidos y gráficos. Necesita Internet y unos 311 MiB para los recursos instalados. Si ya tienes la edición anterior, puedes copiar su carpeta `recursos/` completa a `helbreath-ciudades/` antes de iniciar.

Abre **http://127.0.0.1:1337/** en Firefox o Chromium con WebGL habilitado. Escribe un nombre en **Character name**, conserva **Host** y **Port** y pulsa **Connect**. Si el personaje es nuevo, reparte los 27 puntos entre los cinco atributos y pulsa **Crear personaje y entrar**. Puedes corregir el reparto hasta confirmarlo. El servidor se inicia con el acceso administrativo desactivado. Los comandos `./helbreath jugar` y `./helbreath solo` ejecutan este mismo modo local con guardado en el servidor. Para cerrar la partida usa **Controls → Log Out**, y para detener el servidor pulsa **Ctrl+C** en su terminal. Si ya jugabas desde otra computadora, inicia con `ESCUCHAR_EN=0.0.0.0 ./helbreath jugar` y entra por la dirección del servidor que usabas. Puedes elegir otro puerto con `PUERTO=8181 ./helbreath jugar`.

## Tu personaje

Empiezas en Aresden, en nivel 1, con 0 XP, la bolsa vacía y las casillas de equipo vacías. El daño físico base es 1 y aumenta con el atributo correspondiente. Mantén el botón izquierdo pulsado sobre el terreno para caminar. En **Controls → Player**, **Attack mode** activa la postura de combate. La vida (**HP**) y el maná aparecen en la esquina inferior derecha durante la partida.

Las reglas de progresión de esta edición son las siguientes.

- Cada golpe físico que inflige daño a un monstruo concede 1 XP y 1 punto de práctica en combate sin armas, armas cuerpo a cuerpo o arquería, según el arma equipada. Cada hechizo resuelto concede 1 XP y 1 punto de magia. Las cuatro habilidades empiezan en cero y llegan a 100.
- Un hechizo cuesta 10 de maná. El personaje recupera 1 por segundo mientras está vivo y conectado, hasta su máximo.
- Llegas al nivel 2 con 10 XP acumulados, al 3 con 30 y al 4 con 60. Cada nivel concede 3 puntos de atributo, hasta el nivel 100.
- En **Controls → Player**, pulsa **+1** junto al atributo que quieras subir. Los puntos ganados por nivel se pueden guardar para después. La asignación es permanente para ese personaje.

| Atributo | Efecto por punto |
|---|---|
| Fuerza | +1 al daño físico cuerpo a cuerpo |
| Vitalidad | +10 a la vida actual y máxima |
| Destreza | +1 al daño físico con arco |
| Inteligencia | +5 al maná actual y máximo |
| Poder mágico | +1 al daño directo de hechizos |

La identidad local se conserva en el perfil del navegador. Vuelve desde el mismo perfil y la misma dirección. El servidor guarda el progreso y los atributos en `multiplayer/server/Chars/`. Los archivos de jugador llevan el prefijo `jugador-`. Para continuar una partida anterior, detén ambos servidores y copia la carpeta `multiplayer/server/Chars/` de la instalación anterior dentro de `multiplayer/server/` de la nueva antes de jugar. Si también copias `recursos/` a la raíz de la nueva instalación, podrás reutilizar la descarga. Abre el juego desde la misma dirección y perfil de navegador. Los personajes anteriores reciben los 27 puntos adicionales para repartir en **Controls → Player**. Conservan la experiencia, las habilidades y los atributos que ya tenían.

## Requisitos del equipo

Pasa el cursor sobre un objeto de la bolsa. Verás tu valor actual junto al mínimo necesario. Para equipar la pieza debes cumplir el nivel y todos sus atributos mínimos. Puedes recogerla y llevarla en la bolsa mientras progresas. Si un personaje anterior llevaba una pieza que ya no puede usar, la encontrará en la bolsa. Las reglas son iguales para jugador y administrador.

| Pieza | Nivel mínimo | Atributos mínimos |
|---|---:|---|
| Camisa (Shirt) | 1 | Destreza 1 |
| Espada corta (Short Sword) | 1 | Fuerza 5 |
| Arco corto (Short Bow) | 1 | Destreza 5 |
| Varita básica (Magic Wand 1) | 1 | Inteligencia 4 y Poder mágico 3 |
| Armadura de placas (Plate Mail) | 12 | Fuerza 22 y Vitalidad 10 |
| Martillo bárbaro (Barbarian Battle Hammer) | 20 | Fuerza 35 |

Para cambiar los requisitos de esta edición, edita `requirements` en `multiplayer/server/Config/Items.json` y reinicia el servidor. Cada pieza indica `level` y los atributos que requiere entre `strength`, `vitality`, `dexterity`, `intelligence` y `magicPower`. El cliente recibe estos valores del servidor.

## Viajar desde la zona inicial

Empiezas en Aresden. Para entrenar cerca del inicio, camina a **(149, 154)** y entra en la **Zona de viajeros**. Allí encontrarás Slimes y hormigas. Para regresar a Aresden usa **(59, 96)**. La salida **(68, 96)** te lleva a Elvine. Al llegar a la otra ciudad puedes volver por el mismo recorrido.

En las ciudades, **Controls → Comercios y rutas** muestra tu posición y las entradas. En los mapas exteriores y cuarteles abre **Controls → Rutas del mapa**. En los mapas que tienen minimapa, los puntos verdes señalan las rutas y los amarillos señalan comercios, bancos y torre de magia.

| Recorrido | Primera salida desde Aresden | Siguiente tramo |
|---|---|---|
| Aresden → Zona de viajeros → Elvine | 149, 154 | En la Zona de viajeros, sal por 68, 96 |
| Aresden → Middleland → Elvine | 27, 20 | Cruza Middleland y sal por 99, 20 |
| Aresden → Granja de Aresden → Promiseland → Granja de Elvine → Elvine | 279, 203 | Sigue las salidas verdes hacia cada mapa |
| Aresden → Coto o mazmorra | Coto 26, 279 · Mazmorra 78, 210 | El coto y la mazmorra también están conectados |

Cada ciudad tiene cuatro salas de cuartel comunicadas entre sí. En Aresden entra por **(252, 157)** y en Elvine por **(72, 96)**. Las granjas, los cuarteles y los cotos tienen monstruos para practicar y conseguir botín. En Promiseland la parte occidental de la salida sur lleva directamente a Aresden y la oriental a la Granja de Aresden.

## Tiendas, torre de magia y banco

En **Controls → Comercios y rutas** puedes consultar tu posición y las coordenadas de cada puerta. En el minimapa, los puntos amarillos indican las entradas y el punto azul indica tu posición. Camina sobre la puerta. Dentro aparece el mostrador. Puedes cerrarlo para explorar la habitación y volver a abrirlo pulsando sobre el encargado o desde **Controls**. Para salir, camina sobre la puerta interior.

| Lugar | Puerta de Aresden (X, Y) | Puerta de Elvine (X, Y) |
|---|---|---|
| Tienda general | 126, 166 | 225, 151 |
| Herrería | 167, 195 | 239, 107 |
| Torre de magia | 55, 118 | 180, 77 |
| Banco principal | 101, 183 | 197, 127 |
| Banco auxiliar | 217, 132 | 87, 174 |

Los monstruos que derrotas con armas, a puño limpio o con hechizos dejan **Gold** en el suelo y pueden dejar una poción o equipo. Camina hasta la casilla del botín y haz clic izquierdo sobre tu propia casilla para recoger el objeto de arriba. Repite el clic para recoger lo que quede debajo. En multijugador, los objetos en el suelo son visibles y recogibles por otros jugadores. La tienda vende ropa, pociones y equipo básico. La herrería vende armas, escudos y armaduras. Puedes comprar una pieza antes de cumplir sus requisitos de equipo.

| Monstruos | Oro por muerte | Posibilidad de un objeto adicional |
|---|---:|---:|
| Iniciales, como Slime, Ant, Snake y Bunny | 1–3 | 30 % |
| Comunes, como Orc y Skeleton | 3–7 | 45 % |
| Mayores, como Dragon, Demon y Lich | 8–18 | 70 % |

Por ejemplo, un Slime puede dejar una poción roja, una azul, una daga o un escudo de cuero. El oro y los objetos recogidos entran en la bolsa y pueden depositarse en el banco. Conserva el botín que quieras llevarte antes de detener el servidor.

El libro de esta edición empieza con **Energy Bolt**. Los personajes de versiones anteriores también empiezan con este hechizo al migrar, ya que aquellas versiones no registraban qué hechizos se habían aprendido. En la torre, **Fire Ball** cuesta 5 de oro. Los hechizos que compras aparecen en **Controls → Spells** y se guardan con el personaje.

El banco guarda los objetos y el oro de la bolsa. **Depositar** y **Retirar** mueven la pila completa. Las cuatro sucursales dan acceso al mismo depósito de tu personaje. Para guardar un objeto equipado, quítatelo primero.

## Habilitar un administrador opcionalmente

Detén el servidor anterior con **Ctrl+C** y ejecuta `./helbreath admin`. La dirección habitual sigue abriendo el acceso de jugador. La terminal muestra una segunda dirección local que termina en `/?admin` y una clave temporal para esa ejecución. Abre esa dirección en otra pestaña y escribe la clave en **Clave de administrador**. Allí aparecen los controles para crear objetos, invocar criaturas y cambiar los parámetros del mundo. Ambas sesiones pueden compartir el mapa. El personaje de administrador tiene su propio inventario y progreso. Reiniciar con `./helbreath jugar` vuelve a dejar el servidor exclusivamente en modo jugador.

## Compilar desde el código

Ejecuta estos comandos desde la raíz del paquete en Ubuntu 26.04.

```bash
./helbreath dependencias
./helbreath compilar
./helbreath jugar
```

El primer comando instala Node.js, npm, el SDK de .NET 10, el compilador de Protocol Buffers, Python 3 y los certificados desde APT. Requiere permisos de administrador. Los otros comandos se ejecutan como tu usuario. Descargar las dependencias de npm y NuGet requiere Internet. El servidor y los clientes se pueden compilar antes de descargar los recursos.

El script usa `npm ci` y los archivos de bloqueo de cada cliente, regenera los mensajes TypeScript desde `multiplayer/proto/network.proto` con el compilador de Ubuntu y publica el servidor con su entorno de ejecución incluido. Los resultados quedan en `multiplayer/mp-client/dist/`, `sp-client/dist/` y `bin/linux-x64/`. En una máquina ARM64 el script selecciona `bin/linux-arm64/`. El binario distribuido y las pruebas de esta entrega corresponden a x86-64.

## Usar una copia local de los recursos

Si ya tienes una copia completa del repositorio de origen en la revisión indicada, puedes importar sus recursos antes de jugar.

```bash
./helbreath recursos /ruta/a/helbreath-base-game
./helbreath jugar
```

También puedes trasladar la carpeta `recursos/` que genere el lanzador junto con el paquete a otra computadora de tu uso para ejecutar el juego sin conexión. Conserva la carpeta completa con su archivo `.revision`.

## Procedencia y licencia

La base es la recreación comunitaria [ErkoKnoll/helbreath-base-game](https://github.com/ErkoKnoll/helbreath-base-game/tree/734f95cf506d666f3a39dbce5bb292f43d162c47), revisión `734f95cf506d666f3a39dbce5bb292f43d162c47`. Ofrece movimiento, combate, mapas, inventario y chat. El autor la describe como una base jugable en desarrollo. El cliente clásico de Windows utiliza otro protocolo.

El texto de la licencia MIT del código y la excepción para los recursos originales están en **LICENSE**. Los mapas, gráficos y sonidos proceden del repositorio de origen y se descargan por separado. **licencias/** reúne los avisos de las dependencias redistribuidas. **README-upstream.md** conserva la documentación del proyecto original.
