import os
import sqlite3
import time

from dotenv import load_dotenv
from flask import Flask, jsonify, request
from prometheus_client import Counter, Histogram, generate_latest

# Load environment variables
load_dotenv()

app = Flask(__name__)

DATABASE = "tasks.db"

# -----------------------------
# Prometheus Metrics
# -----------------------------
REQUEST_COUNT = Counter(
    "http_requests_total",
    "Total number of HTTP requests"
)

REQUEST_LATENCY = Histogram(
    "http_request_duration_seconds",
    "HTTP request latency in seconds"
)


# -----------------------------
# Database Functions
# -----------------------------
def get_db_connection():
    connection = sqlite3.connect(DATABASE)
    connection.row_factory = sqlite3.Row
    return connection


def init_db():
    connection = get_db_connection()

    connection.execute("""
        CREATE TABLE IF NOT EXISTS tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            completed INTEGER NOT NULL DEFAULT 0
        )
    """)

    connection.commit()
    connection.close()


# -----------------------------
# Prometheus Middleware
# -----------------------------
@app.before_request
def before_request():
    request.start_time = time.time()


@app.after_request
def after_request(response):
    REQUEST_COUNT.inc()

    REQUEST_LATENCY.observe(
        time.time() - request.start_time
    )

    return response


# -----------------------------
# Routes
# -----------------------------
@app.route("/")
def home():
    return jsonify({
        "message": "DevOps Task Manager API v3",
        "status": "running"
    })


@app.route("/health")
def health():
    return jsonify({
        "status": "healthy"
    }), 200


@app.route("/metrics")
def metrics():
    return (
        generate_latest(),
        200,
        {
            "Content-Type": "text/plain"
        }
    )


# -----------------------------
# Task API
# -----------------------------
@app.route("/api/tasks", methods=["GET"])
def get_tasks():
    connection = get_db_connection()

    tasks = connection.execute(
        "SELECT * FROM tasks"
    ).fetchall()

    connection.close()

    return jsonify([
        {
            "id": task["id"],
            "title": task["title"],
            "completed": bool(task["completed"])
        }
        for task in tasks
    ])


@app.route("/api/tasks", methods=["POST"])
def create_task():
    data = request.get_json()

    if not data or not data.get("title"):
        return jsonify({
            "error": "Task title is required"
        }), 400

    connection = get_db_connection()

    cursor = connection.execute(
        "INSERT INTO tasks(title) VALUES (?)",
        (data["title"],)
    )

    connection.commit()

    task_id = cursor.lastrowid

    connection.close()

    return jsonify({
        "id": task_id,
        "title": data["title"],
        "completed": False
    }), 201


# -----------------------------
# Application Entry Point
# -----------------------------
if __name__ == "__main__":
    init_db()

    app.run(
        host=os.getenv("APP_HOST", "0.0.0.0"),
        port=int(os.getenv("APP_PORT", "5000")),
        debug=os.getenv("APP_ENV", "development") == "development"
    )
