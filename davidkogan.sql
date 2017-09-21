(1)

1. SELECT id, extra 
   FROM SLEEP;

2. SELECT extra, id 
   FROM SLEEP;

3. SELECT DISTINCT category 
   FROM SLEEP;

4. SELECT id 
   FROM SLEEP
   WHERE extra > 0;

5. SELECT category, SUM(extra) AS extraSum, COUNT(*) AS categoryNum
   FROM SLEEP
   GROUP BY category;

6. SELECT category, AVG(extra) AS mean_extra
   FROM SLEEP
   GROUP BY category;

(2)

1. SELECT * 
   FROM Department 
   LIMIT 2;

2. SELECT EmployeeName, HireDate, BaseWage 
   FROM Employee;

3. SELECT EmployeeName, (BaseWage * WageLevel) AS TotalWage 
   FROM Employee;

4. SELECT EmployeeName, BaseWage FROM Employee
   WHERE BaseWage >= 2000 AND BaseWage <=3000
   ORDER BY BaseWage DESC;

5. SELECT EmployeeName, HireDate, BaseWage FROM Employee
   WHERE EmployeeName LIKE '%8'
   AND HireDate > 6/10/2010;

6. SELECT EmployeeName, DepartmentID FROM Employee
   WHERE BaseWage*WageLevel > 7000;

7. SELECT DepartmentID FROM Employee
   GROUP BY DepartmentID
   HAVING COUNT(BaseWage >= 3000) >= 2;

8. SELECT DepartmentID, AVG(BaseWage * WageLevel) AS AverageTotalWage
   FROM Employee
   GROUP BY DepartmentID
   ORDER BY AverageTotalWage;

9. SELECT DepartmentID, EmployeeSex, AVG(BaseWage * WageLevel) AS AverageTotalWage
   FROM Employee
   GROUP BY DepartmentID, EmployeeSex
   ORDER BY DepartmentID DESC;

10. SELECT EmployeeName, DepartmentName, Principal
    FROM Employee LEFT JOIN Department 
    ON Employee.DepartmentID = Department.DepartmentID;

(3)

1. adult (age int, workclass char(64), fnlwgt int, 
			education char(64), educationNum int, 
			maritalStatus char(64), occupation char(64), 
			relationship char(64), race char(64), sex char(64), 
			capitalGain int, capitalLoss int, hoursPerWeek int, 
			nativeCountry char(64), class char(64));

2. LOAD DATA LOCAL INFILE 'adult' INTO TABLE adult
   FIELDS TERMINATED BY ', '
   LINES TERMINATED BY '\n';

3. SELECT COUNT(*) FROM adult
   WHERE (age IS NULL OR workclass = '?' OR fnlwgt IS NULL 
   OR education = '?' OR educationNum IS NULL OR maritalStatus = '?' 
   OR occupation = '?' OR relationship = '?' OR race = '?' OR sex = '?' 
   OR capitalGain IS NULL OR capitalLoss IS NULL OR hoursPerWeek IS NULL 
   OR nativeCountry = '?' OR class = '?');

4. DELETE FROM adult
   WHERE (age IS NULL OR workclass = '?' OR fnlwgt IS NULL 
   OR education = '?' OR educationNum IS NULL OR maritalStatus = '?' 
   OR occupation = '?' OR relationship = '?' OR race = '?' OR sex = '?' 
   OR capitalGain IS NULL OR capitalLoss IS NULL OR hoursPerWeek IS NULL 
   OR nativeCountry = '?' OR class = '?');

5. CREATE TEMPORARY TABLE Poor
   SELECT class FROM adult
   WHERE class = '<=50K';

   CREATE TEMPORARY TABLE Rich 
   SELECT class FROM adult
   WHERE class = '>50K';

   Select Count1/Count2 AS ratio
   FROM (SELECT Count(*) Count1 FROM Poor) Poor,
   (SELECT Count(*) Count2 FROM Rich) Rich;

   DROP TEMPORARY TABLE Poor
   DROP TEMPORARY TABLE Rich;

6. SELECT class, AVG(age) AS AverageAge 
   FROM adult 
   GROUP BY class;

7. SELECT COUNT(*) 
   FROM adult 
   WHERE class = '>50K';

8. SELECT class, AVG(hoursPerWeek) AS AverageHours
   FROM adult 
   GROUP BY class;

9. CREATE TEMPORARY TABLE Poor
   SELECT sex, COUNT(*) AS poorcount FROM adult
   WHERE class = '<=50K'
   GROUP BY sex;

   CREATE TEMPORARY TABLE Rich
   SELECT sex, COUNT(*) AS richcount FROM adult
   WHERE class = '>50K'
   GROUP BY sex;


   Select poorcount/richcount AS ratio
   FROM Poor JOIN Rich ON Poor.sex = Rich.sex
