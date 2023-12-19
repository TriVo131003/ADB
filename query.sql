--Câu truy vấn xác minh tài khoản , mật khẩu đăng nhập và xác định tên , loại người dùng
CREATE PROCEDURE VerifyLogin(
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
CREATE PROCEDURE FindCustomerAppointments
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
--Câu truy vấn xem danh sách nha sĩ
go
CREATE PROCEDURE ListDentists
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
--Câu truy vấn xem danh sách nha sĩ và người làm việc , cuộc hẹn của nha sĩ đó

--Câu truy vấn xem chi tiết nha sĩ
go
CREATE PROCEDURE GetDentistDetails
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
CREATE PROCEDURE GetEmployeeListByBranch
(
  @branchID char(2)
)
AS
BEGIN
  SELECT *
  FROM Employee
  WHERE branch_id = @branchID;
END
--Câu truy vấn xem chi tiết nhân viên
go
CREATE PROCEDURE GetEmployeeDetails
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

--Câu truy vấn xem danh sách cuộc hẹn

--Câu truy vấn xem chi tiết cuộc hẹn
--Câu truy vấn xem cuộc hẹn của Customer
--Câu truy vấn xem chi tiết liệu trình
--Câu truy vấn xem chi tiết hóa đơn
--Câu truy vấn xem danh sách răng đã khám và ghi trong hóa đơn
--Câu truy vấn xem chi tiết thuốc trong hóa đơn
--Câu truy vấn xem dị ứng của bệnh nhân
--Câu truy vấn xem chống chỉ định thuốc của bệnh nhân
--Câu truy vấn xem danh sách thuốc
