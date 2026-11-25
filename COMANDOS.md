# Comandos y controles de Helbreath para Ubuntu

Referencia de los comandos del juego, los controles de jugador y administrador, las herramientas de desarrollo y el script de subida a GitHub. Corresponde a la edición de `rodolfo99/helbreath-ubuntu` con servidor C#, cliente web y ejecutable para Ubuntu 26.04 x86-64.

Salvo que una sección indique otra carpeta, ejecuta los comandos desde la raíz del proyecto: donde están `helbreath`, `multiplayer`, `sp-client` y `subir_helbreath_github.sh`. Sustituye las rutas de ejemplo por las tuyas y conserva las comillas cuando haya espacios. Los comandos de la terminal se escriben en Ubuntu; las acciones de **Controls** se realizan dentro del navegador.

## Inicio rápido

Para descargar el proyecto por primera vez e iniciar una partida normal:

```bash
git clone https://github.com/rodolfo99/helbreath-ubuntu.git
cd helbreath-ubuntu
./helbreath jugar
```

Abre `http://127.0.0.1:1337/`, escribe el nombre del personaje y pulsa **Connect**. El primer inicio descarga los recursos si todavía no están instalados. El ejecutable distribuido incluye el entorno de ejecución de .NET; para usar ese ejecutable no hace falta compilar primero. La instalación de recursos sí necesita Python 3 y, cuando se descargan, conexión a Internet.

Para terminar la sesión utiliza **Controls → Log Out**. Para detener el servidor pulsa **Ctrl+C** en su terminal. Para volver a iniciarlo ejecuta de nuevo `./helbreath jugar`.

## Comandos del lanzador

| Comando | Función |
|---|---|
| `./helbreath` | Inicia el juego como jugador normal; equivale a `jugar`. |
| `./helbreath jugar` | Inicia el servidor y sirve el cliente web. Mantiene desactivado el acceso administrativo. |
| `./helbreath solo` | Alias de `jugar` en esta edición: utiliza el mismo servidor, cliente multijugador y guardado. |
| `./helbreath admin` | Inicia el servidor con acceso administrativo mediante una clave temporal. También permite conexiones normales. |
| `./helbreath dependencias` | Instala las herramientas necesarias para compilar mediante APT. |
| `./helbreath compilar` | Instala las dependencias de los clientes, compila ambos y publica el servidor para la arquitectura del equipo. |
| `./helbreath recursos` | Instala los recursos desde la revisión original fijada por el proyecto. |
| `./helbreath recursos "/ruta/helbreath-base-game"` | Instala los recursos desde una copia local compatible del repositorio original. |
| `./helbreath ayuda` | Muestra la ayuda breve del lanzador. |
| `./helbreath --help` | Alias de `ayuda`. |
| `./helbreath -h` | Alias de `ayuda`. |
| `./helbreath recursos --help` | Muestra la ayuda del instalador de recursos. También acepta `-h`. |

`solo` no abre el cliente independiente de `sp-client`. Tampoco existen subcomandos propios `stop`, `restart`, `status`, `reset`, `instalar` o `crear-usuario`. Para reiniciar, detén el proceso con **Ctrl+C** y vuelve a ejecutar el modo deseado.

Usa las formas de ayuda de la tabla. Añadir `--help` a `compilar`, `dependencias` o `jugar` no muestra una ayuda específica: esos subcomandos pueden comenzar a compilar, instalar o arrancar el juego.

Fuente: [lanzador helbreath](helbreath).

## Puerto y conexiones desde otros equipos

El lanzador admite estas dos variables:

| Variable | Valor predeterminado | Significado |
|---|---|---|
| `PUERTO` | `1337` | Puerto HTTP y WebSocket. Acepta un entero de 1 a 65535, sin ceros iniciales. |
| `ESCUCHAR_EN` | `127.0.0.1` | Dirección de escucha. `0.0.0.0` permite escuchar en todas las interfaces IPv4. |

Cambiar el puerto:

```bash
PUERTO=8181 ./helbreath jugar
```

Después abre `http://127.0.0.1:8181/`.

Permitir conexiones desde la red:

```bash
ESCUCHAR_EN=0.0.0.0 ./helbreath jugar
```

Combinar dirección y puerto:

```bash
ESCUCHAR_EN=0.0.0.0 PUERTO=8181 ./helbreath jugar
```

En la otra computadora abre `http://IP_DEL_SERVIDOR:8181/`, sustituyendo `IP_DEL_SERVIDOR` por la dirección alcanzable de tu equipo. `0.0.0.0` indica dónde escucha el proceso; no es la dirección concreta que debe usar otro equipo. El acceso desde Internet también depende del cortafuegos, el router y la conectividad pública del servidor.

Estas variables también funcionan con `admin` y `solo`. Una asignación al principio de la orden se aplica a esa ejecución. Para volver a los valores habituales, ejecuta `./helbreath jugar` sin ellas, siempre que no las hayas exportado previamente en la terminal. Si las exportaste, puedes retirarlas con:

```bash
unset PUERTO ESCUCHAR_EN
```

Comandos de consulta útiles:

```bash
ip -br address
ss -ltnp 'sport = :1337'
```

El primero muestra las direcciones del equipo; el segundo permite comprobar si existe un proceso escuchando en el puerto 1337. Cambia el número si elegiste otro puerto.

Fuente: [helbreath](helbreath).

## Entrar y salir del modo administrador

1. Detén el servidor que tengas abierto con **Ctrl+C**.
2. Inicia el modo administrativo:

```bash
./helbreath admin
```

