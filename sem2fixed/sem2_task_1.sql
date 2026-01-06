SELECT
    cl.course_code,
    ci.instance_id AS course_instance_id,
    cl.hp,
    p.period_name,
    ci.num_students,
    SUM(CASE WHEN ta.activity_name = 'Lecture' THEN pa.planned_hours * ta.factor ELSE 0 END) AS lecture_hours,
    SUM(CASE WHEN ta.activity_name = 'Tutorial' THEN pa.planned_hours * ta.factor ELSE 0 END) AS tutorial_hours,
    SUM(CASE WHEN ta.activity_name = 'Computer Lab' THEN pa.planned_hours * ta.factor ELSE 0 END) AS lab_hours,
    SUM(CASE WHEN ta.activity_name = 'Seminar' THEN pa.planned_hours * ta.factor ELSE 0 END) AS seminar_hours,
    SUM(CASE WHEN ta.activity_name = 'Other Overhead' THEN pa.planned_hours * ta.factor ELSE 0 END) AS other_overhead_hours,
    (2 * cl.hp + 28 + 0.2 * ci.num_students) AS admin_hours,
    (32 + 0.725 * ci.num_students) AS exam_hours,
    (SUM(pa.planned_hours * ta.factor)
      + (2 * cl.hp + 28 + 0.2 * ci.num_students)
      + (32 + 0.725 * ci.num_students)) AS total_hours
FROM course_instance ci
JOIN course_layout cl ON cl.course_layout_id = ci.course_layout_id
JOIN period p ON p.period_id = ci.period_id
JOIN planned_activity pa ON pa.course_instance_id = ci.course_instance_id
JOIN teaching_activity ta ON ta.teaching_activity_id = pa.teaching_activity_id
WHERE LEFT(ci.instance_id, 4)::int = EXTRACT(YEAR FROM CURRENT_DATE)::int
GROUP BY cl.course_code, ci.instance_id, cl.hp, p.period_name, ci.num_students
ORDER BY cl.course_code, ci.instance_id;
