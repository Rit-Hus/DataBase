SELECT
    cl.course_code,
    ci.instance_id AS course_instance_id,
    cl.hp,
    per.first_name AS teacher_name,
    jt.title_name AS job_title,
    SUM(CASE WHEN ta.activity_name = 'Lecture' THEN wa.allocated_hours * ta.factor ELSE 0 END) AS lecture_hours,
    SUM(CASE WHEN ta.activity_name = 'Tutorial' THEN wa.allocated_hours * ta.factor ELSE 0 END) AS tutorial_hours,
    SUM(CASE WHEN ta.activity_name = 'Computer Lab' THEN wa.allocated_hours * ta.factor ELSE 0 END) AS lab_hours,
    SUM(CASE WHEN ta.activity_name = 'Seminar' THEN wa.allocated_hours * ta.factor ELSE 0 END) AS seminar_hours,
    SUM(CASE WHEN ta.activity_name = 'Other Overhead' THEN wa.allocated_hours * ta.factor ELSE 0 END) AS other_overhead_hours,
    SUM(wa.allocated_hours * ta.factor) AS total_hours
FROM work_allocation wa
JOIN employee e ON e.employee_id = wa.employee_id
JOIN person per ON per.person_id = e.person_id
JOIN job_title jt ON jt.job_title_id = e.job_title_id
JOIN planned_activity pa ON pa.planned_activity_id = wa.planned_activity_id
JOIN teaching_activity ta ON ta.teaching_activity_id = pa.teaching_activity_id
JOIN course_instance ci ON ci.course_instance_id = pa.course_instance_id
JOIN course_layout cl ON cl.course_layout_id = ci.course_layout_id
WHERE LEFT(ci.instance_id, 4)::int = EXTRACT(YEAR FROM CURRENT_DATE)::int
AND ci.instance_id = '2026-103'
GROUP BY cl.course_code, ci.instance_id, cl.hp, per.first_name, jt.title_name
ORDER BY cl.course_code, ci.instance_id, per.first_name;