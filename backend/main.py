from fastapi import FastAPI
from routes import login, user_profile, social_service_progress, social_service
from fastapi.middleware.cors import CORSMiddleware
from db import get_connection

# Crea la aplicación, es la base donde se va a hacer todo pues funciona como marco de trabajo
app = FastAPI()

app.include_router(login.router)
app.include_router(user_profile.router)
app.include_router(social_service_progress.router)
app.include_router(social_service.router)

# Permite peticiones por parte de la app en angular
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:4200",
        "http://localhost:8000",
    ],  # normalmente aquí se inicia la app
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# Es un Endpoint para revisar si la conexión con la base de datos es correcta
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
