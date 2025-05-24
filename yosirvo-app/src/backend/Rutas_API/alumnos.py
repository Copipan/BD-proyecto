from fastapi import APIRouter
from BaseDeDatos import get_connection

router = APIRouter(prefix="/alumnos")

@router.get("/")
def get_alumnos():
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM alumnos")
    rows = cursor.fetchall()
    cursor.close()
    conn.close()
    return {"alumnos": rows}
