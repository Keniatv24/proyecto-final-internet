from flask import Flask, render_template, request
import psycopg2
import os

app = Flask(__name__)

DB_HOST = os.getenv("DB_HOST")
DB_NAME = os.getenv("DB_NAME", "proyecto_final")
DB_USER = os.getenv("DB_USER", "admin")
DB_PASSWORD = os.getenv("DB_PASSWORD", "admin123")
LANGUAGE = os.getenv("LANGUAGE", "es")

def get_connection():
    return psycopg2.connect(
        host=DB_HOST,
        database=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD
    )

@app.route("/", methods=["GET", "POST"])
def index():
    mensaje = None

    if request.method == "POST":
        nombre = request.form["nombre"]
        comuna = request.form["comuna"]
        carrera = request.form["carrera"]

        conn = get_connection()
        cur = conn.cursor()
        cur.execute(
            "INSERT INTO registros (nombre, comuna, carrera, idioma) VALUES (%s, %s, %s, %s)",
            (nombre, comuna, carrera, LANGUAGE)
        )
        conn.commit()
        cur.close()
        conn.close()

        mensaje = "Registration saved successfully" if LANGUAGE == "en" else "Registro guardado correctamente"

    if LANGUAGE == "en":
        return render_template("index_en.html", mensaje=mensaje)

    return render_template("index_es.html", mensaje=mensaje)

@app.route("/health")
def health():
    return "OK", 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
