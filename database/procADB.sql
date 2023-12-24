use QLPHONGKHAM
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
    RAISERROR(N'Thuốc không tồn tại', 16, 1);
	Rollback;
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

  -- số lượng thuốc đủ hay không
  -- sau khi kê thì cập nhật lại số lượng thuốc trong kho

  if(@drug_quantity > (select drug_quantity from Drug where drug_id = @drug_id))
  begin
	raiserror(N'Số lượng thuốc không đủ cấp', 16, 1)
	rollback
	return
  end

	DECLARE @drug_cost Float
	select @drug_cost = @drug_quantity * (select drug_price from Drug)
  -- Insert prescription and quantity
  INSERT INTO Prescription (treatment_plan_id, drug_id, drug_quantity, drug_cost)
  VALUES (
    @treatment_plan_id,
    @drug_id,
    @drug_quantity,
	@drug_cost
  );

  update Drug
  set drug_quantity = drug_quantity - @drug_quantity
  where drug_id = @drug_id

END;
GO
--1

CREATE or alter PROCEDURE insertDrugAllergy
	@patient_id CHAR(5),
	@drug_id CHAR(5),
	@drug_allergy_description nvarchar(50)
AS
BEGIN
    IF NOT EXISTS (SELECT * FROM Patient WHERE patient_id = @patient_id)
    BEGIN
        RAISERROR(N'Bệnh nhân không tồn tại', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT * FROM Drug WHERE drug_id = @drug_id)
    BEGIN
        RAISERROR(N'Thuốc không tồn tại', 16, 1);
        RETURN;
    END
	if exists(Select 1 from DrugAllergy where patient_id= @patient_id and @drug_id = drug_id)
	begin
		RAISERROR(N'Thuốc dị ứng của bệnh nhân đã tồn tại', 16, 1);
        RETURN;
	end

    INSERT INTO DrugAllergy (patient_id, drug_id, drugallergy_description)
    VALUES (@patient_id, @drug_id, @drug_allergy_description);
END
GO
--2

CREATE or alter PROCEDURE insertContradiction
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
        RAISERROR(N'Thuốc không tồn tại', 16, 1);
        RETURN;
    END
	if exists (select 1 from Contradication where @drug_id = drug_id and @patient_id = patient_id)
	BEGIN
        RAISERROR(N'Thuốc chống chỉ định cho bệnh nhân đã tồn tại', 16, 1);
        RETURN;
    END

    INSERT INTO Contradication (patient_id, drug_id, contradication_description)
    VALUES (@patient_id, @drug_id, @description);
END
GO
--3

CREATE or alter PROCEDURE updateContradiction
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
        RAISERROR(N'Thuốc không tồn tại', 16, 1);
        RETURN;
    END

	IF NOT EXISTS (SELECT * FROM Contradication WHERE drug_id = @drug_id and patient_id = @patient_id)
    BEGIN
        RAISERROR(N'Bệnh nhân không có chống chỉ định', 16, 1);
        RETURN;
    END

	Update Contradication 
	set contradication_description = @description
	where patient_id = @patient_id and drug_id = @drug_id
END
GO
--4

CREATE or alter PROCEDURE updateDrugAllergy
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
        RAISERROR(N'Thuốc không tồn tại', 16, 1);
        RETURN;
    END

	IF NOT EXISTS (SELECT * FROM DrugAllergy WHERE drug_id = @drug_id and patient_id = @patient_id)
    BEGIN
        RAISERROR(N'Bệnh nhân không có thuốc dị ứng', 16, 1);
        RETURN;
    END

	Update DrugAllergy
	set drugallergy_description = @description
	where patient_id = @patient_id and drug_id = @drug_id
END
GO
--5

CREATE or alter PROCEDURE deleteContradiction
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
        RAISERROR(N'Thuốc không tồn tại', 16, 1);
        RETURN;
    END
	IF NOT EXISTS (SELECT * FROM Contradication WHERE drug_id = @drug_id and patient_id = @patient_id)
    BEGIN
        RAISERROR(N'Bệnh nhân không có chống chỉ định', 16, 1);
        RETURN;
    END

    DELETE FROM Contradication
    WHERE patient_id = @patient_id AND drug_id = @drug_id;
