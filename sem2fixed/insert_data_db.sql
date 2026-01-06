TRUNCATE TABLE work_allocation, planned_activity, employee, course_instance,
               department, course_layout, person, teaching_activity,
               job_title, period CASCADE;

INSERT INTO period (period_name) VALUES ('P1'), ('P2'), ('P3'), ('P4');

INSERT INTO job_title (title_name)
VALUES ('Professor'), ('Lecturer'), ('PhD Student')
ON CONFLICT (title_name) DO NOTHING;

INSERT INTO teaching_activity (activity_name, factor) VALUES
  ('Lecture', 3.60),
  ('Tutorial', 2.40),
  ('Computer Lab', 2.40),
  ('Seminar', 1.80),
  ('Administration', 1.00),
  ('Other Overhead', 1.00)
ON CONFLICT (activity_name) DO NOTHING;

INSERT INTO department (department_name)
VALUES ('Computer Science'), ('Mathematics')
ON CONFLICT (department_name) DO NOTHING;

INSERT INTO course_layout (course_code, course_name, min_students, max_students, hp)
VALUES ('IV1351', 'Data Storage Paradigms', 20, 250, 7.5)
ON CONFLICT (course_code) DO NOTHING;

INSERT INTO person (personal_number, first_name, address) VALUES
  ('19750303-3333', 'Eva Director', 'Strandvägen 1'),
  ('19800101-1234', 'Alice Smith', 'Kistagången 16'),
  ('19900202-2222', 'Bob Lecturer', 'Sveavägen 10')
ON CONFLICT (personal_number) DO NOTHING;

INSERT INTO employee (skill_set, salary, person_id, department_id, job_title_id)
SELECT 'Management', 65000,
  (SELECT person_id FROM person WHERE personal_number = '19750303-3333'),
  (SELECT department_id FROM department WHERE department_name = 'Computer Science'),
  (SELECT job_title_id FROM job_title WHERE title_name = 'Professor');

INSERT INTO employee (skill_set, salary, person_id, department_id, job_title_id, manager_id)
SELECT 'Databases', 50000,
  (SELECT person_id FROM person WHERE personal_number = '19800101-1234'),
  (SELECT department_id FROM department WHERE department_name = 'Computer Science'),
  (SELECT job_title_id FROM job_title WHERE title_name = 'Professor'),
  (SELECT employee_id FROM employee LIMIT 1);

INSERT INTO employee (skill_set, salary, person_id, department_id, job_title_id, manager_id)
SELECT 'Teaching', 42000,
  (SELECT person_id FROM person WHERE personal_number = '19900202-2222'),
  (SELECT department_id FROM department WHERE department_name = 'Computer Science'),
  (SELECT job_title_id FROM job_title WHERE title_name = 'Lecturer'),
  (SELECT employee_id FROM employee LIMIT 1);

UPDATE department
SET manager_employee_id = (SELECT employee_id FROM employee LIMIT 1)
WHERE department_name = 'Computer Science';

DO $$
DECLARE
  y TEXT := EXTRACT(YEAR FROM CURRENT_DATE)::int::text;
  current_p CHAR(2);
BEGIN
  current_p := CASE
    WHEN EXTRACT(MONTH FROM CURRENT_DATE) BETWEEN 1 AND 3 THEN 'P1'
    WHEN EXTRACT(MONTH FROM CURRENT_DATE) BETWEEN 4 AND 6 THEN 'P2'
    WHEN EXTRACT(MONTH FROM CURRENT_DATE) BETWEEN 7 AND 9 THEN 'P3'
    ELSE 'P4'
  END;

  INSERT INTO course_instance (instance_id, num_students, course_layout_id, period_id)
  VALUES
    (y || '-101', 120,
      (SELECT course_layout_id FROM course_layout WHERE course_code='IV1351'),
      (SELECT period_id FROM period WHERE period_name = current_p)),
    (y || '-102', 80,
      (SELECT course_layout_id FROM course_layout WHERE course_code='IV1351'),
      (SELECT period_id FROM period WHERE period_name = current_p)),
    (y || '-103', 200,
      (SELECT course_layout_id FROM course_layout WHERE course_code='IV1351'),
      (SELECT period_id FROM period WHERE period_name = current_p)),
    (y || '-104', 60,
      (SELECT course_layout_id FROM course_layout WHERE course_code='IV1351'),
      (SELECT period_id FROM period WHERE period_name = current_p));
END $$;

INSERT INTO planned_activity (planned_hours, teaching_activity_id, course_instance_id)
SELECT v.planned_hours,
       (SELECT teaching_activity_id FROM teaching_activity WHERE activity_name = v.activity_name),
       ci.course_instance_id
FROM course_instance ci
JOIN (VALUES
  ('Lecture', 20),
  ('Tutorial', 10),
  ('Computer Lab', 15),
  ('Seminar', 12),
  ('Other Overhead', 5)
) AS v(activity_name, planned_hours)
ON TRUE;

DO $$
DECLARE
  y TEXT := EXTRACT(YEAR FROM CURRENT_DATE)::int::text;
  alice_id INT;
  bob_id INT;
BEGIN
  SELECT e.employee_id INTO alice_id
  FROM employee e JOIN person p ON p.person_id=e.person_id
  WHERE p.personal_number='19800101-1234';

  SELECT e.employee_id INTO bob_id
  FROM employee e JOIN person p ON p.person_id=e.person_id
  WHERE p.personal_number='19900202-2222';

  INSERT INTO work_allocation (employee_id, planned_activity_id, allocated_hours)
  SELECT alice_id, pa.planned_activity_id, pa.planned_hours
  FROM planned_activity pa
  JOIN course_instance ci ON ci.course_instance_id=pa.course_instance_id
  WHERE ci.instance_id IN (y || '-101', y || '-102', y || '-104');

  INSERT INTO work_allocation (employee_id, planned_activity_id, allocated_hours)
  SELECT bob_id, pa.planned_activity_id, CEIL(pa.planned_hours * 0.6)::int
  FROM planned_activity pa
  JOIN course_instance ci ON ci.course_instance_id=pa.course_instance_id
  WHERE ci.instance_id = (y || '-103');
END $$;
