#!/usr/bin/env bash
# Sube la carpeta de Helbreath como archivos individuales a GitHub.
# Requisitos en Ubuntu: git y python3. Para autenticarse: gh auth login.
# Ejemplo: bash subir_helbreath_github.sh "/ruta/helbreath-ciudades" --subir --rama main
# Sin --subir solo prepara y verifica; no crea commits ni publica.
set -euo pipefail
if ! command -v python3 >/dev/null 2>&1; then
    echo 'Falta Python 3. Instala las dependencias: sudo apt install git python3 gh' >&2
    exit 1
fi
exec python3 - "$0" "$@" <<'PY'
import argparse
import datetime
import gzip
import hashlib
import json
import os
from pathlib import Path
import re
import shlex
import shutil
import stat
import subprocess
import sys
import tempfile
import uuid

SCRIPT = str(Path(sys.argv.pop(1)).resolve())
REPO = "https://github.com/rodolfo99/helbreath-ubuntu.git"
MIB = 1024 * 1024
WORK = None


def say(message):
    print(message, flush=True)


def fail(message):
    raise RuntimeError(message)


def git(*args, cwd=None, check=True, raw=False, live=False, data=None):
    result = subprocess.run(
        ["git", *map(str, args)], cwd=cwd, input=data,
        stdout=None if live else subprocess.PIPE,
        stderr=None if live else subprocess.PIPE,
    )
    if check and result.returncode:
        detail = (result.stderr or b"").decode("utf-8", "replace").strip()
        fail("Falló git " + str(args[0]) + (":\n" + detail if detail else "."))
    if not check:
        return result
    if live:
        return ""
    return result.stdout if raw else result.stdout.decode("utf-8", "replace").strip()


def contains(parent, child):
    return child == parent or parent in child.parents


def excluded(rel, directory=False):
    name = rel.name
    if name in {".git", ".hg", ".svn", ".gitmodules"}:
        return "metadatos Git; las fuentes anidadas se copian como archivos"
    if name in {"node_modules", "__pycache__", ".venv", "venv", "obj"} and directory:
        return "dependencias o archivos intermedios"
    if name.startswith((".helbreath-parche-", ".importar-")):
        return "copia temporal"
    if rel.as_posix() in {"multiplayer/server/Chars", "multiplayer/server/bin"}:
        return "partidas privadas o salida intermedia del servidor"
    if name in {".env", ".npmrc", ".pypirc", ".netrc", ".git-credentials"}:
        return "configuración local o credenciales"
    if name.startswith(".env.") and name not in {".env.example", ".env.sample", ".env.template"}:
        return "configuración privada"
    if name in {".ssh", ".aws", ".azure", ".gnupg"} and directory:
        return "configuración privada"
    if name.endswith((".log", ".pyc", ".pyo", ".tsbuildinfo")) or name == ".recursos.lock":
        return "registro, caché o bloqueo local"
    if re.fullmatch(r"bin/[^/]+/Server\.gz", rel.as_posix()):
        return "el servidor se publica sin comprimir como Server"
    return None


def inventory(source):
    selected, omitted = [], []

    def onerror(error):
        raise error

    for root, dirs, files in os.walk(source, followlinks=False, onerror=onerror):
        base = Path(root)
        for name in sorted(dirs[:]):
            path = base / name
            rel = path.relative_to(source)
            reason = excluded(rel, True)
            if reason:
                dirs.remove(name)
                omitted.append((rel.as_posix() + "/", reason))
            elif path.is_symlink():
                fail(f"Hay un directorio enlazado: {rel}. Usa una copia con los archivos reales.")
        for name in sorted(files):
            path = base / name
            rel = path.relative_to(source)
            reason = excluded(rel)
            if reason:
                omitted.append((rel.as_posix(), reason))
                continue
            if path.is_symlink() or not stat.S_ISREG(path.stat().st_mode):
                fail(f"No es un archivo normal: {rel}. Usa una copia con los archivos reales.")
            if path.stat().st_size > 100 * MIB:
                fail(f"{rel} supera 100 MiB. No se omitirá en silencio: requiere Git LFS.")
            selected.append(rel)
    return sorted(selected), omitted


IGNORE_BLOCK = """
# Reglas de la importacion de Helbreath: fuentes y ejecutables completos.
**/node_modules/
**/__pycache__/
**/obj/
/multiplayer/server/Chars/
/multiplayer/server/bin/
.env
.env.*
!.env.example
!.env.sample
!.env.template
.npmrc
.pypirc
.netrc
.git-credentials
*.log
*.pyc
*.pyo
*.tsbuildinfo
.recursos.lock
.helbreath-parche-*/
.importar-*/
# Mantener los binarios entregados, los clientes web y los recursos presentes.
!/bin/
!/bin/*/
!/bin/*/Server
/bin/*/Server.gz
!/multiplayer/mp-client/dist/
!/multiplayer/mp-client/dist/**
!/sp-client/dist/
!/sp-client/dist/**
!/recursos/
!/recursos/**
"""


