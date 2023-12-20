use master
GO

IF DB_ID('QLPHONGKHAM') IS NOT NULL
	DROP DATABASE QLPHONGKHAM
GO

CREATE DATABASE QLPHONGKHAM
GO

USE QLPHONGKHAM
GO

--table ACCOUNT
CREATE TABLE Account
(
	accountID char(5),
	username varchar(20) NOT NULL UNIQUE,
	[password] char(64) NOT NULL,
	account_status bit NOT NULL

	CONSTRAINT PK_Account
	PRIMARY KEY (accountID)
)

--table ACCOUNT
CREATE TABLE Employee
(
	employee_id char(3),
	employee_name nvarchar(30) NOT NULL,
	employee_gender nvarchar(3) NOT NULL,
	employee_birthday date NOT NULL,
	employee_address nvarchar(30),
	employee_national_id char(12) NOT NULL UNIQUE,
	employee_phone char(10) NOT NULL,
	employee_type char(2) NOT NULL,
	branch_id char(2),
	account_id char(5)

	CONSTRAINT PK_Employee
	PRIMARY KEY (employee_id)
)

ALTER TABLE Employee
ADD CONSTRAINT EmployeeType CHECK (employee_type IN ('DE', 'NU', 'AD', 'ST'));

--table DENTIST
CREATE TABLE Dentist
(
	dentist_id char(3),

	CONSTRAINT PK_Dentist
	PRIMARY KEY(dentist_id)
)

--table Nurse
CREATE TABLE Nurse
(
	nurse_id char(3),

	CONSTRAINT PK_Nurse
	PRIMARY KEY(nurse_id)
)

--table Branch
CREATE TABLE Branch
(
	branch_id char(2),
	branch_name nvarchar(20) NOT NULL,
	branch_address nvarchar(30) NOT NULL,
	branch_phone char(10) NOT NULL

	CONSTRAINT PK_branch
	PRIMARY KEY(branch_id)
)

--table personalAppointment
CREATE TABLE PersonalAppointment
(
	personal_appointment_id char(5),
	personal_appointment_date date NOT NULL,
	personal_appointment_start_time time,
	personal_appointment_end_time time,
	room_id char(2) NOT NULL,
	dentist_id char(3) NOT NULL

	CONSTRAINT PK_personalAppointment
	PRIMARY KEY(personal_appointment_id)
)

--table Room
CREATE TABLE Room
(
	room_id char(2),
	room_name nvarchar(20) NOT NULL,

	CONSTRAINT PK_Room
	PRIMARY KEY(room_id)
)

create table Branch_Room
(
	branch_id char(2),
	room_id char(2),

	constraint PK_Branch_Room
	primary key (branch_id, room_id),

	constraint FK_Branch_Room
	foreign key (branch_id) references Branch,

	constraint FK_Room_Branch
	foreign key (room_id) references Room
)

--table PATIENT
CREATE TABLE Patient
(
	patient_id char(5),
	patient_name nvarchar(30) NOT NULL,
	patient_birthday DATE,
	patient_address nvarchar(40),
	patient_phone char(10) NOT NULL UNIQUE,
	patient_gender nvarchar(3),
	patient_email varchar(20)

	CONSTRAINT PK_Patient
	PRIMARY KEY(patient_id)
)

--table GeneralHealth
CREATE TABLE GeneralHealth
(
	patient_id char(5),
	note_date datetime,
	health_description nvarchar(30) NOT NULL

	CONSTRAINT PK_generalhealth
	PRIMARY KEY(patient_id, note_date)
)

--table APPOINTMENT
CREATE TABLE Appointment
(
	appointment_id char(5),
	request_time datetime NOT NULL,
	appointment_confirm nvarchar(10) NOT NULL,
	appointment_date date NOT NULL,
	appointment_time time NOT NULL,
	appointment_state bit NOT NULL,
	numerical_order char(3) NOT NULL,
	room_id char(2) NOT NULL,
	is_new_patient bit,
	patient_id char(5) NOT NULL,
	dentist_id char(3) NOT NULL,
	nurse_id char(3)

	CONSTRAINT PK_Appointment
	PRIMARY KEY(appointment_id)
)

--table Refferal letter
CREATE TABLE RefferalLetter
(
	refferal_id char(5),
	refferal_to_clinic nvarchar(15),
	appointment_id char(5)

	CONSTRAINT PK_RefferalLetter
	PRIMARY KEY(refferal_id)
)

--table re-exam
CREATE TABLE Reexamination
(
	re_examination_id char(5), 
	re_examination_date date,
	re_examination_note nvarchar(30),
	re_examination_status bit,
	appointment_id char(5),
	treatment_plan_id char(5)

	CONSTRAINT PK_Reexamination
	PRIMARY KEY(re_examination_id)
)

