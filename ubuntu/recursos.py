#!/usr/bin/env python3
"""Instala los recursos exactos utilizados por ambos clientes y el servidor."""
import argparse
import fcntl
import hashlib
import json
from pathlib import Path
import sys
import tarfile
import tempfile
from urllib.request import urlopen

REVISION = "734f95cf506d666f3a39dbce5bb292f43d162c47"
URL = f"https://codeload.github.com/ErkoKnoll/helbreath-base-game/tar.gz/{REVISION}"
ROOT = Path(__file__).resolve().parents[1]
TARGET = ROOT / "recursos"
CLIENT = "sp-client/public/assets/"
SERVER = "multiplayer/server/Config/maps/"


def destination(stage, name):
    if name.startswith(CLIENT):
        return stage / "cliente" / name[len(CLIENT):]
    if name.startswith(SERVER):
        return stage / "mapas-servidor" / name[len(SERVER):]
    raise ValueError(f"Ruta imprevista en el manifiesto: {name}")


def install_file(stream, path, expected):
    path.parent.mkdir(parents=True, exist_ok=True)
    digest = hashlib.sha256()
    with path.open("xb") as out:
        while chunk := stream.read(1024 * 1024):
            digest.update(chunk)
            out.write(chunk)
    if digest.hexdigest() != expected:
        raise ValueError(f"El contenido de {path.name} difiere de la revisión {REVISION[:12]}.")


def install(local):
    manifest = json.loads((ROOT / "ubuntu/recursos-sha256.json").read_text())
    with (ROOT / ".recursos.lock").open("a") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        stamp = TARGET / ".revision"
        if stamp.is_file() and stamp.read_text().strip() == REVISION:
            return
        if TARGET.exists():
            raise ValueError("La carpeta recursos ya existe y está incompleta o es de otra versión. Renómbrala para conservarla y reintenta.")

        with tempfile.TemporaryDirectory(prefix=".importar-", dir=ROOT) as temporary:
            stage = Path(temporary) / "recursos"
            if local:
                for name, checksum in manifest.items():
                    with (local / name).open("rb") as source:
                        install_file(source, destination(stage, name), checksum)
            else:
                print("Primera ejecución. Descargando los recursos de la revisión original desde GitHub…", flush=True)
                pending = manifest.copy()
                prefix = f"helbreath-base-game-{REVISION}/"
                with urlopen(URL, timeout=120) as response, tarfile.open(fileobj=response, mode="r|gz") as archive:
                    for member in archive:
                        if member.name.startswith(prefix):
                            name = member.name[len(prefix):]
                            if name in pending and member.isfile():
                                with archive.extractfile(member) as source:
                                    install_file(source, destination(stage, name), pending.pop(name))
                if pending:
                    raise ValueError(f"Faltan {len(pending)} archivos en la descarga.")
            (stage / ".revision").write_text(REVISION + "\n")
            stage.rename(TARGET)
    print(f"Recursos listos. {len(manifest)} archivos verificados.")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("repositorio", nargs="?", type=Path, help="copia local de la revisión de origen, opcional")
    args = parser.parse_args()
    try:
        install(args.repositorio)
    except (OSError, ValueError, tarfile.TarError, EOFError) as error:
        sys.exit(f"No se pudieron instalar los recursos. {error}\nPuedes reintentar o usar ./helbreath recursos /ruta/al/repositorio.")