def safe_target(checkout, rel):
    target = checkout / rel
    for part in [target, *target.parents]:
        if part == checkout:
            break
        if part.is_symlink():
            fail(f"El repositorio de destino tiene un enlace en {rel}; revisa el conflicto.")
    if target.is_dir():
        fail(f"En el remoto {rel} es un directorio y en el origen es un archivo.")
    target.parent.mkdir(parents=True, exist_ok=True)
    return target


def main():
    global WORK
    parser = argparse.ArgumentParser(
        prog=Path(SCRIPT).name,
        description="Importar Helbreath en GitHub sin empaquetar el proyecto.",
        epilog="Ejemplo: bash subir_helbreath_github.sh /ruta/helbreath-ciudades --subir --rama main",
    )
    parser.add_argument("carpeta", nargs="?", default=".", help="carpeta que contiene helbreath, multiplayer y sp-client")
    parser.add_argument("--subir", action="store_true", help="crear commit y publicar; sin esta opción solo se prepara")
    parser.add_argument("--rama", help="rama destino; main actualiza main; por defecto se crea una rama nueva")
    parser.add_argument("--repo", default=REPO, help="repositorio destino (por defecto rodolfo99/helbreath-ubuntu)")
    parser.add_argument("--destino", help="carpeta NUEVA para el clon y los informes; nunca dentro del origen")
    parser.add_argument("--mensaje", default="Subir fuentes y ejecutables de Helbreath para Ubuntu sin comprimir")
    args = parser.parse_args()
    if not shutil.which("git"):
        fail("Falta Git. Instala las dependencias: sudo apt install git python3 gh")
    source = Path(args.carpeta).expanduser().resolve()
    if not source.is_dir():
        fail(f"No existe la carpeta: {source}")
    required = [
        "helbreath", "multiplayer/server/Server.csproj", "multiplayer/server/Server.cs",
        "multiplayer/mp-client/package.json", "sp-client/package.json",
    ]
    missing = [name for name in required if not (source / name).is_file()]
    for name in ("multiplayer/mp-client/src", "sp-client/src"):
        if not (source / name).is_dir() or not any((source / name).rglob("*.ts*")):
            missing.append(name)
    if missing:
        fail("Esta no es la carpeta completa del proyecto. Faltan:\n  " + "\n  ".join(missing)
             + "\nEl clon que solo contiene README no sirve como origen; usa la carpeta del juego.")
    selected, omitted = inventory(source)
    branch = args.rama or ("subir-codigo-" + datetime.datetime.now(datetime.timezone.utc).strftime("%Y%m%d-%H%M%S-") + uuid.uuid4().hex[:6])
    if branch.startswith("-") or git("check-ref-format", "refs/heads/" + branch, check=False).returncode:
        fail("Nombre de rama no válido.")
    repository = args.repo
    if Path(repository).expanduser().exists():
        repository = str(Path(repository).expanduser().resolve())
    if repository.startswith("-"):
        fail("Repositorio no válido.")
    if args.destino:
        work = Path(args.destino).expanduser().resolve()
        if contains(source, work):
            fail("La carpeta destino debe estar fuera del origen.")
        work.mkdir(parents=True, exist_ok=False)
    else:
        parent = Path.home().resolve()
        if contains(source, parent):
            fail("Usa --destino con una carpeta nueva fuera del origen.")
        work = Path(tempfile.mkdtemp(prefix="helbreath-subida-", dir=parent))
    WORK = work
    checkout = work / "repositorio"
    say(f"Origen: {source}\nDestino: {repository}\nRama: {branch}\nCopia de trabajo: {checkout}")
    say("Clonando el historial existente...")
    git("clone", "--no-recurse-submodules", "--", repository, checkout, live=True)
    if git("rev-parse", "--verify", "HEAD", cwd=checkout, check=False).returncode:
        fail("El remoto no tiene un commit inicial. Este script parte del repositorio con README.")
    default_branch = git("symbolic-ref", "--short", "HEAD", cwd=checkout)
    current = default_branch
    ref = "refs/remotes/origin/" + branch
    if branch != current:
        if git("show-ref", "--verify", "--quiet", ref, cwd=checkout, check=False).returncode == 0:
            git("checkout", "-b", branch, "--track", "origin/" + branch, cwd=checkout)
        else:
            git("checkout", "-b", branch, cwd=checkout)
    base_sha = git("rev-parse", "HEAD", cwd=checkout)
    # Solo cambia opciones del clon nuevo; respeta el repositorio original.
    git("config", "--local", "core.excludesFile", os.devnull, cwd=checkout)
    git("config", "--local", "core.autocrlf", "false", cwd=checkout)
    git("config", "--local", "core.filemode", "true", cwd=checkout)
    expected = set()
    readme = checkout / "README.md"
    readme_backup = Path("README-del-paquete.md")
    for rel in selected:
        src = source / rel
        dest_rel = rel
        if rel.as_posix() == "README.md" and readme.is_symlink():
            fail("README.md del destino es un enlace; revisa el repositorio antes de importar.")
        if rel.as_posix() == "README.md" and readme.exists():
            if src.read_bytes() == readme.read_bytes():
                expected.add("README.md")
                continue
            dest_rel = readme_backup
            if (source / readme_backup).exists():
                fail("El origen ya contiene README-del-paquete.md; revisa qué README conservar.")
            say("Se conserva README.md de GitHub; el README local se guarda como README-del-paquete.md.")
        dest = safe_target(checkout, dest_rel)
        shutil.copy2(src, dest)
        expected.add(dest_rel.as_posix())

    # La entrega anterior podía traer Server.gz. Publicar siempre el ejecutable real.
    for packed in sorted((source / "bin").glob("*/Server.gz")):
        if packed.is_symlink() or not packed.is_file():
            fail(f"{packed.relative_to(source)} debe ser un archivo normal, no un enlace.")
        rel = packed.relative_to(source).with_suffix("")
        dest = safe_target(checkout, rel)
        if rel.as_posix() not in expected:
            say(f"Descomprimiendo {rel} en la copia de trabajo...")
            total = 0
            with gzip.open(packed, "rb") as src, dest.open("wb") as out:
                while True:
                    block = src.read(MIB)
                    if not block:
                        break
                    total += len(block)
                    if total > 100 * MIB:
                        fail(f"{rel} descomprimido supera 100 MiB y requiere Git LFS.")
                    out.write(block)
            expected.add(rel.as_posix())
        sha_file = packed.with_name("Server.sha256")
        if sha_file.is_file():
            tokens = sha_file.read_text(encoding="utf-8").split()
            if not tokens:
                fail(f"{sha_file.relative_to(source)} está vacío; revisa el paquete.")
            digest = tokens[0]
            actual = hashlib.sha256(dest.read_bytes()).hexdigest()
            if not re.fullmatch(r"[0-9a-fA-F]{64}", digest) or actual != digest.lower():
                fail(f"No coincide el SHA-256 de {rel}; no se publicará.")

    executable_paths = ["helbreath", "ubuntu/compilar", *[p for p in expected if re.fullmatch(r"bin/[^/]+/Server", p)]]
    for rel in executable_paths:
        dest = checkout / rel
        if rel in expected and dest.is_file():
            dest.chmod(dest.stat().st_mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)
    ignore = safe_target(checkout, Path(".gitignore"))
    ignore_text = ignore.read_text(encoding="utf-8") if ignore.exists() else ""
    if IGNORE_BLOCK.strip() not in ignore_text:
        ignore.write_text(ignore_text.rstrip() + "\n" + IGNORE_BLOCK, encoding="utf-8")
    expected.add(".gitignore")
    git("add", "--all", "--", ".", cwd=checkout)
    indexed = git("ls-files", "--stage", "-z", cwd=checkout, raw=True).split(b"\0")
    tracked = set()
    for item in indexed:
        if not item:
            continue
        metadata, path = item.split(b"\t", 1)
        name = os.fsdecode(path)
        if metadata.split()[0] == b"160000":
            fail(f"{name} quedó como submódulo y no como archivos. Revisa el clon antes de subir.")
        tracked.add(name)
    missing_index = sorted(expected - tracked)
    if missing_index:
        (work / "archivos-no-incluidos.txt").write_text("\n".join(missing_index) + "\n", encoding="utf-8")
        fail("Git está ignorando archivos necesarios. No se ha publicado nada. Revisa los .gitignore:\n  "
             + "\n  ".join(missing_index[:20]) + f"\nLista completa: {work / 'archivos-no-incluidos.txt'}")
    changes = git("diff", "--cached", "--name-status", cwd=checkout)
    (work / "cambios.txt").write_text(changes + "\n", encoding="utf-8")
    (work / "archivos-incluidos.txt").write_text("\n".join(sorted(expected)) + "\n", encoding="utf-8")
    (work / "archivos-excluidos.txt").write_text("\n".join(p + "\t" + reason for p, reason in omitted) + "\n", encoding="utf-8")
    total_size = 0
    for rel in sorted(expected):
        size = (checkout / rel).stat().st_size
        total_size += size
        if size > 100 * MIB:
            fail(f"{rel} supera 100 MiB; requiere Git LFS.")
        if size > 50 * MIB:
            say(f"Archivo grande: {rel} ({size / MIB:.1f} MiB).")
    say(f"\nVerificados: {len(expected)} archivos del proyecto ({total_size / MIB:.1f} MiB).")
    say(f"Informe de cambios: {work / 'cambios.txt'}")
    say(f"Exclusiones: {work / 'archivos-excluidos.txt'}")
    if not (checkout / "bin/linux-x64/Server").is_file() or not (checkout / "multiplayer/mp-client/dist/index.html").is_file():
        say("La carpeta contiene fuentes, pero faltan ejecutables preparados; será necesario compilar para jugar.")
    if not (source / "recursos").is_dir():
        say("El origen no incluye recursos/; se conserva el descargador y su manifiesto, si están en el paquete.")
    report = {"origen": str(source), "repositorio": repository, "rama": branch,
              "base": base_sha, "archivos": len(expected), "bytes": total_size, "publicado": False}
    report_path = work / "resultado.json"
    report_path.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    if not changes:
        say("Sin cambios: el contenido seleccionado ya está en la rama de origen. No se creó otro commit.")
        return
    git("diff", "--cached", "--stat=100,70,20", cwd=checkout, live=True)
    if not args.subir:
        say("\nPREPARADO. No se creó ningún commit ni se publicó nada.")
        command = ["bash", SCRIPT, str(source), "--subir", "--rama", branch]
        if args.repo != REPO:
            command += ["--repo", args.repo]
        if args.mensaje != parser.get_default("mensaje"):
            command += ["--mensaje", args.mensaje]
        say("Para subir esta selección, repite desde el origen con:\n" + shlex.join(command))
        say("Para actualizar main, usa --rama main en ese comando.")
        return
    for key, fallback in [("user.name", "Rodolfo Valencia Rodriguez"),
                          ("user.email", "41081472+rodolfo99@users.noreply.github.com")]:
        configured = git("config", "--get", key, cwd=checkout, check=False)
        if configured.returncode or not configured.stdout.strip():
            git("config", "--local", key, fallback, cwd=checkout)
    git("commit", "-m", args.mensaje, cwd=checkout, live=True)
    sha = git("rev-parse", "HEAD", cwd=checkout)
    report["commit"] = sha
    report_path.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    say(f"Publicando en {branch} con un push normal...")
    if git("push", "origin", f"HEAD:refs/heads/{branch}", cwd=checkout, check=False, live=True).returncode:
        fail("No se completó el push. El commit queda en la copia de trabajo.\n"
             "Si falta autenticación, ejecuta gh auth login --hostname github.com --git-protocol https --web\n"
             "y gh auth setup-git --hostname github.com. Luego repite el script.\n"
             "Si la rama cambió o está protegida, revisa el mensaje de Git; no uses --force.")
    remote = git("ls-remote", "--refs", "origin", "refs/heads/" + branch, cwd=checkout)
    if not remote or remote.split()[0] != sha:
        fail("El push fue aceptado, pero no pude confirmar el mismo commit en el remoto. Revisa la rama.")
    report["publicado"] = True
    report_path.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    say(f"\nSUBIDA VERIFICADA. Rama: {branch}\nCommit: {sha}")
    if repository in {REPO, REPO[:-4], "git@github.com:rodolfo99/helbreath-ubuntu.git"}:
        from urllib.parse import quote
        say("https://github.com/rodolfo99/helbreath-ubuntu/tree/" + quote(branch, safe="/"))
    if branch != default_branch:
        say(f"El código está en {branch}; {default_branch} conserva su contenido hasta integrar esa rama.")
    say(f"Copia local conservada: {checkout}")


try:
    main()
except (RuntimeError, OSError, ValueError, EOFError) as error:
    print("\nERROR: " + str(error), file=sys.stderr, flush=True)
    if WORK:
        print("Trabajo conservado en: " + str(WORK), file=sys.stderr, flush=True)
    sys.exit(1)
except KeyboardInterrupt:
    print("\nInterrumpido. Revisa el remoto si el push ya había empezado.", file=sys.stderr)
    if WORK:
        print("Trabajo conservado en: " + str(WORK), file=sys.stderr)
    sys.exit(130)
PY
