#continuous Development using views and triggers
#	1 Users look at view, which looks at primary table
	
#	2 We can alter side tables, keep things in sync, then transition over and work on primary table after without impact to the user.
	
#	3 Other methods can be utilized to achieve a similar outcome.
#		- Mirroring
#		- ETL
#		- Log Shipping
#		- Replication
		
#	4 Illustrating changes made to tables with locking tables. Due to the size of the tables and the length of the presentation, no major changes will be made. I'll instead lock the tables to indicate work or maintenance performed as I can then show in real time what user impact would feel like.
	
#	5 The demonstration is a basic insert and data entry application like program for the user. I'll cover what would change with updates and deletes towards the end.
	
#Reset the environment

#SETUP
SET sql_notes = 0;
UNLOCK TABLES;

ALTER VIEW OzarSurvey as 
select `stg_OzarSurveyA`.`SurveyYear` AS `SurveyYear`,`stg_OzarSurveyA`.`Timestamp` AS `Timestamp`,`stg_OzarSurveyA`.`SalaryUSD` AS `SalaryUSD`,`stg_OzarSurveyA`.`Country` AS `Country`,`stg_OzarSurveyA`.`PostalCode` AS `PostalCode`,`stg_OzarSurveyA`.`PrimaryDatabase` AS `PrimaryDatabase`,`stg_OzarSurveyA`.`YearsWithThisDatabase` AS `YearsWithThisDatabase`,`stg_OzarSurveyA`.`OtherDatabases` AS `OtherDatabases`,`stg_OzarSurveyA`.`EmploymentStatus` AS `EmploymentStatus`,`stg_OzarSurveyA`.`JobTitle` AS `JobTitle`,`stg_OzarSurveyA`.`ManageStaff` AS `ManageStaff`,`stg_OzarSurveyA`.`YearsWithThisTypeOfJob` AS `YearsWithThisTypeOfJob`,`stg_OzarSurveyA`.`OtherPeopleOnYourTeam` AS `OtherPeopleOnYourTeam`,`stg_OzarSurveyA`.`DatabaseServers` AS `DatabaseServers`,`stg_OzarSurveyA`.`Education` AS `Education`,`stg_OzarSurveyA`.`EducationIsComputerRelated` AS `EducationIsComputerRelated`,`stg_OzarSurveyA`.`Certifications` AS `Certifications`,`stg_OzarSurveyA`.`HoursWorkedPerWeek` AS `HoursWorkedPerWeek`,`stg_OzarSurveyA`.`TelecommuteDaysPerWeek` AS `TelecommuteDaysPerWeek`,`stg_OzarSurveyA`.`EmploymentSector` AS `EmploymentSector`,`stg_OzarSurveyA`.`LookingForAnotherJob` AS `LookingForAnotherJob`,`stg_OzarSurveyA`.`CareerPlansThisYear` AS `CareerPlansThisYear`,`stg_OzarSurveyA`.`Gender` AS `Gender`,`stg_OzarSurveyA`.`OtherJobDuties` AS `OtherJobDuties`,`stg_OzarSurveyA`.`KindsOfTasksPerformed` AS `KindsOfTasksPerformed`,`stg_OzarSurveyA`.`Counter` AS `Counter` from `stg_OzarSurveyA`;

