use QLPHONGKHAM
go

--Câu truy vấn xác minh tài khoản , mật khẩu đăng nhập và xác định tên , loại người dùng
CREATE OR ALTER PROCEDURE VerifyLogin(
    @username VARCHAR(20),
    @password VARCHAR(64)
)
AS
BEGIN
    SELECT
        e.employee_id,
        e.employee_name,
        e.employee_type,
        a.accountID
    FROM Account a JOIN Employee e ON a.accountID = e.account_id
    WHERE a.username = @username AND a.password = @password
        AND a.account_status = 1
END
--Câu truy vấn tìm cuộc hẹn của Customer
go
CREATE OR ALTER PROCEDURE FindCustomerAppointments
(
  @customerID char(5)
)
AS
BEGIN
  SELECT A.appointment_id, A.request_time, A.appointment_confirm, A.appointment_date,
         A.appointment_time, A.appointment_state, A.numerical_order, A.room_id,
         A.is_new_patient, A.patient_id, A.dentist_id, A.nurse_id
  FROM Appointment A
  JOIN Patient P ON A.patient_id = P.patient_id
  WHERE P.patient_id = @customerID
END
go
--Câu truy vấn xem danh sách nha sĩ
CREATE OR ALTER PROCEDURE ListDentists
(
	@branch_id char(2)
)
AS
BEGIN
  SELECT E.employee_name, E.employee_id
  FROM Dentist D
  JOIN Employee E ON D.dentist_id = E.employee_id JOIN Branch b on b.branch_id = E.branch_id
  where b.branch_id = @branch_id
END
go

--Câu truy vấn xem danh sách nha sĩ và người làm việc , cuộc hẹn của nha sĩ đó
Create or alter Proc DentistApp 
as
	begin
		select emp.employee_name as DentistName, nur.employee_name as NurseName, app.appointment_time, app.appointment_date
		from Appointment app join Employee emp on emp.employee_id = dentist_id join Employee nur on nur.employee_id = app.nurse_id
		where emp.employee_type = 'DE'
		Order by dentist_id, appointment_date DESC, app.appointment_time DESC
	end
go
--Câu truy vấn xem chi tiết nha sĩ
CREATE OR ALTER PROCEDURE GetDentistDetails
(
  @dentistID char(3)
)
AS
BEGIN
  SELECT *
  FROM Dentist D JOIN Employee E ON D.dentist_id = E.employee_id
  WHERE D.dentist_id = @dentistID;
END
--Câu truy vấn xem danh sách nhân viên
go
CREATE OR ALTER PROCEDURE GetEmployeeListByBranch
(
  @branchID char(2)
)
AS
BEGIN
  SELECT *
  FROM Employee
  WHERE branch_id = @branchID;
END
go

--Câu truy vấn xem chi tiết nhân viên
CREATE OR ALTER PROCEDURE GetEmployeeDetails
(
  @employeeID char(3)
)
AS
BEGIN
  SELECT E.employee_id, E.employee_name, E.employee_gender, E.employee_birthday, E.employee_address,
         E.employee_national_id, E.employee_phone, E.employee_type, E.branch_id
  FROM Employee E
  WHERE E.employee_id = @employeeID;
END
go

--Câu truy vấn xem danh sách cuộc hẹn
CREATE OR ALTER PROCEDURE GetAppointment
AS
BEGIN
  SELECT de.employee_name as DentistName, nur.employee_name as NurseName, pa.patient_name, app.appointment_date, app.numerical_order
  FROM Appointment app join Patient pa on pa.patient_id = app.patient_id join Employee de on de.employee_id = app.dentist_id join Employee nur on nur.employee_id = app.nurse_id
  Order by app.appointment_id
END
go

--Câu truy vấn xem chi tiết cuộc hẹn
CREATE OR ALTER PROCEDURE GetAppointmentDetailed
(
  @appointmentID char(5)
)
AS
BEGIN
  SELECT de.employee_name as DentistName, nur.employee_name as NurseName, pa.patient_name, app.appointment_date, app.numerical_order
  FROM Appointment app join Patient pa on pa.patient_id = app.patient_id join Employee de on de.employee_id = app.dentist_id join Employee nur on nur.employee_id = app.nurse_id
  where app.appointment_id= @appointmentID
  Order by app.appointment_id
END
go

--Câu truy vấn xem cuộc hẹn của bệnh nhân
CREATE OR ALTER PROCEDURE GetPatientAppointment
(
  @patientID char(5)
)
AS
BEGIN
  SELECT de.employee_name as DentistName, nur.employee_name as NurseName, pa.patient_name, app.appointment_date, app.numerical_order
  FROM Appointment app join Patient pa on pa.patient_id = app.patient_id join Employee de on de.employee_id = app.dentist_id join Employee nur on nur.employee_id = app.nurse_id
  where app.patient_id = @patientID
  Order by app.appointment_id
END
go

--Câu truy vấn xem chi tiết liệu trình
CREATE OR ALTER PROC GetTreatmentSession (@treatmentplanid char(5))
as
begin
	select *
	from TreatmentPlan tp join TreatmentSession ts on tp.treatment_plan_id = ts.treatment_plan_id
	where tp.treatment_plan_id = @treatmentplanid
end
go

--Câu truy vấn xem chi tiết hóa đơn
CREATE OR ALTER PROC GetPaymentDetail (@payment_id char(5))
as
begin
	select * 
	from PaymentRecord pay 
	where @payment_id = pay.payment_id
end
go

--Câu truy vấn xem danh sách răng đã khám và ghi trong hóa đơn
CREATE OR ALTER PROC GetToothInPayment (@payment_id char(5))
as
begin
	select pay.payment_id, pos.tooth_position_type, pos.tooth_position_description, sur.tooth_surface_title, pay.total_cost
	from PaymentRecord pay join ToothSelection ts on pay.treatment_plan_id = ts.treatment_plan_id join ToothPosition pos on pos.tooth_position_id = ts.tooth_position_id join ToothSurface sur on sur.tooth_surface_code = ts.tooth_surface_code
	where @payment_id = pay.payment_id
end
go

--Câu truy vấn xem chi tiết thuốc trong hóa đơn
CREATE OR ALTER PROC GetMedicineInPayment (@payment_id char(5))
as
begin
	select pay.payment_id, dr.drug_name, dr.drug_price, dr.expiration_date, dr.indication
	from PaymentRecord pay join  Prescription pre on pre.treatment_plan_id = pay.treatment_plan_id join Drug dr on dr.drug_id = pre.drug_id
	where @payment_id = pay.payment_id
end
go

--Câu truy vấn xem dị ứng của bệnh nhân
CREATE OR ALTER PROC GetAllergyDetail (@patiant_id char(5))
as
begin
	select pa.patient_name, dr.drug_name, allergy.drugallergy_description
	from DrugAllergy allergy join Drug dr on dr.drug_id = allergy.drug_id join Patient pa on pa.patient_id = allergy.patient_id
	where allergy.patient_id = @patiant_id
end
go

--Câu truy vấn xem chống chỉ định thuốc của bệnh nhân
CREATE OR ALTER PROC GetContradicationDetail (@patiant_id char(5))
as
begin
	select pa.patient_name, dr.drug_name, con.contradication_description
	from Contradication con join Drug dr on dr.drug_id = con.drug_id join Patient pa on pa.patient_id = con.patient_id
	where con.patient_id = @patiant_id
end
go

--Câu truy vấn xem danh sách thuốc
create or alter proc GetMedicine
as
begin
	select drug_id, drug_name, drug_quantity, drug_price, expiration_date, indication
	from Drug
end
go