3. La terminal mostrará la dirección administrativa y una **clave temporal de administrador**.
4. Abre `http://127.0.0.1:1337/?admin`, escribe esa clave en **Clave de administrador** y conecta.

Para usar otro puerto:

```bash
PUERTO=8181 ./helbreath admin
```

En ese caso la dirección es `http://127.0.0.1:8181/?admin`.

La clave cambia cada vez que se reinicia el servidor. La dirección ordinaria, sin `?admin`, permite entrar como jugador normal. El personaje administrativo y el personaje normal del mismo navegador tienen inventario y progreso separados.

Para desactivar nuevamente la administración, detén el servidor y arráncalo así:

```bash
./helbreath jugar
```

El modo administrativo utiliza la dirección de escucha que hayas elegido: con `ESCUCHAR_EN=0.0.0.0` también es alcanzable por la red y sigue exigiendo su clave. El código no impone una restricción adicional que lo limite al equipo local.

No hay comandos administrativos `/gm`, `/item`, `/give` o `/teleport` en el chat de esta adaptación. La administración se realiza desde **Controls**. El servidor tampoco ofrece una consola interactiva de órdenes dentro de la terminal.

Fuentes: [autenticación y arranque del servidor](multiplayer/server/Server.cs), [formulario de conexión](multiplayer/mp-client/src/ui/dialogs/ConnectDialog.tsx) y [procesamiento del chat](multiplayer/server/World/Global/GlobalWorld.cs).

## Controles de jugador

### Ratón y teclado

| Control | Acción |
|---|---|
| Clic izquierdo sobre el terreno | Caminar hacia la casilla indicada. |
| Mantener pulsado el botón izquierdo | Continuar moviéndose siguiendo el cursor. |
| Clic izquierdo sobre un objetivo | Interactuar o atacar según el objetivo, el modo del personaje y la acción seleccionada. |
| Clic izquierdo sobre tu propia casilla | Recoger el objeto superior del suelo; repetir para recoger los siguientes. |
| Botón derecho | Cancelar el desplazamiento o la selección de lanzamiento; mantenerlo permite orientar al personaje. |
| Clic izquierdo después de **Spells → Cast** | Seleccionar el objetivo o la posición del hechizo cuando lo requiera. |
| Doble clic sobre un objeto de la bolsa | Equiparlo o consumirlo, según su tipo. |
| Doble clic sobre un objeto equipado | Devolverlo a la bolsa. |
| Botón derecho sobre un objeto de la bolsa | Abrir el menú **Equip**, **Consume** o **Drop**, según corresponda. |
| **Enter** dentro del campo de chat | Enviar el mensaje. |
| **Escape** con el menú contextual del inventario abierto | Cerrar ese menú. |
| **Ctrl+C** en la terminal del servidor | Detener el servidor. No se escribe en el chat. |

No hay desplazamiento WASD ni un conjunto de órdenes F1–F12 programado para este cliente. El chat envía texto general; no interpreta órdenes con `/`. El campo de entrada del cliente permite hasta 256 caracteres.

### Panel Controls

| Opción | Función disponible para un jugador normal |
|---|---|
| **Enter fullscreen / Exit fullscreen** | Entrar o salir de pantalla completa. |
| **Player** | Consultar progreso, repartir puntos de atributo y ajustar controles o apariencia permitidos. |
| **Inventory** | Gestionar bolsa y equipo. Los objetos siguen sujetos a requisitos de atributos y nivel. |
| **Spells** | Elegir entre los hechizos aprendidos y preparar su lanzamiento. |
| **Camera** | Ajustar la vista de la cámara. |
| **Minimap** | Abrir el minimapa cuando el mapa dispone de él. |
| **Sound** | Ajustar sonido y música del cliente. |
| **Chat** | Abrir el chat. |
| **Comercios y rutas / Rutas del mapa**, o el título del servicio actual | Consultar entradas y rutas o abrir el servicio correspondiente al lugar en que estás. |
| **Log Out** | Iniciar la salida de la partida. La configuración actual espera 5 segundos; durante la espera aparece **Cancel**. |
| **Resurrect**, en la ventana de muerte | Resucitar cuando el personaje está muerto. |

En **Player**, el jugador normal dispone de **Attack mode**, **Run mode**, selección de **Gender**, **Skin**, **Hair Style** y **Underwear Color**, además de los botones **+1** para gastar puntos de atributo disponibles. Al crear un personaje se distribuyen los 27 puntos iniciales. Los puntos ganados después se asignan desde este panel y el gasto se guarda con el personaje.

Los comercios y el banco se usan dentro de sus habitaciones, haciendo clic en el encargado o abriendo el servicio desde **Controls**. **Depositar** y **Retirar** mueven una pila completa entre bolsa y banco. Para guardar un objeto equipado, primero quítatelo. La compra de hechizos se realiza en la torre de magia; después aparecen en **Spells**.

En el inventario, **Equip** equipa, **Consume** consume una unidad del objeto y **Drop** deja el objeto en el suelo. También se pueden arrastrar objetos para ordenar la bolsa o equiparlos. Cambiar el género del personaje puede devolver a la bolsa ropa que deje de ser compatible. La tienda ofrece **Comprar**; esta interfaz no incluye una acción **Vender**. Las rutas del panel indican puertas y coordenadas a las que debes caminar, no teletransportes gratuitos.

### Cámara, sonido y minimapa