END
GO
--6

CREATE or alter PROCEDURE deleteDrugAllergy
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
        RAISERROR(N'Thuốc không tồn tại', 16, 1);
        RETURN;
    END

	IF NOT EXISTS (SELECT * FROM DrugAllergy WHERE drug_id = @drug_id and patient_id = @patient_id)
    BEGIN
        RAISERROR(N'Bệnh nhân không có thuốc dị ứng', 16, 1);
        RETURN;
    END

    DELETE FROM DrugAllergy
    WHERE patient_id = @patient_id AND drug_id = @drug_id;
END
go
--7

CREATE or alter PROCEDURE insertAccount
	@username varchar(20),
	@password char(64)
AS
BEGIN
	IF EXISTS((SELECT * FROM Account WHERE username = @username))
	BEGIN
        RAISERROR(N'Tên tài khoản đã tồn tại', 16, 1)
		ROLLBACK
		RETURN
    END
	DECLARE @new_account_id char(5);
	IF NOT EXISTS (SELECT 1 FROM Account)
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
	(@new_account_id, @username, @password, 1);
END;
go
--8

CREATE or alter PROCEDURE updateAccount
	@userName varchar(20),
	@password char(64),
	@accountStatus BIT
AS
BEGIN
	IF NOT EXISTS((SELECT * FROM Account WHERE username = @userName))
	BEGIN
        RAISERROR(N'Tài khoản không tồn tại', 16, 1)
		RETURN
    END
	UPDATE Account
	SET password = @password,
	account_status = @accountStatus
	WHERE username = @userName;
END;
go
--9

