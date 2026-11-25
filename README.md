# Helbreath para Ubuntu 26.04

Edición para Ubuntu 26.04 x86-64 con servidor multijugador y cliente de navegador. Empiezas en Aresden con 27 puntos de atributo para repartir. Puedes viajar a Elvine, explorar mazmorras, conseguir botín, comprar hechizos y guardar objetos en el banco.

## Comandos y controles

Consulta la [referencia completa de comandos](COMANDOS.md) para iniciar el juego, configurar conexiones por IP, usar los controles de jugador y administrador, compilar, conservar partidas y publicar el código en GitHub. Incluye todas las opciones del script de subida y el estado de las herramientas de desarrollo.

## Jugar

```bash
git clone https://github.com/rodolfo99/helbreath-ubuntu.git
cd helbreath-ubuntu
./helbreath jugar
```

Abre **http://127.0.0.1:1337/** en Firefox o Chromium. La primera ejecución necesita Internet para descargar y verificar los 791 archivos de mapas, gráficos y sonidos (unos 311 MiB una vez instalados).

El repositorio incluye el servidor compilado para x86-64 y los clientes web compilados. Para recompilarlos desde el código en Ubuntu 26.04, ejecuta `./helbreath dependencias` y luego `./helbreath compilar`.

La [guía de juego y configuración](LEEME.md) explica cómo crear o migrar un personaje, habilitar el modo administrador y encontrar los comercios y rutas entre ciudades. Consulta también la [licencia y su excepción para los recursos originales](LICENSE).
