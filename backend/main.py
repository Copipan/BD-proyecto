from fastapi import FastAPI
from Rutas_API import login, user_profile, socialserviceprogress, socialservice
from fastapi.middleware.cors import CORSMiddleware
from BaseDeDatos import get_connection

app = FastAPI() # Crea la aplicación

app.include_router(login.router)
app.include_router(user_profile.router)
app.include_router(socialserviceprogress.router)
app.include_router(socialservice.router)

# Permite peticiones por parte de la app en angular
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:4200"],  # normalmente aquí se inicia la app
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


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