CREATE or alter PROCEDURE InsertAppointment
(
    @request_time datetime,
    @appointment_date date,
    @appointment_time time,
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
	begin
		RAISERROR('Bệnh nhân không tồn tại', 16, 1)
		RETURN
	end
	IF NOT EXISTS (SELECT * FROM Dentist WHERE dentist_id = @dentist_id)
	begin
		RAISERROR('Nha sĩ không tồn tại', 16, 1)
		RETURN
	end
	IF @nurse_id is not null
	BEGIN
		IF NOT EXISTS (SELECT * FROM Nurse WHERE @nurse_id = nurse_id)
		begin
			RAISERROR('Trợ khám không tồn tại', 16, 1)
			RETURN
		end
	END

	-- kiểm tra ngày và giờ đó bác sĩ có rảnh không
	--thíu
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

CREATE or alter PROCEDURE UpdateAppointment
(
    @appointment_id char(5),
	@request_time datetime,
    @appointment_date date,
    @appointment_time time,
    @room_id char(2),
    @is_new_patient bit,
    @patient_id char(5),
    @dentist_id char(3),
    @nurse_id char(3)
)
AS
BEGIN
	IF NOT EXISTS (SELECT * FROM Appointment WHERE appointment_id = @appointment_id)
	begin
		RAISERROR('Cuộc hẹn không tồn tại', 16, 1)
		RETURN
	end
	IF NOT EXISTS (SELECT * FROM Patient WHERE patient_id = @patient_id)
	begin
		RAISERROR('Bệnh nhân không tồn tại', 16, 1)
		RETURN
	end
	IF NOT EXISTS (SELECT * FROM Dentist WHERE dentist_id = @dentist_id)
	begin
		RAISERROR('Nha sĩ không tồn tại', 16, 1)
		RETURN
	end
	IF @nurse_id is not null
	BEGIN
		IF NOT EXISTS (SELECT * FROM Nurse WHERE @nurse_id = nurse_id)
		begin
			RAISERROR('Trợ khám không tồn tại', 16, 1)
			RETURN
		end
	END 

	-- hàm kiểm tra nha sĩ có rảnh vào thời gian đó không
	-- thíu

    -- Update appointment data
    UPDATE Appointment
    SET
        request_time = @request_time,
        appointment_date = @appointment_date,
        appointment_time = @appointment_time,
        room_id = @room_id,
        is_new_patient = @is_new_patient,
        patient_id = @patient_id,
        dentist_id = @dentist_id,
        nurse_id = @nurse_id
    WHERE appointment_id = @appointment_id;
END;
go

CREATE or alter PROCEDURE updateGeneralHealth
(
    @patientPhone char(10),
	@note_date datetime,
    @health_description nvarchar(30)
)
AS
BEGIN
	if not exists(select 1 from Patient where @patientPhone = patient_phone)
	begin
		raiserror(N'Bệnh nhân không tồn tại', 16, 1)
		return;
	end

    -- Update general health data
	declare @patientID char(5)
	select @patientID = patient_id from Patient where patient_phone = @patientPhone

	if not exists (select 1 from GeneralHealth where note_date = @note_date and @patientID = patient_id)
	begin
		raiserror(N'Tổng quan sức khỏe của bệnh nhân chưa được tạo', 16, 1)
		rollback
		return
	end

    UPDATE GeneralHealth
    SET
        health_description = @health_description
    WHERE patient_id = @patientID AND note_date = @note_date;
END;
GO
--10

CREATE or alter PROCEDURE insertGeneralHealth
(
    @patientPhone char(10),
    @note_date datetime,
    @health_description nvarchar(30)
)
AS
BEGIN

	if not exists(select 1 from Patient where @patientPhone = patient_phone)
	begin
		raiserror(N'Bệnh nhân chưa tồn tại', 16, 1)
		return;
	end

	declare @patientID char(5)
	select @patientID = patient_id from Patient where patient_phone = @patientPhone

	if exists (select 1 from GeneralHealth where note_date = @note_date and @patientID = patient_id)
	begin
		raiserror(N'Tổng quan sức khỏe của bệnh nhân đã được tạo', 16, 1)
		rollback
		return
	end

    -- Insert general health data
    INSERT INTO GeneralHealth
    (
        patient_id,
        note_date,
        health_description
    )
    VALUES
    (
        @patientID,
        @note_date,
        @health_description
    );
END;
go
--11

-- kiểm tra lại
CREATE or alter PROCEDURE updateTreatmentPlan
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
   UPDATE ToothSelection
	SET treatment_tooth_price = tt.tooth_price	
	FROM ToothSelection ts JOIN TreatmentTooth tt
	ON ts.tooth_position_id = tt.tooth_position_id
	WHERE ts.treatment_plan_id = @treatment_plan_id and tt.treatment_id = @treatment_id
END;

exec updateTreatmentPlan '00007', "2023/12/10 10:10:00", 'wear about and beat', 'sth', N'Kế hoạch', '01' , '00376', '159', '067'

go

CREATE or alter PROCEDURE insertTreatmentPlan
(
    @treatment_plan_created_date datetime,
    @treatment_plan_note nvarchar(30),
    @treatment_plan_description nvarchar(50),
    @treatment_id char(2),
    @patient_id char(5),
    @dentist_id char(3),
    @nurse_id char(3)
)
AS
BEGIN

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

	Declare @new_treatmentplan_id char(5)
	IF NOT EXISTS (SELECT * FROM TreatmentPlan)
    BEGIN
        SET @new_treatmentplan_id= '00001';
    END
    ELSE
    BEGIN
		SELECT @new_treatmentplan_id = RIGHT('00000' + CAST(CAST(SUBSTRING((SELECT MAX(treatment_plan_id) from TreatmentPlan), 2, 4) AS INT) + 1 AS VARCHAR(5)), 5)
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
        N'Kế hoạch',
        @treatment_id,
        @patient_id,
        @dentist_id,
        @nurse_id
    );
END;
go

CREATE or alter PROCEDURE insertDrug
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
--12

