from fastapi import APIRouter
from pydantic import BaseModel
from BaseDeDatos import get_connection

router = APIRouter(prefix="/progreso")

class ProgresoUpdate(BaseModel):
    papeleria_entregada: str  # 'Y' o 'N'
    reportes_entregados: str  # 'Y' o 'N'
    horas_completadas: int

@router.put("/editar/{student_id}")
def update_progreso(student_id: int, progreso: ProgresoUpdate):
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("""
        UPDATE socialserviceprogress
        SET papeleria_entregada = :1,
            reportes_entregados = :2,
            horas_completadas = :3
        WHERE student_id = :4
    """, [
        progreso.papeleria_entregada,
        progreso.reportes_entregados,
        progreso.horas_completadas,
        student_id
    ])
    print("Actualizando progreso para student_id:", student_id)
    conn.commit()
    cursor.close()
    conn.close()
    return {"message": "Progreso actualizado"}

@router.get("/solicitudes")
def update_progreso():
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("""
        SELECT s.student_id, u.nombres || ' ' || u.apellido_paterno as nombre, a.email, s.updated_at
        FROM socialserviceprogress s
        JOIN userprofile u on s.student_id = u.user_id
        JOIN students a on s.student_id = a.user_id
    """)

    rows = cursor.fetchall()
    column_names = [col[0].lower() for col in cursor.description]
    applications = [dict(zip(column_names, row)) for row in rows]

    cursor.close()
    conn.close()
    return applications

@router.get("/por-usuario/{usuario_id}")
def get_progreso_por_usuario(usuario_id: int):
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT papeleria_entregada, reportes_entregados, horas_completadas, updated_at
        FROM socialserviceprogress
        WHERE student_id = :1
    """, [usuario_id])

    row = cursor.fetchone()
    cursor.close()
    conn.close()

    if row:
        return {
            "papeleria_entregada": row[0],
            "reportes_entregados": row[1],
            "horas_completadas": row[2],
            "updated_at": row[3]
        }

    return {"error": "No se encontró progreso para este usuario"}
