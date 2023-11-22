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
	[password] varchar(20),
	account_status bit

	CONSTRAINT PK_Account
	PRIMARY KEY (accountID)
)

--table ACCOUNT
CREATE TABLE Employee
(
	employee_id char(5),
	employee_name nvarchar(30),
	employee_gender nvarchar(3),
	employee_birthday date,
	employee_address nvarchar(30),
	employee_national_id char(12),
	employee_phone char(10),
	employee_type varchar(6),
	branch_id char(3),
	account_id char(5)

	CONSTRAINT PK_Employee
	PRIMARY KEY (employee_id)
)
--table ADMIN
CREATE TABLE [Admin]
(
	admin_id char(5)
	CONSTRAINT PK_Admin
	PRIMARY KEY(admin_id)
)

--table STAFF
CREATE TABLE Staff
(
	staff_id char(5),

	CONSTRAINT PK_Staff
	PRIMARY KEY(staff_id)
)

--table DENTIST
CREATE TABLE Dentist
(
	dentist_id char(5),

	CONSTRAINT PK_Dentist
	PRIMARY KEY(dentist_id)
)

--table Nurse
CREATE TABLE Nurse
(
	nurse_id char(5),

	CONSTRAINT PK_Nurse
	PRIMARY KEY(nurse_id)
)

--table Branch
CREATE TABLE Branch
(
	branch_id char(3),
	branch_name nvarchar(20),
	branch_address nvarchar(30),
	branch_phone char(10)

	CONSTRAINT PK_branch
	PRIMARY KEY(branch_id)
)

--table PersionalAppointment
CREATE TABLE PersionalAppointment
(
	persional_appointment_id char(5),
	persional_appointment_date date,
	room_id char(2),
	dentist_id char(5)

	CONSTRAINT PK_PersionalAppointment
	PRIMARY KEY(persional_appointment_id)
)

--table Room
CREATE TABLE Room
(
	room_id char(2),
	room_name nvarchar(20),

	CONSTRAINT PK_Room
	PRIMARY KEY(room_id)
)

--table PATIENT
CREATE TABLE Patient
(
	patient_id char(5),
	patient_name nvarchar(30),
	patient_birthday DATE,
	patient_address nvarchar(40),
	patient_phone char(10),
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
	health_description nvarchar(30)

	CONSTRAINT PK_generalhealth
	PRIMARY KEY(patient_id, note_date)
)

--table APPOINTMENT
CREATE TABLE Appointment
(
	appointment_id char(5),
	request_time datetime,
	appointment_confirm nvarchar(10),
	appointment_date date,
	appointment_time time,
	appointment_duration int,
	appointment_state bit,
	numerical_order char(3),
	room_id char(2),
	is_new_patient bit,
	patient_id char(5),
	dentist_id char(5),
	nurse_id char(5)

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
	treatment_selection_id char(5)

	CONSTRAINT PK_Reexamination
	PRIMARY KEY(re_examination_id)
)

--table select treatment
CREATE TABLE TreatmentSelection
(
	treatment_selection_id char(5),
	treatment_selection_created_date datetime, 
	treatment_selection_note nvarchar(30),
	treatment_selection_description nvarchar(50),
	treatment_id char(2),
	patient_id char(5),
	dentist_id char(5),
	nurse_id char(5),
	CONSTRAINT PK_TreatmentSelection
	PRIMARY KEY(treatment_selection_id)
)

--table session treatment
CREATE TABLE TreatmentSession
(
	treatment_session_id char(5),
	treatment_session_created_date datetime, 
	treatment_session_description nvarchar(50),
	treatment_selection_id char(5)

	CONSTRAINT PK_TreatmentSession
	PRIMARY KEY(treatment_session_id)
)

CREATE TABLE TreatmentTooth
(
	treatment_selection_id char(5),
	tooth_position_id char(2),
	tooth_surface_code char(1),
	treatment_tooth_price float

	CONSTRAINT PK_TreatmentTooth
	PRIMARY KEY(treatment_selection_id, tooth_position_id, tooth_surface_code)
)

CREATE TABLE ToothPrice
(
	tooth_position_id char(2),
	treatment_id char(2),
	tooth_price float

	CONSTRAINT PK_ToothPrice
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
	tooth_position_type nvarchar(15),
	tooth_position_description nvarchar(30),

	CONSTRAINT PK_Toothposition
	PRIMARY KEY(tooth_position_id)
)

CREATE TABLE Treatment
(
	treatment_id char(2),
	treatment_title nvarchar(15),
	treatment_description nvarchar(30),
	treatment_cost float

	CONSTRAINT PK_Treatment
	PRIMARY KEY(treatment_id)
)