| Panel | Controles |
|---|---|
| **Camera** | Botones de dirección para mover la cámara, **Follow player**, **Camera shake**, **Post processing** con **None / FXAA**, **Game window size** de 100–200 %, **Camera Zoom** de 20–200 % en pasos de 10 y **Reset Zoom**. |
| **Sound** | Selector **Music**, **Play map music**, **Music volume** y **Sound volume**, ambos de 0–100. |
| **Minimap** | Posición y marcadores del mapa; se puede cambiar el tamaño arrastrando las esquinas. |

Fuentes: [ControlsDialog](multiplayer/mp-client/src/ui/dialogs/ControlsDialog.tsx), [PlayerDialog](multiplayer/mp-client/src/ui/dialogs/PlayerDialog.tsx), [GameWorld del cliente](multiplayer/mp-client/src/game/scenes/GameWorld.ts), [ChatDialog](multiplayer/mp-client/src/ui/dialogs/ChatDialog.tsx) y [guía de juego](LEEME.md).

## Controles de administrador

Estos paneles adicionales aparecen al conectar con una clave administrativa válida. Sus acciones afectan la sesión o el mundo compartido según se indica.

| Panel | Acciones |
|---|---|
| **Items** | Elegir un objeto, ajustar su apariencia y pulsar **Create item**. Incluye ajustes **Glow**, **Glare**, **Tint** e **Inventory Tint**. |
| **Monsters** | Elegir tipo, cantidad y parámetros; pulsar **Summon**. **Kill all** mata a todos los monstruos vivos del mapa actual. |
| **NPCs** | Elegir y crear NPC con **Summon**. **Kill all** elimina los NPC del mapa actual, incluidos los configurados para ese mapa. |
| **Effects** | Seleccionar un efecto, pulsar **Cast**, activar **Repeat** o eliminar los efectos visuales del cliente mediante **Kill all**. Este último no mata entidades del servidor. |
| **Maps** | Seleccionar un mapa y pulsar **Load map**; elegir **Weather** y ajustar opciones de representación o depuración. El cambio de clima se transmite a los jugadores de ese mapa. |
| **Server** | Seleccionar **Teleport to cell** o **Make server cell occupied** y después una casilla; ajustar simulación de retraso y fluctuación de red; cambiar **Movement animation grace period** y **Sync with server**. |
| **Performance** | Consultar indicadores de rendimiento del cliente y del servidor. |

**Make server cell occupied** marca una casilla como ocupada. El panel no ofrece un botón inverso para deshacer esa marca. Las acciones **Kill all** de monstruos y NPC tienen alcance sobre el mapa actual: no se limitan a lo creado por el administrador que pulsa el botón.

### Player en una sesión administrativa

Además de las opciones normales, el administrador dispone de:

| Ajuste | Intervalo o valores del panel |
|---|---|
| **Movement speed** | 100–500 ms. |
| **Cast speed** | 200–2000 ms. |
| **Attack speed** | 200–2000 ms. |
| **Attack range** | 1–20 casillas. |
| **Damage** | 1–1000. |
| **Stun duration** | 100–2000 ms. |
| **Attack type** | **No Interrupt**, **Interrupt**, **Stun** o **Knockback**. |
| **Allow dash attack** | Activado o desactivado. |

Los valores de tiempo representan duración: un número menor permite acciones más rápidas. Los requisitos de nivel y atributos para equipar objetos también se aplican al personaje administrador.

### Monsters, clima y simulación de red

El panel **Monsters** permite cantidades de 1–1000, HP y daño de 1–1000, ocho orientaciones y afinidad **Hostile**, **Neutral** o **Friendly**. Los controles de movimiento y ataque abarcan 200–2000 ms; el extremo de movimiento de 2000 ms representa un monstruo inmóvil. También incluye recuperación de 0–2000 ms, aturdimiento de 100–2000 ms y rangos de persecución o ataque de 1–20 casillas.

**Weather** ofrece **Dry**, lluvia **light / medium / heavy** y nieve **light / medium / heavy**. En **Server**, los ajustes **Incoming / Outgoing network delay**, **Incoming / Outgoing network fluctuation** y **Movement animation grace period** usan intervalos de 0–500 ms. Son herramientas para inspección y pruebas del comportamiento del cliente y del servidor.

Las casillas de visualización de **Maps** son **Render map tiles**, **Render static map objects**, **Display sprites information**, **Display non-movable cells**, **Display map teleport cells**, **Display server teleport cells**, **Display water cells**, **Display farmable cells**, **Display grid** y **Display large items**.

Para colocar un efecto, pulsa **Effects → Cast** y después haz clic en el mapa. Para teletransportarte, pulsa **Server → Teleport to cell** y elige una casilla libre; el servidor no teletransporta un personaje muerto ni acepta una casilla ocupada. **Performance** muestra **FPS**, **Ping**, **Ping variance**, **Players in map** y **Game world queue**.

Fuentes: [diálogos del cliente](multiplayer/mp-client/src/ui/dialogs), [configuración de controles](multiplayer/mp-client/src/Config.ts), [GameWorld del servidor](multiplayer/server/World/Game/GameWorld.cs) y [acciones permitidas](multiplayer/server/PlayerActions.cs).

### Diferencias del cliente independiente sp-client

`sp-client` conserva una interfaz local de pruebas: muestra **Items**, **Monsters**, **NPCs**, **Effects** y **Maps** sin autenticación administrativa de servidor. No tiene los paneles multijugador **Server**, **Performance** ni **Chat**. Tampoco lo selecciona el comando `./helbreath solo` de esta edición.