DROP TRIGGER IF EXISTS ins_OzarSurveyA ;
CREATE TRIGGER ins_OzarSurveyA AFTER INSERT
ON stg_OzarSurveyA
for each row
INSERT INTO stg_OzarSurveyB (SurveyYear,Timestamp,SalaryUSD,Country,PostalCode,PrimaryDatabase,YearsWithThisDatabase,OtherDatabases,EmploymentStatus,JobTitle,ManageStaff,YearsWithThisTypeOfJob,OtherPeopleOnYourTeam,DatabaseServers,Education,EducationIsComputerRelated,Certifications,HoursWorkedPerWeek,TelecommuteDaysPerWeek,EmploymentSector,LookingForAnotherJob,CareerPlansThisYear,Gender,OtherJobDuties,KindsOfTasksPerformed,Counter)
VALUES
(new.SurveyYear,new.Timestamp,new.SalaryUSD,new.Country,new.PostalCode,new.PrimaryDatabase,new.YearsWithThisDatabase,new.OtherDatabases,new.EmploymentStatus,new.JobTitle,new.ManageStaff,new.YearsWithThisTypeOfJob,new.OtherPeopleOnYourTeam,new.DatabaseServers,new.Education,new.EducationIsComputerRelated,new.Certifications,new.HoursWorkedPerWeek,new.TelecommuteDaysPerWeek,new.EmploymentSector,new.LookingForAnotherJob,new.CareerPlansThisYear,new.Gender,new.OtherJobDuties,new.KindsOfTasksPerformed,new.Counter);

DROP TRIGGER IF EXISTS ins_OzarSurveyB;

TRUNCATE TABLE stg_OzarSurveyA;
TRUNCATE TABLE stg_OzarSurveyB;
TRUNCATE TABLE stg_OzarSurveyC;

insert into OzarSurvey
select * from stg_OzarSurveyNew
ORDER BY SurveyYear limit 2;
####################################################
#########################1##########################
####################################################
#Our goal is to be able to modify table A without impacting users.
#We must make a round-about approach to solving this
#Trigger takes anything new from A to B
#Keepds table A and B in sync
#Primary Table, has two rows currently. We see the same in table B.

select * from stg_OzarSurveyA for update;

#Secondary Table, has two rows

select * from stg_OzarSurveyB for update;

#Transition Table, has no rows

select * from stg_OzarSurveyC for update;

#View pointing to primary table, has two rows

SELECT * FROM OzarSurvey for update;
####################################################
#########################2##########################
####################################################
#Switch trigger to bring anything new from A to C


DROP TRIGGER IF EXISTS ins_OzarSurveyA;
CREATE TRIGGER ins_OzarSurveyA AFTER INSERT
ON stg_OzarSurveyA
for each row
INSERT INTO stg_OzarSurveyC (SurveyYear,Timestamp,SalaryUSD,Country,PostalCode,PrimaryDatabase,YearsWithThisDatabase,OtherDatabases,EmploymentStatus,JobTitle,ManageStaff,YearsWithThisTypeOfJob,OtherPeopleOnYourTeam,DatabaseServers,Education,EducationIsComputerRelated,Certifications,HoursWorkedPerWeek,TelecommuteDaysPerWeek,EmploymentSector,LookingForAnotherJob,CareerPlansThisYear,Gender,OtherJobDuties,KindsOfTasksPerformed,Counter)
VALUES
(new.SurveyYear,new.Timestamp,new.SalaryUSD,new.Country,new.PostalCode,new.PrimaryDatabase,new.YearsWithThisDatabase,new.OtherDatabases,new.EmploymentStatus,new.JobTitle,new.ManageStaff,new.YearsWithThisTypeOfJob,new.OtherPeopleOnYourTeam,new.DatabaseServers,new.Education,new.EducationIsComputerRelated,new.Certifications,new.HoursWorkedPerWeek,new.TelecommuteDaysPerWeek,new.EmploymentSector,new.LookingForAnotherJob,new.CareerPlansThisYear,new.Gender,new.OtherJobDuties,new.KindsOfTasksPerformed,new.Counter);

insert into OzarSurvey
select * from stg_OzarSurveyNew
ORDER BY SurveyYear Limit 1 OFFSET 3;

SELECT * FROM OzarSurvey;
SELECT * FROM stg_OzarSurveyC;
####################################################
#########################3##########################
####################################################
#This section demonstrates locking our secondary table while capturing changes from A. 

LOCK TABLES stg_OzarSurveyA WRITE, stg_OzarSurveyC WRITE, stg_OzarSurveyNew WRITE, OzarSurvey WRITE;
#select * from stg_OzarSurveyA;
select * from stg_OzarSurveyC;
SELECT * FROM OzarSurvey;
#select * from stg_OzarSurveyB;

