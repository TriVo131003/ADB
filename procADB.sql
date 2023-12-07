



go
CREATE or alter PROCEDURE AddPrescription(
  @treatment_plan_id char(5),
  @drug_id char(5),
  @drug_quantity int
)
AS
BEGIN
  IF NOT EXISTS (SELECT * FROM Drug WHERE drug_id = @drug_id)
  BEGIN
    RAISERROR(N'Thuốc không tồn tại.', 16, 1);
    RETURN;
  END

  IF NOT EXISTS (SELECT * FROM TreatmentPlan WHERE treatment_plan_id = @treatment_plan_id)
  BEGIN
    RAISERROR(N'Buổi điều trị không tồn tại.', 16, 1);
    RETURN;
  END

  DECLARE @expiryDate date;
  SELECT @expiryDate = expiration_date FROM Drug WHERE drug_id = @drug_id;
  IF @expiryDate < GETDATE()
  BEGIN
    RAISERROR(N'Thuốc đã hết hạn.', 16, 1, @drug_id);
    RETURN;
  END

	DECLARE @drug_cost Float
	select @drug_cost = @drug_quantity * (select drug_price from Drug)
  -- Insert prescription and quantity
  INSERT INTO Prescription (
    treatment_plan_id,
    drug_id,
    drug_quantity,
	drug_cost
  )
  VALUES (
    @treatment_plan_id,
    @drug_id,
    @drug_quantity,
	@drug_cost
  );
END;

GO
CREATE PROCEDURE insertDrugAllergy
	@patient_id CHAR(5),
	@drug_id CHAR(5)
AS
BEGIN
    IF NOT EXISTS (SELECT * FROM Patient WHERE patient_id = @patient_id)
    BEGIN
        RAISERROR(N'Bệnh nhân không tồn tại', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT * FROM Drug WHERE drug_id = @drug_id)
    BEGIN
        RAISERROR('Thuốc không tồn tại', 16, 1);
        RETURN;
    END

    INSERT INTO DrugAllergy (patient_id, drug_id)
    VALUES (@patient_id, @drug_id);
END

GO
CREATE PROCEDURE insertContradiction
@patient_id CHAR(5),
@drug_id CHAR(5),
@description NVARCHAR(50)
AS
BEGIN
    IF NOT EXISTS (SELECT * FROM Patient WHERE patient_id = @patient_id)
    BEGIN
        RAISERROR(N'Bệnh nhân không tồn tại', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT * FROM Drug WHERE drug_id = @drug_id)
    BEGIN
        RAISERROR('Thuốc không tồn tại', 16, 1);
        RETURN;
    END

    INSERT INTO Contradication (patient_id, drug_id, contradication_description)
    VALUES (@patient_id, @drug_id, @description);
END

GO
CREATE PROCEDURE updateContradiction
	@patient_id CHAR(5),
	@drug_id CHAR(5),
	@description NVARCHAR(50)
AS
BEGIN
    IF NOT EXISTS (SELECT * FROM Patient WHERE patient_id = @patient_id)
    BEGIN
        RAISERROR(N'Bệnh nhân không tồn tại', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT * FROM Drug WHERE drug_id = @drug_id)
    BEGIN
        RAISERROR('Thuốc không tồn tại', 16, 1);
        RETURN;
    END

	Update Contradication 
	set contradication_description = @description
	where patient_id = @patient_id and drug_id = @drug_id
END

GO
CREATE PROCEDURE updateDrugAllergy
	@patient_id CHAR(5),
	@drug_id CHAR(5),
	@description NVARCHAR(50)
AS
BEGIN
    IF NOT EXISTS (SELECT * FROM Patient WHERE patient_id = @patient_id)
    BEGIN
        RAISERROR(N'Bệnh nhân không tồn tại', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT * FROM Drug WHERE drug_id = @drug_id)
    BEGIN
        RAISERROR('Thuốc không tồn tại', 16, 1);
        RETURN;
    END

	Update DrugAllergy
	set drugallergy_description = @description
	where patient_id = @patient_id and drug_id = @drug_id
END

GO
CREATE PROCEDURE deleteContradiction
	@patient_id CHAR(5),
	@drug_id CHAR(5)
