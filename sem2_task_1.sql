


SELECT 
    course_layout.course_code,
    course_instance.instance_id AS course_instance_id,
    course_layout.hp,
    period.period_name,
    course_instance.num_students,
    
    SUM(CASE WHEN teaching_activity.activity_name = 'Lecture' 
             THEN planned_activity.planned_hours * teaching_activity.factor ELSE 0 END) AS lecture_hours,

    SUM(CASE WHEN teaching_activity.activity_name = 'Computer Lab' 
             THEN planned_activity.planned_hours * teaching_activity.factor ELSE 0 END) AS lab_hours,

    SUM(CASE WHEN teaching_activity.activity_name = 'Seminar' 
             THEN planned_activity.planned_hours * teaching_activity.factor ELSE 0 END) AS seminar_hours,

    SUM(CASE WHEN teaching_activity.activity_name = 'Administration' 
             THEN planned_activity.planned_hours * teaching_activity.factor ELSE 0 END) AS admin_hours,

    SUM(planned_activity.planned_hours * teaching_activity.factor) AS total_hours

FROM course_instance
JOIN course_layout 
    ON course_instance.course_layout_id = course_layout.course_layout_id
JOIN period 
    ON course_instance.period_id = period.period_id
LEFT JOIN planned_activity 
    ON course_instance.course_instance_id = planned_activity.course_instance_id
LEFT JOIN teaching_activity 
    ON planned_activity.teaching_activity_id = teaching_activity.teaching_activity_id

GROUP BY 
    course_layout.course_code, 
    course_instance.instance_id, 
    course_layout.hp, 
    period.period_name, 
    course_instance.num_students
ORDER BY 
    course_layout.course_code;