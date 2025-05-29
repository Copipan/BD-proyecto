from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from typing import Optional
from datetime import date
from BaseDeDatos import get_connection

router = APIRouter(prefix="/social-service")

class SocialServiceApplication(BaseModel):
    # Personal Information
    fecha_nacimiento: Optional[date] = None
    lugar_nacimiento: Optional[str] = None
    sexo: Optional[str] = None
    edad: Optional[int] = None
    estado_civil: Optional[str] = None
    
    # Address
    calle: Optional[str] = None
    numero: Optional[str] = None
    colonia: Optional[str] = None
    ciudad: Optional[str] = None
    estado: Optional[str] = None
    
    # Contact Info
    telefono: Optional[str] = None
    celular: Optional[str] = None
    correo: Optional[str] = None
    
    # Academic Info
    carrera: Optional[str] = None
    matricula: Optional[str] = None
    semestre: Optional[int] = None
    porcentaje_materias: Optional[str] = None
    
    # Institution Info
    institucion_nombre: Optional[str] = None
    institucion_departamento: Optional[str] = None
    institucion_calle: Optional[str] = None
    institucion_numero: Optional[str] = None
    institucion_colonia: Optional[str] = None
    institucion_ciudad: Optional[str] = None
    institucion_estado: Optional[str] = None
    institucion_telefono: Optional[str] = None
    institucion_celular: Optional[str] = None
    
    # Assignment Info
    zona: Optional[str] = None
    horario: Optional[str] = None
    modalidad: Optional[str] = None
    platica_sensibilizacion: Optional[str] = None

