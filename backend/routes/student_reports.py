from fastapi import APIRouter
from pydantic import BaseModel
from typing import Optional
from db import get_db_connection

router = APIRouter(prefix="/reportes")


class ReporteCreate(BaseModel):
    description: str
    hours_worked: int


class ReporteUpdate(BaseModel):
    description: Optional[str] = None
    hours_worked: Optional[int] = None


class ReporteRevision(BaseModel):
    status: str  # 'approved' o 'rejected'
    feedback: Optional[str] = None


@router.get("/estudiante/{usuario_id}")
def get_reportes_por_usuario(usuario_id: int):
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute("SELECT id FROM students WHERE user_id = %s", [usuario_id])
        row = cursor.fetchone()
        if not row:
            return {"error": "Estudiante no encontrado"}
        student_id = row[0]

        cursor.execute(
            """
            SELECT id, report_number, description, hours_worked, status, feedback, submitted_at, updated_at
            FROM student_reports
            WHERE student_id = %s
            ORDER BY report_number ASC
            """,
            [student_id],
        )
        rows = cursor.fetchall()
        column_names = [col[0].lower() for col in cursor.description]
        return [dict(zip(column_names, row)) for row in rows]
    finally:
        cursor.close()
        conn.close()


@router.post("/estudiante/{usuario_id}")
def crear_reporte(usuario_id: int, reporte: ReporteCreate):
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute("SELECT id FROM students WHERE user_id = %s", [usuario_id])
        row = cursor.fetchone()
        if not row:
            return {"error": "Estudiante no encontrado"}
        student_id = row[0]

        cursor.execute(
            "SELECT status FROM socialserviceapplication WHERE student_id = %s",
            [student_id],
        )
        app_row = cursor.fetchone()
        if not app_row or app_row[0] != "accepted":
            return {"error": "Solo puedes enviar reportes si tu solicitud fue aceptada"}

        cursor.execute(
            "SELECT COALESCE(MAX(report_number), 0) + 1 FROM student_reports WHERE student_id = %s",
            [student_id],
        )
        next_number = cursor.fetchone()[0]

        cursor.execute(
            """
            INSERT INTO student_reports (student_id, report_number, description, hours_worked)
            VALUES (%s, %s, %s, %s)
            RETURNING id, report_number, description, hours_worked, status, submitted_at
            """,
            [student_id, next_number, reporte.description, reporte.hours_worked],
        )
        new_row = cursor.fetchone()
        conn.commit()
        return {
            "id": new_row[0],
            "report_number": new_row[1],
            "description": new_row[2],
            "hours_worked": new_row[3],
            "status": new_row[4],
            "submitted_at": new_row[5],
        }
    finally:
        cursor.close()
        conn.close()


@router.get("/admin/todos")
def get_todos_los_reportes():
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute(
            """
            SELECT
                sr.id,
                sr.report_number,
                sr.description,
                sr.hours_worked,
                sr.status,
                sr.feedback,
                sr.submitted_at,
                sr.updated_at,
                up.nombres || ' ' || up.apellido_paterno AS nombre_estudiante,
                st.student_id AS matricula,
                c.name AS carrera
            FROM student_reports sr
            JOIN students st ON sr.student_id = st.id
            JOIN userprofile up ON st.user_id = up.user_id
            JOIN career c ON st.career_id = c.id
            ORDER BY sr.submitted_at DESC
            """
        )
        rows = cursor.fetchall()
        column_names = [col[0].lower() for col in cursor.description]
        return [dict(zip(column_names, row)) for row in rows]
    finally:
        cursor.close()
        conn.close()


@router.put("/admin/revisar/{reporte_id}")
def revisar_reporte(reporte_id: int, revision: ReporteRevision):
    if revision.status not in ("approved", "rejected"):
        return {"error": "Status debe ser 'approved' o 'rejected'"}

    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        # Obtener estado anterior del reporte y a qué estudiante pertenece
        cursor.execute(
            "SELECT student_id, status, hours_worked FROM student_reports WHERE id = %s",
            [reporte_id],
        )
        report_row = cursor.fetchone()
        if not report_row:
            return {"error": "Reporte no encontrado"}

        student_id = report_row[0]
        old_status = report_row[1]
        hours_worked = report_row[2]

        # Actualizar el reporte
        cursor.execute(
            """
            UPDATE student_reports
            SET status = %s, feedback = %s, updated_at = CURRENT_TIMESTAMP
            WHERE id = %s
            """,
            [revision.status, revision.feedback, reporte_id],
        )

        # Recalcular horas y conteo de reportes aprobados para este estudiante
        # (reconteo completo para que sea idempotente: re-aprobar o revertir queda correcto)
        cursor.execute(
            """
            SELECT
                COALESCE(SUM(hours_worked), 0) AS total_horas,
                COUNT(*) FILTER (WHERE status = 'approved') AS total_aprobados
            FROM student_reports
            WHERE student_id = %s
              AND (id != %s OR %s = 'approved')
            """,
            # Excluimos el reporte actual de la suma anterior y lo incluimos
            # con el nuevo estado usando un recálculo limpio:
            [student_id, reporte_id, revision.status],
        )
        # Mejor: recalcular después de la actualización (ya hicimos el UPDATE arriba)
        cursor.execute(
            """
            SELECT
                COALESCE(SUM(hours_worked), 0),
                COUNT(*) FILTER (WHERE status = 'approved')
            FROM student_reports
            WHERE student_id = %s
            """,
            [student_id],
        )
        calc_row = cursor.fetchone()
        total_horas = calc_row[0]
        total_aprobados = min(calc_row[1], 3)  # Máximo 3 reportes bimestrales

        # Actualizar socialserviceprogress
        cursor.execute(
            """
            UPDATE socialserviceprogress
            SET horas_completadas = %s,
                reportes_entregados = %s,
                updated_at = CURRENT_TIMESTAMP
            WHERE student_id = %s
            """,
            [total_horas, total_aprobados, student_id],
        )

        conn.commit()
        return {
            "id": reporte_id,
            "status": revision.status,
            "feedback": revision.feedback,
            "horas_completadas": total_horas,
            "reportes_entregados": total_aprobados,
        }
    except Exception as e:
        conn.rollback()
        return {"error": str(e)}
    finally:
        cursor.close()
        conn.close()


@router.delete("/{reporte_id}/estudiante/{usuario_id}")
def eliminar_reporte(reporte_id: int, usuario_id: int):
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute("SELECT id FROM students WHERE user_id = %s", [usuario_id])
        row = cursor.fetchone()
        if not row:
            return {"error": "Estudiante no encontrado"}
        student_id = row[0]

        cursor.execute(
            "DELETE FROM student_reports WHERE id = %s AND student_id = %s AND status = 'pending'",
            [reporte_id, student_id],
        )
        if cursor.rowcount == 0:
            conn.rollback()
            return {"error": "No se puede eliminar: reporte no encontrado o ya fue revisado"}
        conn.commit()
        return {"message": "Reporte eliminado"}
    finally:
        cursor.close()
        conn.close()
