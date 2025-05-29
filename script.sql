-- Eliminar tablas existentes
-- Tablas dependientes
DROP TABLE SocialServiceProgress CASCADE CONSTRAINTS;
DROP TABLE SocialServiceApplication CASCADE CONSTRAINTS;
DROP TABLE Admins CASCADE CONSTRAINTS;
DROP TABLE Students CASCADE CONSTRAINTS;

-- Tablas principales
DROP TABLE UserProfile CASCADE CONSTRAINTS;
DROP TABLE Users CASCADE CONSTRAINTS;

-- Lookup tables
DROP TABLE Career CASCADE CONSTRAINTS;
DROP TABLE Faculty CASCADE CONSTRAINTS;
DROP TABLE Campus CASCADE CONSTRAINTS;

-- Eliminar secuencias existentes (si las hay)
DROP SEQUENCE faculty_seq;
DROP SEQUENCE campus_seq;
DROP SEQUENCE career_seq;
DROP SEQUENCE users_admin_seq;
DROP SEQUENCE users_student_seq;
DROP SEQUENCE userprofile_seq;
DROP SEQUENCE students_seq;
DROP SEQUENCE admins_seq;
DROP SEQUENCE socialserviceapp_seq;
DROP SEQUENCE socialserviceprog_seq;

-- Crear secuencias
CREATE SEQUENCE faculty_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE campus_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE career_seq START WITH 1 INCREMENT BY 1;
-- IDs de administradores comenzando desde 1001
CREATE SEQUENCE users_admin_seq START WITH 1001 INCREMENT BY 1;
-- IDs de estudiantes comenzando desde 1
CREATE SEQUENCE users_student_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE userprofile_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE students_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE admins_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE socialserviceapp_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE socialserviceprog_seq START WITH 1 INCREMENT BY 1;

-- Crear tablas con claves primarias que usan las secuencias
CREATE TABLE Faculty (
    id NUMBER PRIMARY KEY,
    name VARCHAR2(100) UNIQUE NOT NULL
);

CREATE TABLE Campus (
    id NUMBER PRIMARY KEY,
    name VARCHAR2(100) UNIQUE NOT NULL
    --location VARCHAR2(100)
);

CREATE TABLE Career (
    id NUMBER PRIMARY KEY,
    name VARCHAR2(100) NOT NULL,
    faculty_id NUMBER NOT NULL,
    CONSTRAINT career_faculty_fk FOREIGN KEY (faculty_id) REFERENCES Faculty(id),
    CONSTRAINT career_name_faculty_unique UNIQUE (name, faculty_id)
);

CREATE TABLE Users (
    id NUMBER PRIMARY KEY,
    username VARCHAR2(50) UNIQUE NOT NULL,
    password VARCHAR2(255) NOT NULL,
    user_type VARCHAR2(10) CHECK (user_type IN ('admin', 'student')) NOT NULL
);

CREATE TABLE UserProfile (
    id NUMBER PRIMARY KEY,
    user_id NUMBER UNIQUE NOT NULL,
    apellido_paterno VARCHAR2(50) NOT NULL,
    apellido_materno VARCHAR2(50),
    nombres VARCHAR2(100) NOT NULL,
    faculty_id NUMBER NOT NULL,
    campus_id NUMBER NOT NULL,
    FOREIGN KEY (user_id) REFERENCES Users(id),
    FOREIGN KEY (faculty_id) REFERENCES Faculty(id),
    FOREIGN KEY (campus_id) REFERENCES Campus(id)
);

CREATE TABLE Students (
    id NUMBER PRIMARY KEY,
    user_id NUMBER UNIQUE NOT NULL,
    student_id VARCHAR2(20) UNIQUE NOT NULL,
    email VARCHAR2(100),
    cellphone VARCHAR2(20),
    house_phone VARCHAR2(20),
    career_id NUMBER NOT NULL,
    FOREIGN KEY (user_id) REFERENCES Users(id),
    FOREIGN KEY (career_id) REFERENCES Career(id)
);

CREATE TABLE Admins (
    id NUMBER PRIMARY KEY,
    user_id NUMBER UNIQUE NOT NULL,
    FOREIGN KEY (user_id) REFERENCES Users(id)
);

