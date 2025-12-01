CREATE INDEX planned_course_course
ON course_instance (course_layout_id);

CREATE INDEX period_id
ON course_instance (period_id);

CREATE INDEX planned_teaching_course_id
ON planned_activity (course_instance_id);

CREATE INDEX planned_teaching_activity
ON planned_activity (teaching_activity_id);

CREATE INDEX wa_planned_activity_id
ON work_allocation (planned_activity_id);

CREATE INDEX employee_person_id
ON employee (person_id);

CREATE INDEX ci_period_id
ON course_instance (period_id);

