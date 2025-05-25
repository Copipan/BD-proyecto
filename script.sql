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
--Modalidad de carrera (Presencial 1/Virtual 2)
CREATE TABLE modalidad (
    id NUMBER  PRIMARY KEY,
    nombre VARCHAR2(100) NOT NULL
);

CREATE TABLE carreras (
    id NUMBER CONSTRAINT CARRERAS_PK PRIMARY KEY,
    nombre VARCHAR2(100) NOT NULL,
    modalidad_id NUMBER,
    CONSTRAINT MODALIDAD_ID_AL_FK FOREIGN KEY (modalidad_id) REFERENCES modalidad(id)
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
    porcentaje_creditos_aprobados NUMBER(5,2),
    direccion_id NUMBER,
    telefono VARCHAR2(20),
    celular VARCHAR2(20),
    correo VARCHAR2(100),
    estado_id NUMBER,
    CONSTRAINT USUARIO_ID_AL_FK FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
    CONSTRAINT CARRERA_ID_AL_FK FOREIGN KEY (carrera_id) REFERENCES carreras(id),
    CONSTRAINT CAMPUS_ID_AL_FK FOREIGN KEY (campus_id) REFERENCES campus(id),
    CONSTRAINT DIRECCION_ID_AL_FK FOREIGN KEY (direccion_id) REFERENCES direcciones(id),
    CONSTRAINT ESTADO_ID_AL_FK FOREIGN KEY (estado_id) REFERENCES estado(id)
);