CREATE TABLE SocialServiceApplication (
    id NUMBER PRIMARY KEY,
    student_id NUMBER NOT NULL,
    FOREIGN KEY (student_id) REFERENCES Students(id),
    fecha_nacimiento DATE,
    lugar_nacimiento VARCHAR2(100),
    sexo VARCHAR2(10),
    edad NUMBER,
    estado_civil VARCHAR2(20),
    calle VARCHAR2(100),
    numero VARCHAR2(20),
    colonia VARCHAR2(100),
    ciudad VARCHAR2(100),
    estado VARCHAR2(100),
    telefono VARCHAR2(20),
    celular VARCHAR2(20),
    correo VARCHAR2(100),
    carrera VARCHAR2(100),
    matricula VARCHAR2(20),
    semestre NUMBER,
    porcentaje_materias VARCHAR2(50),
    institucion_nombre VARCHAR2(100),
    institucion_departamento VARCHAR2(100),
    institucion_calle VARCHAR2(100),
    institucion_numero VARCHAR2(20),
    institucion_colonia VARCHAR2(100),
    institucion_ciudad VARCHAR2(100),
    institucion_estado VARCHAR2(100),
    institucion_telefono VARCHAR2(20),
    institucion_celular VARCHAR2(20),
    zona VARCHAR2(10),
    horario VARCHAR2(100),
    modalidad VARCHAR2(30),
    platica_sensibilizacion VARCHAR2(3) CHECK (platica_sensibilizacion IN ('si', 'no')),
    status VARCHAR2(20) DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected')),
    submitted_at DATE DEFAULT SYSDATE
);

CREATE TABLE SocialServiceProgress (
    id NUMBER PRIMARY KEY,
    student_id NUMBER NOT NULL UNIQUE,
    papeleria_entregada CHAR(1) DEFAULT 'N' CHECK (papeleria_entregada IN ('Y', 'N')),
    reportes_entregados CHAR(1) DEFAULT 'N' CHECK (reportes_entregados IN ('Y', 'N')),
    horas_completadas NUMBER DEFAULT 0,
    updated_at DATE DEFAULT SYSDATE,
    FOREIGN KEY (student_id) REFERENCES Students(id)
);

-- Crear triggers para usar las secuencias
CREATE OR REPLACE TRIGGER faculty_trg
BEFORE INSERT ON Faculty
FOR EACH ROW
BEGIN
    SELECT faculty_seq.NEXTVAL INTO :NEW.id FROM dual;
END;
/

CREATE OR REPLACE TRIGGER campus_trg
BEFORE INSERT ON Campus
FOR EACH ROW
BEGIN
    SELECT campus_seq.NEXTVAL INTO :NEW.id FROM dual;
END;
/

CREATE OR REPLACE TRIGGER career_trg
BEFORE INSERT ON Career
FOR EACH ROW
BEGIN
    SELECT career_seq.NEXTVAL INTO :NEW.id FROM dual;
END;
/

CREATE OR REPLACE TRIGGER users_trg
BEFORE INSERT ON Users
FOR EACH ROW
BEGIN
    IF :NEW.user_type = 'admin' THEN
        SELECT users_admin_seq.NEXTVAL INTO :NEW.id FROM dual;
    ELSIF :NEW.user_type = 'student' THEN
        SELECT users_student_seq.NEXTVAL INTO :NEW.id FROM dual;
    ELSE
        RAISE_APPLICATION_ERROR(-20001, 'Tipo de usuario no válido. Debe ser "admin" o "student".');
    END IF;
END;
/

CREATE OR REPLACE TRIGGER userprofile_trg
BEFORE INSERT ON UserProfile
FOR EACH ROW
BEGIN
    SELECT userprofile_seq.NEXTVAL INTO :NEW.id FROM dual;
END;
/

CREATE OR REPLACE TRIGGER students_trg
BEFORE INSERT ON Students
FOR EACH ROW
BEGIN
    SELECT students_seq.NEXTVAL INTO :NEW.id FROM dual;
END;
/

CREATE OR REPLACE TRIGGER admins_trg
BEFORE INSERT ON Admins
FOR EACH ROW
BEGIN
    SELECT admins_seq.NEXTVAL INTO :NEW.id FROM dual;
END;
/

CREATE OR REPLACE TRIGGER socialserviceapp_trg
BEFORE INSERT ON SocialServiceApplication
FOR EACH ROW
BEGIN
    SELECT socialserviceapp_seq.NEXTVAL INTO :NEW.id FROM dual;
END;
/

CREATE OR REPLACE TRIGGER socialserviceprog_trg
BEFORE INSERT ON SocialServiceProgress
FOR EACH ROW
BEGIN
    SELECT socialserviceprog_seq.NEXTVAL INTO :NEW.id FROM dual;
END;
/

INSERT INTO Campus (name) VALUES ('Campus II');
INSERT INTO Faculty (name) VALUES ('Facultad de Ingeniería');

