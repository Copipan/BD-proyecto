from fastapi import APIRouter, HTTPException
from BaseDeDatos import get_connection
from pydantic import BaseModel

router = APIRouter()
connection = get_connection()

class LoginData(BaseModel):
    username: str
    password: str

@router.post("/login")
def login(data: LoginData):
    cursor = connection.cursor()

    query = "SELECT username, user_type FROM users WHERE username = :username AND password = :password"
    cursor.execute(query, {"username": data.username, "password": data.password})
    user = cursor.fetchone()

    if user:
        username, role = user
        return {
            "message": "Inicio de sesión correcto",
            "username": username,
            "role": role  
        }
    else:
        raise HTTPException(status_code=401, detail="Correo electrónico o contraseña inválido")