AS
BEGIN
    IF NOT EXISTS (SELECT * FROM Patient WHERE patient_id = @patient_id)
    BEGIN
        RAISERROR(N'Bệnh nhân không tồn tại', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT * FROM Drug WHERE drug_id = @drug_id)
    BEGIN
        RAISERROR('Thuốc không tồn tại', 16, 1);
        RETURN;
    END

    DELETE FROM Contradication
    WHERE patient_id = @patient_id AND drug_id = @drug_id;
END

GO
CREATE PROCEDURE deleteDrugAllergy
	@patient_id CHAR(5),
	@drug_id CHAR(5)
AS
BEGIN
    IF NOT EXISTS (SELECT * FROM Patient WHERE patient_id = @patient_id)
    BEGIN
        RAISERROR(N'Bệnh nhân không tồn tại', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT * FROM Drug WHERE drug_id = @drug_id)
    BEGIN
        RAISERROR('Thuốc không tồn tại', 16, 1);
        RETURN;
    END

    DELETE FROM DrugAllergy
    WHERE patient_id = @patient_id AND drug_id = @drug_id;
END

go
CREATE PROCEDURE insertAccount
	@username varchar(10),
	@password varchar(15)
AS
BEGIN
	IF EXISTS((SELECT * FROM Account WHERE username = @username))
	BEGIN
        RAISERROR(N'Tên tài khoản đã tồn tại', 16, 1)
		ROLLBACK
		RETURN
    END
	DECLARE @new_account_id char(5);
	IF NOT EXISTS (SELECT * FROM Account)
    BEGIN
        SET @new_account_id = '00001';
    END
    ELSE

    BEGIN
		SELECT @new_account_id = RIGHT('00000' + CAST(CAST(SUBSTRING((SELECT MAX(accountID) from Account), 2, 4) AS INT) + 1 AS VARCHAR(5)), 5)
	END

	INSERT INTO Account (
	accountID,
	username,
	password,
	account_status
	)
	VALUES
	(@new_account_id, @username, @password, 1
	);
END;

go
CREATE PROCEDURE updateAccount
	@accountId char(5),
	@password varchar(15),
	@accountStatus BIT
AS
BEGIN
	IF NOT EXISTS((SELECT * FROM Account WHERE accountID = @accountId))
	BEGIN
        RAISERROR(N'Tên tài khoản không tồn tại', 16, 1)
		RETURN
    END
	UPDATE Account
	SET password = @password,
	account_status = @accountStatus
	WHERE accountID = @accountId;
END;

go
CREATE PROCEDURE InsertAppointment
(
    @request_time datetime,
    @appointment_date date,
    @appointment_time time,
    @appointment_duration int,
    @room_id char(2),
    @is_new_patient bit,
    @patient_id char(5),
    @dentist_id char(3),
    @nurse_id char(3)
)
AS
BEGIN
    -- Check if appointment ID already exists
    IF NOT EXISTS (SELECT * FROM Patient WHERE patient_id = @patient_id)
		RAISERROR('Bệnh nhân không tồn tại', 16, 1)
		RETURN
	IF NOT EXISTS (SELECT * FROM Dentist WHERE dentist_id = @dentist_id)
		RAISERROR('Nha sĩ không tồn tại', 16, 1)
		RETURN
	IF @nurse_id is not null
	BEGIN
		IF NOT EXISTS (SELECT * FROM Nurse WHERE @nurse_id = nurse_id)
		RAISERROR('Trợ khám không tồn tại', 16, 1)
		RETURN
	END

	DECLARE @new_appointment_id char(5);

	IF NOT EXISTS (SELECT * FROM Appointment)
    BEGIN
        SET @new_appointment_id = '00001';
    END
    ELSE
    BEGIN
		SELECT @new_appointment_id = RIGHT('00000' + CAST(CAST(SUBSTRING((SELECT MAX(appointment_id) from Appointment), 2, 4) AS INT) + 1 AS VARCHAR(5)), 5)
	END

    -- Insert new appointment data
    INSERT INTO Appointment
    (
        appointment_id,
        request_time,
        appointment_confirm,
        appointment_date,
        appointment_time,
        appointment_duration,
        appointment_state,
        numerical_order,
        room_id,
        is_new_patient,
        patient_id,
        dentist_id,
        nurse_id
    )
    VALUES
    (
        @new_appointment_id,
        @request_time,
        0,
        @appointment_date,
        @appointment_time,
        @appointment_duration,
        0,
		DATEDIFF(MINUTE, '08:00:00', @appointment_time)/30 + 1,
        @room_id,
        @is_new_patient,
        @patient_id,
        @dentist_id,
        @nurse_id
    );
