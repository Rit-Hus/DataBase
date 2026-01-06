TRUNCATE TABLE work_allocation, planned_activity, employee, course_instance,
               department, course_layout, person, teaching_activity,
               job_title, period, system_config CASCADE;

-- Periods
INSERT INTO period (period_name) VALUES ('P1'), ('P2'), ('P3'), ('P4');

-- Job titles
INSERT INTO job_title (title_name)
VALUES ('Professor'), ('Lecturer'), ('PhD Student');

-- Configuration (max 4 course instances per period)
INSERT INTO system_config (config_key, config_value)
VALUES ('max_teaching_load', 4);

-- Teaching activities including Admin, Exam, Exercise
INSERT INTO teaching_activity (activity_name, factor) VALUES
  ('Lecture', 3.60),
  ('Tutorial', 2.40),
  ('Computer Lab', 2.40),
  ('Seminar', 1.80),
  ('Admin', 1.00),
  ('Exam', 1.00),
  ('Other Overhead', 1.00),
  ('Exercise', 2.00);

-- Departments
INSERT INTO department (department_name)
VALUES ('Computer Science'), ('Mathematics');

-- Course layout
INSERT INTO course_layout (course_code, course_name, min_students, max_students, hp)
VALUES ('IV1351', 'Data Storage Paradigms', 20, 250, 7.5);

-- Persons
INSERT INTO person (personal_number, first_name, address) VALUES
  ('19750303-3333', 'Eva Director', 'Strandvägen 1'),
  ('19800101-1234', 'Alice Smith', 'Kistagången 16'),
  ('19900202-2222', 'Bob Lecturer', 'Sveavägen 10');

-- Employees
INSERT INTO employee (skill_set, salary, person_id, department_id, job_title_id)
SELECT 'Management', 65000, person_id,
       (SELECT department_id FROM department WHERE department_name='Computer Science'),
       (SELECT job_title_id FROM job_title WHERE title_name='Professor')
FROM person WHERE personal_number='19750303-3333';

INSERT INTO employee (skill_set, salary, person_id, department_id, job_title_id, manager_id)
SELECT 'Databases', 50000, person_id,
       (SELECT department_id FROM department WHERE department_name='Computer Science'),
       (SELECT job_title_id FROM job_title WHERE title_name='Professor'),
       (SELECT employee_id FROM employee LIMIT 1)
FROM person WHERE personal_number='19800101-1234';

INSERT INTO employee (skill_set, salary, person_id, department_id, job_title_id, manager_id)
SELECT 'Teaching', 42000, person_id,
       (SELECT department_id FROM department WHERE department_name='Computer Science'),
       (SELECT job_title_id FROM job_title WHERE title_name='Lecturer'),
       (SELECT employee_id FROM employee LIMIT 1)
FROM person WHERE personal_number='19900202-2222';

UPDATE department
SET manager_employee_id = (SELECT employee_id FROM employee LIMIT 1)
WHERE department_name='Computer Science';

-- Course instances (5 in same period to allow overload test)
DO $$
DECLARE
  y TEXT := EXTRACT(YEAR FROM CURRENT_DATE)::text;
  p CHAR(2);
BEGIN
  p := CASE
    WHEN EXTRACT(MONTH FROM CURRENT_DATE) BETWEEN 1 AND 3 THEN 'P1'
    WHEN EXTRACT(MONTH FROM CURRENT_DATE) BETWEEN 4 AND 6 THEN 'P2'
    WHEN EXTRACT(MONTH FROM CURRENT_DATE) BETWEEN 7 AND 9 THEN 'P3'
    ELSE 'P4'
  END;

  INSERT INTO course_instance (instance_id, num_students, course_layout_id, period_id)
  SELECT y||'-'||g, 50*g,
         (SELECT course_layout_id FROM course_layout WHERE course_code='IV1351'),
         (SELECT period_id FROM period WHERE period_name=p)
  FROM generate_series(101,105) g;
END $$;

-- Base planned activities
INSERT INTO planned_activity (planned_hours, teaching_activity_id, course_instance_id)
SELECT v.h,
       (SELECT teaching_activity_id FROM teaching_activity WHERE activity_name=v.a),
       ci.course_instance_id
FROM course_instance ci
JOIN (VALUES
 ('Lecture',20),('Tutorial',10),('Computer Lab',15),('Seminar',12),('Other Overhead',5)
) v(a,h) ON TRUE;

-- Admin and Exam planned hours (allocatable)
INSERT INTO planned_activity (planned_hours, teaching_activity_id, course_instance_id)
SELECT CEIL(CASE a
  WHEN 'Exam' THEN 32 + 0.725*ci.num_students
  WHEN 'Admin' THEN (2*cl.hp) + 28 + 0.2*ci.num_students END),
  (SELECT teaching_activity_id FROM teaching_activity WHERE activity_name=a),
  ci.course_instance_id
FROM course_instance ci
JOIN course_layout cl ON cl.course_layout_id=ci.course_layout_id
JOIN (VALUES ('Exam'),('Admin')) t(a) ON TRUE;

-- Exercise activity attached to one instance
INSERT INTO planned_activity (planned_hours, teaching_activity_id, course_instance_id)
SELECT 8,
       (SELECT teaching_activity_id FROM teaching_activity WHERE activity_name='Exercise'),
       course_instance_id
FROM course_instance
LIMIT 1;
