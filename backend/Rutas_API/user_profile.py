from fastapi import APIRouter, HTTPException
from BaseDeDatos import get_connection
from pydantic import BaseModel

router = APIRouter()
connection = get_connection()

@router.get("/profile/student/{user_id}")
def get_student_profile(user_id: int):
    cursor = connection.cursor()

    query = """
        SELECT u.nombres, u.apellido_paterno, u.apellido_materno,
               ca.name as career
        FROM USERPROFILE u
        JOIN STUDENTS s ON s.user_id = u.user_id
        JOIN CAREER ca ON s.career_id = ca.id
        WHERE u.user_id = :user_id
    """
    cursor.execute(query, {"user_id": user_id})
    data = cursor.fetchone()

    if data:
        nombres, ap_pat, ap_mat, career = data
        return {
            "nombre_completo": f"{nombres} {ap_pat} {ap_mat or ''}",
            "facultad": "",   # Optional: use "" or null if not available
            "campus": "",
            "carrera": career
        }
    else:
        raise HTTPException(status_code=404, detail="Perfil no encontrado")