END;

go
CREATE PROCEDURE UpdateAppointment
(
    @appointment_id char(5),
	@request_time datetime,
    @appointment_date date,
    @appointment_time time,
    @appointment_duration int,
    @room_id char(2),
    @is_new_patient bit,
    @patient_id char(5),
    @dentist_id char(3),
    @nurse_id char(3)
)
AS
BEGIN
	IF NOT EXISTS (SELECT * FROM Appointment WHERE appointment_id = @appointment_id)
		RAISERROR('Cuộc hẹn không tồn tại', 16, 1)
		RETURN
	IF NOT EXISTS (SELECT * FROM Patient WHERE patient_id = @patient_id)
		RAISERROR('Bệnh nhân không tồn tại', 16, 1)
		RETURN
	IF NOT EXISTS (SELECT * FROM Dentist WHERE dentist_id = @dentist_id)
		RAISERROR('Nha sĩ không tồn tại', 16, 1)
		RETURN
	IF @nurse_id is not null
	BEGIN
		IF NOT EXISTS (SELECT * FROM Nurse WHERE @nurse_id = nurse_id)
		RAISERROR('Trợ khám không tồn tại', 16, 1)
		RETURN
	END 
    -- Update appointment data
    UPDATE Appointment
    SET
        request_time = @request_time,
        appointment_date = @appointment_date,
        appointment_time = @appointment_time,
        appointment_duration = @appointment_duration,
        room_id = @room_id,
        is_new_patient = @is_new_patient,
        patient_id = @patient_id,
        dentist_id = @dentist_id,
        nurse_id = @nurse_id
    WHERE appointment_id = @appointment_id;
END;

go
CREATE PROCEDURE updateGeneralHealth
(
    @patient_id char(5),
	@note_date datetime,
    @health_description nvarchar(30)
)
AS
BEGIN
    -- Check if patient ID exists
    DECLARE @existing_patient_id char(5);

    SELECT @existing_patient_id = patient_id
    FROM Patient
    WHERE patient_id = @patient_id;

    IF @existing_patient_id IS NULL
    BEGIN
        RAISERROR('Bệnh nhân không tồn tại', 16, 1)
        RETURN;
    END

    -- Update general health data
    UPDATE GeneralHealth
    SET
        health_description = @health_description
    WHERE patient_id = @patient_id AND note_date = @note_date;
END;

GO
CREATE PROCEDURE insertGeneralHealth
(
    @patient_id char(5),
    @note_date datetime,
    @health_description nvarchar(30)
)
AS
BEGIN
    -- Check if patient ID exists
    DECLARE @existing_patient_id char(5);

    SELECT @existing_patient_id = patient_id
    FROM Patient
    WHERE patient_id = @patient_id;

    IF @existing_patient_id IS NULL
    BEGIN
        RAISERROR('Bệnh nhân không tồn tại', 16, 1)
        RETURN;
    END

    -- Insert general health data
    INSERT INTO GeneralHealth
    (
        patient_id,
        note_date,
        health_description
    )
    VALUES
    (
        @patient_id,
        @note_date,
        @health_description
    );
END;