--Carreras
INSERT INTO career (id, name, faculty_id) VALUES (1, 'Aeroespacial', 1);
INSERT INTO career (id, name, faculty_id) VALUES (2, 'Civil', 1);
INSERT INTO career (id, name, faculty_id) VALUES (3, 'Computación', 1);
INSERT INTO career (id, name, faculty_id) VALUES (4, 'Minas y Metalurgia', 1);
INSERT INTO career (id, name, faculty_id) VALUES (5, 'Topográfica', 1);
INSERT INTO career (id, name, faculty_id) VALUES (6, 'Procesos industriales', 1);
INSERT INTO career (id, name, faculty_id) VALUES (7, 'Física', 1);
INSERT INTO career (id, name, faculty_id) VALUES (8, 'Geológica', 1);
INSERT INTO career (id, name, faculty_id) VALUES (9, 'Ciencia de Datos y Matemáticas aplicadas', 1);

--Users
INSERT INTO Users (username, password, user_type) VALUES ('anaadm', 'admin123', 'admin');
INSERT INTO Users (username, password, user_type) VALUES ('luisadm', 'admin456', 'admin');
INSERT INTO Users (username, password, user_type) VALUES ('jose_gomez', 'pass001', 'student');
INSERT INTO Users (username, password, user_type) VALUES ('maria_hernandez', 'pass002', 'student');
INSERT INTO Users (username, password, user_type) VALUES ('carlos_lopez', 'pass003', 'student');
INSERT INTO Users (username, password, user_type) VALUES ('laura_ruiz', 'pass004', 'student');
INSERT INTO Users (username, password, user_type) VALUES ('fernando_diaz', 'pass005', 'student');
INSERT INTO Users (username, password, user_type) VALUES ('sofia_fernandez', 'pass006', 'student');
INSERT INTO Users (username, password, user_type) VALUES ('diego_ramirez', 'pass007', 'student');
INSERT INTO Users (username, password, user_type) VALUES ('valeria_mendoza', 'pass008', 'student');
INSERT INTO Users (username, password, user_type) VALUES ('david_ortiz', 'pass009', 'student');
INSERT INTO Users (username, password, user_type) VALUES ('andrea_torres', 'pass010', 'student');
INSERT INTO Users (username, password, user_type) VALUES ('hector_rojas', 'pass011', 'student');
INSERT INTO Users (username, password, user_type) VALUES ('elena_castro', 'pass012', 'student');
INSERT INTO Users (username, password, user_type) VALUES ('raul_martinez', 'pass013', 'student');
INSERT INTO Users (username, password, user_type) VALUES ('natalia_vargas', 'pass014', 'student');
INSERT INTO Users (username, password, user_type) VALUES ('sergio_soto', 'pass015', 'student');
INSERT INTO Users (username, password, user_type) VALUES ('monica_guzman', 'pass016', 'student');
INSERT INTO Users (username, password, user_type) VALUES ('jorge_sandoval', 'pass017', 'student');
INSERT INTO Users (username, password, user_type) VALUES ('fatima_morales', 'pass018', 'student');
INSERT INTO Users (username, password, user_type) VALUES ('ricardo_salazar', 'pass019', 'student');
INSERT INTO Users (username, password, user_type) VALUES ('karla_navarro', 'pass020', 'student');
INSERT INTO Users (username, password, user_type) VALUES ('alejandro_rivera', 'pass021', 'student');
INSERT INTO Users (username, password, user_type) VALUES ('diana_vega', 'pass022', 'student');
INSERT INTO Users (username, password, user_type) VALUES ('ivan_aguilar', 'pass023', 'student');
INSERT INTO Users (username, password, user_type) VALUES ('isabel_campos', 'pass024', 'student');
INSERT INTO Users (username, password, user_type) VALUES ('roberto_miranda', 'pass025', 'student');
INSERT INTO Users (username, password, user_type) VALUES ('pamela_reyes', 'pass026', 'student');
INSERT INTO Users (username, password, user_type) VALUES ('marco_ayala', 'pass027', 'student');
INSERT INTO Users (username, password, user_type) VALUES ('alejandra_garza', 'pass028', 'student');
INSERT INTO Users (username, password, user_type) VALUES ('adrian_pineda', 'pass029', 'student');
INSERT INTO Users (username, password, user_type) VALUES ('melissa_luna', 'pass030', 'student');
INSERT INTO Users (username, password, user_type) VALUES ('julio_carrillo', 'pass031', 'student');
INSERT INTO Users (username, password, user_type) VALUES ('brenda_mendez', 'pass032', 'student');
INSERT INTO Users (username, password, user_type) VALUES ('francisco_valdez', 'pass033', 'student');
INSERT INTO Users (username, password, user_type) VALUES ('mariana_silva', 'pass034', 'student');
INSERT INTO Users (username, password, user_type) VALUES ('gustavo_perez', 'pass035', 'student');
INSERT INTO Users (username, password, user_type) VALUES ('rebeca_rios', 'pass036', 'student');
INSERT INTO Users (username, password, user_type) VALUES ('tomas_quintero', 'pass037', 'student');
INSERT INTO Users (username, password, user_type) VALUES ('irene_lozano', 'pass038', 'student');
INSERT INTO Users (username, password, user_type) VALUES ('arturo_barajas', 'pass039', 'student');
INSERT INTO Users (username, password, user_type) VALUES ('judith_molina', 'pass040', 'student');
INSERT INTO Users (username, password, user_type) VALUES ('ramiro_guerrero', 'pass041', 'student');
INSERT INTO Users (username, password, user_type) VALUES ('paola_santos', 'pass042', 'student');
INSERT INTO Users (username, password, user_type) VALUES ('edgar_tapia', 'pass043', 'student');
INSERT INTO Users (username, password, user_type) VALUES ('gema_fuentes', 'pass044', 'student');
INSERT INTO Users (username, password, user_type) VALUES ('bryan_cano', 'pass045', 'student');
INSERT INTO Users (username, password, user_type) VALUES ('araceli_martel', 'pass046', 'student');
INSERT INTO Users (username, password, user_type) VALUES ('lazaro_castillo', 'pass047', 'student');
INSERT INTO Users (username, password, user_type) VALUES ('leticia_sierra', 'pass048', 'student');
INSERT INTO Users (username, password, user_type) VALUES ('hugo_olivares', 'pass049', 'student');
INSERT INTO Users (username, password, user_type) VALUES ('ruth_saldana', 'pass050', 'student');

