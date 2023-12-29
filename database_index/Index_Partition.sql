USE QLPHONGKHAM_IX
GO-- INDEX
CREATE NONCLUSTERED INDEX IX_ToothSelection_TreatmentPlan
ON ToothSelection (treatment_plan_id);

CREATE NONCLUSTERED INDEX IX_TreatmentPlan_PaON TreatmentPlan (patient_id);

CREATE NONCLUSTERED INDEX IX_Appointment_Pa
ON Appointment (patient_id)

-- PARTITION
-- tạo partition cho payment theo quý
ALTER DATABASE QLPHONGKHAM_IX
ADD FILEGROUP FG1

ALTER DATABASE QLPHONGKHAM_IX
ADD FILEGROUP FG2

ALTER DATABASE QLPHONGKHAM_IX
ADD FILE (NAME = FG1_2023,
FILENAME = 'D:\STUDY AT UNIVERSITY\SchoolYear3\Semeter1\DBA\Project\ADB\database_index\DBPartition_1.ndf',
SIZE = 1MB,
MAXSIZE = UNLIMITED,
FILEGROWTH = 1
) TO FILEGROUP FG1

ALTER DATABASE QLPHONGKHAM_IX
ADD FILE (NAME = FG2_2024,
FILENAME = 'D:\STUDY AT UNIVERSITY\SchoolYear3\Semeter1\DBA\Project\ADB\database_index\DBPartition_2.ndf',
SIZE = 1MB,
MAXSIZE = UNLIMITED,
FILEGROWTH = 1
) TO FILEGROUP FG2

--SELECT name as [File Group Name]
--FROM sys.filegroups
--WHERE type = 'FG'
--GO

---- Confirm Datafiles
--SELECT name as [DB FileName],physical_name as
--[DB File Path]
--FROM sys.database_files
--where type_desc = 'ROWS'
--GO

CREATE PARTITION FUNCTION paymentYearPartitions(DATETIME)
AS RANGE LEFT
FOR VALUES('2022-12-31','2023-12-31')
--
CREATE PARTITION SCHEME paymentYearPartitionsScheme
AS PARTITION paymentYearPartitions
TO (FG1,[PRIMARY],FG2)

CREATE NONCLUSTERED INDEX IX_NGAYTHANHTOAN_DATE
ON PaymentRecord
(
	paid_time
) ON paymentYearPartitionsScheme(paid_time)


SELECT p.partition_number AS partition_number,
f.name AS file_group,
p.rows AS row_count
FROM sys.partitions p JOIN sys.destination_data_spaces dds ON
p.partition_number = dds.destination_id
JOIN sys.filegroups f ON dds.data_space_id = f.data_space_id
WHERE OBJECT_NAME(OBJECT_ID) = 'PaymentRecord'
order by partition_number;