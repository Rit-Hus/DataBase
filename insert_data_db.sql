-- =============================================
-- 1. CLEAR EXISTING DATA
-- =============================================
-- Truncate tables in specific order to avoid FK conflicts
TRUNCATE TABLE work_allocation CASCADE;
TRUNCATE TABLE planned_activity CASCADE;
TRUNCATE TABLE person_phone CASCADE;
TRUNCATE TABLE employee CASCADE; -- This will cascade to department manager FK
TRUNCATE TABLE course_instance CASCADE;
TRUNCATE TABLE department CASCADE;
TRUNCATE TABLE course_layout CASCADE;
TRUNCATE TABLE person CASCADE;
TRUNCATE TABLE teaching_activity CASCADE;
TRUNCATE TABLE job_title CASCADE;
TRUNCATE TABLE period CASCADE;

-- =============================================
-- 2. INSERT INDEPENDENT DATA (Level 1)
-- =============================================

-- Periods
INSERT INTO period (period_name) VALUES 
('P1'), ('P2'), ('P3'), ('P4');

-- Job Titles
INSERT INTO job_title (title_name) VALUES 
('Professor'), 
('Lecturer'), 
('PhD Student'), 
('Teaching Assistant');

-- Teaching Activities (with Factors)
INSERT INTO teaching_activity (activity_name, factor) VALUES 
('Lecture', 3.60),
('Seminar', 1.80),
('Computer Lab', 2.40),
('Administration', 1.00);

-- Departments (Initially no manager to avoid circular error)
INSERT INTO department (department_name) VALUES 
('Computer Science'), 
('Mathematics'),
('Physics');

-- Course Layouts
INSERT INTO course_layout (course_code, course_name, min_students, max_students, hp) VALUES 
('IV1351', 'Data Storage Paradigms', 20, 150, 7.5),
('ID1020', 'Algorithms and Data Structures', 50, 200, 7.5),
('SF1625', 'Calculus in One Variable', 100, 300, 9.0);

-- Persons (The humans behind the employees)
INSERT INTO person (personal_number, first_name, address) VALUES 
('19800101-1234', 'Alice Smith', 'Kistagången 16'),
('19850505-5555', 'Bob Jones', 'Drottninggatan 1'),
('19920909-9999', 'Charlie Day', 'Odenplan 4'),
('19951212-1111', 'David Docker', 'Valhallavägen 79'),
('19750303-3333', 'Eva Director', 'Strandvägen 1');

-- =============================================
-- 3. INSERT DEPENDENT DATA (Level 2)
-- =============================================

-- Person Phones
INSERT INTO person_phone (phone_number, person_id)
VALUES 
('070-1234567', (SELECT person_id FROM person WHERE personal_number = '19800101-1234')),
('070-9876543', (SELECT person_id FROM person WHERE personal_number = '19850505-5555'));

-- Employees
-- Note: We use subqueries to find the IDs for Foreign Keys
INSERT INTO employee (skill_set, salary, person_id, department_id, job_title_id, manager_id)
VALUES 
-- 1. Eva (The Boss of CS, has no manager)
(
    'Management, Budgeting', 
    65000.00, 
    (SELECT person_id FROM person WHERE first_name = 'Eva Director'),
    (SELECT department_id FROM department WHERE department_name = 'Computer Science'),
    (SELECT job_title_id FROM job_title WHERE title_name = 'Professor'),
    NULL -- Top manager
),
-- 2. Alice (Professor in CS, reports to Eva)
(
    'Databases, SQL', 
    50000.00, 
    (SELECT person_id FROM person WHERE first_name = 'Alice Smith'),
    (SELECT department_id FROM department WHERE department_name = 'Computer Science'),
    (SELECT job_title_id FROM job_title WHERE title_name = 'Professor'),
    (SELECT employee_id FROM employee e JOIN person p ON e.person_id = p.person_id WHERE p.first_name = 'Eva Director')
),
-- 3. Bob (Lecturer in CS, reports to Alice)
(
    'Java, Python', 
    42000.00, 
    (SELECT person_id FROM person WHERE first_name = 'Bob Jones'),
    (SELECT department_id FROM department WHERE department_name = 'Computer Science'),
    (SELECT job_title_id FROM job_title WHERE title_name = 'Lecturer'),
    (SELECT employee_id FROM employee e JOIN person p ON e.person_id = p.person_id WHERE p.first_name = 'Alice Smith')
),
-- 4. Charlie (PhD Student in Math)
(
    'Calculus, Linear Algebra', 
    32000.00, 
    (SELECT person_id FROM person WHERE first_name = 'Charlie Day'),
    (SELECT department_id FROM department WHERE department_name = 'Mathematics'),
    (SELECT job_title_id FROM job_title WHERE title_name = 'PhD Student'),
    NULL
);

