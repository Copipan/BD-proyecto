from fastapi import APIRouter, HTTPException, Depends
from db import get_connection

router = APIRouter()


@router.get("/profile/student/{user_id}")
def get_student_profile(user_id: int, cursor=Depends(get_connection)):
    query = """
        SELECT 
            up.nombres || ' ' || up.apellido_paterno || ' ' || COALESCE(up.apellido_materno, '') AS nombre_completo,
            c.name AS carrera,
            f.name AS facultad,
            cam.name AS campus
        FROM Users u
        JOIN UserProfile up ON u.id = up.user_id
        JOIN Students s ON u.id = s.user_id
        JOIN Career c ON s.career_id = c.id
        JOIN Faculty f ON up.faculty_id = f.id
        JOIN Campus cam ON up.campus_id = cam.id
        WHERE u.id = %s
    """
    cursor.execute(query, (user_id,))
    data = cursor.fetchone()

    if data:
        if isinstance(data, dict):
            nombre_completo = data["nombre_completo"]
            carrera = data["carrera"]
            facultad = data["facultad"]
            campus = data["campus"]
        else:
            nombre_completo, carrera, facultad, campus = data
        return {
            "nombre_completo": nombre_completo.strip(),
            "carrera": carrera,
            "facultad": facultad,
            "campus": campus,
        }
    else:
        raise HTTPException(status_code=404, detail="Perfil no encontrado")


@router.get("/profile/admin/{user_id}")
def get_admin_profile(user_id: int, cursor=Depends(get_connection)):
    query = """
        SELECT 
            up.nombres || ' ' || up.apellido_paterno || ' ' || COALESCE(up.apellido_materno, '') AS nombre_completo,
            f.name AS facultad,
            cam.name AS campus
        FROM Users u
        JOIN Admins a ON u.id = a.user_id
        JOIN UserProfile up ON u.id = up.user_id
        JOIN Faculty f ON up.faculty_id = f.id
        JOIN Campus cam ON up.campus_id = cam.id
        WHERE u.id = %s
    """
    cursor.execute(query, (user_id,))
    data = cursor.fetchone()

    if data:
        if isinstance(data, dict):
            nombre_completo = data["nombre_completo"]
            facultad = data["facultad"]
            campus = data["campus"]
        else:
            nombre_completo, facultad, campus = data
        return {
            "nombre_completo": nombre_completo.strip(),
            "facultad": facultad,
            "campus": campus,
        }
    else:
        raise HTTPException(
            status_code=404, detail="Perfil de administrador no encontrado"
        )