CREATE TABLE PaymentRecord
(
	payment_id char(5),
	paid_time datetime,
	paid_money float,
	excess_money float,
	total_cost float,
	payment_note nvarchar(15),
	payment_method_id char(5),
	treatment_session_id char(5)

	CONSTRAINT PK_PaymentRecord
	PRIMARY KEY(payment_id)
)

CREATE TABLE PaymentMethod
(
	payment_method_id char(5),
	payment_method_title nvarchar(15)

	CONSTRAINT PK_paymentmethod
	PRIMARY KEY(payment_method_id)
)


--table PRESCRIPTION
CREATE TABLE Prescription
(
	drug_id char(5),
	treatment_session_id char(5),
	drug_quantity int NOT NULL Check (drug_quantity>=1)

	CONSTRAINT PK_Prescription
	PRIMARY KEY(treatment_session_id, drug_id)
)

--table DRUG 
CREATE TABLE Drug
(
	drug_id char(5),
	drug_name nvarchar(30),
	indication nvarchar(50),
	expiration_date date,
	drug_price money,
	drug_quantity int

	CONSTRAINT PK_Drug
	PRIMARY KEY (drug_id)
)

CREATE TABLE DrugAllergy
(
	patient_id char(5),
	drug_id char(5)

	CONSTRAINT PK_DrugAllergy
	PRIMARY KEY(patient_id, drug_id)
)

CREATE TABLE Contradication
(
	patient_id char(5),
	drug_id char(5)

	CONSTRAINT PK_Contradication
	PRIMARY KEY(patient_id, drug_id)
)

----rang buoc
ALTER TABLE Employee
ADD
	CONSTRAINT FK_Employee_Branch
	FOREIGN KEY (branch_id)
	REFERENCES Branch,
	CONSTRAINT FK_Employee_Account
	FOREIGN KEY (employee_id)
	REFERENCES Account

ALTER TABLE [Admin]
ADD
	CONSTRAINT FK_Admin_employee
	FOREIGN KEY (admin_id)
	REFERENCES Employee(employee_id)
ALTER TABLE Staff
ADD
	CONSTRAINT FK_Staff_employee
	FOREIGN KEY (staff_id)
	REFERENCES Employee(employee_id)
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

ALTER TABLE PersionalAppointment
ADD
	CONSTRAINT FK_PersionalAppointment_Dentist
	FOREIGN KEY (dentist_id)
	REFERENCES Dentist,
	CONSTRAINT FK_PersionalAppointment_Room
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
	CONSTRAINT FK_ReExamination_TreatmentSelection
	FOREIGN KEY (treatment_selection_id)
	REFERENCES Appointment

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
	FOREIGN KEY (treatment_session_id)
	REFERENCES TreatmentSession

ALTER TABLE TreatmentSelection
ADD
	CONSTRAINT FK_TreatmentSelection_Patient
	FOREIGN KEY (patient_id)
	REFERENCES Patient,

	CONSTRAINT FK_TreatmentSelection_Dentist
	FOREIGN KEY (dentist_id)
	REFERENCES Dentist,

	CONSTRAINT FK_TreatmentSelection_Nurse
	FOREIGN KEY (nurse_id)
	REFERENCES Nurse,

	CONSTRAINT FK_TreatmentSelection_Treatment
	FOREIGN KEY (treatment_id)
	REFERENCES Treatment

ALTER TABLE TreatmentSession
ADD
	CONSTRAINT FK_TreatmentSession_Treatmentselection
	FOREIGN KEY (treatment_selection_id)
	REFERENCES TreatmentSelection

ALTER TABLE PaymentRecord
ADD
	CONSTRAINT FK_PaymentRecord_TreatmentSession
	FOREIGN KEY (treatment_session_id)
	REFERENCES TreatmentSession,
	CONSTRAINT FK_PaymentRecord_PaymentMethod
	FOREIGN KEY (payment_method_id)
	REFERENCES PaymentMethod

ALTER TABLE TreatmentTooth
ADD
	CONSTRAINT FK_TreatmentTooth_TreatmentSelection
	FOREIGN KEY (treatment_selection_id)
	REFERENCES TreatmentSelection,

	CONSTRAINT FK_TreatmentTooth_ToothSurface
	FOREIGN KEY (tooth_surface_code)
	REFERENCES ToothSurface,

	CONSTRAINT FK_TreatmentTooth_ToothPosition
	FOREIGN KEY (tooth_position_id)
	REFERENCES ToothPosition

ALTER TABLE ToothPrice
ADD
	CONSTRAINT FK_ToothPrice_Treatment
	FOREIGN KEY (treatment_id)
	REFERENCES Treatment,

	CONSTRAINT FK_ToothPrice_ToothPosition
	FOREIGN KEY (tooth_position_id)
	REFERENCES ToothPosition