CREATE or alter PROCEDURE updateDrug
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
	if not exists(select 1 from Drug where drug_id = @drugID)
	begin
		raiserror(N'Thuốc không tồn tại', 16, 1)
		rollback
		return
	end

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
--13

CREATE or alter PROCEDURE deleteDrug
(
	@drugID char(5)
)
AS
BEGIN

	if not exists(select 1 from Drug where drug_id = @drugID)
	begin
		raiserror(N'Thuốc không tồn tại', 16, 1)
		rollback
		return
	end

	DELETE FROM Drug
	WHERE drug_id = @drugID;
END;
go
--14

CREATE or alter PROCEDURE InsertEmployee
(
	@employee_name nvarchar(30),
	@employee_gender nvarchar(3),
	@employee_birthday date,
	@employee_address nvarchar(30),
	@employee_national_id char(12),
	@employee_phone char(10),
	@employee_type char(2),
	@branch_id char(2),
	@account_id char(5)
)
AS
BEGIN
	DECLARE @new_employee_id char(5)
	IF NOT EXISTS (SELECT * FROM Employee)
    BEGIN
        SET @new_employee_id = '00001';
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
        RAISERROR(N'Chi nhánh không tồn tại', 16, 1)
        RETURN;
    END

    -- Check if account ID exists
    DECLARE @existing_account_id char(5);

    SELECT @existing_account_id = accountID
    FROM Account
    WHERE accountID = @account_id;

    IF @existing_account_id IS NULL
    BEGIN
        RAISERROR(N'Tài khoản không tồn tại', 16, 1)
        RETURN;
    END

	if exists(select 1 from Employee where @employee_phone = employee_phone)
	begin
		raiserror(N'Số điện thoại không hợp lệ', 16, 1)
		rollback
		return
	end

	if exists(select 1 from Employee where @employee_national_id = employee_national_id)
	begin
		raiserror(N'Số chứng minh nhân dân không hợp lệ', 16, 1)
		rollback
		return
	end

    -- Insert data into Employee table

	if (@employee_type = 'DE' or @employee_type = 'NU')
	begin
		raiserror(N'Phương thức không hợp lệ', 16, 1)
		return
	end

	-- chia trường hợp insert Nurse và Dentist
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
--15

CREATE or alter PROCEDURE InsertNewDentist
(
	@employee_name nvarchar(30),
	@employee_gender nvarchar(3),
	@employee_birthday date,
	@employee_address nvarchar(30),
	@employee_national_id char(12),
	@employee_phone char(10),
	@branch_id char(2),
	@account_id char(5)
)
AS
BEGIN
	
	   -- Check if branch ID exists
    DECLARE @existing_branch_id char(2);

    SELECT @existing_branch_id = branch_id
    FROM Branch
    WHERE branch_id = @branch_id;

    IF @existing_branch_id IS NULL
    BEGIN
        RAISERROR(N'Chi nhánh không tồn tại', 16, 1)
        RETURN;
    END

    -- Check if account ID exists
    DECLARE @existing_account_id char(5);

    SELECT @existing_account_id = accountID
    FROM Account
    WHERE accountID = @account_id;

    IF @existing_account_id IS NULL
    BEGIN
        RAISERROR(N'Tài khoản không tồn tại', 16, 1)
        RETURN;
    END
	
	if exists(select 1 from Employee where @employee_phone = employee_phone)
	begin
		raiserror(N'Số điện thoại không hợp lệ', 16, 1)
		rollback
		return
	end

	if exists(select 1 from Employee where @employee_national_id = employee_national_id)
	begin
		raiserror(N'Số chứng minh nhân dân không hợp lệ', 16, 1)
		rollback
		return
	end

	
	DECLARE @new_employee_id char(5)
	IF NOT EXISTS (SELECT * FROM Employee)
    BEGIN
        SET @new_employee_id = '00001';
    END
    ELSE
    BEGIN
		SET @new_employee_id = RIGHT('00000' + CAST(CAST(SUBSTRING((SELECT MAX(employee_id) from Employee), 2, 4) AS INT) + 1 AS VARCHAR(5)), 5)
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
		'DE',
        @branch_id,
        @account_id
    );
