drop table administradores cascade constraints;
drop table alumnos cascade constraints;
drop table campus cascade constraints;
drop table carreras cascade constraints;
drop table direcciones cascade constraints;
drop table horas_servicio cascade constraints;
drop table instituciones cascade constraints;
drop table modalidades cascade constraints;
drop table papeleria cascade constraints;
drop table progreso_servicio cascade constraints;
drop table reportes cascade constraints;
drop table solicitudes cascade constraints;
drop table usuarios cascade constraints;

DROP SEQUENCE seq_usuarios;
DROP SEQUENCE seq_campus;
DROP SEQUENCE seq_modalidades;
DROP SEQUENCE seq_carreras;
DROP SEQUENCE seq_alumnos;
DROP SEQUENCE seq_administradores;
DROP SEQUENCE seq_solicitudes;
DROP SEQUENCE seq_direcciones;
DROP SEQUENCE seq_instituciones;
DROP SEQUENCE seq_progreso_servicio;
DROP SEQUENCE seq_papeleria;
DROP SEQUENCE seq_reportes;
DROP SEQUENCE seq_horas_servicio;

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
    id NUMBER CONSTRAINT USUARIOS_PK PRIMARY KEY,
    correo VARCHAR2(100) CONSTRAINT UQ_USUARIOS_CORREO UNIQUE NOT NULL,
    contrasena VARCHAR2(255) NOT NULL,
    tipo_usuario VARCHAR2(10) NOT NULL
);

CREATE TABLE campus (
    id NUMBER CONSTRAINT CAMPUS_PK PRIMARY KEY,
    nombre VARCHAR2(100) NOT NULL
);

CREATE TABLE modalidades (
    id NUMBER  PRIMARY KEY,
    nombre VARCHAR2(100) NOT NULL
);

CREATE TABLE carreras (
    id NUMBER CONSTRAINT CARRERAS_PK PRIMARY KEY,
    nombre VARCHAR2(100) NOT NULL
);

-- Dirección genérica (alumno y institución)
CREATE TABLE direcciones (
    id NUMBER CONSTRAINT DIRECCIONES_PK PRIMARY KEY,
    calle VARCHAR2(100),
    numero VARCHAR2(10),
    colonia VARCHAR2(100),
    ciudad VARCHAR2(100),
    estado VARCHAR2(100)
);

-- Instituciones
CREATE TABLE instituciones (
    id NUMBER CONSTRAINT INSTITUCIONES_PK PRIMARY KEY,
    nombre VARCHAR2(150),
    departamento VARCHAR2(100),
    direccion_id NUMBER,
    telefono VARCHAR2(20),
    celular VARCHAR2(20),
    zona VARCHAR2(10),
    CONSTRAINT DIRECCION_ID_IN_FK FOREIGN KEY (direccion_id) REFERENCES direcciones(id)
);

-- Alumnos
CREATE TABLE alumnos (
    id NUMBER CONSTRAINT ALUMNOS_PK PRIMARY KEY,
    usuario_id NUMBER CONSTRAINT UQ_USUARIO_AL_ID UNIQUE,
    nombre VARCHAR2(100),
    carrera_id NUMBER,
    campus_id NUMBER,
    modalidad_id NUMBER,
    porcentaje_creditos_aprobados NUMBER(5,2),
    direccion_id NUMBER,
    telefono VARCHAR2(20),
    celular VARCHAR2(20),
    correo VARCHAR2(100),
    CONSTRAINT USUARIO_ID_AL_FK FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
    CONSTRAINT CARRERA_ID_AL_FK FOREIGN KEY (carrera_id) REFERENCES carreras(id),
    CONSTRAINT CAMPUS_ID_AL_FK FOREIGN KEY (campus_id) REFERENCES campus(id),
    CONSTRAINT MODALIDAD_ID_AL_FK FOREIGN KEY (modalidad_id) REFERENCES modalidades(id),
    CONSTRAINT DIRECCION_ID_AL_FK FOREIGN KEY (direccion_id) REFERENCES direcciones(id)
);

-- Administradores
CREATE TABLE administradores (
    id NUMBER CONSTRAINT ADMIN_PK PRIMARY KEY,
    usuario_id NUMBER CONSTRAINT UQ_USUARIO_ADMIN_ID UNIQUE,
    nombre VARCHAR2(100),
    facultad VARCHAR2(100),
    campus_id NUMBER,
    CONSTRAINT USUARIO_ID_AD_FK FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
    CONSTRAINT CAMPUS_ID_AD_FK FOREIGN KEY (campus_id) REFERENCES campus(id)
);

-- Solicitudes
CREATE TABLE solicitudes (
    id NUMBER CONSTRAINT SOLICITUDES_PK PRIMARY KEY,
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
    CONSTRAINT ALUMNO_ID_SO_FK FOREIGN KEY (alumno_id) REFERENCES alumnos(id),
    CONSTRAINT INSTITUCION_ID_SO_FK FOREIGN KEY (institucion_id) REFERENCES instituciones(id)
);

-- Progreso del servicio social
CREATE TABLE progreso_servicio (
    id NUMBER CONSTRAINT PROGRESO_SER_PK PRIMARY KEY,
    solicitud_id NUMBER,
    porcentaje_papeleria NUMBER(5,2) DEFAULT 0,
    porcentaje_reportes NUMBER(5,2) DEFAULT 0,
    horas_realizadas NUMBER DEFAULT 0,
    CONSTRAINT SOLICITUD_ID_PR_FK FOREIGN KEY (solicitud_id) REFERENCES solicitudes(id)
);

-- Papelería
CREATE TABLE papeleria (
    id NUMBER CONSTRAINT PAPELERIA_PK PRIMARY KEY,
    progreso_id NUMBER,
    tipo_documento VARCHAR2(100),
    fecha_entrega DATE,
    estatus VARCHAR2(10) DEFAULT 'pendiente',
    CONSTRAINT PROGRESO_ID_PA_FK FOREIGN KEY (progreso_id) REFERENCES progreso_servicio(id)
);

-- Reportes
CREATE TABLE reportes (
    id NUMBER CONSTRAINT REPORTES_PK PRIMARY KEY,
    progreso_id NUMBER,
    nombre_reporte VARCHAR2(100),
    fecha_entrega DATE,
    estatus VARCHAR2(10) DEFAULT 'pendiente',
    CONSTRAINT PROGRESO_ID_RE_FK FOREIGN KEY (progreso_id) REFERENCES progreso_servicio(id)
);

-- Horas de servicio
CREATE TABLE horas_servicio (
    id NUMBER CONSTRAINT HORAS_SERVICIO_PK PRIMARY KEY,
    progreso_id NUMBER,
    fecha DATE,
    horas NUMBER CHECK (horas > 0),
    CONSTRAINT PROGRESO_ID_HO_FK FOREIGN KEY (progreso_id) REFERENCES progreso_servicio(id)
);
