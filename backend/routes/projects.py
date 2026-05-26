from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Optional
from db import get_db_connection

router = APIRouter(prefix="/projects")


# ─────────────────────────────────────────
# Modelos Pydantic
# ─────────────────────────────────────────

class ProjectCreate(BaseModel):
    title: str
    description: str
    career_id: int
    organization_or_professor: str
    contact_info: str
    required_semester: int
    slots_available: int
    status: Optional[str] = "active"


class ProjectUpdate(ProjectCreate):
    pass


class ApplyRequest(BaseModel):
    user_id: int
    project_id: int


# ─────────────────────────────────────────
# Endpoints — rutas estáticas primero,
# luego las que llevan parámetro {id}
# ─────────────────────────────────────────

@router.get("/careers")
def get_careers():
    """Carreras disponibles para el selector del formulario."""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT id, name FROM Career ORDER BY name")
        rows = cursor.fetchall()
        cursor.close()
        conn.close()
        return [{"id": r[0], "name": r[1]} for r in rows]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/available")
def get_available_projects():
    """Solo proyectos activos — vista del estudiante."""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("""
            SELECT
                p.id,
                p.title,
                p.description,
                p.career_id,
                c.name  AS career_name,
                p.organization_or_professor,
                p.contact_info,
                p.required_semester,
                p.slots_available,
                p.status
            FROM projects p
            JOIN career c ON c.id = p.career_id
            WHERE p.status = 'active'
            ORDER BY p.created_at DESC
        """)
        rows = cursor.fetchall()
        cursor.close()
        conn.close()
        return [
            {
                "id":                        r[0],
                "title":                     r[1],
                "description":               r[2],
                "career_id":                 r[3],
                "career_name":               r[4],
                "organization_or_professor": r[5],
                "contact_info":              r[6],
                "required_semester":         r[7],
                "slots_available":           r[8],
                "status":                    r[9],
            }
            for r in rows
        ]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/applied/{user_id}")
def get_applied_project(user_id: int):
    """Devuelve el project_id al que el alumno ya aplicó, o null si no tiene ninguno."""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("""
            SELECT ssa.project_id
            FROM socialserviceapplication ssa
            JOIN students s ON s.id = ssa.student_id
            WHERE s.user_id = %s
            LIMIT 1
        """, (user_id,))
        row = cursor.fetchone()
        cursor.close()
        conn.close()
        return {"project_id": row[0] if row else None}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("")
def get_projects():
    """Lista todos los proyectos — vista del administrador."""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("""
            SELECT
                p.id,
                p.title,
                p.description,
                p.career_id,
                c.name  AS career_name,
                p.organization_or_professor,
                p.contact_info,
                p.required_semester,
                p.slots_available,
                p.status
            FROM projects p
            JOIN career c ON c.id = p.career_id
            ORDER BY p.created_at DESC
        """)
        rows = cursor.fetchall()
        cursor.close()
        conn.close()
        return [
            {
                "id":                        r[0],
                "title":                     r[1],
                "description":               r[2],
                "career_id":                 r[3],
                "career_name":               r[4],
                "organization_or_professor": r[5],
                "contact_info":              r[6],
                "required_semester":         r[7],
                "slots_available":           r[8],
                "status":                    r[9],
            }
            for r in rows
        ]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("", status_code=201)
def create_project(data: ProjectCreate):
    """Crea un nuevo proyecto."""
    if data.status not in ("active", "inactive", "full"):
        raise HTTPException(status_code=400, detail="Status invalido.")
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("""
            INSERT INTO projects
                (title, description, career_id, organization_or_professor,
                 contact_info, required_semester, slots_available, status)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            RETURNING id
        """, (
            data.title,
            data.description,
            data.career_id,
            data.organization_or_professor,
            data.contact_info,
            data.required_semester,
            data.slots_available,
            data.status,
        ))
        new_id = cursor.fetchone()[0]
        conn.commit()
        cursor.close()
        conn.close()
        return {"message": "Proyecto creado correctamente.", "id": new_id}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/apply")
def apply_to_project(data: ApplyRequest):
    """Vincula la solicitud de servicio social del estudiante con un proyecto."""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        # student.id a partir del user_id de sesion
        cursor.execute("SELECT id FROM students WHERE user_id = %s", (data.user_id,))
        student = cursor.fetchone()
        if not student:
            raise HTTPException(status_code=404, detail="Estudiante no encontrado.")
        student_id = student[0]

        # Proyecto existe y esta activo
        cursor.execute(
            "SELECT id, slots_available FROM projects WHERE id = %s AND status = 'active'",
            (data.project_id,)
        )
        project = cursor.fetchone()
        if not project:
            raise HTTPException(status_code=404, detail="El proyecto no existe o ya no esta disponible.")
        if project[1] <= 0:
            raise HTTPException(status_code=400, detail="Este proyecto ya no tiene vacantes disponibles.")

        # El alumno debe tener solicitud de servicio social previa
        cursor.execute(
            "SELECT id, project_id FROM socialserviceapplication WHERE student_id = %s",
            (student_id,)
        )
        application = cursor.fetchone()
        if not application:
            raise HTTPException(
                status_code=400,
                detail="Debes completar el formulario de registro de servicio social antes de aplicar a un proyecto."
            )
        if application[1] is not None:
            raise HTTPException(status_code=400, detail="Ya tienes un proyecto asignado en tu solicitud.")

        # Asignar proyecto y descontar vacante
        cursor.execute(
            "UPDATE socialserviceapplication SET project_id = %s WHERE student_id = %s",
            (data.project_id, student_id)
        )
        cursor.execute(
            "UPDATE projects SET slots_available = slots_available - 1, updated_at = CURRENT_TIMESTAMP WHERE id = %s",
            (data.project_id,)
        )
        cursor.execute(
            "UPDATE projects SET status = 'full' WHERE id = %s AND slots_available <= 0",
            (data.project_id,)
        )

        conn.commit()
        cursor.close()
        conn.close()
        return {"message": "Solicitud enviada correctamente."}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.put("/{project_id}")
def update_project(project_id: int, data: ProjectUpdate):
    """Actualiza un proyecto existente."""
    if data.status not in ("active", "inactive", "full"):
        raise HTTPException(status_code=400, detail="Status invalido.")
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("""
            UPDATE projects SET
                title                     = %s,
                description               = %s,
                career_id                 = %s,
                organization_or_professor = %s,
                contact_info              = %s,
                required_semester         = %s,
                slots_available           = %s,
                status                    = %s,
                updated_at                = CURRENT_TIMESTAMP
            WHERE id = %s
        """, (
            data.title,
            data.description,
            data.career_id,
            data.organization_or_professor,
            data.contact_info,
            data.required_semester,
            data.slots_available,
            data.status,
            project_id,
        ))
        if cursor.rowcount == 0:
            raise HTTPException(status_code=404, detail="Proyecto no encontrado.")
        conn.commit()
        cursor.close()
        conn.close()
        return {"message": "Proyecto actualizado correctamente."}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.delete("/{project_id}")
def delete_project(project_id: int):
    """Elimina un proyecto."""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("DELETE FROM projects WHERE id = %s", (project_id,))
        if cursor.rowcount == 0:
            raise HTTPException(status_code=404, detail="Proyecto no encontrado.")
        conn.commit()
        cursor.close()
        conn.close()
        return {"message": "Proyecto eliminado correctamente."}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