END;
go
--16

CREATE or alter PROCEDURE InsertNewNurse
(
	@employee_name nvarchar(30),
	@employee_gender nvarchar(3),
	@employee_birthday date,
	@employee_address nvarchar(30),
	@employee_national_id char(12),
	@employee_phone char(10),
	@branch_id char(2),
	@account_id char(5)
)
AS
BEGIN
	
	   -- Check if branch ID exists
    DECLARE @existing_branch_id char(2);

    SELECT @existing_branch_id = branch_id
    FROM Branch
    WHERE branch_id = @branch_id;

    IF @existing_branch_id IS NULL
    BEGIN
        RAISERROR(N'Chi nhánh không tồn tại', 16, 1)
        RETURN;
    END

    -- Check if account ID exists
    DECLARE @existing_account_id char(5);

    SELECT @existing_account_id = accountID
    FROM Account
    WHERE accountID = @account_id;

    IF @existing_account_id IS NULL
    BEGIN
        RAISERROR(N'Tài khoản không tồn tại', 16, 1)
        RETURN;
    END
	
	if exists(select 1 from Employee where @employee_phone = employee_phone)
	begin
		raiserror(N'Số điện thoại không hợp lệ', 16, 1)
		rollback
		return
	end

	if exists(select 1 from Employee where @employee_national_id = employee_national_id)
	begin
		raiserror(N'Số chứng minh nhân dân không hợp lệ', 16, 1)
		rollback
		return
	end

	
	DECLARE @new_employee_id char(5)
	IF NOT EXISTS (SELECT * FROM Employee)
    BEGIN
        SET @new_employee_id = '00001';
    END
    ELSE
    BEGIN
		SET @new_employee_id = RIGHT('00000' + CAST(CAST(SUBSTRING((SELECT MAX(employee_id) from Employee), 2, 4) AS INT) + 1 AS VARCHAR(5)), 5)
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
		'NU',
        @branch_id,
        @account_id
    );
END;
go
--17