--UserProfile
INSERT INTO UserProfile (user_id, nombres, apellido_paterno, apellido_materno, faculty_id, campus_id) VALUES (1001, 'Ana', 'Gonzalez', 'Salazar', 1, 1);
INSERT INTO UserProfile (user_id, nombres, apellido_paterno, apellido_materno, faculty_id, campus_id) VALUES (1002, 'Luis', 'Rodriguez', 'Jaime', 1, 1);
INSERT INTO UserProfile (user_id, nombres, apellido_paterno, apellido_materno, faculty_id, campus_id) VALUES (1, 'Jose', 'Gomez', 'Salazar', 1, 1);
INSERT INTO UserProfile (user_id, nombres, apellido_paterno, apellido_materno, faculty_id, campus_id) VALUES (2, 'Maria', 'Hernandez', 'Castaneda', 1, 1);
INSERT INTO UserProfile (user_id, nombres, apellido_paterno, apellido_materno, faculty_id, campus_id) VALUES (3, 'Carlos', 'Lopez', 'Meza', 1, 1);
INSERT INTO UserProfile (user_id, nombres, apellido_paterno, apellido_materno, faculty_id, campus_id) VALUES (4, 'Laura', 'Ruiz', 'Ayala', 1, 1);
INSERT INTO UserProfile (user_id, nombres, apellido_paterno, apellido_materno, faculty_id, campus_id) VALUES (5, 'Fernando', 'Diaz', 'Camacho', 1, 1);
INSERT INTO UserProfile (user_id, nombres, apellido_paterno, apellido_materno, faculty_id, campus_id) VALUES (6, 'Sofia', 'Fernandez', 'Rojas', 1, 1);
INSERT INTO UserProfile (user_id, nombres, apellido_paterno, apellido_materno, faculty_id, campus_id) VALUES (7, 'Diego', 'Ramirez', 'Cardenas', 1, 1);
INSERT INTO UserProfile (user_id, nombres, apellido_paterno, apellido_materno, faculty_id, campus_id) VALUES (8, 'Valeria', 'Mendoza', 'Pena', 1, 1);
INSERT INTO UserProfile (user_id, nombres, apellido_paterno, apellido_materno, faculty_id, campus_id) VALUES (9, 'David', 'Ortiz', 'Paredes', 1, 1);
INSERT INTO UserProfile (user_id, nombres, apellido_paterno, apellido_materno, faculty_id, campus_id) VALUES (10, 'Andrea', 'Torres', 'Barajas', 1, 1);
INSERT INTO UserProfile (user_id, nombres, apellido_paterno, apellido_materno, faculty_id, campus_id) VALUES (11, 'Hector', 'Rojas', 'Montoya', 1, 1);
INSERT INTO UserProfile (user_id, nombres, apellido_paterno, apellido_materno, faculty_id, campus_id) VALUES (12, 'Elena', 'Castro', 'Escobar', 1, 1);
INSERT INTO UserProfile (user_id, nombres, apellido_paterno, apellido_materno, faculty_id, campus_id) VALUES (13, 'Raul', 'Martinez', 'Vargas', 1, 1);
INSERT INTO UserProfile (user_id, nombres, apellido_paterno, apellido_materno, faculty_id, campus_id) VALUES (14, 'Natalia', 'Vargas', 'Guerrero', 1, 1);
INSERT INTO UserProfile (user_id, nombres, apellido_paterno, apellido_materno, faculty_id, campus_id) VALUES (15, 'Sergio', 'Soto', 'Vazquez', 1, 1);
INSERT INTO UserProfile (user_id, nombres, apellido_paterno, apellido_materno, faculty_id, campus_id) VALUES (16, 'Monica', 'Guzman', 'Luna', 1, 1);
INSERT INTO UserProfile (user_id, nombres, apellido_paterno, apellido_materno, faculty_id, campus_id) VALUES (17, 'Jorge', 'Sandoval', 'Bravo', 1, 1);
INSERT INTO UserProfile (user_id, nombres, apellido_paterno, apellido_materno, faculty_id, campus_id) VALUES (18, 'Fatima', 'Morales', 'Molina', 1, 1);
INSERT INTO UserProfile (user_id, nombres, apellido_paterno, apellido_materno, faculty_id, campus_id) VALUES (19, 'Ricardo', 'Salazar', 'Rivera', 1, 1);
INSERT INTO UserProfile (user_id, nombres, apellido_paterno, apellido_materno, faculty_id, campus_id) VALUES (20, 'Karla', 'Navarro', 'Rodriguez', 1, 1);
INSERT INTO UserProfile (user_id, nombres, apellido_paterno, apellido_materno, faculty_id, campus_id) VALUES (21, 'Alejandro', 'Rivera', 'Tapia', 1, 1);
INSERT INTO UserProfile (user_id, nombres, apellido_paterno, apellido_materno, faculty_id, campus_id) VALUES (22, 'Diana', 'Vega', 'Silva', 1, 1);
INSERT INTO UserProfile (user_id, nombres, apellido_paterno, apellido_materno, faculty_id, campus_id) VALUES (23, 'Ivan', 'Aguilar', 'Lozano', 1, 1);
INSERT INTO UserProfile (user_id, nombres, apellido_paterno, apellido_materno, faculty_id, campus_id) VALUES (24, 'Isabel', 'Campos', 'Soto', 1, 1);
INSERT INTO UserProfile (user_id, nombres, apellido_paterno, apellido_materno, faculty_id, campus_id) VALUES (25, 'Roberto', 'Miranda', 'Gonzalez', 1, 1);
INSERT INTO UserProfile (user_id, nombres, apellido_paterno, apellido_materno, faculty_id, campus_id) VALUES (26, 'Pamela', 'Reyes', 'Carrillo', 1, 1);
INSERT INTO UserProfile (user_id, nombres, apellido_paterno, apellido_materno, faculty_id, campus_id) VALUES (27, 'Marco', 'Ayala', 'Santos', 1, 1);
INSERT INTO UserProfile (user_id, nombres, apellido_paterno, apellido_materno, faculty_id, campus_id) VALUES (28, 'Alejandra', 'Garza', 'Perez', 1, 1);
INSERT INTO UserProfile (user_id, nombres, apellido_paterno, apellido_materno, faculty_id, campus_id) VALUES (29, 'Adrian', 'Pineda', 'Ramirez', 1, 1);
INSERT INTO UserProfile (user_id, nombres, apellido_paterno, apellido_materno, faculty_id, campus_id) VALUES (30, 'Melissa', 'Luna', 'Cruz', 1, 1);
INSERT INTO UserProfile (user_id, nombres, apellido_paterno, apellido_materno, faculty_id, campus_id) VALUES (31, 'Julio', 'Carrillo', 'Romero', 1, 1);
INSERT INTO UserProfile (user_id, nombres, apellido_paterno, apellido_materno, faculty_id, campus_id) VALUES (32, 'Brenda', 'Mendez', 'Navarro', 1, 1);
INSERT INTO UserProfile (user_id, nombres, apellido_paterno, apellido_materno, faculty_id, campus_id) VALUES (33, 'Francisco', 'Valdez', 'Fuentes', 1, 1);
INSERT INTO UserProfile (user_id, nombres, apellido_paterno, apellido_materno, faculty_id, campus_id) VALUES (34, 'Mariana', 'Silva', 'Quintero', 1, 1);
INSERT INTO UserProfile (user_id, nombres, apellido_paterno, apellido_materno, faculty_id, campus_id) VALUES (35, 'Gustavo', 'Perez', 'Guerrero', 1, 1);
INSERT INTO UserProfile (user_id, nombres, apellido_paterno, apellido_materno, faculty_id, campus_id) VALUES (36, 'Rebeca', 'Rios', 'Sanchez', 1, 1);
INSERT INTO UserProfile (user_id, nombres, apellido_paterno, apellido_materno, faculty_id, campus_id) VALUES (37, 'Tomas', 'Quintero', 'Delgado', 1, 1);
INSERT INTO UserProfile (user_id, nombres, apellido_paterno, apellido_materno, faculty_id, campus_id) VALUES (38, 'Irene', 'Lozano', 'Camacho', 1, 1);
INSERT INTO UserProfile (user_id, nombres, apellido_paterno, apellido_materno, faculty_id, campus_id) VALUES (39, 'Arturo', 'Barajas', 'Gutierrez', 1, 1);
INSERT INTO UserProfile (user_id, nombres, apellido_paterno, apellido_materno, faculty_id, campus_id) VALUES (40, 'Judith', 'Molina', 'Sandoval', 1, 1);
INSERT INTO UserProfile (user_id, nombres, apellido_paterno, apellido_materno, faculty_id, campus_id) VALUES (41, 'Ramiro', 'Guerrero', 'Lopez', 1, 1);
INSERT INTO UserProfile (user_id, nombres, apellido_paterno, apellido_materno, faculty_id, campus_id) VALUES (42, 'Paola', 'Santos', 'Vega', 1, 1);
INSERT INTO UserProfile (user_id, nombres, apellido_paterno, apellido_materno, faculty_id, campus_id) VALUES (43, 'Edgar', 'Tapia', 'Morales', 1, 1);
INSERT INTO UserProfile (user_id, nombres, apellido_paterno, apellido_materno, faculty_id, campus_id) VALUES (44, 'Gema', 'Fuentes', 'Herrera', 1, 1);
INSERT INTO UserProfile (user_id, nombres, apellido_paterno, apellido_materno, faculty_id, campus_id) VALUES (45, 'Bryan', 'Cano', 'Rodriguez', 1, 1);
INSERT INTO UserProfile (user_id, nombres, apellido_paterno, apellido_materno, faculty_id, campus_id) VALUES (46, 'Araceli', 'Martel', 'Gonzalez', 1, 1);
INSERT INTO UserProfile (user_id, nombres, apellido_paterno, apellido_materno, faculty_id, campus_id) VALUES (47, 'Lazaro', 'Castillo', 'Vargas', 1, 1);
INSERT INTO UserProfile (user_id, nombres, apellido_paterno, apellido_materno, faculty_id, campus_id) VALUES (48, 'Leticia', 'Sierra', 'Cardenas', 1, 1);
INSERT INTO UserProfile (user_id, nombres, apellido_paterno, apellido_materno, faculty_id, campus_id) VALUES (49, 'Hugo', 'Olivares', 'Paredes', 1, 1);
INSERT INTO UserProfile (user_id, nombres, apellido_paterno, apellido_materno, faculty_id, campus_id) VALUES (50, 'Ruth', 'Saldana', 'Gonzalez', 1, 1);

