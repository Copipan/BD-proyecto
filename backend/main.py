from fastapi import FastAPI, HTTPException
from Rutas_API import alumnos, login
from fastapi.middleware.cors import CORSMiddleware
from BaseDeDatos import get_connection

app = FastAPI()

app.include_router(alumnos.router)
app.include_router(login.router)

# Allow requests from your Angular app (important!)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:4200"],  # Angular runs here by default
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/api/hello")
def say_hello():
    return {"message": "Hello from FastAPI!"}

@app.get("/api/db-check")
def db_check():
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT 'Connected to Oracle' FROM dual")
        result = cursor.fetchone()
        cursor.close()
        conn.close()
        return {"message": result[0]}
    except Exception as e:
        return {"error": str(e)}



