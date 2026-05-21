from fastapi import FastAPI, Depends # IMPORTANTE: Agregar Depends
from routes import login, user_profile, social_service_progress, social_service
from fastapi.middleware.cors import CORSMiddleware
from db import get_connection # IMPORTANTE: Actualizar el nombre de la función

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
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# Es un Endpoint para revisar si la conexión con la base de datos es correcta
@app.get("/api/db-check")
def db_check(cursor=Depends(get_connection)): # Usamos Inyección de Dependencias
    try:
        # Añadimos 'AS status' para darle una llave al diccionario.
        cursor.execute("SELECT 'Connected to PostgreSQL' AS status")
        result = cursor.fetchone()
        
        # Como usamos RealDictCursor en db.py, result es un diccionario, no una tupla.
        return {"message": result['status']}
        
    except Exception as e:
        return {"error": str(e)}