-- Secuencias
CREATE SEQUENCE seq_usuarios START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_campus START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_modalidades START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_carreras START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_alumnos START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_administradores START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_solicitudes START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_direcciones START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_instituciones START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_progreso_servicio START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_papeleria START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_reportes START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_horas_servicio START WITH 1 INCREMENT BY 1;

-- Tablas de referencia
CREATE TABLE usuarios (
    id NUMBER PRIMARY KEY,
    correo VARCHAR2(100) UNIQUE NOT NULL,
    contrasena VARCHAR2(255) NOT NULL,
    tipo_usuario VARCHAR2(10) NOT NULL
);

CREATE TABLE campus (
    id NUMBER PRIMARY KEY,
    nombre VARCHAR2(100) NOT NULL
);

CREATE TABLE modalidades (
    id NUMBER PRIMARY KEY,
    nombre VARCHAR2(100) NOT NULL
);

CREATE TABLE carreras (
    id NUMBER PRIMARY KEY,
    nombre VARCHAR2(100) NOT NULL
);

-- Dirección genérica (alumno y institución)
CREATE TABLE direcciones (
    id NUMBER PRIMARY KEY,
    calle VARCHAR2(100),
    numero VARCHAR2(10),
    colonia VARCHAR2(100),
    ciudad VARCHAR2(100),
    estado VARCHAR2(100)
);

-- Instituciones
CREATE TABLE instituciones (
    id NUMBER PRIMARY KEY,
    nombre VARCHAR2(150),
    departamento VARCHAR2(100),
    direccion_id NUMBER,
    telefono VARCHAR2(20),
    celular VARCHAR2(20),
    zona VARCHAR2(10),
    FOREIGN KEY (direccion_id) REFERENCES direcciones(id)
);

-- Alumnos
CREATE TABLE alumnos (
    id NUMBER PRIMARY KEY,
    usuario_id NUMBER UNIQUE,
    nombre VARCHAR2(100),
    carrera_id NUMBER,
    campus_id NUMBER,
    modalidad_id NUMBER,
    porcentaje_creditos_aprobados NUMBER(5,2),
    direccion_id NUMBER,
    telefono VARCHAR2(20),
    celular VARCHAR2(20),
    correo VARCHAR2(100),
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
    FOREIGN KEY (carrera_id) REFERENCES carreras(id),
    FOREIGN KEY (campus_id) REFERENCES campus(id),
    FOREIGN KEY (modalidad_id) REFERENCES modalidades(id),
    FOREIGN KEY (direccion_id) REFERENCES direcciones(id)
);

-- Administradores
CREATE TABLE administradores (
    id NUMBER PRIMARY KEY,
    usuario_id NUMBER UNIQUE,
    nombre VARCHAR2(100),
    facultad VARCHAR2(100),
    campus_id NUMBER,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
    FOREIGN KEY (campus_id) REFERENCES campus(id)
);

-- Solicitudes
CREATE TABLE solicitudes (
    id NUMBER PRIMARY KEY,
    alumno_id NUMBER NOT NULL,
    apellido_paterno VARCHAR2(100),
    apellido_materno VARCHAR2(100),
    nombres VARCHAR2(100),
    fecha_nacimiento DATE,
    lugar_nacimiento VARCHAR2(100),
    sexo VARCHAR2(10),
    edad NUMBER,
    estado_civil VARCHAR2(20),
    carrera VARCHAR2(100),
    matricula VARCHAR2(20),
    semestre VARCHAR2(10),
    porcentaje_materias NUMBER(5,2),
    institucion_id NUMBER,
    horario VARCHAR2(100),
    modalidad_servicio VARCHAR2(10),
    platica_sensibilizacion NUMBER(1),
    fecha_envio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    observaciones CLOB,
    FOREIGN KEY (alumno_id) REFERENCES alumnos(id),
    FOREIGN KEY (institucion_id) REFERENCES instituciones(id)
);

-- Progreso del servicio social
CREATE TABLE progreso_servicio (
    id NUMBER PRIMARY KEY,
    solicitud_id NUMBER,
    porcentaje_papeleria NUMBER(5,2) DEFAULT 0,
    porcentaje_reportes NUMBER(5,2) DEFAULT 0,
    horas_realizadas NUMBER DEFAULT 0,
    FOREIGN KEY (solicitud_id) REFERENCES solicitudes(id)
);

-- Papelería
CREATE TABLE papeleria (
    id NUMBER PRIMARY KEY,
    progreso_id NUMBER,
    tipo_documento VARCHAR2(100),
    fecha_entrega DATE,
    estatus VARCHAR2(10) DEFAULT 'pendiente',
    FOREIGN KEY (progreso_id) REFERENCES progreso_servicio(id)
);

-- Reportes
CREATE TABLE reportes (
    id NUMBER PRIMARY KEY,
    progreso_id NUMBER,
    nombre_reporte VARCHAR2(100),
    fecha_entrega DATE,
    estatus VARCHAR2(10) DEFAULT 'pendiente',
    FOREIGN KEY (progreso_id) REFERENCES progreso_servicio(id)
);

-- Horas de servicio
CREATE TABLE horas_servicio (
    id NUMBER PRIMARY KEY,
    progreso_id NUMBER,
    fecha DATE,
    horas NUMBER CHECK (horas > 0),
    FOREIGN KEY (progreso_id) REFERENCES progreso_servicio(id)
);