--Students
INSERT INTO Students (user_id, student_id, email, cellphone, house_phone, career_id) 
VALUES (1, 'S001', 'jose.gomez@university.edu', '5551001001', '5552002001', 1);

INSERT INTO Students (user_id, student_id, email, cellphone, house_phone, career_id) 
VALUES (2, 'S002', 'maria.hernandez@university.edu', '5551001002', '5552002002', 2);

INSERT INTO Students (user_id, student_id, email, cellphone, house_phone, career_id) 
VALUES (3, 'S003', 'carlos.lopez@university.edu', '5551001003', '5552002003', 3);

INSERT INTO Students (user_id, student_id, email, cellphone, house_phone, career_id) 
VALUES (4, 'S004', 'laura.ruiz@university.edu', '5551001004', '5552002004', 4);

INSERT INTO Students (user_id, student_id, email, cellphone, house_phone, career_id) 
VALUES (5, 'S005', 'fernando.diaz@university.edu', '5551001005', '5552002005', 5);

INSERT INTO Students (user_id, student_id, email, cellphone, house_phone, career_id) 
VALUES (6, 'S006', 'sofia.fernandez@university.edu', '5551001006', '5552002006', 6);

INSERT INTO Students (user_id, student_id, email, cellphone, house_phone, career_id) 
VALUES (7, 'S007', 'diego.ramirez@university.edu', '5551001007', '5552002007', 7);

