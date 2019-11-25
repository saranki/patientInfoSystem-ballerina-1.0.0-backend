CREATE SCHEMA IF NOT EXISTS patientDB;
show databases;

use patientDB;

CREATE TABLE patient
(
patient_id INT NOT NULL AUTO_INCREMENT,
patient_name VARCHAR(256),
phone_number INT,
email_id VARCHAR(256),

CONSTRAINT PK_patient PRIMARY KEY (patient_id)
);

CREATE TABLE medicine
(
patient_id INT NOT NULL,
medical_record INT NOT NULL,
doctor_name VARCHAR(256),
disease VARCHAR(256),
medicine VARCHAR(256),

CONSTRAINT PK_medicine PRIMARY KEY (patient_id, medical_record),
CONSTRAINT FK_patient FOREIGN KEY (patient_id) REFERENCES patient(patient_id)
);

CREATE TABLE users
(
user_id INT NOT NULL AUTO_INCREMENT,
username VARCHAR(256),
password VARCHAR(256),
role_name VARCHAR(256),

CONSTRAINT PK_users PRIMARY KEY (user_id)
);