| Apartado | Diferencias respecto al cliente multijugador |
|---|---|
| **Player** | Añade **Transparency** de 0–100, **Ghost effect**, **Chilled effect** y **Berserked effect**. Sus escalas de **Movement speed** son 0–100 y las de **Cast speed / Attack speed** son 1–100; no son las escalas en milisegundos de MP. |
| **Attack type** | Ofrece **No Interrupt**, **Interrupt** e **Interrupt Knockback**. |
| **Monsters** | Añade transparencia y efectos de frío o berserk, **Follow distance** de 0–20 y **Attack distance** de 0–10. Cero desactiva esas distancias. |
| **Spells** | Incluye **Use cast animation**. |
| **Kill all** | Afecta a los objetos de ese cliente local. |
| Guardado | Utiliza `localStorage` del navegador; no es la partida guardada en `multiplayer/server/Chars/`. |

Fuentes: [diálogos de sp-client](sp-client/src/ui/dialogs) y [guardado local](sp-client/src/utils/GameStateManager.ts).

## Compilar y comprobar las herramientas

Para una compilación completa:

```bash
./helbreath dependencias
./helbreath compilar
./helbreath jugar
```

`dependencias` ejecuta APT con `sudo` e instala `nodejs`, `npm`, `dotnet-sdk-10.0`, `protobuf-compiler`, `python3` y `ca-certificates`. `compilar` y el juego se ejecutan como tu usuario habitual. Las descargas de npm y NuGet necesitan conectividad.

También se puede invocar directamente el compilador del proyecto:

```bash
./ubuntu/compilar
```

Los resultados son:

| Salida | Contenido |
|---|---|
| `multiplayer/mp-client/dist/` | Cliente web multijugador compilado. |
| `sp-client/dist/` | Cliente independiente compilado. |
| `bin/linux-x64/` | Servidor cuando el equipo es `x86_64`. |
| `bin/linux-arm64/` | Servidor cuando el equipo es `aarch64`. |

La distribución incluye el binario x86-64. El script contempla ARM64, pero eso no equivale a una validación de ejecución en esa arquitectura.

Para consultar versiones y arquitectura:

```bash
uname -m
python3 --version
node --version
npm --version
dotnet --info
protoc --version
git --version
gh --version
```

`git` y `gh` corresponden al flujo de GitHub; no son requisitos del motor para jugar. Para compilar solamente el servidor x86-64, la orden utilizada por el proyecto es:

```bash
dotnet publish multiplayer/server/Server.csproj \
  -c Release \
  -r linux-x64 \
  --self-contained true \
  -p:PublishSingleFile=true \
  -p:EnableCompressionInSingleFile=true \
  -p:DebugType=None \
  -o bin/linux-x64
```

Fuente: [ubuntu/compilar](ubuntu/compilar) y [Server.csproj](multiplayer/server/Server.csproj).

## Instalar y conservar los recursos

Estos comandos son equivalentes por pares:

```bash
./helbreath recursos
python3 ubuntu/recursos.py
```

```bash
./helbreath recursos "/ruta/helbreath-base-game"
python3 ubuntu/recursos.py "/ruta/helbreath-base-game"
```

Consulta de ayuda:

```bash
python3 ubuntu/recursos.py --help
```

Ejecuta solo una de las órdenes equivalentes; no hace falta repetir ambas. La copia local de origen debe contener la estructura original `sp-client/public/assets/` y `multiplayer/server/Config/maps/`. El argumento no es una carpeta `recursos/` ya reorganizada por este paquete.

El instalador utiliza la revisión `734f95cf506d666f3a39dbce5bb292f43d162c47` del proyecto original y un manifiesto de 791 archivos. Los coloca en `recursos/cliente/` y `recursos/mapas-servidor/`, y escribe `recursos/.revision`. Verifica sus SHA-256 durante la instalación.

Si `.revision` ya tiene el valor esperado, el comando termina sin volver a comprobar todos los archivos. Por eso no es una orden de auditoría o reparación completa. Si `recursos/` existe con una marca ausente o distinta, el instalador se detiene para conservarla. Con el servidor detenido, puedes apartarla y volver a instalar:

```bash
mv recursos "recursos-anteriores-$(date +%Y%m%d-%H%M%S)"
./helbreath recursos
```

Este ejemplo supone que la carpeta existe. La copia anterior se conserva y permite revisar qué faltaba. No hay opciones propias `--force`, `--reparar` o `--verificar` en este instalador.

Para reutilizar una instalación completa en otra carpeta del juego:

```bash
cp -a "/ruta/juego-anterior/recursos" "/ruta/juego-nuevo/"
```

Hazlo cuando la carpeta de destino todavía no tenga su propio `recursos/`, y conserva el archivo `.revision`.

Fuentes: [instalador](ubuntu/recursos.py) y [manifiesto](ubuntu/recursos-sha256.json).

## Guardar y trasladar partidas

Las partidas se guardan en `multiplayer/server/Chars/`. Antes de copiar esa carpeta, cierra las sesiones y detén el servidor para obtener una copia consistente.

Crear un respaldo sin comprimir, si `Chars/` ya existe:

```bash
cp -a multiplayer/server/Chars "$HOME/helbreath-partidas-$(date +%Y%m%d-%H%M%S)"
```

Trasladar las partidas a una instalación nueva que todavía no tenga `Chars/`:

```bash
cp -a "/ruta/juego-anterior/multiplayer/server/Chars" "/ruta/juego-nuevo/multiplayer/server/"
```

Si la instalación nueva ya tiene partidas, conserva primero su carpeta y decide cuáles quieres recuperar antes de reemplazarla. La identidad del personaje también depende del perfil del navegador y de la dirección usada para entrar; vuelve desde el mismo perfil y dirección para continuar con la misma identidad.