INSERT INTO Students (user_id, student_id, email, cellphone, house_phone, career_id) 
VALUES (8, 'S008', 'valeria.mendoza@university.edu', '5551001008', '5552002008', 8);

INSERT INTO Students (user_id, student_id, email, cellphone, house_phone, career_id) 
VALUES (9, 'S009', 'david.ortiz@university.edu', '5551001009', '5552002009', 9);

INSERT INTO Students (user_id, student_id, email, cellphone, house_phone, career_id) 
VALUES (10, 'S010', 'andrea.torres@university.edu', '5551001010', '5552002010', 1);

INSERT INTO Students (user_id, student_id, email, cellphone, house_phone, career_id) 
VALUES (11, 'S011', 'hector.rojas@university.edu', '5551001011', '5552002011', 2);

INSERT INTO Students (user_id, student_id, email, cellphone, house_phone, career_id) 
VALUES (12, 'S012', 'elena.castro@university.edu', '5551001012', '5552002012', 3);

INSERT INTO Students (user_id, student_id, email, cellphone, house_phone, career_id) 
VALUES (13, 'S013', 'raul.martinez@university.edu', '5551001013', '5552002013', 4);

INSERT INTO Students (user_id, student_id, email, cellphone, house_phone, career_id) 
VALUES (14, 'S014', 'natalia.vargas@university.edu', '5551001014', '5552002014', 5);

