from fastapi import APIRouter, HTTPException
from BaseDeDatos import get_connection
from pydantic import BaseModel

router = APIRouter()
connection = get_connection()

class LoginData(BaseModel):
    email: str
    password: str

@router.post("/login")
def login(data: LoginData):
    cursor = connection.cursor()

    query = "SELECT correo, tipo_usuario FROM usuarios WHERE correo = :email AND contrasena = :password"
    cursor.execute(query, email=data.email, password=data.password)
    user = cursor.fetchone()

    if user:
        email, role = user
        return {
            "message": "Inicio de sesión correcto",
            "email": email,
            "role": role  
        }
    else:
        raise HTTPException(status_code=401, detail="Correo electrónico o contraseña inválido")