CREATE TABLE course_layout (
 course_layout_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 course_code  CHAR(6) UNIQUE,
 course_name VARCHAR(100),
 min_students INT,
 max_students INT,
 hp NUMERIC(4,1)
);

ALTER TABLE course_layout ADD CONSTRAINT PK_course_layout PRIMARY KEY (course_layout_id);


CREATE TABLE department (
 department_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 department_name VARCHAR(100) UNIQUE,
 manager_employee_id INT
);

ALTER TABLE department ADD CONSTRAINT PK_department PRIMARY KEY (department_id);





CREATE TABLE job_title (
 job_title_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 title_name  VARCHAR(100) UNIQUE
);

ALTER TABLE job_title ADD CONSTRAINT PK_job_title PRIMARY KEY (job_title_id);


CREATE TABLE period (
 period_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 period_name  CHAR(2) UNIQUE
);

ALTER TABLE period ADD CONSTRAINT PK_period PRIMARY KEY (period_id);


CREATE TABLE person (
 person_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 personal_number VARCHAR(20) UNIQUE,
 first_name VARCHAR(100),
 address VARCHAR(100)
);

ALTER TABLE person ADD CONSTRAINT PK_person PRIMARY KEY (person_id);


CREATE TABLE person_phone (
 phone_number VARCHAR(20) NOT NULL,
 person_id INT NOT NULL
);

ALTER TABLE person_phone ADD CONSTRAINT PK_person_phone PRIMARY KEY (phone_number,person_id);


CREATE TABLE teaching_activity (
 teaching_activity_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 factor NUMERIC(4,2),
 activity_name VARCHAR(100) UNIQUE
);

ALTER TABLE teaching_activity ADD CONSTRAINT PK_teaching_activity PRIMARY KEY (teaching_activity_id);


CREATE TABLE course_instance (
 course_instance_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 instance_id INT UNIQUE,
 num_students INT,
 course_layout_id INT NOT NULL,
 period_id INT NOT NULL
);

ALTER TABLE course_instance ADD CONSTRAINT PK_course_instance PRIMARY KEY (course_instance_id);


CREATE TABLE employee (
 employee_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 skill_set VARCHAR(100),
 salary NUMERIC(10,2),
 manager_id  INT ,
 department_id INT NOT NULL,
 job_title_id INT NOT NULL,
 person_id INT NOT NULL
);

ALTER TABLE employee ADD CONSTRAINT PK_employee PRIMARY KEY (employee_id);


CREATE TABLE planned_activity (
 planned_activity_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 planned_hours INT,
 teaching_activity_id INT NOT NULL,
 course_instance_id INT NOT NULL
);

ALTER TABLE planned_activity ADD CONSTRAINT PK_planned_activity PRIMARY KEY (planned_activity_id);


CREATE TABLE work_allocation (
 employee_id INT NOT NULL,
 planned_activity_id INT NOT NULL,
 allocated_hours INT
);

ALTER TABLE work_allocation ADD CONSTRAINT PK_work_allocation PRIMARY KEY (employee_id,planned_activity_id);


ALTER TABLE person_phone ADD CONSTRAINT FK_person_phone_0 FOREIGN KEY (person_id) REFERENCES person (person_id);


ALTER TABLE course_instance ADD CONSTRAINT FK_course_instance_0 FOREIGN KEY (course_layout_id) REFERENCES course_layout (course_layout_id);
ALTER TABLE course_instance ADD CONSTRAINT FK_course_instance_1 FOREIGN KEY (period_id) REFERENCES period (period_id);


ALTER TABLE employee ADD CONSTRAINT FK_employee_0 FOREIGN KEY (department_id) REFERENCES department (department_id);
ALTER TABLE employee ADD CONSTRAINT FK_employee_1 FOREIGN KEY (job_title_id) REFERENCES job_title (job_title_id);
ALTER TABLE employee ADD CONSTRAINT FK_employee_2 FOREIGN KEY (person_id) REFERENCES person (person_id);


ALTER TABLE planned_activity ADD CONSTRAINT FK_planned_activity_0 FOREIGN KEY (teaching_activity_id) REFERENCES teaching_activity (teaching_activity_id);
ALTER TABLE planned_activity ADD CONSTRAINT FK_planned_activity_1 FOREIGN KEY (course_instance_id) REFERENCES course_instance (course_instance_id);


ALTER TABLE work_allocation ADD CONSTRAINT FK_work_allocation_0 FOREIGN KEY (employee_id) REFERENCES employee (employee_id);
ALTER TABLE work_allocation ADD CONSTRAINT FK_work_allocation_1 FOREIGN KEY (planned_activity_id) REFERENCES planned_activity (planned_activity_id);

ALTER TABLE department ADD CONSTRAINT FK_department_manager FOREIGN KEY (manager_employee_id) REFERENCES employee (employee_id);
ALTER TABLE employee ADD CONSTRAINT FK_employee_manager FOREIGN KEY (manager_id) REFERENCES employee (employee_id);