go
CREATE PROCEDURE updateTreatmentPlan
(
    @treatment_plan_id char(5),
    @treatment_plan_created_date datetime,
    @treatment_plan_note nvarchar(30),
    @treatment_plan_description nvarchar(50),
    @treatment_plan_status nvarchar(15),
    @treatment_id char(2),
    @patient_id char(5),
    @dentist_id char(3),
    @nurse_id char(3)
)
AS
BEGIN
    -- Check if treatment plan ID exists
    DECLARE @existing_treatment_plan_id char(5);

    SELECT @existing_treatment_plan_id = treatment_plan_id
    FROM TreatmentPlan
    WHERE treatment_plan_id = @treatment_plan_id;

    IF @existing_treatment_plan_id IS NULL
    BEGIN
        RAISERROR('Mã kế hoạch điều trị không tồn tại', 16, 1)
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Patient WHERE patient_id = @patient_id)
    BEGIN
        RAISERROR('Bệnh nhân không tồn tại', 16, 1)
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Dentist WHERE dentist_id = @dentist_id)
    BEGIN
        RAISERROR('Nha sĩ không tồn tại', 16, 1)
        RETURN;
    END

    IF @nurse_id IS NOT NULL
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM Nurse WHERE nurse_id = @nurse_id)
        BEGIN
            RAISERROR('Trợ khám không tồn tại', 16, 1)
            RETURN;
        END
    END

    -- Update treatment plan data
    UPDATE TreatmentPlan
    SET
        treatment_plan_created_date = @treatment_plan_created_date,
        treatment_plan_note = @treatment_plan_note,
        treatment_plan_description = @treatment_plan_description,
        treatment_plan_status = @treatment_plan_status,
        treatment_id = @treatment_id,
        patient_id = @patient_id,
        dentist_id = @dentist_id,
        nurse_id = @nurse_id
    WHERE treatment_plan_id = @treatment_plan_id;
END;


go
CREATE PROCEDURE insertTreatmentPlan
(
    @treatment_plan_created_date datetime NOT NULL,
    @treatment_plan_note nvarchar(30),
    @treatment_plan_description nvarchar(50),
	@treatment_plan_status nvarchar(15),
    @treatment_id char(2) NOT NULL,
    @patient_id char(5) NOT NULL,
    @dentist_id char(3) NOT NULL,
    @nurse_id char(3)
)
AS
BEGIN
	Declare @new_treatmentplan_id char(5)
	IF NOT EXISTS (SELECT * FROM TreatmentPlan)
    BEGIN
        SET @new_treatmentplan_id= '00001';
    END
    ELSE
    BEGIN
		SELECT @new_treatmentplan_id = RIGHT('00000' + CAST(CAST(SUBSTRING((SELECT MAX(treatment_plan_id) from TreatmentPlan), 2, 4) AS INT) + 1 AS VARCHAR(5)), 5)
	END

    IF NOT EXISTS (SELECT 1 FROM Patient WHERE patient_id = @patient_id)
    BEGIN
        RAISERROR('Bệnh nhân không tồn tại', 16, 1)
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Dentist WHERE dentist_id = @dentist_id)
    BEGIN
        RAISERROR('Nha sĩ không tồn tại', 16, 1)
        RETURN;
    END

    IF @nurse_id IS NOT NULL
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM Nurse WHERE nurse_id = @nurse_id)
        BEGIN
            RAISERROR('Trợ khám không tồn tại', 16, 1)
            RETURN;
        END
    END

    -- Thêm dữ liệu
    INSERT INTO TreatmentPlan
    (
        treatment_plan_id,
        treatment_plan_created_date,
        treatment_plan_note,
        treatment_plan_description,
        treatment_plan_status,
        treatment_id,
        patient_id,
        dentist_id,
        nurse_id
    )
    VALUES
    (
        @new_treatmentplan_id,
        @treatment_plan_created_date,
        @treatment_plan_note,
        @treatment_plan_description,
        @treatment_plan_status,
        @treatment_id,
        @patient_id,
        @dentist_id,
        @nurse_id
    );
END;

go
CREATE PROCEDURE insertDrug
(
	@drugName nvarchar(30),
	@indication nvarchar(50),
	@expirationDate date,
	@price money,
	@drugStockQuantity int
)
AS
BEGIN
	DECLARE @new_drug_id char(5);
	IF NOT EXISTS (SELECT * FROM DRUG)
    BEGIN
        SET @new_drug_id = 'DR001';
    END
    ELSE
    BEGIN
		SET @new_drug_id = 'DR' + RIGHT('00000' + CAST(CAST(SUBSTRING((SELECT MAX(drug_id) FROM Drug), 3, 3) AS INT) + 1 AS VARCHAR(3)), 3)
	END

	INSERT INTO Drug (
	drug_id,
	drug_name,
	indication,
	expiration_date,
	drug_price,
	drug_quantity
	)
	VALUES
	(
	@new_drug_id,
	@drugName,
	@indication,
	@expirationDate,
	@price,
	@drugStockQuantity
	);