@router.get("/student-info/{user_id}")
def get_student_info(user_id: int):
    try:
        conn = get_connection()
        cursor = conn.cursor()
        
        # Get basic student info
        query = """
        SELECT 
            s.student_id, s.email, s.cellphone, s.house_phone,
            c.name as carrera,
            up.apellido_paterno, up.apellido_materno, up.nombres
        FROM Students s
        JOIN Career c ON s.career_id = c.id
        JOIN UserProfile up ON s.user_id = up.user_id
        WHERE s.user_id = :user_id
        """
        cursor.execute(query, {"user_id": user_id})
        student = cursor.fetchone()
        
        if not student:
            raise HTTPException(status_code=404, detail="Estudiante no encontrado")
            
        # Revisa si ya existe
        query = "SELECT id FROM SocialServiceApplication WHERE student_id = (SELECT id FROM Students WHERE user_id = :user_id)"
        cursor.execute(query, {"user_id": user_id})
        existing_app = cursor.fetchone()
        
        cursor.close()
        conn.close()
        
        return {
            "student_id": student[0],
            "email": student[1],
            "cellphone": student[2],
            "house_phone": student[3],
            "carrera": student[4],
            "apellido_paterno": student[5],
            "apellido_materno": student[6],
            "nombres": student[7],
            "has_existing_application": existing_app is not None
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/submit-application/{user_id}")
def submit_application(user_id: int, application: SocialServiceApplication):
    try:
        conn = get_connection()
        cursor = conn.cursor()
        
        if not user_id:
            raise HTTPException(status_code=404, detail="Student not found")
            
        student_id = user_id
        
        # Check for existing application
        cursor.execute("SELECT id FROM SocialServiceApplication WHERE student_id = :student_id", {"student_id": student_id})
        if cursor.fetchone():
            raise HTTPException(status_code=400, detail="Application already exists")
        
        # Prepare all possible parameters with None as default
        app_data = {
            "fecha_nacimiento": None,
            "lugar_nacimiento": None,
            "sexo": None,
            "edad": None,
            "estado_civil": None,
            "calle": None,
            "numero": None,
            "colonia": None,
            "ciudad": None,
            "estado": None,
            "telefono": None,
            "celular": None,
            "correo": None,
            "carrera": None,
            "matricula": None,
            "semestre": None,
            "porcentaje_materias": None,
            "institucion_nombre": None,
            "institucion_departamento": None,
            "institucion_calle": None,
            "institucion_numero": None,
            "institucion_colonia": None,
            "institucion_ciudad": None,
            "institucion_estado": None,
            "institucion_telefono": None,
            "institucion_celular": None,
            "zona": None,
            "horario": None,
            "modalidad": None,
            "platica_sensibilizacion": None
        }
        
        # Update with actual values from the request
        app_data.update(application.dict(exclude_unset=True))
        
        # Handle date conversion
        if app_data["fecha_nacimiento"]:
            app_data["fecha_nacimiento"] = app_data["fecha_nacimiento"].strftime('%Y-%m-%d')
        
        # Add student_id to parameters
        app_data["student_id"] = student_id
        
        print("Parameters being sent:", app_data)  # Debug output

        # Iniciar transacción
        conn.autocommit = False
        
        query = """
        INSERT INTO SocialServiceApplication (
            student_id, fecha_nacimiento, lugar_nacimiento, sexo, edad, estado_civil,
            calle, numero, colonia, ciudad, estado, telefono, celular, correo,
            carrera, matricula, semestre, porcentaje_materias,
            institucion_nombre, institucion_departamento, institucion_calle, institucion_numero,
            institucion_colonia, institucion_ciudad, institucion_estado, institucion_telefono,
            institucion_celular, zona, horario, modalidad, platica_sensibilizacion
        ) VALUES (
            :student_id, 
            TO_DATE(:fecha_nacimiento, 'YYYY-MM-DD'), 
            :lugar_nacimiento, 
            :sexo, 
            :edad, 
            :estado_civil,
            :calle, 
            :numero, 
            :colonia, 
            :ciudad, 
            :estado, 
            :telefono, 
            :celular, 
            :correo,
            :carrera, 
            :matricula, 
            :semestre, 
            :porcentaje_materias,
            :institucion_nombre, 
            :institucion_departamento, 
            :institucion_calle, 
            :institucion_numero,
            :institucion_colonia, 
            :institucion_ciudad, 
            :institucion_estado, 
            :institucion_telefono,
            :institucion_celular, 
            :zona, 
            :horario, 
            :modalidad, 
            :platica_sensibilizacion
        )
        """
        
        cursor.execute(query, app_data)

        # 2. Insertar en tabla secundaria con valores por defecto
        tracking_query = """
        INSERT INTO SocialServiceProgress 
        (student_id, papeleria_entregada, reportes_entregados, horas_completadas, updated_at)
        VALUES (:student_id, 'N', 'N', 0, SYSDATE)
        """
        cursor.execute(tracking_query, {"student_id": student_id})
        
        # Confirmar transacción
        conn.commit()
        
        return {"message": "Registro enviado con éxito y seguimiento creado"}
        
    except Exception as e:
        print("Detailed error:", str(e))
        if conn:
            conn.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()

@router.get("/full-application/{student_id}")
def get_full_application(student_id: int):
    try:
        conn = get_connection()
        cursor = conn.cursor()
        
        # Get student info
        student_query = """
        SELECT 
            s.student_id, s.email, s.cellphone, s.house_phone,
            c.name as carrera,
            up.apellido_paterno, up.apellido_materno, up.nombres
        FROM Students s
        JOIN Career c ON s.career_id = c.id
        JOIN UserProfile up ON s.user_id = up.user_id
        WHERE s.id = :student_id
        """
        cursor.execute(student_query, {"student_id": student_id})
        student = cursor.fetchone()
        
        if not student:
            raise HTTPException(status_code=404, detail="Estudiante no encontrado")
            
        # Get application
        app_query = "SELECT * FROM SocialServiceApplication WHERE student_id = :student_id"
        cursor.execute(app_query, {"student_id": student_id})
        columns = [col[0] for col in cursor.description]
        application = cursor.fetchone()
        
        if not application:
            raise HTTPException(status_code=404, detail="Solicitud no encontrada")
            
        # Convert to dict
        application_dict = dict(zip(columns, application))
        
        cursor.close()
        conn.close()
        
        return {
            "studentInfo": {
                "student_id": student[0],
                "email": student[1],
                "cellphone": student[2],
                "house_phone": student[3],
                "carrera": student[4],
                "apellido_paterno": student[5],
                "apellido_materno": student[6],
                "nombres": student[7]
            },
            "application": application_dict
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.put("/update-status/{student_id}")
def update_application_status(student_id: int, status_data: dict):
    try:
        conn = get_connection()
        cursor = conn.cursor()
        
        new_status = status_data.get("status")
        if new_status not in ["pending", "accepted", "rejected"]:
            raise HTTPException(status_code=400, detail="Estado inválido")
        
        query = """
        UPDATE SocialServiceApplication 
        SET status = :status 
        WHERE student_id = :student_id
        """
        cursor.execute(query, {"status": new_status, "student_id": student_id})
        conn.commit()
        
        return {"message": "Estado actualizado correctamente"}
        
    except Exception as e:
        if conn:
            conn.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()

@router.delete("/delete-application/{student_id}")
def delete_application(student_id: int):
    try:
        conn = get_connection()
        cursor = conn.cursor()
        
        # Iniciar transacción
        conn.autocommit = False
        
        # 1. Eliminar de SocialServiceProgress (tabla dependiente)
        cursor.execute(
            "DELETE FROM SocialServiceProgress WHERE student_id = :student_id",
            {"student_id": student_id}
        )
        
        # 2. Eliminar de SocialServiceApplication (tabla principal)
        cursor.execute(
            "DELETE FROM SocialServiceApplication WHERE student_id = :student_id",
            {"student_id": student_id}
        )
        
        # Verificar si se eliminó algún registro
        if cursor.rowcount == 0:
            raise HTTPException(
                status_code=404,
                detail="No se encontró la solicitud del estudiante"
            )
        
        # Confirmar transacción
        conn.commit()
        
        return {"message": "Solicitud eliminada correctamente"}
        
    except HTTPException:
        raise  # Re-lanza excepciones HTTP personalizadas
    except Exception as e:
        if conn:
            conn.rollback()
        raise HTTPException(
            status_code=500,
            detail=f"Error al eliminar la solicitud: {str(e)}"
        )
    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()