--table select treatment
CREATE TABLE TreatmentPlan
(
	treatment_plan_id char(5),
	treatment_plan_created_date datetime NOT NULL, 
	treatment_plan_note nvarchar(30),
	treatment_plan_description nvarchar(50),
	treatment_plan_status nvarchar(15) NOT NULL,
	treatment_id char(2) NOT NULL,
	patient_id char(5) NOT NULL,
	dentist_id char(3) NOT NULL,
	nurse_id char(3),
	CONSTRAINT PK_TreatmentPlan
	PRIMARY KEY(treatment_plan_id)
)

ALTER TABLE TreatmentPlan
ADD CONSTRAINT treatmentPlanStatusValue CHECK (treatment_plan_status IN (N'Kế hoạch', N'Đã hoàn thành', N'Đã hủy'));

--table session treatment
CREATE TABLE TreatmentSession
(
	treatment_session_id char(5),
	treatment_session_created_date datetime NOT NULL, 
	treatment_session_description nvarchar(50),
	treatment_plan_id char(5) NOT NULL

	CONSTRAINT PK_TreatmentSession
	PRIMARY KEY(treatment_session_id)
)

CREATE TABLE ToothSelection
(
	treatment_plan_id char(5),
	tooth_position_id char(2),
	tooth_surface_code char(1),
	treatment_tooth_price float

	CONSTRAINT PK_ToothSelection
	PRIMARY KEY(treatment_plan_id, tooth_position_id, tooth_surface_code)
)

CREATE TABLE TreatmentTooth
(
	tooth_position_id char(2),
	treatment_id char(2),
	tooth_price float

	CONSTRAINT PK_TreatmentTooth
	PRIMARY KEY(tooth_position_id, treatment_id)
)

CREATE TABLE ToothSurface
(
	tooth_surface_code char(1),
	tooth_surface_title nvarchar(15),
	tooth_surface_description nvarchar(30),


	CONSTRAINT PK_Toothsurface
	PRIMARY KEY(tooth_surface_code)
)

CREATE TABLE ToothPosition
(
	tooth_position_id char(2),
	tooth_position_type nvarchar(15) NOT NULL,
	tooth_position_description nvarchar(30),

	CONSTRAINT PK_Toothposition
	PRIMARY KEY(tooth_position_id)
)

CREATE TABLE Treatment
(
	treatment_id char(2),
	treatment_title nvarchar(15) NOT NULL UNIQUE,
	treatment_description nvarchar(30),
	treatment_cost float  NOT NULL

	CONSTRAINT PK_Treatment
	PRIMARY KEY(treatment_id)
)

CREATE TABLE PaymentRecord
(
	payment_id char(5),
	paid_time datetime  NOT NULL,
	paid_money float  NOT NULL,
	total_cost float,
	payment_note nvarchar(15),
	payment_method_id char(5) NOT NULL,
	treatment_plan_id char(5) NOT NULL

	CONSTRAINT PK_PaymentRecord
	PRIMARY KEY(payment_id)
)

CREATE TABLE PaymentMethod
(
	payment_method_id char(5),
	payment_method_title nvarchar(15) NOT NULL UNIQUE,

	CONSTRAINT PK_paymentmethod
	PRIMARY KEY(payment_method_id)
)


--table PRESCRIPTION
CREATE TABLE Prescription
(
	drug_id char(5),
	treatment_plan_id char(5),
	drug_quantity int NOT NULL Check (drug_quantity>=1),
	drug_cost float

	CONSTRAINT PK_Prescription
	PRIMARY KEY(treatment_plan_id, drug_id)
)

--table DRUG 
CREATE TABLE Drug
(
	drug_id char(5),
	drug_name nvarchar(30) NOT NULL,
	indication nvarchar(50) NOT NULL,
	expiration_date date NOT NULL,
	drug_price float NOT NULL,
	drug_quantity int

	CONSTRAINT PK_Drug
	PRIMARY KEY (drug_id)
)

CREATE TABLE DrugAllergy
(
	patient_id char(5),
	drug_id char(5),
	drugallergy_description nvarchar(50)

	CONSTRAINT PK_DrugAllergy
	PRIMARY KEY(patient_id, drug_id)
)

CREATE TABLE Contradication
(
	patient_id char(5),
	drug_id char(5),
	contradication_description nvarchar(50)

	CONSTRAINT PK_Contradication
	PRIMARY KEY(patient_id, drug_id)
)


CREATE TABLE DefaultDentist
(
	patient_id char(5),
	dentist_id char(3)

	CONSTRAINT PK_DefaultDentist
	PRIMARY KEY(patient_id, dentist_id)
)

----rang buoc
ALTER TABLE DefaultDentist
ADD
	CONSTRAINT FK_DefaultDentist_Patient
	FOREIGN KEY (patient_id)
	REFERENCES Patient,
	CONSTRAINT FK_DefaultDentist_Dentist
	FOREIGN KEY (dentist_id)
	REFERENCES Dentist

ALTER TABLE Employee
ADD
	CONSTRAINT FK_Employee_Branch
	FOREIGN KEY (branch_id)
	REFERENCES Branch,
	CONSTRAINT FK_Employee_Account
	FOREIGN KEY (account_id)
	REFERENCES Account

