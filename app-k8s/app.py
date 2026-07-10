"""
App para AKS: un campo cuyo valor se puede cambiar desde el navegador, 
con historial de cambios. Valor e historial se guardan en /data,
que en Kubernetes será un volumen persistente (PVC): si el pod muere,
el historial sobrevive, esa es la demostración del caso práctico.
"""
from flask import Flask, request, redirect
from datetime import datetime
from html import escape
import os

app = Flask(__name__)
VALOR_FILE = "/data/valor.txt"
HISTORIAL_FILE = "/data/historial.txt"
os.makedirs("/data", exist_ok=True)

def leer(ruta, defecto=""):
    """Devuelve el contenido del archivo, o un valor por defecto si no existe aún."""
    if os.path.exists(ruta):
        with open(ruta) as f:
            return f.read()
    return defecto


@app.route("/")
def index():
    valor = escape(leer(VALOR_FILE, "(sin valor todavía)").strip())
    lineas = leer(HISTORIAL_FILE).strip().splitlines()
    # Historial en orden inverso: el cambio más reciente arriba
    items = "".join(f"<li>{escape(l)}</li>" for l in reversed(lineas))
    return f"""<!DOCTYPE html>
<html lang="es">
<head><meta charset="utf-8"><title>App K8s — Caso Práctico 2</title></head>
<body>
  <h1>Valor actual: {valor}</h1>
  <form action="/cambiar" method="post">
    <input name="valor" placeholder="Nuevo valor" required>
    <button type="submit">Cambiar</button>
  </form>
  <h2>Historial de cambios ({len(lineas)})</h2>
  <ul>{items or "<li>(sin cambios todavía)</li>"}</ul>
</body>
</html>"""


@app.route("/cambiar", methods=["POST"])
def cambiar():
    nuevo = request.form.get("valor", "").strip()
    if nuevo:
        anterior = leer(VALOR_FILE, "(vacío)").strip() or "(vacío)"
        marca = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        with open(VALOR_FILE, "w") as f:
            f.write(nuevo)
        # El historial se ABRE EN MODO APPEND: cada cambio añade una línea
        with open(HISTORIAL_FILE, "a") as f:
            f.write(f"{marca} · '{anterior}' → '{nuevo}'\n")
    return redirect("/")


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)