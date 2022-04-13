--------------------------------------------------------
--  File created - Tuesday-April-12-2022   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Trigger DECREMENT_CLASS_SIZE
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "SYSTEM"."DECREMENT_CLASS_SIZE" 
after delete on g_enrollments
for each row
begin
update classes set class_size = class_size-1 where classid = :OLD.classid;
end;
/
ALTER TRIGGER "SYSTEM"."DECREMENT_CLASS_SIZE" ENABLE;
--------------------------------------------------------
--  DDL for Trigger DELETE_G_STUDENT
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "SYSTEM"."DELETE_G_STUDENT" 
before delete on students
for each row
begin
delete from g_enrollments where g_b# = :OLD.b#;
end;
/
ALTER TRIGGER "SYSTEM"."DELETE_G_STUDENT" ENABLE;
--------------------------------------------------------
--  DDL for Trigger INCREMENT_CLASS_SIZE
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "SYSTEM"."INCREMENT_CLASS_SIZE" 
after insert on g_enrollments
for each row
begin
update classes set class_size = class_size+1 where classid = :NEW.classid;
end;
/
ALTER TRIGGER "SYSTEM"."INCREMENT_CLASS_SIZE" ENABLE;
--------------------------------------------------------
--  DDL for Trigger INSERT_INTO_LOGS_ON_G_STUDENT_ADD
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "SYSTEM"."INSERT_INTO_LOGS_ON_G_STUDENT_ADD" 
after insert on g_enrollments
for each row
begin
insert into logs values(LOG_SEQ.NEXTVAL, user, to_date(sysdate, 'yyyy/mm/dd hh24:mi:ss'), 'G_ENROLLMENTS', 'Insert', concat(concat(:NEW.g_b#,','),:NEW.classid));
end;
/
ALTER TRIGGER "SYSTEM"."INSERT_INTO_LOGS_ON_G_STUDENT_ADD" ENABLE;
--------------------------------------------------------
--  DDL for Trigger INSERT_INTO_LOGS_ON_G_STUDENT_DELETE
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "SYSTEM"."INSERT_INTO_LOGS_ON_G_STUDENT_DELETE" 
after delete on g_enrollments
for each row
begin
insert into logs values(LOG_SEQ.NEXTVAL, user, to_date(sysdate, 'yyyy/mm/dd hh24:mi:ss'), 'G_ENROLLMENTS', 'Delete', concat(concat(:OLD.g_b#,','),:OLD.classid));
end;
/
ALTER TRIGGER "SYSTEM"."INSERT_INTO_LOGS_ON_G_STUDENT_DELETE" ENABLE;
--------------------------------------------------------
--  DDL for Trigger INSERT_INTO_LOGS_ON_STUDENT_ADD
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "SYSTEM"."INSERT_INTO_LOGS_ON_STUDENT_ADD" 
after insert on students
for each row
begin
insert into logs values(LOG_SEQ.NEXTVAL, user, to_date(sysdate, 'yyyy/mm/dd hh24:mi:ss'), 'STUDENTS', 'Insert', :NEW.b#);
end;
/
ALTER TRIGGER "SYSTEM"."INSERT_INTO_LOGS_ON_STUDENT_ADD" ENABLE;
--------------------------------------------------------
--  DDL for Trigger INSERT_INTO_LOGS_ON_STUDENT_DELETE
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "SYSTEM"."INSERT_INTO_LOGS_ON_STUDENT_DELETE" 
after delete on students
for each row
begin
insert into logs values(LOG_SEQ.NEXTVAL, user, to_date(sysdate, 'yyyy/mm/dd hh24:mi:ss'), 'STUDENTS', 'Delete', :OLD.b#);
end;
/
ALTER TRIGGER "SYSTEM"."INSERT_INTO_LOGS_ON_STUDENT_DELETE" ENABLE;