#Uncomment and show B is unqueryable

####################################################
#########################4##########################
####################################################
#Insert record into C
#Shows we capture new records still while work is being done on Table B

insert into OzarSurvey
select * from stg_OzarSurveyNew
ORDER BY SurveyYear Limit 1 OFFSET 5;

#Show records from various tables
#select * from stg_OzarSurveyA;
select * from stg_OzarSurveyC;
SELECT * FROM OzarSurvey;
####################################################
#########################5##########################
####################################################
#Unlock Table B
#Switch Trigger from C to B
#Insert records from C to B
#A and B now match. Anything that occurs on A will come back to B.

UNLOCK TABLES;

DROP Trigger IF EXISTS ins_OzarSurveyA;
CREATE TRIGGER ins_OzarSurveyA AFTER INSERT
ON stg_OzarSurveyA
for each row

INSERT INTO stg_OzarSurveyB (SurveyYear,Timestamp,SalaryUSD,Country,PostalCode,PrimaryDatabase,YearsWithThisDatabase,OtherDatabases,EmploymentStatus,JobTitle,ManageStaff,YearsWithThisTypeOfJob,OtherPeopleOnYourTeam,DatabaseServers,Education,EducationIsComputerRelated,Certifications,HoursWorkedPerWeek,TelecommuteDaysPerWeek,EmploymentSector,LookingForAnotherJob,CareerPlansThisYear,Gender,OtherJobDuties,KindsOfTasksPerformed,Counter)
VALUES
(new.SurveyYear,new.Timestamp,new.SalaryUSD,new.Country,new.PostalCode,new.PrimaryDatabase,new.YearsWithThisDatabase,new.OtherDatabases,new.EmploymentStatus,new.JobTitle,new.ManageStaff,new.YearsWithThisTypeOfJob,new.OtherPeopleOnYourTeam,new.DatabaseServers,new.Education,new.EducationIsComputerRelated,new.Certifications,new.HoursWorkedPerWeek,new.TelecommuteDaysPerWeek,new.EmploymentSector,new.LookingForAnotherJob,new.CareerPlansThisYear,new.Gender,new.OtherJobDuties,new.KindsOfTasksPerformed,new.Counter);

INSERT INTO stg_OzarSurveyB 
SELECT * FROM stg_OzarSurveyC;

SELECT * FROM stg_OzarSurveyB;
SELECT * FROM OzarSurvey;
#B now has changes made as necessary and has lost no records from A. 
####################################################
#########################6##########################
####################################################
#Lock Table C
#Work would be performed on C
#Table A and B still remain functional

LOCK TABLES stg_OzarSurveyA WRITE, stg_OzarSurveyB WRITE, stg_OzarSurveyNew WRITE, OzarSurvey WRITE;

#Illustrate other tables are still unlocked
select * from stg_OzarSurveyB;
SELECT * FROM OzarSurvey;
#select * from stg_OzarSurveyB;

#Uncomment and show C is unqueryable
select * from stg_OzarSurveyC;

####################################################
#########################7##########################
####################################################
#Theorhetical changes are made to B and C. 
#Unlock C, empty C out

UNLOCK TABLES; 

TRUNCATE TABLE stg_OzarSurveyC;

select * from stg_OzarSurveyC;
####################################################
#########################8##########################
####################################################
#While the View points to A, Clients are using the view to run the application. 
#B has all records equal to A. C has no records as it is the staging point.
#Put trigger on B to bring all changes to C
#Then we will change the view to point to B, changes will be made on B now and propogate to C while A is locked

DROP TRIGGER IF EXISTS ins_OzarSurveyB;
CREATE TRIGGER ins_OzarSurveyB AFTER INSERT
ON stg_OzarSurveyB
for each row