INSERT INTO Students (user_id, student_id, email, cellphone, house_phone, career_id) 
VALUES (15, 'S015', 'sergio.soto@university.edu', '5551001015', '5552002015', 6);

INSERT INTO Students (user_id, student_id, email, cellphone, house_phone, career_id) 
VALUES (16, 'S016', 'monica.guzman@university.edu', '5551001016', '5552002016', 7);

INSERT INTO Students (user_id, student_id, email, cellphone, house_phone, career_id) 
VALUES (17, 'S017', 'jorge.sandoval@university.edu', '5551001017', '5552002017', 8);

INSERT INTO Students (user_id, student_id, email, cellphone, house_phone, career_id) 
VALUES (18, 'S018', 'fatima.morales@university.edu', '5551001018', '5552002018', 9);

INSERT INTO Students (user_id, student_id, email, cellphone, house_phone, career_id) 
VALUES (19, 'S019', 'ricardo.salazar@university.edu', '5551001019', '5552002019', 1);

INSERT INTO Students (user_id, student_id, email, cellphone, house_phone, career_id) 
VALUES (20, 'S020', 'karla.navarro@university.edu', '5551001020', '5552002020', 2);

INSERT INTO Students (user_id, student_id, email, cellphone, house_phone, career_id) 
VALUES (21, 'S021', 'alejandro.rivera@university.edu', '5551001021', '5552002021', 3);

INSERT INTO Students (user_id, student_id, email, cellphone, house_phone, career_id) 
VALUES (22, 'S022', 'diana.vega@university.edu', '5551001022', '5552002022', 4);

INSERT INTO Students (user_id, student_id, email, cellphone, house_phone, career_id) 
VALUES (23, 'S023', 'ivan.aguilar@university.edu', '5551001023', '5552002023', 5);

INSERT INTO Students (user_id, student_id, email, cellphone, house_phone, career_id) 
VALUES (24, 'S024', 'isabel.campos@university.edu', '5551001024', '5552002024', 6);

INSERT INTO Students (user_id, student_id, email, cellphone, house_phone, career_id) 
VALUES (25, 'S025', 'roberto.miranda@university.edu', '5551001025', '5552002025', 7);

INSERT INTO Students (user_id, student_id, email, cellphone, house_phone, career_id) 
VALUES (26, 'S026', 'pamela.reyes@university.edu', '5551001026', '5552002026', 8);

INSERT INTO Students (user_id, student_id, email, cellphone, house_phone, career_id) 
VALUES (27, 'S027', 'marco.ayala@university.edu', '5551001027', '5552002027', 9);

INSERT INTO Students (user_id, student_id, email, cellphone, house_phone, career_id) 
VALUES (28, 'S028', 'alejandra.garza@university.edu', '5551001028', '5552002028', 1);