END;

go
CREATE PROCEDURE updateDrug
(
	@drugID char(5),
	@unit varchar(5),
	@drugName nvarchar(30),
	@indication nvarchar(50),
	@expirationDate date,
	@price money,
	@drugStockQuantity int
)
AS
BEGIN
	UPDATE Drug
	SET
	drug_name = @drugName,
	indication = @indication,
	expiration_date = @expirationDate,
	drug_price = @price,
	drug_quantity = @drugStockQuantity
	WHERE drug_id = @drugID;
END;

go
CREATE PROCEDURE deleteDrug
(
	@drugID char(5)
)
AS
BEGIN
	DELETE FROM Drug
	WHERE drug_id = @drugID;
END;

go
CREATE PROCEDURE InsertEmployee
(
	@employee_name nvarchar(30),
	@employee_gender nvarchar(3),
	@employee_birthday date,
	@employee_address nvarchar(30),
	@employee_national_id char(12),
	@employee_phone char(10),
	@employee_type varchar(6),
	@branch_id char(2),
	@account_id char(5)
)
AS
BEGIN
	DECLARE @new_employee_id char(5);
	IF NOT EXISTS (SELECT * FROM DRUG)
    BEGIN
        SET @new_employee_id = 'DR001';
    END
    ELSE
    BEGIN
		SET @new_employee_id = RIGHT('00000' + CAST(CAST(SUBSTRING((SELECT MAX(employee_id) from Employee), 2, 4) AS INT) + 1 AS VARCHAR(5)), 5)
	END
    -- Check if branch ID exists
    DECLARE @existing_branch_id char(2);

    SELECT @existing_branch_id = branch_id
    FROM Branch
    WHERE branch_id = @branch_id;

    IF @existing_branch_id IS NULL
    BEGIN
        RAISERROR('Chi nhánh không tồn tại', 16, 1)
        RETURN;
    END

    -- Check if account ID exists
    DECLARE @existing_account_id char(5);

    SELECT @existing_account_id = accountID
    FROM Account
    WHERE accountID = @account_id;

    IF @existing_account_id IS NULL
    BEGIN
        RAISERROR('Tài khoản không tồn tại', 16, 1)
        RETURN;
    END

    -- Insert data into Employee table
    INSERT INTO Employee
    (
        employee_id,
        employee_name,
        employee_gender,
        employee_birthday,
        employee_address,
        employee_national_id,
        employee_phone,
        employee_type,
        branch_id,
        account_id
    )
    VALUES
    (
        @new_employee_id,
        @employee_name,
        @employee_gender,
        @employee_birthday,
        @employee_address,
        @employee_national_id,
        @employee_phone,
        @employee_type,
        @branch_id,
        @account_id
    );
END;

go
CREATE PROCEDURE UpdateEmployee
(
	@employee_id char(3),
	@employee_address nvarchar(30),
	@employee_phone char(10),
	@employee_type varchar(6),
	@branch_id char(2)
)
AS
BEGIN
    -- Check if employee ID exists
    DECLARE @existing_employee_id char(3);

    SELECT @existing_employee_id = employee_id
    FROM Employee
    WHERE employee_id = @employee_id;

    IF @existing_employee_id IS NULL
    BEGIN
        RAISERROR('Nhân viên không tồn tại', 16, 1)
        RETURN;
    END

    -- Check if branch ID exists
    DECLARE @existing_branch_id char(2);

    SELECT @existing_branch_id = branch_id
    FROM Branch
    WHERE branch_id = @branch_id;

    IF @existing_branch_id IS NULL
    BEGIN
        RAISERROR('Chi nhánh không tồn tại', 16, 1)
        RETURN;
    END

    -- Update data in Employee table
    UPDATE Employee
    SET
        employee_address = @employee_address,
        employee_phone = @employee_phone,
        employee_type = @employee_type,
        branch_id = @branch_id
    WHERE employee_id = @employee_id;
END;

go
CREATE PROCEDURE insertPersonalAppointment
	@personalAppointmentStartTime time,
	@personalAppointmentEndTime time,
	@personalAppointmentDate date,
	@dentistID char(5)