El script de subida excluye `Chars/`: publicar el código no respalda tus partidas. Tampoco hay un comando del lanzador para borrar personajes o reiniciar su progreso.

Fuente: [persistencia y uso del juego](LEEME.md).

## Script de subida a GitHub

### Requisitos y autenticación

El script necesita Bash, Git y Python 3.8 o posterior. GitHub CLI facilita la autenticación, pero puede omitirse si Git ya tiene credenciales válidas.

```bash
sudo apt update
sudo apt install -y git python3 gh
gh auth login --hostname github.com --git-protocol https --web
gh auth setup-git --hostname github.com
gh auth status --hostname github.com
```

Utiliza la cuenta que tenga permiso para escribir en el repositorio; en este proyecto, `rodolfo99`. El script no inicia sesión ni instala paquetes por sí mismo. Sus ejecuciones normales se hacen sin `sudo`.

Referencias: [inicio de sesión de GitHub CLI](https://cli.github.com/manual/gh_auth_login) y [configuración de credenciales Git](https://cli.github.com/manual/gh_auth_setup-git).

### Sintaxis y todas las opciones

```bash
bash ./subir_helbreath_github.sh [CARPETA] [OPCIONES]
```

| Argumento u opción | Función y valor predeterminado |
|---|---|
| `CARPETA` | Carpeta completa del juego. Si se omite, usa `.`: el directorio actual de la terminal. |
| `-h`, `--help` | Mostrar ayuda y terminar. |
| `--subir` | Crear el commit y publicarlo después de las comprobaciones. Si se omite, solo prepara. |
| `--rama NOMBRE` | Rama de destino. Sin esta opción crea una rama `subir-codigo-AAAAMMDD-HHMMSS-xxxxxx`, usando UTC y un sufijo aleatorio. |
| `--repo REPOSITORIO` | Destino. Predeterminado: `https://github.com/rodolfo99/helbreath-ubuntu.git`. Admite también un remoto SSH o un repositorio local compatible con Git. |
| `--destino CARPETA_NUEVA` | Carpeta para el clon y los informes. Debe no existir y estar fuera del origen. Por defecto crea `helbreath-subida-…` en tu carpeta personal. |
| `--mensaje TEXTO` | Mensaje del commit. Predeterminado: `Subir fuentes y ejecutables de Helbreath para Ubuntu sin comprimir`. |

No hay flags propios `--dry-run`, `--force`, `--continuar`, `--incluir-partidas`, `-y` o `-r`. Para preparar sin publicar, omite `--subir`.

### Ejemplos completos

Consultar la ayuda:

```bash
bash ./subir_helbreath_github.sh --help
```

Preparar una actualización de `main` sin crear commit ni publicar:

```bash
bash ./subir_helbreath_github.sh . --rama main
```

Publicar el contenido de la carpeta actual en `main`:

```bash
bash ./subir_helbreath_github.sh . --subir --rama main
```

Publicar en una rama independiente:

```bash
bash ./subir_helbreath_github.sh . --subir --rama subir-codigo-completo
```

Elegir un directorio de preparación y un mensaje:

```bash
bash ./subir_helbreath_github.sh . \
  --rama main \
  --destino "$HOME/helbreath-revision-01" \
  --mensaje "Actualizar cliente y servidor de Helbreath"
```

No crees previamente `helbreath-revision-01`. Ese ejemplo solo prepara; añade `--subir` si quieres publicar en esa ejecución.

Usar SSH cuando tu equipo ya tiene configurada esa autenticación:

```bash
bash ./subir_helbreath_github.sh . \
  --repo git@github.com:rodolfo99/helbreath-ubuntu.git \
  --subir --rama main
```

Usar el script descargado por separado e indicar la carpeta del juego:

```bash
bash "$HOME/Descargas/subir_helbreath_github.sh" \
  "/ruta/helbreath-ciudades" --subir --rama main
```

### Qué ocurre al prepararlo y publicarlo

El programa clona el remoto en otra carpeta, copia los archivos seleccionados y prepara el índice Git. El origen permanece intacto. **Sin `--subir` también crea archivos locales y accede al remoto para clonarlo**, pero no crea un commit ni publica.

Cada ejecución crea una copia nueva y vuelve a leer el origen. Repetir la orden con `--subir` no reutiliza las ediciones manuales hechas dentro del clon de una preparación anterior. Para que esas ediciones se incluyan al repetir, deben formar parte de la carpeta que indiques como origen.

Si la rama elegida existe remotamente, parte de ella. Si no existe, parte de la rama predeterminada del remoto. Si no hay cambios, termina sin commit y sin push, incluso con `--subir`; una rama nueva sin cambios tampoco se publica. El remoto debe tener al menos un commit inicial.

Una subida a otra rama no modifica `main`. El script no crea una pull request ni fusiona ramas. Al publicar utiliza un push normal y comprueba que el SHA de la rama remota coincida con el commit enviado. Solo entonces informa **SUBIDA VERIFICADA**.

Utiliza tu identidad Git configurada. Si no existe nombre o correo, configura únicamente en el clon nuevo el nombre y correo de GitHub de Rodolfo incluidos en el script.

### Qué incluye, qué excluye y cómo conserva el README

Incluye las fuentes, configuraciones funcionales, licencias, ejecutables y clientes `dist/`. También incluye `recursos/` si existe en el origen. No compila ni descarga recursos durante la subida; si faltan los ejecutables, permite subir las fuentes y avisa que será necesario compilar.

Conserva el `README.md` remoto. Si el README del origen es distinto, lo guarda como `README-del-paquete.md`. Si ambos README son distintos y el origen ya contiene ese nombre de respaldo, se detiene para resolver la colisión. Cuando ambos README son iguales, no crea otra copia. Si el remoto no tiene `README.md`, copia el del origen.

El tratamiento especial de `bin/*/Server.gz` publica el ejecutable real `Server`: utiliza el que exista o lo descomprime en la copia de trabajo. Si también existe `Server.sha256`, valida el checksum. No crea ZIP ni TAR del proyecto; no excluye de forma general todos los archivos comprimidos que pudieran formar parte del código.

Filtra estas rutas o nombres al importar:

| Grupo | Exclusiones |
|---|---|
| Metadatos de repositorios | `.git`, `.hg`, `.svn`, `.gitmodules`. Los archivos de repositorios anidados se importan como archivos normales. |
| Dependencias e intermedios | Directorios `node_modules`, `__pycache__`, `.venv`, `venv`, `obj`; `multiplayer/server/bin`. |
| Partidas | `multiplayer/server/Chars`. |
| Configuración privada | `.env`, `.env.*`, `.npmrc`, `.pypirc`, `.netrc`, `.git-credentials`; directorios `.ssh`, `.aws`, `.azure`, `.gnupg`. Se permiten `.env.example`, `.env.sample` y `.env.template`. |
| Registros y temporales | `*.log`, `*.pyc`, `*.pyo`, `*.tsbuildinfo`, `.recursos.lock`, nombres que empiezan por `.helbreath-parche-` o `.importar-`. |
| Servidor comprimido | `bin/<arquitectura>/Server.gz`, porque se importa `Server` sin comprimir. |

Añade excepciones a `.gitignore` para conservar el servidor, ambos clientes compilados y los recursos presentes. Si otra regla sigue ocultando un archivo seleccionado, detiene la operación y enumera los archivos que faltan en el índice.

No importa enlaces simbólicos ni archivos especiales. Se detiene ante archivos de más de 100 MiB y muestra un aviso para los de más de 50 MiB; no instala ni configura Git LFS automáticamente. Estos tamaños corresponden a los [límites documentados de GitHub](https://docs.github.com/en/repositories/working-with-files/managing-large-files/about-large-files-on-github).

La copia es acumulativa: no borra un archivo remoto solo porque falte en el origen. Sus exclusiones tampoco eliminan datos que ya se hubieran publicado ni reescriben el historial.

### Informes, revisión y recuperación

La ruta de trabajo se muestra en la terminal. Contiene:

| Archivo o carpeta | Contenido |
|---|---|
| `repositorio/` | Clon con los cambios preparados o el commit creado. |
| `cambios.txt` | Archivos añadidos o modificados según el índice. |
| `archivos-incluidos.txt` | Archivos seleccionados y comprobados. |
| `archivos-excluidos.txt` | Rutas omitidas y sus motivos. |
| `archivos-no-incluidos.txt` | Se crea cuando Git sigue ignorando archivos de la selección. |
| `resultado.json` | Origen, remoto, rama, commit base, cantidad y tamaño; después añade el commit creado y el resultado de la verificación remota. |

Un error temprano puede ocurrir antes de crear todos los informes. Para revisarlos, sustituye la ruta del ejemplo por la que imprimió tu ejecución:

```bash
git -C "/ruta/helbreath-subida-XXXX/repositorio" status --short
git -C "/ruta/helbreath-subida-XXXX/repositorio" diff --cached --stat
git -C "/ruta/helbreath-subida-XXXX/repositorio" diff --cached --name-status
git -C "/ruta/helbreath-subida-XXXX/repositorio" log -1 --oneline
cat "/ruta/helbreath-subida-XXXX/resultado.json"
```

Si falla la autenticación, corrígela con `gh auth login` y `gh auth setup-git`, y vuelve a ejecutar el script utilizando un destino nuevo. Si el push falla después de crear el commit, ese commit se conserva en el clon. Tras comprobar la rama y el commit, puedes reintentar solo su envío:

```bash
git -C "/ruta/helbreath-subida-XXXX/repositorio" push origin HEAD:refs/heads/main
```

Esa orden corresponde a una subida destinada a `main`; cambia el nombre si habías elegido otra rama. Si el remoto avanzó o tiene protecciones, revisa el rechazo antes de seguir. No hace falta crear otro commit para reintentar el mismo envío.

Si interrumpiste un push, o Git lo aceptó pero falló la comprobación posterior, consulta primero el remoto:

```bash
git ls-remote https://github.com/rodolfo99/helbreath-ubuntu.git refs/heads/main
```

Sustituye la URL y la rama de esa consulta si utilizaste otros valores en `--repo` o `--rama`.

`resultado.json` puede seguir indicando `publicado: false` si no se completó la verificación, aunque el push hubiera sido aceptado.

| Código de salida | Significado |
|---|---|
| `0` | Ayuda, preparación correcta, subida verificada o ausencia de cambios. |
| `1` | Error controlado. |
| `2` | Error de argumentos. |
| `130` | Interrupción mediante teclado. |

Fuente de esta sección: [subir_helbreath_github.sh](subir_helbreath_github.sh).

## Desarrollo de los clientes y herramientas

### Cliente multijugador

Necesitas Node.js, npm y `protoc`. Puedes instalar las herramientas desde la raíz con `./helbreath dependencias`. `npm ci` instala las dependencias JavaScript, pero no instala el ejecutable `protoc` que requieren los ganchos de desarrollo y compilación.

Ejecuta las órdenes de esta tabla dentro de `multiplayer/mp-client/`:

```bash
cd multiplayer/mp-client
npm ci
```

| Comando | Función |
|---|---|
| `npm run proto:generate` | Generar el código TypeScript del protocolo con `protoc`. |
| `npm run dev` | Regenerar el protocolo y arrancar Vite. |
| `npm run build` | Regenerar el protocolo y compilar a `dist/`. |
| `npm run dev-nolog` | Mismo comportamiento que `dev` en los scripts actuales. |
| `npm run build-nolog` | Mismo comportamiento que `build` en los scripts actuales. |
| `npm run predev` | Ejecutar explícitamente el gancho de generación del protocolo. |
| `npm run prebuild` | Igual; normalmente npm lo ejecuta antes de `build`. |
| `npm run predev-nolog` | Gancho de generación antes de `dev-nolog`. |
| `npm run prebuild-nolog` | Gancho de generación antes de `build-nolog`. |
| `npm run lint` | Comprobar tipos mediante `tsc --noEmit`. |
| `npm run lint:eslint` | Invocar ESLint. La entrega no incluye su configuración; necesita configurarla para ser utilizable. |
| `npm run compress-assets` | Ejecutar la herramienta opcional de assets con nivel 1. |
| `npm run compress-assets:fast` | Alias del anterior, nivel 1. |
| `npm run compress-assets:best` | Ejecutarla con nivel 9. |

Los ganchos `pre…` se ejecutan automáticamente al utilizar su comando principal; normalmente no necesitas ejecutarlos a mano. Los nombres `-nolog` no activan una configuración adicional que elimine los registros.

### Cliente independiente

Desde la raíz del proyecto, entra en `sp-client/` e instala sus dependencias:

```bash
cd sp-client
npm ci
```

| Comando | Función |
|---|---|
| `npm run dev` | Arrancar Vite para este cliente. |
| `npm run build` | Compilarlo a `dist/`. |
| `npm run dev-nolog` | Alias de `dev` en esta entrega. |
| `npm run build-nolog` | Alias de `build` en esta entrega. |
| `npm run compress-assets` | Compresión opcional de assets, nivel 1. |
| `npm run compress-assets:fast` | Alias de la anterior. |
| `npm run compress-assets:best` | Compresión opcional, nivel 9. |

`sp-client` no declara scripts `lint` ni `test`. El lanzador `./helbreath solo` no selecciona este cliente independiente.

### Condiciones de los servidores de desarrollo

Ambos Vite escuchan en `127.0.0.1:8080` y usan `strictPort: true`. No pueden ocupar simultáneamente ese puerto y no lo liberan cuando otro proceso lo está usando. Sus README heredados pueden describir un comportamiento anterior; las tablas de esta guía corresponden a los `package.json` actuales.

Vite tampoco instala ni sirve automáticamente los recursos desde `recursos/cliente`. Para desarrollar hay que preparar los assets bajo `public/assets` del cliente o configurar su servicio de recursos. `npm run dev` por sí solo no sustituye al arranque completo `./helbreath jugar`. En el cliente multijugador también debe estar disponible el servidor del juego.

Fuentes: [scripts MP](multiplayer/mp-client/package.json), [scripts SP](sp-client/package.json), [Vite MP](multiplayer/mp-client/vite/config.dev.mjs) y [Vite SP](sp-client/vite/config.dev.mjs).

### Herramientas declaradas en tools

Dentro de `tools/`, las órdenes declaradas son:

| Comando | Estado y función |
|---|---|
| `npm install` | Instala sus dependencias. Esta carpeta no incluye un `package-lock.json`; no usar `npm ci` como paso inicial aquí. |
| `npm run proto:generate` | Generación alternativa del protocolo con `grpc_tools_node_protoc`. |
| `npm run client-simulator` | Declarado, pero no utilizable con esta entrega: falta `client-simulator.ts` y requiere `pnpm`, que el instalador del juego no incluye. |

La documentación histórica de pruebas de carga no convierte el simulador en una herramienta disponible en este paquete.

### Referencia del compresor opcional de assets

Esta herramienta existe en el código original, pero no forma parte del flujo de subida sin comprimir. Requiere las dependencias de `tools/`, incluida `fflate`, incluso para mostrar ayuda. Desde la raíz:

```bash
node tools/compress-assets.js --help
node tools/compress-assets.js --client-dir=sp-client --dry-run
```

| Opción | Efecto |
|---|---|
| `--client-dir=DIR` | Selecciona el cliente. Por defecto usa el directorio actual si contiene `src/constants/Assets.ts`; en otro caso usa `sp-client`. |
| `--ratio=N` | Nivel de compresión de 0 a 9; predeterminado 1. |
| `--output=FILE` | Archivo de salida, relativo al cliente. Predeterminado `public/assets.zip`. Reemplaza la salida si ya existe. |
| `--dry-run` | Inspecciona los recursos sin escribir un ZIP. |
| `--help`, `-h` | Muestra ayuda. |

Las opciones con valor se escriben con `=`, como en la tabla. La herramienta busca archivos bajo `public/assets` del cliente, mientras el lanzador de Ubuntu los instala en `recursos/cliente`. Puede advertir que faltan archivos y continuar con los que encontró: generar una salida no acredita que contenga todos los recursos.

Fuentes: [tools/package.json](tools/package.json) y [compress-assets.js](tools/compress-assets.js).

## Variables internas y arranque directo del servidor

Esta sección es para trabajar con el ejecutable directamente. Para el uso habitual basta con `jugar`, `admin`, `PUERTO` y `ESCUCHAR_EN`.

| Variable interna | Comportamiento del servidor |
|---|---|
| `HELBREATH_URL` | URL de escucha. Sin ella utiliza `http://127.0.0.1:<puerto de Settings.json>`. |
| `HELBREATH_CLIENT` | Ruta absoluta al cliente compilado. Se combina con `HELBREATH_ASSETS` para habilitar el servicio web estático. |
| `HELBREATH_ASSETS` | Ruta absoluta de los recursos servidos como `/assets`. |
| `HELBREATH_MAPS` | Carpeta de mapas. Sin ella utiliza `Config/maps` respecto al directorio de trabajo. |
| `HELBREATH_ENABLE_ADMIN` | El valor exacto `1` habilita la clave administrativa temporal. |
| `HELBREATH_SOLO` | El valor exacto `1` inicia solamente el servicio web estático, sin preparar el mundo multijugador. |

El lanzador sobrescribe todas estas variables. Por ejemplo, `HELBREATH_ENABLE_ADMIN=1 ./helbreath jugar` no activa la administración, y `HELBREATH_SOLO=1 ./helbreath solo` no selecciona el cliente independiente.

Si necesitas iniciar manualmente el ejecutable x86-64 con los mismos directorios que usa el lanzador, después de instalar los recursos y compilar:

```bash
HELBREATH_PROYECTO="$PWD"
(
  cd "$HELBREATH_PROYECTO/multiplayer/server"
  HELBREATH_URL="http://127.0.0.1:1337" \
  HELBREATH_CLIENT="$HELBREATH_PROYECTO/multiplayer/mp-client/dist" \
  HELBREATH_ASSETS="$HELBREATH_PROYECTO/recursos/cliente" \
  HELBREATH_MAPS="$HELBREATH_PROYECTO/recursos/mapas-servidor" \
  HELBREATH_ENABLE_ADMIN=0 \
  HELBREATH_SOLO=0 \
  "$HELBREATH_PROYECTO/bin/linux-x64/Server"
)
```

El directorio de trabajo importa: el servidor lee `Config/` y guarda `Chars/` respecto a `multiplayer/server`. No copies una orden aislada `dotnet run` de otra distribución esperando que encuentre los mapas de este paquete sin configurar sus rutas.

Fuente: [Server.cs](multiplayer/server/Server.cs).

## Consultar y actualizar el repositorio

En un clon del proyecto, estas órdenes permiten revisar el estado:

```bash
git status --short
git branch --show-current
git remote -v
git log -5 --oneline
git diff --stat
```

Para actualizar un clon sin cambios locales pendientes y situado en `main`:

```bash
git pull --ff-only origin main
```

`--ff-only` se detiene si las historias divergieron; no crea una fusión automática. Revisa primero cualquier cambio local o divergencia. Si la actualización cambia fuentes y no incluye sus compilaciones correspondientes, utiliza `./helbreath compilar` antes de jugar.

Referencia: [manual de git pull](https://git-scm.com/docs/git-pull).

## Problemas habituales

| Mensaje o situación | Qué revisar o ejecutar |
|---|---|
| `Permission denied` al ejecutar el lanzador | Desde la raíz: `chmod +x helbreath ubuntu/compilar`. Si perdió permisos el servidor, aplica `chmod +x bin/linux-x64/Server` al ejecutable de tu arquitectura. |
| `Primero ejecuta ./helbreath compilar` | Falta el cliente web compilado: ejecuta `./helbreath dependencias` y `./helbreath compilar`. |
| `Compila el servidor para este equipo` | Falta un ejecutable utilizable para tu arquitectura. Comprueba `uname -m` y compila. |
| Puerto ocupado | Detén el proceso anterior o inicia con otro `PUERTO`, por ejemplo `PUERTO=8181 ./helbreath jugar`. |
| Otra computadora no conecta | Comprueba `ESCUCHAR_EN`, el puerto, la IP alcanzable y el cortafuegos o router. |
| No aparece el campo de administrador | Abre la dirección con `/?admin` después de iniciar con `./helbreath admin`. |
| Clave administrativa incorrecta | Usa la que imprimió la ejecución actual del servidor. |
| `recursos` incompleta o de otra revisión | Conserva la carpeta con otro nombre y vuelve a ejecutar `./helbreath recursos`. |
| El script de subida dice que no es el proyecto completo | Indica la raíz que contiene las fuentes y el lanzador, no una carpeta con solo documentación. |
| Git ignora archivos necesarios | Consulta `archivos-no-incluidos.txt` y las reglas `.gitignore` antes de volver a publicar. |
| Falló un push | Conserva el clon indicado, revisa autenticación, rama y mensaje de Git; no fuerces el envío. |
| No encuentras el reparador de conexión o el descompresor de entregas anteriores | Esas utilidades no están incluidas en esta versión del repositorio. El cliente actual ya incorpora la corrección HTTP por IP y el servidor se entrega sin comprimir. |

## Fuentes y alcance de esta referencia

La referencia se contrastó con el código de la [revisión 2bad144](https://github.com/rodolfo99/helbreath-ubuntu/tree/2bad144ab7b6b67395875fbcb574d2641e814834), incluidos el lanzador, los scripts de Ubuntu, las opciones reales del script de subida, los `package.json` y los paneles del cliente multijugador. Describe los comandos propios de esta edición y las órdenes externas necesarias para sus flujos habituales; no pretende enumerar todas las opciones generales de Bash, Git, npm o .NET.

Los scripts declarados pero incompletos se identifican expresamente. Las herramientas de la edición independiente y los controles de desarrollo no deben confundirse con las funciones disponibles para un jugador normal en `./helbreath jugar`. Para reglas de progresión, coordenadas de ciudades y comercios, consulta [LEEME.md](LEEME.md).
