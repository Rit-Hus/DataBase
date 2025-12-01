SELECT
    course_layout.course_code,
    course_instance.instance_id,
    course_layout.hp,

    person.first_name AS teacher_name,
    job_title.title_name AS designation,

    SUM(
        CASE WHEN teaching_activity.activity_name = 'Lecture'
             THEN planned_activity.planned_hours * teaching_activity.factor
             ELSE 0 END
    ) AS lecture_hours,

    SUM(
        CASE WHEN teaching_activity.activity_name = 'Tutorial'
             THEN planned_activity.planned_hours * teaching_activity.factor
             ELSE 0 END
    ) AS tutorial_hours,

    SUM(
        CASE WHEN teaching_activity.activity_name = 'Computer Lab'
             THEN planned_activity.planned_hours * teaching_activity.factor
             ELSE 0 END
    ) AS lab_hours,

    SUM(
        CASE WHEN teaching_activity.activity_name = 'Seminar'
             THEN planned_activity.planned_hours * teaching_activity.factor
             ELSE 0 END
    ) AS seminar_hours,

    
    SUM(
        CASE WHEN teaching_activity.activity_name = 'Administration'
             THEN planned_activity.planned_hours * teaching_activity.factor
             ELSE 0 END
    ) AS admin_hours,

    SUM(
        CASE WHEN teaching_activity.activity_name = 'Exam'
             THEN planned_activity.planned_hours * teaching_activity.factor
             ELSE 0 END
    ) AS exam_hours,

    (
        SUM(planned_activity.planned_hours * teaching_activity.factor)
        -
        (
            SUM(
                CASE WHEN teaching_activity.activity_name = 'Lecture'
                     THEN planned_activity.planned_hours * teaching_activity.factor
                     ELSE 0 END
            )
            +
            SUM(
                CASE WHEN teaching_activity.activity_name = 'Tutorial'
                     THEN planned_activity.planned_hours * teaching_activity.factor
                     ELSE 0 END
            )
            +
            SUM(
                CASE WHEN teaching_activity.activity_name = 'Computer Lab'
                     THEN planned_activity.planned_hours * teaching_activity.factor
                     ELSE 0 END
            )
            +
            SUM(
                CASE WHEN teaching_activity.activity_name = 'Seminar'
                     THEN planned_activity.planned_hours * teaching_activity.factor
                     ELSE 0 END
            )
            +
            SUM(
                CASE WHEN teaching_activity.activity_name = 'Administration'
                     THEN planned_activity.planned_hours * teaching_activity.factor
                     ELSE 0 END
            )
            +
            SUM(
                CASE WHEN teaching_activity.activity_name = 'Exam'
                     THEN planned_activity.planned_hours * teaching_activity.factor
                     ELSE 0 END
            )
        )
    ) AS other_overhead_hours,

    SUM(planned_activity.planned_hours * teaching_activity.factor) AS total_hours

FROM course_instance
JOIN course_layout
    ON course_instance.course_layout_id = course_layout.course_layout_id
JOIN planned_activity
    ON planned_activity.course_instance_id = course_instance.course_instance_id
JOIN teaching_activity
    ON teaching_activity.teaching_activity_id = planned_activity.teaching_activity_id
JOIN work_allocation
    ON work_allocation.planned_activity_id = planned_activity.planned_activity_id
JOIN employee
    ON employee.employee_id = work_allocation.employee_id
JOIN person
    ON person.person_id = employee.person_id
JOIN job_title
    ON job_title.job_title_id = employee.job_title_id


WHERE person.first_name = 'Alice Smith'

GROUP BY
    course_layout.course_code,
    course_instance.instance_id,
    course_layout.hp,
	person.first_name,
    job_title.title_name

ORDER BY
    course_layout.course_code,
    person.first_name;