INSERT INTO stg_OzarSurveyC (SurveyYear,Timestamp,SalaryUSD,Country,PostalCode,PrimaryDatabase,YearsWithThisDatabase,OtherDatabases,EmploymentStatus,JobTitle,ManageStaff,YearsWithThisTypeOfJob,OtherPeopleOnYourTeam,DatabaseServers,Education,EducationIsComputerRelated,Certifications,HoursWorkedPerWeek,TelecommuteDaysPerWeek,EmploymentSector,LookingForAnotherJob,CareerPlansThisYear,Gender,OtherJobDuties,KindsOfTasksPerformed,Counter)
VALUES
(new.SurveyYear,new.Timestamp,new.SalaryUSD,new.Country,new.PostalCode,new.PrimaryDatabase,new.YearsWithThisDatabase,new.OtherDatabases,new.EmploymentStatus,new.JobTitle,new.ManageStaff,new.YearsWithThisTypeOfJob,new.OtherPeopleOnYourTeam,new.DatabaseServers,new.Education,new.EducationIsComputerRelated,new.Certifications,new.HoursWorkedPerWeek,new.TelecommuteDaysPerWeek,new.EmploymentSector,new.LookingForAnotherJob,new.CareerPlansThisYear,new.Gender,new.OtherJobDuties,new.KindsOfTasksPerformed,new.Counter);

#Alter view from A to B

ALTER VIEW OzarSurvey as 
select `stg_OzarSurveyB`.`SurveyYear` AS `SurveyYear`,`stg_OzarSurveyB`.`Timestamp` AS `Timestamp`,`stg_OzarSurveyB`.`SalaryUSD` AS `SalaryUSD`,`stg_OzarSurveyB`.`Country` AS `Country`,`stg_OzarSurveyB`.`PostalCode` AS `PostalCode`,`stg_OzarSurveyB`.`PrimaryDatabase` AS `PrimaryDatabase`,`stg_OzarSurveyB`.`YearsWithThisDatabase` AS `YearsWithThisDatabase`,`stg_OzarSurveyB`.`OtherDatabases` AS `OtherDatabases`,`stg_OzarSurveyB`.`EmploymentStatus` AS `EmploymentStatus`,`stg_OzarSurveyB`.`JobTitle` AS `JobTitle`,`stg_OzarSurveyB`.`ManageStaff` AS `ManageStaff`,`stg_OzarSurveyB`.`YearsWithThisTypeOfJob` AS `YearsWithThisTypeOfJob`,`stg_OzarSurveyB`.`OtherPeopleOnYourTeam` AS `OtherPeopleOnYourTeam`,`stg_OzarSurveyB`.`DatabaseServers` AS `DatabaseServers`,`stg_OzarSurveyB`.`Education` AS `Education`,`stg_OzarSurveyB`.`EducationIsComputerRelated` AS `EducationIsComputerRelated`,`stg_OzarSurveyB`.`Certifications` AS `Certifications`,`stg_OzarSurveyB`.`HoursWorkedPerWeek` AS `HoursWorkedPerWeek`,`stg_OzarSurveyB`.`TelecommuteDaysPerWeek` AS `TelecommuteDaysPerWeek`,`stg_OzarSurveyB`.`EmploymentSector` AS `EmploymentSector`,`stg_OzarSurveyB`.`LookingForAnotherJob` AS `LookingForAnotherJob`,`stg_OzarSurveyB`.`CareerPlansThisYear` AS `CareerPlansThisYear`,`stg_OzarSurveyB`.`Gender` AS `Gender`,`stg_OzarSurveyB`.`OtherJobDuties` AS `OtherJobDuties`,`stg_OzarSurveyB`.`KindsOfTasksPerformed` AS `KindsOfTasksPerformed`,`stg_OzarSurveyB`.`Counter` AS `Counter` from `stg_OzarSurveyB`;

#Drop Trigger on A
DROP Trigger IF EXISTS ins_OzarSurveyA;

insert into OzarSurvey
select * from stg_OzarSurveyNew
ORDER BY SurveyYear Limit 1 OFFSET 10;

#We see records flow to B and replicate to C
SELECT * FROM OzarSurvey;
SELECT * FROM stg_OzarSurveyC;