AS
BEGIN
	DECLARE @new_personal_appointment_id char(5); 
	IF NOT EXISTS (SELECT * FROM PersonalAppointment)
	BEGIN
		SET @new_personal_appointment_id = '00001'
	END
	ELSE
	BEGIN
		SELECT @new_personal_appointment_id = RIGHT('00000' + CAST(CAST(SUBSTRING((SELECT MAX(personal_appointment_id) from personalAppointment), 2, 4) AS INT) + 1 AS VARCHAR(5)), 5)
	END
	
	INSERT INTO personalAppointment(
		personal_appointment_id,
		personal_appointment_start_time,
		personal_appointment_end_time,
		personal_appointment_date,
		dentist_id)
	VALUES
	(@new_personal_appointment_id,
	@personalAppointmentStartTime,
	@personalAppointmentEndTime,
	@personalAppointmentDate,
	@dentistID);
END;

go
CREATE PROCEDURE deletePersonalAppointment
	@personalAppointmentID char(5)
AS
BEGIN
DELETE FROM personalAppointment
WHERE personal_appointment_id = @personalAppointmentID;
END;

go
CREATE PROCEDURE updatePersonalAppointment
	@personalAppointmentID char(5),
	@personalAppointmentStartTime time,
	@personalAppointmentEndTime time,
	@personalAppointmentDate date,
	@dentistID char(5)
AS
BEGIN
	UPDATE personalAppointment
	SET personal_appointment_start_time = @personalAppointmentStartTime,
	personal_appointment_end_time = @personalAppointmentEndTime,
	personal_appointment_date = @personalAppointmentDate,
	dentist_id = @dentistID
	WHERE personal_appointment_id = @personalAppointmentID;
END;

go
CREATE PROCEDURE insertPatient
(
	@patient_name nvarchar(30) NOT NULL,
	@patient_birthday DATE,
	@patient_address nvarchar(40),
	@patient_phone char(10) NOT NULL,
	@patient_gender nvarchar(3),
	@patient_email varchar(20)
)
AS
BEGIN
   
   DECLARE @new_patient_id char(5); 
	IF NOT EXISTS (SELECT * FROM Patient)
	BEGIN
		SET @new_patient_id = '00001'
	END
	ELSE
	BEGIN
		SELECT @new_patient_id = RIGHT('00000' + CAST(CAST(SUBSTRING((SELECT MAX(patient_id) from Patient), 2, 4) AS INT) + 1 AS VARCHAR(5)), 5)
	END
    -- Insert data into Patient table
    INSERT INTO Patient
    (
        patient_id,
        patient_name,
        patient_birthday,
        patient_address,
        patient_phone,
        patient_gender,
        patient_email
    )
    VALUES
    (
        @new_patient_id,
        @patient_name,
        @patient_birthday,
        @patient_address,
        @patient_phone,
        @patient_gender,
        @patient_email
    );
END;

go
CREATE PROCEDURE epdatePatient
(
	@patient_id char(5),
	@patient_name nvarchar(30) NOT NULL,
	@patient_birthday DATE,
	@patient_address nvarchar(40),
	@patient_phone char(10) NOT NULL,
	@patient_gender nvarchar(3),
	@patient_email varchar(20)
)
AS
BEGIN
    -- Check if patient ID exists
    DECLARE @existing_patient_id char(5);

    SELECT @existing_patient_id = patient_id
    FROM Patient
    WHERE patient_id = @patient_id;

    IF @existing_patient_id IS NULL
    BEGIN
        RAISERROR('Bệnh nhân không tồn tại', 16, 1)
        RETURN;
    END

    -- Update data in Patient table
    UPDATE Patient
    SET
        patient_name = @patient_name,
        patient_birthday = @patient_birthday,
        patient_address = @patient_address,
        patient_phone = @patient_phone,
        patient_gender = @patient_gender,
        patient_email = @patient_email
    WHERE patient_id = @patient_id;
END;