--Subcategorías de alumnos (Pendiente 0, Aceptado 1, Rechazado 2)
CREATE TABLE estado (
    id NUMBER PRIMARY KEY,
    nombre VARCHAR2(100) NOT NULL
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

--Usuarios
INSERT INTO usuarios (id, correo, contrasena, tipo_usuario) VALUES (1, 'juan.perez@email.com', 'clave123', 'cliente');
INSERT INTO usuarios (id, correo, contrasena, tipo_usuario) VALUES (2, 'maria.garcia@email.com', 'pass456', 'cliente');
INSERT INTO usuarios (id, correo, contrasena, tipo_usuario) VALUES (3, 'carlos.lopez@email.com', 'qwerty789', 'cliente');
INSERT INTO usuarios (id, correo, contrasena, tipo_usuario) VALUES (4, 'laura.mendez@email.com', 'abc12345', 'cliente');
INSERT INTO usuarios (id, correo, contrasena, tipo_usuario) VALUES (5, 'jose.ramirez@email.com', 'pass2025', 'cliente');
INSERT INTO usuarios (id, correo, contrasena, tipo_usuario) VALUES (6, 'ana.torres@email.com', 'clave987', 'cliente');
INSERT INTO usuarios (id, correo, contrasena, tipo_usuario) VALUES (7, 'luis.alvarez@email.com', 'mypass12', 'cliente');
INSERT INTO usuarios (id, correo, contrasena, tipo_usuario) VALUES (8, 'patricia.sanchez@email.com', 'contra456', 'cliente');
INSERT INTO usuarios (id, correo, contrasena, tipo_usuario) VALUES (9, 'diego.fernandez@email.com', 'clave789', 'cliente');
INSERT INTO usuarios (id, correo, contrasena, tipo_usuario) VALUES (10, 'carla.romero@email.com', 'segura321', 'cliente');

INSERT INTO usuarios (id, correo, contrasena, tipo_usuario) VALUES (11, 'david.morales@email.com', 'testclave', 'cliente');
INSERT INTO usuarios (id, correo, contrasena, tipo_usuario) VALUES (12, 'valeria.nunez@email.com', 'clave321', 'cliente');
INSERT INTO usuarios (id, correo, contrasena, tipo_usuario) VALUES (13, 'ricardo.ortiz@email.com', 'clave456', 'cliente');
INSERT INTO usuarios (id, correo, contrasena, tipo_usuario) VALUES (14, 'paula.gomez@email.com', 'clave654', 'cliente');
INSERT INTO usuarios (id, correo, contrasena, tipo_usuario) VALUES (15, 'javier.silva@email.com', 'access123', 'cliente');
INSERT INTO usuarios (id, correo, contrasena, tipo_usuario) VALUES (16, 'luisa.flores@email.com', 'passluisa', 'cliente');
INSERT INTO usuarios (id, correo, contrasena, tipo_usuario) VALUES (17, 'fernando.vargas@email.com', 'qwe789asd', 'cliente');
INSERT INTO usuarios (id, correo, contrasena, tipo_usuario) VALUES (18, 'daniela.cruz@email.com', 'segura2025', 'cliente');
INSERT INTO usuarios (id, correo, contrasena, tipo_usuario) VALUES (19, 'alejandro.rios@email.com', 'mypassword', 'cliente');
INSERT INTO usuarios (id, correo, contrasena, tipo_usuario) VALUES (20, 'camila.molina@email.com', 'clavecamila', 'cliente');

INSERT INTO usuarios (id, correo, contrasena, tipo_usuario) VALUES (21, 'andres.castillo@email.com', '123secure', 'cliente');
INSERT INTO usuarios (id, correo, contrasena, tipo_usuario) VALUES (22, 'sofia.leon@email.com', 'leonsofia', 'cliente');
INSERT INTO usuarios (id, correo, contrasena, tipo_usuario) VALUES (23, 'martin.reyes@email.com', 'clave3210', 'cliente');
INSERT INTO usuarios (id, correo, contrasena, tipo_usuario) VALUES (24, 'ines.salazar@email.com', 'abcd9876', 'cliente');
INSERT INTO usuarios (id, correo, contrasena, tipo_usuario) VALUES (25, 'sergio.castro@email.com', 'contraseña', 'cliente');
INSERT INTO usuarios (id, correo, contrasena, tipo_usuario) VALUES (26, 'marta.espinoza@email.com', 'claveclave', 'cliente');
INSERT INTO usuarios (id, correo, contrasena, tipo_usuario) VALUES (27, 'julian.martinez@email.com', 'julpass', 'cliente');
INSERT INTO usuarios (id, correo, contrasena, tipo_usuario) VALUES (28, 'melina.duran@email.com', 'melidura', 'cliente');
INSERT INTO usuarios (id, correo, contrasena, tipo_usuario) VALUES (29, 'roberto.carrillo@email.com', 'robocarr', 'cliente');
INSERT INTO usuarios (id, correo, contrasena, tipo_usuario) VALUES (30, 'rebecca.solis@email.com', 'pass4567', 'cliente');

INSERT INTO usuarios (id, correo, contrasena, tipo_usuario) VALUES (31, 'esteban.benitez@email.com', 'claveclara', 'cliente');
INSERT INTO usuarios (id, correo, contrasena, tipo_usuario) VALUES (32, 'silvia.acosta@email.com', 'silvia321', 'cliente');
INSERT INTO usuarios (id, correo, contrasena, tipo_usuario) VALUES (33, 'hugo.navarro@email.com', 'hugopass', 'cliente');
INSERT INTO usuarios (id, correo, contrasena, tipo_usuario) VALUES (34, 'elena.cortes@email.com', 'elena987', 'cliente');
INSERT INTO usuarios (id, correo, contrasena, tipo_usuario) VALUES (35, 'oscar.mendoza@email.com', 'oscaros', 'cliente');
INSERT INTO usuarios (id, correo, contrasena, tipo_usuario) VALUES (36, 'lorena.paz@email.com', 'lorenita', 'cliente');
INSERT INTO usuarios (id, correo, contrasena, tipo_usuario) VALUES (37, 'ramon.vera@email.com', 'rampass', 'cliente');
INSERT INTO usuarios (id, correo, contrasena, tipo_usuario) VALUES (38, 'viviana.escobar@email.com', 'vivpass', 'cliente');
INSERT INTO usuarios (id, correo, contrasena, tipo_usuario) VALUES (39, 'gustavo.saenz@email.com', 'gusclave', 'cliente');
INSERT INTO usuarios (id, correo, contrasena, tipo_usuario) VALUES (40, 'natalia.miranda@email.com', 'natpass', 'cliente');

INSERT INTO usuarios (id, correo, contrasena, tipo_usuario) VALUES (41, 'hector.iglesias@email.com', 'hector123', 'cliente');
INSERT INTO usuarios (id, correo, contrasena, tipo_usuario) VALUES (42, 'lorenzo.caballero@email.com', 'lorenzo456', 'cliente');
INSERT INTO usuarios (id, correo, contrasena, tipo_usuario) VALUES (43, 'brenda.araujo@email.com', 'brendita', 'cliente');
INSERT INTO usuarios (id, correo, contrasena, tipo_usuario) VALUES (44, 'joaquin.valdez@email.com', 'joaopass', 'cliente');
INSERT INTO usuarios (id, correo, contrasena, tipo_usuario) VALUES (45, 'susana.rivera@email.com', 'susyclave', 'cliente');
INSERT INTO usuarios (id, correo, contrasena, tipo_usuario) VALUES (46, 'manuel.palacios@email.com', 'manpass', 'cliente');
INSERT INTO usuarios (id, correo, contrasena, tipo_usuario) VALUES (47, 'veronica.arenas@email.com', 'vero456', 'cliente');
INSERT INTO usuarios (id, correo, contrasena, tipo_usuario) VALUES (48, 'ignacio.bustos@email.com', 'nachopass', 'cliente');
INSERT INTO usuarios (id, correo, contrasena, tipo_usuario) VALUES (49, 'claudia.lagos@email.com', 'clauclave', 'cliente');
INSERT INTO usuarios (id, correo, contrasena, tipo_usuario) VALUES (50, 'gabriel.mesa@email.com', 'gabpass', 'cliente');

-- Estado
INSERT INTO estado (id, nombre) VALUES (0, 'Pendiente');
INSERT INTO estado (id, nombre) VALUES (1, 'Aceptado');
INSERT INTO estado (id, nombre) VALUES (2, 'Rechazado');

-- Campus
INSERT INTO campus (id, nombre) VALUES (seq_campus.NEXTVAL, 'UACH Campus I');
INSERT INTO campus (id, nombre) VALUES (seq_campus.NEXTVAL, 'Campus Uach II');

-- Modalidad
INSERT INTO modalidad (id, nombre) VALUES (seq_modalidad.NEXTVAL, 'Presencial');
INSERT INTO modalidad (id, nombre) VALUES (seq_modalidad.NEXTVAL, 'En línea');

-- Carreras
INSERT INTO carreras (id, nombre, modalidad_id) 
VALUES (seq_carreras.NEXTVAL, 'Ingeniero Aeroespacial', 
        (SELECT id FROM modalidad WHERE nombre = 'Presencial'));
INSERT INTO carreras (id, nombre, modalidad_id) 
VALUES (seq_carreras.NEXTVAL, 'Ingeniero en Ciencias de la Computación', 
        (SELECT id FROM modalidad WHERE nombre = 'Presencial'));
INSERT INTO carreras (id, nombre, modalidad_id) 
VALUES (seq_carreras.NEXTVAL, 'Ingeniero Civil', 
        (SELECT id FROM modalidad WHERE nombre = 'Presencial'));
INSERT INTO carreras (id, nombre, modalidad_id) 
VALUES (seq_carreras.NEXTVAL, 'Ingeniero de Software', 
        (SELECT id FROM modalidad WHERE nombre = 'En línea'));
INSERT INTO carreras (id, nombre, modalidad_id) 
VALUES (seq_carreras.NEXTVAL, 'Ingeniero en Minas y Metalurgista', 
        (SELECT id FROM modalidad WHERE nombre = 'Presencial'));
INSERT INTO carreras (id, nombre, modalidad_id) 
VALUES (seq_carreras.NEXTVAL, 'Ingeniero en Sistemas Computacionales en Hardware', 
        (SELECT id FROM modalidad WHERE nombre = 'Presencial'));
INSERT INTO carreras (id, nombre, modalidad_id) 
VALUES (seq_carreras.NEXTVAL, 'Ingeniero en Sistemas Topográficos', 
        (SELECT id FROM modalidad WHERE nombre = 'Presencial'));
INSERT INTO carreras (id, nombre, modalidad_id) 
VALUES (seq_carreras.NEXTVAL, 'Ingeniero en Tecnología de Procesos', 
        (SELECT id FROM modalidad WHERE nombre = 'Presencial'));
INSERT INTO carreras (id, nombre, modalidad_id) 
VALUES (seq_carreras.NEXTVAL, 'Ingeniero Físico', 
        (SELECT id FROM modalidad WHERE nombre = 'Presencial'));
INSERT INTO carreras (id, nombre, modalidad_id) 
VALUES (seq_carreras.NEXTVAL, 'Ingeniero Geólogo', 
        (SELECT id FROM modalidad WHERE nombre = 'Presencial'));
INSERT INTO carreras (id, nombre, modalidad_id) 
VALUES (seq_carreras.NEXTVAL, 'Ingeniero Matemático', 
        (SELECT id FROM modalidad WHERE nombre = 'Presencial'));

-- Direcciones
INSERT INTO direcciones (id, calle, numero, colonia, ciudad, estado)
VALUES (seq_direcciones.NEXTVAL, 'Calle San Felipe', '1900', 'Centro', 'Chihuahua', 'Chihuahua');
INSERT INTO direcciones (id, calle, numero, colonia, ciudad, estado)
VALUES (seq_direcciones.NEXTVAL, 'Escorza', '900', 'Centro', 'Chihuahua', 'Chihuahua');
INSERT INTO direcciones (id, calle, numero, colonia, ciudad, estado)
VALUES (seq_direcciones.NEXTVAL, 'Av. Tecnológico', '901', 'San Jorge', 'Chihuahua', 'Chihuahua');
INSERT INTO direcciones (id, calle, numero, colonia, ciudad, estado)
VALUES (seq_direcciones.NEXTVAL, 'Av. Teófilo Borunda', '2702', 'Colonia Santo Niño', 'Chihuahua', 'Chihuahua');

-- Instituciones
INSERT INTO instituciones (id, nombre, departamento, direccion_id, telefono, celular, zona)
VALUES (seq_instituciones.NEXTVAL, 'Hospital Central del Estado', 'Salud Pública', 
        seq_direcciones.CURRVAL, '6144321000', '6141234567', 'Centro');
INSERT INTO instituciones (id, nombre, departamento, direccion_id, telefono, celular, zona)
VALUES (seq_instituciones.NEXTVAL, 'Universidad Autónoma de Chihuahua', 'Educación Superior', 
        seq_direcciones.CURRVAL, '6144391500', '6149876543', 'Centro');
INSERT INTO instituciones (id, nombre, departamento, direccion_id, telefono, celular, zona)
VALUES (seq_instituciones.NEXTVAL, 'Sistema DIF Estatal Chihuahua', 'Asistencia Social', 
        seq_direcciones.CURRVAL, '6144293300', '6145551234', 'Norte');
INSERT INTO instituciones (id, nombre, departamento, direccion_id, telefono, celular, zona)
VALUES (seq_instituciones.NEXTVAL, 'Museo Semilla Chihuahua', 'Cultura y Educación', 
        seq_direcciones.CURRVAL, '6144144800', '6147654321', 'Centro');