-- =============================================
-- 4. UPDATE CIRCULAR DEPENDENCIES
-- =============================================

-- Now that Employees exist, we set the Department Managers
UPDATE department 
SET manager_employee_id = (
    SELECT employee_id 
    FROM employee e 
    JOIN person p ON e.person_id = p.person_id 
    WHERE p.first_name = 'Eva Director'
)
WHERE department_name = 'Computer Science';

-- =============================================
-- 5. COURSE INSTANCES & ACTIVITIES
-- =============================================

-- Create an Instance of "Data Storage" (IV1351) in Period 1
INSERT INTO course_instance (instance_id, num_students, course_layout_id, period_id)
VALUES 
(
    101, -- Using an arbitrary integer for the unique instance_id logic
    120, 
    (SELECT course_layout_id FROM course_layout WHERE course_code = 'IV1351'),
    (SELECT period_id FROM period WHERE period_name = 'P1')
);

-- Create an Instance of "Algorithms" (ID1020) in Period 2
INSERT INTO course_instance (instance_id, num_students, course_layout_id, period_id)
VALUES 
(
    102, 
    180, 
    (SELECT course_layout_id FROM course_layout WHERE course_code = 'ID1020'),
    (SELECT period_id FROM period WHERE period_name = 'P2')
);

-- Add Planned Activities for "Data Storage" (IV1351)
-- 1. Lectures (20 hours)
INSERT INTO planned_activity (planned_hours, teaching_activity_id, course_instance_id)
VALUES 
(
    20, 
    (SELECT teaching_activity_id FROM teaching_activity WHERE activity_name = 'Lecture'),
    (SELECT course_instance_id FROM course_instance WHERE instance_id = 101)
);

-- 2. Labs (40 hours)
INSERT INTO planned_activity (planned_hours, teaching_activity_id, course_instance_id)
VALUES 
(
    40, 
    (SELECT teaching_activity_id FROM teaching_activity WHERE activity_name = 'Computer Lab'),
    (SELECT course_instance_id FROM course_instance WHERE instance_id = 101)
);

-- =============================================
-- 6. WORK ALLOCATIONS (M:N Relationships)
-- =============================================

-- Scenario: Alice teaches the Lectures for Data Storage
INSERT INTO work_allocation (employee_id, planned_activity_id, allocated_hours)
VALUES 
(
    -- Find Alice's Employee ID
    (SELECT employee_id FROM employee e JOIN person p ON e.person_id = p.person_id WHERE p.first_name = 'Alice Smith'),
    
    -- Find the ID for "Lectures" in "Data Storage" (IV1351)
    (
        SELECT pa.planned_activity_id 
        FROM planned_activity pa
        JOIN course_instance ci ON pa.course_instance_id = ci.course_instance_id
        JOIN course_layout cl ON ci.course_layout_id = cl.course_layout_id
        JOIN teaching_activity ta ON pa.teaching_activity_id = ta.teaching_activity_id
        WHERE cl.course_code = 'IV1351' AND ta.activity_name = 'Lecture'
    ),
    20 -- She takes all 20 hours
);

-- Scenario: Bob takes half the Labs for Data Storage
INSERT INTO work_allocation (employee_id, planned_activity_id, allocated_hours)
VALUES 
(
    (SELECT employee_id FROM employee e JOIN person p ON e.person_id = p.person_id WHERE p.first_name = 'Bob Jones'),
    (
        SELECT pa.planned_activity_id 
        FROM planned_activity pa
        JOIN course_instance ci ON pa.course_instance_id = ci.course_instance_id
        JOIN course_layout cl ON ci.course_layout_id = cl.course_layout_id
        JOIN teaching_activity ta ON pa.teaching_activity_id = ta.teaching_activity_id
        WHERE cl.course_code = 'IV1351' AND ta.activity_name = 'Computer Lab'
    ),
    20 -- He takes 20 of the 40 hours
);