go
CREATE PROCEDURE insertTreatmentSession
(
    @treatment_session_created_date datetime NOT NULL,
    @treatment_session_description nvarchar(50),
    @treatment_plan_id char(5) NOT NULL
)
AS
BEGIN
	DECLARE @new_treatment_session_id char(5); 
	IF NOT EXISTS (SELECT * FROM TreatmentSession)
	BEGIN
		SET @new_treatment_session_id = '00001'
	END
	ELSE
	BEGIN
		SELECT @new_treatment_session_id = RIGHT('00000' + CAST(CAST(SUBSTRING((SELECT MAX(treatment_session_id) from TreatmentSession), 2, 4) AS INT) + 1 AS VARCHAR(5)), 5)
	END

    -- Insert data into TreatmentSession table
    INSERT INTO TreatmentSession
    (
        treatment_session_id,
        treatment_session_created_date,
        treatment_session_description,
        treatment_plan_id
    )
    VALUES
    (
        @new_treatment_session_id,
        @treatment_session_created_date,
        @treatment_session_description,
        @treatment_plan_id
    );
END;

GO
CREATE PROCEDURE insertToothSelection
(
    @treatment_plan_id char(5),
    @tooth_position_id char(2),
    @tooth_surface_code char(1)
)
AS
BEGIN
    -- Check if treatment plan ID exists
    DECLARE @existing_treatment_plan_id char(5);

    SELECT @existing_treatment_plan_id = treatment_plan_id
    FROM TreatmentPlan
    WHERE treatment_plan_id = @treatment_plan_id;

    IF @existing_treatment_plan_id IS NULL
    BEGIN
        RAISERROR('Kế hoạch điều trị không tồn tại', 16, 1)
        RETURN;
    END

    -- Check if tooth position ID exists
    DECLARE @existing_tooth_position_id char(2);

    SELECT @existing_tooth_position_id = tooth_position_id
    FROM ToothPosition
    WHERE tooth_position_id = @tooth_position_id;

    IF @existing_tooth_position_id IS NULL
    BEGIN
        RAISERROR('Vị trí răng không tồn tại', 16, 1)
        RETURN;
    END

    -- Check if tooth surface code exists
    DECLARE @existing_tooth_surface_code char(1);

    SELECT @existing_tooth_surface_code = tooth_surface_code
    FROM ToothSurface
    WHERE tooth_surface_code = @tooth_surface_code;

    IF @existing_tooth_surface_code IS NULL
    BEGIN
        RAISERROR('Bề mặt răng không tồn tại', 16, 1)
        RETURN;
    END
	DECLARE @treatment_id char(2)
	set @treatment_id = (select treatment_id from TreatmentPlan where treatment_plan_id = @treatment_plan_id)
	DECLARE @treatment_tooth_price float
	set @treatment_tooth_price = (select tooth_price from TreatmentTooth where @treatment_id = treatment_id)
    -- Insert data into ToothSelection table
    INSERT INTO ToothSelection
    (
        treatment_plan_id,
        tooth_position_id,
        tooth_surface_code,
        treatment_tooth_price
    )
    VALUES
    (
        @treatment_plan_id,
        @tooth_position_id,
        @tooth_surface_code,
        @treatment_tooth_price
    );
END;

go
CREATE PROCEDURE updateToothSelection
(
    @treatment_plan_id char(5),
    @tooth_position_id char(2),
    @tooth_surface_code char(1)
)
AS
BEGIN
    -- Check if treatment plan ID exists
    DECLARE @existing_treatment_plan_id char(5);

    SELECT @existing_treatment_plan_id = treatment_plan_id
    FROM TreatmentPlan
    WHERE treatment_plan_id = @treatment_plan_id;

    IF @existing_treatment_plan_id IS NULL
    BEGIN
        RAISERROR('Kế hoạch điều trị không tồn tại', 16, 1)
        RETURN;
    END

    -- Check if tooth position ID exists
    DECLARE @existing_tooth_position_id char(2);

    SELECT @existing_tooth_position_id = tooth_position_id
    FROM ToothPosition
    WHERE tooth_position_id = @tooth_position_id;

    IF @existing_tooth_position_id IS NULL
    BEGIN
        RAISERROR('Vị trí răng không tồn tại', 16, 1)
        RETURN;
    END

    -- Check if tooth surface code exists
    DECLARE @existing_tooth_surface_code char(1);

    SELECT @existing_tooth_surface_code = tooth_surface_code
    FROM ToothSurface
    WHERE tooth_surface_code = @tooth_surface_code;

    IF @existing_tooth_surface_code IS NULL
    BEGIN
        RAISERROR('Bề mặt răng không tồn tại', 16, 1)
        RETURN;
    END

	DECLARE @treatment_id char(2)
	set @treatment_id = (select treatment_id from TreatmentPlan where treatment_plan_id = @treatment_plan_id)
	DECLARE @treatment_tooth_price float
	set @treatment_tooth_price = (select tooth_price from TreatmentTooth where @treatment_id = treatment_id)
    -- Update data in ToothSelection table
    UPDATE ToothSelection
    SET
        tooth_position_id = @tooth_position_id,
        tooth_surface_code = @tooth_surface_code,
		treatment_tooth_price = @treatment_tooth_price
    WHERE
        treatment_plan_id = @treatment_plan_id
