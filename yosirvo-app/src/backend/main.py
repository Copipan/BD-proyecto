from fastapi import FastAPI
from Rutas_API import alumnos

app = FastAPI()

app.include_router(alumnos.router)