INSERT INTO Students (user_id, student_id, email, cellphone, house_phone, career_id) 
VALUES (29, 'S029', 'adrian.pineda@university.edu', '5551001029', '5552002029', 2);

INSERT INTO Students (user_id, student_id, email, cellphone, house_phone, career_id) 
VALUES (30, 'S030', 'melissa.luna@university.edu', '5551001030', '5552002030', 3);

INSERT INTO Students (user_id, student_id, email, cellphone, house_phone, career_id) 
VALUES (31, 'S031', 'julio.carrillo@university.edu', '5551001031', '5552002031', 4);

INSERT INTO Students (user_id, student_id, email, cellphone, house_phone, career_id) 
VALUES (32, 'S032', 'brenda.mendez@university.edu', '5551001032', '5552002032', 5);

INSERT INTO Students (user_id, student_id, email, cellphone, house_phone, career_id) 
VALUES (33, 'S033', 'francisco.valdez@university.edu', '5551001033', '5552002033', 6);

INSERT INTO Students (user_id, student_id, email, cellphone, house_phone, career_id) 
VALUES (34, 'S034', 'mariana.silva@university.edu', '5551001034', '5552002034', 7);

INSERT INTO Students (user_id, student_id, email, cellphone, house_phone, career_id) 
VALUES (35, 'S035', 'gustavo.perez@university.edu', '5551001035', '5552002035', 8);

INSERT INTO Students (user_id, student_id, email, cellphone, house_phone, career_id) 
VALUES (36, 'S036', 'rebeca.rios@university.edu', '5551001036', '5552002036', 9);

INSERT INTO Students (user_id, student_id, email, cellphone, house_phone, career_id) 
VALUES (37, 'S037', 'tomas.quintero@university.edu', '5551001037', '5552002037', 1);

INSERT INTO Students (user_id, student_id, email, cellphone, house_phone, career_id) 
VALUES (38, 'S038', 'irene.lozano@university.edu', '5551001038', '5552002038', 2);

INSERT INTO Students (user_id, student_id, email, cellphone, house_phone, career_id) 
VALUES (39, 'S039', 'arturo.barajas@university.edu', '5551001039', '5552002039', 3);

INSERT INTO Students (user_id, student_id, email, cellphone, house_phone, career_id) 
VALUES (40, 'S040', 'judith.molina@university.edu', '5551001040', '5552002040', 4);

INSERT INTO Students (user_id, student_id, email, cellphone, house_phone, career_id) 
VALUES (41, 'S041', 'ramiro.guerrero@university.edu', '5551001041', '5552002041', 5);

INSERT INTO Students (user_id, student_id, email, cellphone, house_phone, career_id) 
VALUES (42, 'S042', 'paola.santos@university.edu', '5551001042', '5552002042', 6);

INSERT INTO Students (user_id, student_id, email, cellphone, house_phone, career_id) 
VALUES (43, 'S043', 'edgar.tapia@university.edu', '5551001043', '5552002043', 7);

INSERT INTO Students (user_id, student_id, email, cellphone, house_phone, career_id) 
VALUES (44, 'S044', 'gema.fuentes@university.edu', '5551001044', '5552002044', 8);

INSERT INTO Students (user_id, student_id, email, cellphone, house_phone, career_id) 
VALUES (45, 'S045', 'bryan.cano@university.edu', '5551001045', '5552002045', 9);

INSERT INTO Students (user_id, student_id, email, cellphone, house_phone, career_id) 
VALUES (46, 'S046', 'araceli.martel@university.edu', '5551001046', '5552002046', 1);

INSERT INTO Students (user_id, student_id, email, cellphone, house_phone, career_id) 
VALUES (47, 'S047', 'lazaro.castillo@university.edu', '5551001047', '5552002047', 2);

INSERT INTO Students (user_id, student_id, email, cellphone, house_phone, career_id) 
VALUES (48, 'S048', 'leticia.sierra@university.edu', '5551001048', '5552002048', 3);

INSERT INTO Students (user_id, student_id, email, cellphone, house_phone, career_id) 
VALUES (49, 'S049', 'hugo.olivares@university.edu', '5551001049', '5552002049', 4);

INSERT INTO Students (user_id, student_id, email, cellphone, house_phone, career_id) 
VALUES (50, 'S050', 'ruth.saldana@university.edu', '5551001050', '5552002050', 5);

--Admins
INSERT INTO Admins (user_id) VALUES (1001);  -- Corresponde a 'anaadm'
INSERT INTO Admins (user_id) VALUES (1002);  -- Corresponde a 'luisadm'
