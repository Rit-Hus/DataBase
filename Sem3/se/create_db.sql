DROP TABLE IF EXISTS
    work_allocation,
    planned_activity,
    employee,
    course_instance,
    department,
    course_layout,
    person,
    teaching_activity,
    job_title,
    period,
    system_config
CASCADE;

CREATE TABLE course_layout (
    course_layout_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
    course_code CHAR(6) UNIQUE,
    course_name VARCHAR(100),
    min_students INT,
    max_students INT,
    hp NUMERIC(4,1),
    PRIMARY KEY (course_layout_id)
);

CREATE TABLE department (
    department_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
    department_name VARCHAR(100) UNIQUE,
    manager_employee_id INT,
    PRIMARY KEY (department_id)
);

CREATE TABLE job_title (
    job_title_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
    title_name VARCHAR(100) UNIQUE,
    PRIMARY KEY (job_title_id)
);

CREATE TABLE period (
    period_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
    period_name CHAR(2) UNIQUE,
    PRIMARY KEY (period_id)
);

CREATE TABLE person (
    person_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
    personal_number VARCHAR(20) UNIQUE,
    first_name VARCHAR(100),
    address VARCHAR(100),
    PRIMARY KEY (person_id)
);

CREATE TABLE course_instance (
    course_instance_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
    instance_id VARCHAR(50) UNIQUE,
    num_students INT,
    course_layout_id INT,
    period_id INT,
    PRIMARY KEY (course_instance_id)
);

CREATE TABLE teaching_activity (
    teaching_activity_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
    activity_name VARCHAR(100) UNIQUE,
    factor NUMERIC(4,2),
    PRIMARY KEY (teaching_activity_id)
);

CREATE TABLE employee (
    employee_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
    skill_set VARCHAR(500),
    salary NUMERIC(10,2),
    person_id INT,
    department_id INT,
    job_title_id INT,
    manager_id INT,
    PRIMARY KEY (employee_id)
);

CREATE TABLE planned_activity (
    planned_activity_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
    planned_hours INT,
    teaching_activity_id INT,
    course_instance_id INT,
    PRIMARY KEY (planned_activity_id)
);

CREATE TABLE work_allocation (
    work_allocation_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
    employee_id INT,
    planned_activity_id INT,
    allocated_hours INT,
    PRIMARY KEY (work_allocation_id),
    UNIQUE (employee_id, planned_activity_id)
);

CREATE TABLE system_config (
    config_key VARCHAR(100) PRIMARY KEY,
    config_value INT NOT NULL
);

ALTER TABLE course_instance ADD FOREIGN KEY (course_layout_id) REFERENCES course_layout(course_layout_id);
ALTER TABLE course_instance ADD FOREIGN KEY (period_id) REFERENCES period(period_id);
ALTER TABLE employee ADD FOREIGN KEY (department_id) REFERENCES department(department_id);
ALTER TABLE employee ADD FOREIGN KEY (job_title_id) REFERENCES job_title(job_title_id);
ALTER TABLE employee ADD FOREIGN KEY (person_id) REFERENCES person(person_id);
ALTER TABLE employee ADD FOREIGN KEY (manager_id) REFERENCES employee(employee_id) DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE department ADD FOREIGN KEY (manager_employee_id) REFERENCES employee(employee_id) DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE planned_activity ADD FOREIGN KEY (teaching_activity_id) REFERENCES teaching_activity(teaching_activity_id);
ALTER TABLE planned_activity ADD FOREIGN KEY (course_instance_id) REFERENCES course_instance(course_instance_id);
ALTER TABLE work_allocation ADD FOREIGN KEY (employee_id) REFERENCES employee(employee_id);
ALTER TABLE work_allocation ADD FOREIGN KEY (planned_activity_id) REFERENCES planned_activity(planned_activity_id);