ALTER TABLE Dentist
ADD
	CONSTRAINT FK_Dentist_employee
	FOREIGN KEY (dentist_id)
	REFERENCES Employee(employee_id)
ALTER TABLE Nurse
ADD
	CONSTRAINT FK_Nurse_employee
	FOREIGN KEY (nurse_id)
	REFERENCES Employee

ALTER TABLE personalAppointment
ADD
	CONSTRAINT FK_personalAppointment_Dentist
	FOREIGN KEY (dentist_id)
	REFERENCES Dentist,
	CONSTRAINT FK_personalAppointment_Room
	FOREIGN KEY (room_id)
	REFERENCES Room

ALTER TABLE Appointment
ADD
	CONSTRAINT FK_Appointment_Patient
	FOREIGN KEY (patient_id)
	REFERENCES Patient,

	CONSTRAINT FK_Appointment_Dentist
	FOREIGN KEY (dentist_id)
	REFERENCES Dentist,

	CONSTRAINT FK_Appointment_Nurse
	FOREIGN KEY (nurse_id)
	REFERENCES Nurse

ALTER TABLE RefferalLetter
ADD
	CONSTRAINT FK_RefferalLetter_Appointment
	FOREIGN KEY (appointment_id)
	REFERENCES Appointment

ALTER TABLE ReExamination
ADD
	CONSTRAINT FK_ReExamination_Appointment
	FOREIGN KEY (appointment_id)
	REFERENCES Appointment, 
	CONSTRAINT FK_ReExamination_TreatmentPlan
	FOREIGN KEY (treatment_plan_id)
	REFERENCES TreatmentPlan

ALTER TABLE GeneralHealth
ADD
	CONSTRAINT FK_GeneralHealth_Patient
	FOREIGN KEY (patient_id)
	REFERENCES Patient

ALTER TABLE DrugAllergy
ADD
	CONSTRAINT FK_DrugAllergy_Patient
	FOREIGN KEY (patient_id)
	REFERENCES Patient,
	CONSTRAINT FK_DrugAllergy_Drug 
	FOREIGN KEY (drug_id)
	REFERENCES Drug

ALTER TABLE Contradication
ADD
	CONSTRAINT FK_Contradication_Patient
	FOREIGN KEY (patient_id)
	REFERENCES Patient,
	CONSTRAINT FK_Contradication_Drug 
	FOREIGN KEY (drug_id)
	REFERENCES Drug

ALTER TABLE Prescription
ADD
	CONSTRAINT FK_Prescription_Drug
	FOREIGN KEY (drug_id)
	REFERENCES Drug,

	CONSTRAINT FK_Prescription_treatmentsession
	FOREIGN KEY (treatment_plan_id)
	REFERENCES TreatmentPlan

ALTER TABLE TreatmentPlan
ADD
	CONSTRAINT FK_TreatmentPlan_Patient
	FOREIGN KEY (patient_id)
	REFERENCES Patient,

	CONSTRAINT FK_TreatmentPlan_Dentist
	FOREIGN KEY (dentist_id)
	REFERENCES Dentist,

	CONSTRAINT FK_TreatmentPlan_Nurse
	FOREIGN KEY (nurse_id)
	REFERENCES Nurse,

	CONSTRAINT FK_TreatmentPlan_Treatment
	FOREIGN KEY (treatment_id)
	REFERENCES Treatment

ALTER TABLE TreatmentSession
ADD
	CONSTRAINT FK_TreatmentSession_TreatmentPlan
	FOREIGN KEY (treatment_plan_id)
	REFERENCES TreatmentPlan

ALTER TABLE PaymentRecord
ADD
	CONSTRAINT FK_PaymentRecord_TreatmentSession
	FOREIGN KEY (treatment_plan_id)
	REFERENCES TreatmentPlan,
	CONSTRAINT FK_PaymentRecord_PaymentMethod
	FOREIGN KEY (payment_method_id)
	REFERENCES PaymentMethod

ALTER TABLE ToothSelection
ADD
	CONSTRAINT FK_ToothSelection_TreatmentPlan
	FOREIGN KEY (treatment_plan_id)
	REFERENCES TreatmentPlan,

	CONSTRAINT FK_ToothSelection_ToothSurface
	FOREIGN KEY (tooth_surface_code)
	REFERENCES ToothSurface,

	CONSTRAINT FK_ToothSelection_ToothPosition
	FOREIGN KEY (tooth_position_id)
	REFERENCES ToothPosition

ALTER TABLE TreatmentTooth
ADD
	CONSTRAINT FK_TreatmentTooth_Treatment
	FOREIGN KEY (treatment_id)
	REFERENCES Treatment,

	CONSTRAINT FK_TreatmentTooth_ToothPosition
	FOREIGN KEY (tooth_position_id)
	REFERENCES ToothPosition

