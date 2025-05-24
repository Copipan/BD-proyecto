from fastapi import APIRouter
from BaseDeDatos import get_connection
from pydantic import BaseModel


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

class Alumno(BaseModel):
    nombre: str

@router.post("/")
def create_alumno(alumno: Alumno):
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("INSERT INTO alumnos (id, nombre) VALUES (seq_alumnos.NEXTVAL, :1)", [alumno.nombre])
    conn.commit()
    cursor.close()
    conn.close()
    return {"message": "Alumno creado"}

@router.put("/{alumno_id}")
def update_alumno(alumno_id: int, alumno: Alumno):
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("UPDATE alumnos SET nombre = :1 WHERE id = :2", [alumno.nombre, alumno_id])
    conn.commit()
    cursor.close()
    conn.close()
    return {"message": "Alumno actualizado"}

@router.delete("/{alumno_id}")
def delete_alumno(alumno_id: int):
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("DELETE FROM alumnos WHERE id = :1", [alumno_id])
    conn.commit()
    cursor.close()
    conn.close()
    return {"message": "Alumno eliminado"}