END;

go
CREATE PROCEDURE InsertPaymentRecord
(
	@paid_time datetime NOT NULL,
	@paid_money float NOT NULL,
	@payment_note nvarchar(15),
	@payment_method_id char(5) NOT NULL,
	@treatment_plan_id char(5) NOT NULL
)
AS
BEGIN
	DECLARE @new_payment_record_id char(5); 
	IF NOT EXISTS (SELECT * FROM PaymentRecord)
	BEGIN
		SET @new_payment_record_id = '00001'
	END
	ELSE
	BEGIN
		SELECT @new_payment_record_id = RIGHT('00000' + CAST(CAST(SUBSTRING((SELECT MAX(@new_payment_record_id) from PaymentRecord), 2, 4) AS INT) + 1 AS VARCHAR(5)), 5)
	END

    -- Check if payment method ID exists
    DECLARE @existing_payment_method_id char(5);

    SELECT @existing_payment_method_id = payment_method_id
    FROM PaymentMethod
    WHERE payment_method_id = @payment_method_id;

    IF @existing_payment_method_id IS NULL
    BEGIN
        RAISERROR('Phương thức thanh toán không tồn tại', 16, 1)
        RETURN;
    END

    -- Check if treatment plan ID exists
    DECLARE @existing_treatment_plan_id char(5);

    SELECT @existing_treatment_plan_id = treatment_plan_id
    FROM TreatmentPlan
    WHERE treatment_plan_id = @treatment_plan_id;

    IF @existing_treatment_plan_id IS NULL
    BEGIN
        RAISERROR('Kế hoạch điều trị không tồn tại', 16, 1)
        RETURN;
    END

	DECLARE @total_cost float
	DECLARE @drug_cost float
	DECLARE @treatment_cost float
	SET @treatment_cost = (select treatment_tooth_price from ToothSelection where treatment_plan_id = @treatment_plan_id)
	SET @drug_cost = (SELECT SUM(drug_cost) FROM Prescription where treatment_plan_id = @treatment_plan_id)
	SET @total_cost = @treatment_cost +  @drug_cost
    -- Insert data into PaymentRecord table
    INSERT INTO PaymentRecord
    (
        payment_id,
        paid_time,
        paid_money,
        total_cost,
        payment_note,
        payment_method_id,
        treatment_plan_id
    )
    VALUES
    (
        @new_payment_record_id,
        @paid_time,
        @paid_money,
        @total_cost,
        @payment_note,
        @payment_method_id,
        @treatment_plan_id
    );
END;

go
CREATE PROCEDURE InsertPaymentMethod
(
    @payment_method_title nvarchar(15) NOT NULL
)
AS
BEGIN
    -- Check if payment method ID already exists
    DECLARE @new_payment_method_id char(5); 
	IF NOT EXISTS (SELECT * FROM PaymentMethod)
	BEGIN
		SET @new_payment_method_id = '00001'
	END
	ELSE
	BEGIN
		SELECT @new_payment_method_id = RIGHT('00000' + CAST(CAST(SUBSTRING((SELECT MAX(@new_payment_method_id) from PaymentMethod), 2, 4) AS INT) + 1 AS VARCHAR(5)), 5)
	END


    -- Insert data into PaymentMethod table
    INSERT INTO PaymentMethod
    (
        payment_method_id,
        payment_method_title
    )
    VALUES
    (
        @new_payment_method_id,
        @payment_method_title
    );
END;