####################################################
#########################9##########################
####################################################
#Now we finish by making theorhetical changes to A
#Lock Table A

LOCK TABLES stg_OzarSurveyC WRITE, stg_OzarSurveyB WRITE, stg_OzarSurveyNew WRITE, OzarSurvey WRITE;

#Illustrate other tables are still unlocked
insert into OzarSurvey
select * from stg_OzarSurveyNew
ORDER BY SurveyYear Limit 1 OFFSET 18;

select * from stg_OzarSurveyC;
SELECT * FROM OzarSurvey;
#select * from stg_OzarSurveyB;

#Uncomment and show A is unqueryable
select * from stg_OzarSurveyA;
####################################################
#########################10#########################
####################################################
#Theorhetical changes are made to A. 
#Unlock A
#Change trigger on Table B to bring new changes to Table A
#Move changes from Table C to Table A
#Empty Table C out
#Now you can either switch the VIEWS and TRIGGERS or leave it and do the opposite switch the next time you need to make changes.

UNLOCK TABLES;

#Change Trigger from C to A

DROP TRIGGER IF EXISTS ins_OzarSurveyB;
CREATE TRIGGER ins_OzarSurveyB AFTER INSERT
ON stg_OzarSurveyB
for each row

INSERT INTO stg_OzarSurveyA (SurveyYear,Timestamp,SalaryUSD,Country,PostalCode,PrimaryDatabase,YearsWithThisDatabase,OtherDatabases,EmploymentStatus,JobTitle,ManageStaff,YearsWithThisTypeOfJob,OtherPeopleOnYourTeam,DatabaseServers,Education,EducationIsComputerRelated,Certifications,HoursWorkedPerWeek,TelecommuteDaysPerWeek,EmploymentSector,LookingForAnotherJob,CareerPlansThisYear,Gender,OtherJobDuties,KindsOfTasksPerformed,Counter)
VALUES
(new.SurveyYear,new.Timestamp,new.SalaryUSD,new.Country,new.PostalCode,new.PrimaryDatabase,new.YearsWithThisDatabase,new.OtherDatabases,new.EmploymentStatus,new.JobTitle,new.ManageStaff,new.YearsWithThisTypeOfJob,new.OtherPeopleOnYourTeam,new.DatabaseServers,new.Education,new.EducationIsComputerRelated,new.Certifications,new.HoursWorkedPerWeek,new.TelecommuteDaysPerWeek,new.EmploymentSector,new.LookingForAnotherJob,new.CareerPlansThisYear,new.Gender,new.OtherJobDuties,new.KindsOfTasksPerformed,new.Counter);

#Move any changes from C to A

INSERT INTO stg_OzarSurveyA
SELECT * FROM stg_OzarSurveyC;

SELECT * FROM stg_OzarSurveyA;
SELECT * FROM stg_OzarSurveyB;
SELECT * FROM OzarSurvey;
####################################################


Summary:
Now you have two tables that will maintain and stay identical. Both had theorhetical changes, as you will need to modify the triggers in addition to replicate the new column data over. For the simplicity of the presentation, that layer was not shown nor the modification of the tables. This was to give a high level demonstration of a creative approach to making modifications to an environment requiring high availability without network changes.

Thoughts on updates and deletes with this method:

Table A and B would have had a primary key created via an incrementing column with a sequence function based on a pre-generated sequence table. 

You would need an UPDATE and DELETE trigger in addition. When the trigger is pointed towards A or B, it would actually modify that table. When the trigger is pointed towards C, it would insert the data being modified and the action taken. The C table would have a column indicating the action of the trigger bringing data over, it would illustrate INS, UPD, DEL. The procedure that syncs the data from C to either B or A would be two part. One would be a DELETE rows in B or A based on the Column Indicator with INS, UPD, or DEL, by being joined to the ID generated by A or B from the sequence procedure. Inserts and Updates would be performed by an INSERT ON DUPLICATE KEY UPDATE statement. 