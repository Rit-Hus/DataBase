INSERT INTO period (period_name) VALUES
('P1'), ('P2'), ('P3'), ('P4');

INSERT INTO teaching_activity (factor, activity_name) VALUES
(1.00, 'Lecture'),
(1.00, 'Seminar'),
(1.00, 'Computer Lab');

INSERT INTO job_title (title_name) VALUES
('Professor'),
('Lecturer'),
('Assistant');

INSERT INTO department (department_name) VALUES
('Computer Science'),
('Mathematics');

INSERT INTO person (personal_number, first_name, address) VALUES
('19900101-1111', 'Alice', 'Street 1'),
('19851212-2222', 'Bob', 'Street 2'),
('19951105-3333', 'Carol', 'Street 3');

INSERT INTO person_phone (person_id, phone_number) VALUES
(1, '070-1111111'),
(2, '070-2222222'),
(3, '070-3333333');

INSERT INTO employee (skill_set, department_id, job_title_id, person_id, manager_id) VALUES
('Databases', 1, 1, 1, NULL),
('Programming', 1, 2, 2, 1),
('Teaching', 2, 3, 3, 1);

UPDATE department SET manager_supervisor_id = 1 WHERE department_id = 1;
UPDATE department SET manager_supervisor_id = 3 WHERE department_id = 2;

INSERT INTO employee_salary (employee_id, salary, valid_from, valid_to) VALUES
(1, 55000.00, '2024-01-01', '2024-12-31'),
(1, 60000.00, '2025-01-01', NULL),
(2, 42000.00, '2024-01-01', NULL),
(3, 38000.00, '2024-06-01', NULL);

INSERT INTO course (course_name, course_code) VALUES
('Database Systems', 'DB1001'),
('Programming 1', 'PR1001');

INSERT INTO course_layout (course_id, min_students, max_students, hp) VALUES
(1, 10, 120, 7.5),
(1, 10, 120, 15.0),
(2, 10, 200, 7.5);

INSERT INTO course_instance (instance_id, num_students, course_layout_id, period_id, course_id) VALUES
(2025, 80, 1, 1, 1),
(2026, 90, 2, 2, 1),
(2027, 150, 3, 1, 2);

INSERT INTO planned_activity (planned_hours, teaching_activity_id, course_instance_id) VALUES
(20, 1, 1),
(10, 2, 1),
(15, 3, 1),
(25, 1, 2),
(12, 2, 2),
(18, 3, 2),
(30, 1, 3),
(15, 2, 3),
(20, 3, 3);

INSERT INTO work_allocation (employee_id, planned_activity_id, allocated_hours) VALUES
(1, 1, 10),
(2, 1, 10),
(2, 2, 10),
(3, 3, 15),
(1, 4, 10),
(2, 4, 15),
(2, 5, 12),
(3, 6, 18),
(2, 7, 20),
(3, 8, 15),
(1, 9, 10);
