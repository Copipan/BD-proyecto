from fastapi import APIRouter, HTTPException, Depends
from db import get_connection
from pydantic import BaseModel

router = APIRouter()


class LoginData(BaseModel):
    username: str
    password: str


@router.post("/login")
def login(data: LoginData, cursor=Depends(get_connection)):
    query = "SELECT id, username, user_type FROM users WHERE username = %s AND password = %s"
    cursor.execute(query, (data.username, data.password))
    user = cursor.fetchone()

    if user:
        if isinstance(user, dict):
            user_id = user["id"]
            username = user["username"]
            role = user["user_type"]
        else:
            user_id, username, role = user
        return {
            "message": "Inicio de sesión correcto",
            "username": username,
            "role": role,
            "user_id": user_id,
        }
    else:
        raise HTTPException(
            status_code=401, detail="Nombre de usuario o contraseña inválido"
        )