CREATE or alter PROCEDURE UpdateEmployee
(
	@employee_id char(3),
	@employee_address nvarchar(30),
	@employee_phone char(10),
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

	if exists(select 1 from Employee where @employee_phone = employee_phone)
	begin
		raiserror(N'Số điện thoại không hợp lệ', 16, 1)
		rollback
		return
	end

    -- Update data in Employee table
    UPDATE Employee
    SET
        employee_address = @employee_address,
        employee_phone = @employee_phone,
        branch_id = @branch_id
    WHERE employee_id = @employee_id;
END;
go
--18

CREATE or alter PROCEDURE UpdateEmployeeType
(
	@employee_id char(3),
	@employee_type char(2)
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
	if (@employee_type = 'DE' and (select employee_type from Employee where employee_id = @employee_id) = 'NU')
    begin
		UPDATE Employee
		SET
			employee_type = @employee_type
		WHERE employee_id = @employee_id;

		Insert Dentist
		values(@employee_id)

		Delete Nurse
		where @employee_id = nurse_id
	end

	else if (@employee_type = 'NU' and (select employee_type from Employee where employee_id = @employee_id) = 'DE')
    begin
		UPDATE Employee
		SET
			employee_type = @employee_type
		WHERE employee_id = @employee_id;
		Insert Nurse
		values(@employee_id)

		Delete Dentist
		where @employee_id = dentist_id
	end

	else if (@employee_type != 'NU' and @employee_type != 'DE' and (select employee_type from Employee where employee_id = @employee_id) = 'DE')
    begin
		UPDATE Employee
		SET
			employee_type = @employee_type
		WHERE employee_id = @employee_id;

		Delete Dentist
		where @employee_id = dentist_id
	end

	else if (@employee_type != 'NU' and @employee_type != 'DE' and (select employee_type from Employee where employee_id = @employee_id) = 'NU')
    begin
		UPDATE Employee
		SET
			employee_type = @employee_type
		WHERE employee_id = @employee_id;

		Delete Nurse
		where @employee_id = nurse_id
	end

	else if (@employee_type = 'NU' and (select employee_type from Employee where employee_id = @employee_id) != 'NU' and (select employee_type from Employee where employee_id = @employee_id) != 'DE')
    begin
		UPDATE Employee
		SET
			employee_type = @employee_type
		WHERE employee_id = @employee_id;

		Insert Nurse
		values(@employee_id)
	end

	else if (@employee_type = 'DE' and (select employee_type from Employee where employee_id = @employee_id) != 'NU' and (select employee_type from Employee where employee_id = @employee_id) != 'DE')
    begin
		UPDATE Employee
		SET
			employee_type = @employee_type
		WHERE employee_id = @employee_id;

		Insert Dentist
		values(@employee_id)
	end
END;
go
--19

CREATE or alter PROCEDURE insertPersonalAppointment
	@personalAppointmentStartTime time,
	@personalAppointmentEndTime time,
	@personalAppointmentDate date,
	@dentistID char(5)
AS
BEGIN

	if exists (select 1 from PersonalAppointment where @dentistID = dentist_id and @personalAppointmentDate = personal_appointment_date and @personalAppointmentStartTime = personal_appointment_start_time)
	begin
		raiserror('Lịch khám của bác sĩ đã được tạo', 16, 1)
		return
	end

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
--20

CREATE or alter PROCEDURE deletePersonalAppointment
	@personalAppointmentID char(5)
AS
BEGIN
	if not exists (select 1 from PersonalAppointment where personal_appointment_id = @personalAppointmentID)
	begin
		raiserror('Lịch khám của bác sĩ chưa được tạo', 16, 1)
		return
	end
	
	-- kiểm tra xem bác sĩ có lịch làm việc vào giờ đó không

	DELETE FROM personalAppointment
	WHERE personal_appointment_id = @personalAppointmentID;
END;
go

CREATE or alter PROCEDURE updatePersonalAppointment
	@personalAppointmentID char(5),
	@personalAppointmentStartTime time,
	@personalAppointmentEndTime time,
	@personalAppointmentDate date,
	@dentistID char(5)
AS
BEGIN
	if not exists (select 1 from PersonalAppointment where personal_appointment_id = @personalAppointmentID)
	begin
		raiserror('Lịch khám của bác sĩ chưa được tạo', 16, 1)
		return
	end

	-- kiểm tra xem bác sĩ có lịch làm việc vào giờ đó không

	UPDATE personalAppointment
	SET personal_appointment_start_time = @personalAppointmentStartTime,
	personal_appointment_end_time = @personalAppointmentEndTime,
	personal_appointment_date = @personalAppointmentDate,
	dentist_id = @dentistID
	WHERE personal_appointment_id = @personalAppointmentID;
END;

go
CREATE or alter PROCEDURE insertPatient
(
	@patient_name nvarchar(30),
	@patient_birthday DATE,
	@patient_address nvarchar(40),
	@patient_phone char(10),
	@patient_gender nvarchar(3),
	@patient_email varchar(20)
)
AS
BEGIN
	if exists(select 1 from Patient where @patient_phone = patient_phone)
	begin
		raiserror(N'Số điện thoại không hợp lệ', 16, 1)
		rollback
		return
	end


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
--21

CREATE or alter PROCEDURE updatePatient
(
	@patient_id char(5),
	@patient_name nvarchar(30),
	@patient_birthday DATE,
	@patient_address nvarchar(40),
	@patient_phone char(10),
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

	if exists(select 1 from Patient where @patient_phone = patient_phone)
	begin
		raiserror(N'Số điện thoại không hợp lệ', 16, 1)
		rollback
		return
	end

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
--22

CREATE or alter PROCEDURE insertTreatmentSession
(
    @treatment_session_created_date datetime,
    @treatment_session_description nvarchar(50),
    @treatment_plan_id char(5)
)
AS
BEGIN

	if not exists (select 1 from TreatmentPlan where @treatment_plan_id = treatment_plan_id)
	begin
		raiserror(N'Kế hoạch điều trị không tồn tại', 16, 1)
		rollback
		return
	end

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
--23

CREATE or alter PROCEDURE insertToothSelection
(
    @treatment_plan_id char(5),
    @tooth_position_id char(2),
    @tooth_surface_code char(1)
)
AS
BEGIN
    -- Check if treatment plan ID exists
    if not exists (select 1 from TreatmentPlan where @treatment_plan_id = treatment_plan_id)
	begin
		raiserror(N'Kế hoạch điều trị không tồn tại', 16, 1)
		rollback
		return
	end

    -- Check if tooth position ID exists
	if not exists (select 1 from ToothPosition where @tooth_position_id = tooth_position_id)
	begin
		raiserror(N'Vị trí răng không tồn tại', 16, 1)
		rollback
		return
	end

    -- Check if tooth surface code exists
	if not exists (select 1 from ToothSurface where tooth_surface_code = tooth_surface_code)
	begin
		raiserror(N'Vị trí răng không tồn tại', 16, 1)
		rollback
		return
	end

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
--24

CREATE or alter PROCEDURE updateToothSelection
(
    @treatment_plan_id char(5),
    @tooth_position_id char(2),
    @tooth_surface_code char(1)
)
AS
BEGIN
    -- Check if treatment plan ID exists
    if not exists (select 1 from TreatmentPlan where @treatment_plan_id = treatment_plan_id)
	begin
		raiserror(N'Kế hoạch điều trị không tồn tại', 16, 1)
		rollback
		return
	end

    -- Check if tooth position ID exists
	if not exists (select 1 from ToothPosition where @tooth_position_id = tooth_position_id)
	begin
		raiserror(N'Vị trí răng không tồn tại', 16, 1)
		rollback
		return
	end

    -- Check if tooth surface code exists
	if not exists (select 1 from ToothSurface where @tooth_surface_code = tooth_surface_code)
	begin
		raiserror(N'Vị trí răng không tồn tại', 16, 1)
		rollback
		return
	end
	-- hình như thiếu ToothSelection chưa kiểm tra khi update
	DECLARE @treatment_id char(2)
	set @treatment_id = (select treatment_id from TreatmentPlan where treatment_plan_id = @treatment_plan_id)
	DECLARE @treatment_tooth_price float
	set @treatment_tooth_price = (select tooth_price from TreatmentTooth where @treatment_id = treatment_id and tooth_position_id = @tooth_position_id)
    -- Update data in ToothSelection table
    UPDATE ToothSelection
    SET
        tooth_position_id = @tooth_position_id,
        tooth_surface_code = @tooth_surface_code,
		treatment_tooth_price = @treatment_tooth_price
    WHERE
        treatment_plan_id = @treatment_plan_id
END;

exec updateToothSelection '00007','01','R'

go

CREATE or alter PROCEDURE InsertPaymentRecord
(
	@paid_time datetime,
	@paid_money float,
	@payment_note nvarchar(15),
	@payment_method_id char(5),
	@treatment_plan_id char(5)
)
AS
BEGIN
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

	DECLARE @new_payment_record_id char(5); 
	IF NOT EXISTS (SELECT * FROM PaymentRecord)
	BEGIN
		SET @new_payment_record_id = '00001'
	END
	ELSE
	BEGIN
		SELECT @new_payment_record_id = RIGHT('00000' + CAST(CAST(SUBSTRING((SELECT MAX(@new_payment_record_id) from PaymentRecord), 2, 4) AS INT) + 1 AS VARCHAR(5)), 5)
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
--25

CREATE or alter PROCEDURE InsertPaymentMethod
    @payment_method_title nvarchar(15)
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
go
--26