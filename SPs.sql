--------------------------------------------------------
--  File created - Tuesday-April-12-2022   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Procedure DROP_G_STUDENT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "SYSTEM"."DROP_G_STUDENT" 
        (p_B# in students.B#%type, p_classid in classes.classid%type) is
        
             B#_invalid EXCEPTION;
            not_grad_stud EXCEPTION;
            class_invalid EXCEPTION;
            not_enrolled_in_class EXCEPTION;
            invalid_sem EXCEPTION;
            only_class EXCEPTION;

             coun1 number(10);

   begin

        select count(B#) into coun1 from students where B# = p_B#;
        if coun1 = 0
        then 
        raise B#_invalid;
        end if;

        select count(g_B#) into coun1 from g_enrollments where g_B# = p_B#;
        if coun1 = 0
        then 
        raise not_grad_stud;
        end if;

        select count(classid) into coun1 from classes where classid = p_classid;
        if coun1 = 0
        then
        raise class_invalid;
        end if;

        select count(classid) into coun1 from g_enrollments where g_b# = p_b# and classid = p_classid;
        if coun1 <= 0
        then
        raise not_enrolled_in_class;
        end if;

        select count(classid) into coun1 from g_enrollments where g_b# = p_b#;
        if coun1 <= 1
        then
        raise only_class;
        end if;


        select count(classid) into coun1 from classes where classid = p_classid and lower(semester) = 'spring' and year = 2021;
        if coun1 = 0
        then
        raise invalid_sem;
        end if;

        delete from g_enrollments where g_b# = p_b# and classid = p_classid;

--        insert into logs values(LOG_SEQ.NEXTVAL, user, to_date(sysdate, 'yyyy/mm/dd hh24:mi:ss'), 'G_ENROLLMENTS', 'Delete', CONCAT(CONCAT(p_B#, '|'), p_CLASSID));
        commit;

exception
        when B#_invalid then
                dbms_output.put_line('The B# is invalid.');
        when not_grad_stud then
                dbms_output.put_line('This is not a graduate student.');
        when class_invalid then
                dbms_output.put_line('The class is invalid.');
        when invalid_sem then
                dbms_output.put_line('Only enrollment in the current semester can be dropped.');
        when not_enrolled_in_class then
                dbms_output.put_line('The student is not enrolled in the class.');
        when only_class then
                dbms_output.put_line('This is the only class for this student in Spring 2021 and cannot be dropped.');


end;

/
--------------------------------------------------------
--  DDL for Procedure DROP_STUDENT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "SYSTEM"."DROP_STUDENT" 
        (p_B# in students.B#%type) is
            B#_invalid EXCEPTION;
             coun1 number(10);

   begin

        select count(B#) into coun1 from students where B# = p_B#;
        if coun1 = 0
        then 
        raise B#_invalid;
        end if;

        delete from students where lower(b#) = lower(p_b#);
--        insert into logs values(LOG_SEQ.NEXTVAL, user, to_date(sysdate, 'yyyy/mm/dd hh24:mi:ss'), 'STUDENTS', 'Delete', p_b#);
        commit;

exception
        when B#_invalid then
                dbms_output.put_line('The B# is invalid.');
end;

/
--------------------------------------------------------
--  DDL for Procedure ENROLL_G_STUDENT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "SYSTEM"."ENROLL_G_STUDENT" 
        (p_B# in students.B#%type, p_classid in classes.classid%type) is
        
               cursor c1 is
                               
        select distinct pre_dept_code dept, pre_course# course# from  classes c join prerequisites p on c.dept_code = p.dept_code and c.course# = p.course# 
        where c.classid = p_classid;

                c1_rec c1%rowtype; 

             B#_invalid EXCEPTION;
            not_grad_stud EXCEPTION;
            class_invalid EXCEPTION;
            invalid_sem EXCEPTION;
            prereq_not_complete EXCEPTION;
            class_full EXCEPTION;
            already_enrolled EXCEPTION;
            more_than_five_classes EXCEPTION;
             coun1 number(10);

   begin


        select count(B#) into coun1 from students where B# = p_B#;
        if coun1 = 0
        then 
        raise B#_invalid;
        end if;

        select count(g_B#) into coun1 from g_enrollments where g_B# = p_B#;
        if coun1 = 0
        then 
        raise not_grad_stud;
        end if;

        select count(classid) into coun1 from classes where classid = p_classid;
        if coun1 = 0
        then
        raise class_invalid;
        end if;

        select count(classid) into coun1 from classes where classid = p_classid and lower(semester) = 'spring' and year = 2021;
        if coun1 = 0
        then
        raise invalid_sem;
        end if;

        select count(*) into coun1 from classes where classid = p_classid and limit = class_size;
        if coun1 > 0
        then 
        raise class_full;
        end if;

        select count(1) into coun1 from g_enrollments where g_b# = p_b# and classid = p_classid;
        if coun1 > 0
        then
        raise already_enrolled;
        end if;

        select count(distinct classid) into coun1 from g_enrollments where g_b# = p_b#;
        if coun1 >= 5
        then 
        raise more_than_five_classes;
        end if;


        open c1;
        fetch c1 into c1_rec;

                if c1%found
                then
                    select count(*) into coun1 from classes c join g_enrollments e on c.classid = e.classid join score_grade sc on sc.score = e.score
                    where c.course# = c1_rec.course# and c.dept_code = c1_rec.dept and e.g_b# = p_b# and sc.lgrade in ('A', 'A-', 'B+', 'B', 'B-', 'C+', 'C');
                    if coun1 <=0
                    then
                      raise prereq_not_complete;
                    end if;
                end if;


        close c1;



        insert into g_enrollments values(p_b#, p_classid, null);

--        insert into logs values(LOG_SEQ.NEXTVAL, user, to_date(sysdate, 'yyyy/mm/dd hh24:mi:ss'), 'G_ENROLLMENTS', 'Insert', CONCAT(CONCAT(p_B#, '|'), p_CLASSID));
        commit;

exception
        when B#_invalid then
                dbms_output.put_line('The B# is invalid.');
        when not_grad_stud then
                dbms_output.put_line('This is not a graduate student.');
        when class_invalid then
                dbms_output.put_line('The class is invalid.');
        when invalid_sem then
                dbms_output.put_line('Cannot enroll into a class from a previous semester.');
        when prereq_not_complete then
                dbms_output.put_line('Prerequisite not satisfied.');
        when class_full then
                dbms_output.put_line('The class is already full.');
        when already_enrolled then
                dbms_output.put_line('The student is already in the class.');
        when more_than_five_classes then
                dbms_output.put_line('Students cannot be enrolled in more than five classes in the same semeste.');


end;

/
