-- DATASET

SELECT * FROM [C:asavela].dbo.billing;
SELECT * FROM [C:asavela].dbo.treatments;
SELECT * FROM [C:asavela].dbo.doctors;
SELECT * FROM [C:asavela].dbo.patients;
SELECT * FROM [C:asavela].dbo.appointments;

-- CONFIGURING DATA TYPES
ALTER TABLE billing
ALTER COLUMN amount FLOAT

ALTER TABLE billing
ALTER COLUMN bill_date DATE;

ALTER TABLE treatments
ALTER COLUMN cost FLOAT;

ALTER TABLE [C:asavela].dbo.doctors
ALTER COLUMN doctor_id NVARCHAR(50);

ALTER TABLE [C:asavela].dbo.patients
ALTER COLUMN patient_id NVARCHAR(50)

-- DETERMINING THE PERIOD OF OPERATION FOR HOSPITAL X
SELECT MIN(treatment_date) AS MIN_DATE,
	    MAX(treatment_date) AS MAX_DATE
FROM [C:asavela].dbo.treatments;

-- TREATMENTS OFFERED DURING A 12 MONTH PERIOD FROM HIGHEST TO SMALLEST
SELECT DISTINCT treatment_type,description, COUNT(treatment_id) AS NUMBER_OF_TREATMENTS
FROM  [C:asavela].dbo.treatments
GROUP BY treatment_type,description
ORDER BY NUMBER_OF_TREATMENTS DESC;

-- CUSTOMER SEGMENTATION

SELECT gender, COUNT(patient_id) AS NUMBER
FROM [C:asavela].dbo.patients
GROUP BY gender

-- JOINING PATIENT TABLE AND BILLING TABLE TO ANALYSE THE PAYMENT STATUS OF CLIENTS
SELECT P.patient_id,first_name,last_name,insurance_provider,insurance_number,bill_date,amount,payment_method,payment_status
FROM [C:asavela].dbo.patients P
LEFT JOIN [C:asavela].dbo.Billing AS B ON B.patient_id = P.patient_id

--- CHECKING THE MOST POPULAR INSURANCE PROVIDER
SELECT insurance_provider,COUNT(patient_id) NUMBER
FROM [C:asavela].dbo.patients
GROUP BY insurance_provider

--- DOCTORS AND THEIR SPECIALIZATIONS ---
SELECT first_name,last_name,specialization,years_experience
FROM  [C:asavela].dbo.doctors;

-- JOINING BILLING TABLE AND TREATMENTS TABLE TO EVALUATE THE PAYMENT STATUS OF SERVICES

SELECT treatment_type,description,
      SUM(CASE 
	          WHEN payment_status = 'Paid' THEN amount ELSE 0 END) AS 'Paid Total',
	  SUM(CASE
	          WHEN payment_status = 'Pending' THEN amount ELSE 0 END) AS 'Pending Total',
	  SUM(CASE
	          WHEN payment_status = 'Failed'   THEN amount ELSE 0 END) AS 'Failed Total'
FROM [C:asavela].dbo.treatments TR
LEFT JOIN [C:asavela].dbo.billing B ON TR.treatment_id = B.treatment_id
GROUP BY treatment_type,description
ORDER BY SUM(CASE 
	          WHEN payment_status = 'Paid' THEN amount ELSE 0 END) DESC;

-- EVALUATE APPOINTMENT STATUS

SELECT status,COUNT(appointment_id) AS Status_Count
FROM [C:asavela].dbo.appointments
GROUP BY status;

-- EVALUATE REASON LINKED TO NO SHOW BY PATIENTS 
SELECT reason_for_visit,
       COUNT(CASE 
				WHEN status = 'No-show' THEN 1 END) AS no_show,
	   COUNT(*) AS total_appointments,
	   COUNT(CASE
				WHEN status = 'No-show' THEN 1 END) * 100 / COUNT(*) AS no_show_percentage
FROM [C:asavela].dbo.appointments
GROUP BY reason_for_visit
ORDER BY no_show_percentage DESC;

--- EVALUATE REASON FOR VISIT

SELECT reason_for_visit, COUNT(appointment_id) AS ReasonForVistCount
FROM [C:asavela].dbo.appointments
GROUP BY reason_for_visit;
---------------------------------- TIME BASED ANALYSIS -------------------------------------------------
-----------------------EVALUATING BUSIEST HOURS IN THE HOSPITAL

SELECT appointment_date,
DATEPART(HOUR,appointment_time) AS appointment_hour,status,
COUNT(*) AS appointments_per_hour
FROM [C:asavela].dbo.appointments
GROUP BY appointment_date,DATEPART(HOUR,appointment_time),status
ORDER BY COUNT(*) DESC;

-- EVALAUTING TRENDS OVER MONTHS
SELECT 
DATENAME(Month,appointment_date) AS MONTH,status,
COUNT(*) AS appointments_per_month
FROM [C:asavela].dbo.appointments
GROUP BY DATENAME(Month,appointment_date),status
ORDER BY COUNT(*) ASC;

SELECT 
DATENAME(WEEKDAY,appointment_date) AS WEEKDAY,status,
COUNT(*) AS appointments_per_month
FROM [C:asavela].dbo.appointments
GROUP BY DATENAME(WEEKDAY,appointment_date),status
ORDER BY COUNT(*) ASC;

------------------------REVENUE ANALYSIS----------------------------------------------------


SELECT D.first_name, D.last_name,D.specialization,hospital_branch,
       SUM(CASE 
	          WHEN payment_status = 'Paid' THEN amount ELSE 0 END) AS 'Paid Total',
	   SUM(CASE
	          WHEN payment_status = 'Pending' THEN amount ELSE 0 END) AS 'Pending Total',
	   SUM(CASE
	          WHEN payment_status = 'Failed'   THEN amount ELSE 0 END) AS 'Failed Total',
	 SUM(amount) as Total_Billing
FROM [C:asavela].dbo.appointments AP
INNER JOIN [C:asavela].dbo.patients P ON AP.patient_id = P.patient_id
INNER JOIN [C:asavela].dbo.billing B ON AP.patient_id = B.patient_id
INNER JOIN [C:asavela].dbo.doctors D ON AP.doctor_id = D.doctor_id
GROUP BY D.first_name, D.last_name,D.specialization,hospital_branch

-- EVALUATING REASON FOR FAILED PAYMENTS 
  SELECT  D.first_name, D.last_name, D.specialization,D.hospital_branch, T.treatment_type,T.description, B.amount, B.payment_status
FROM [C:asavela].dbo.appointments AP
INNER JOIN [C:asavela].dbo.patients P ON AP.patient_id = P.patient_id
INNER JOIN [C:asavela].dbo.billing B ON AP.patient_id = B.patient_id
INNER JOIN [C:asavela].dbo.doctors D ON AP.doctor_id = D.doctor_id
INNER JOIN [C:asavela].dbo.treatments T ON B.treatment_id = T.treatment_id
WHERE B.payment_status = 'Failed'
ORDER BY D.last_name, T.treatment_type