WITH current_period AS (
  SELECT CASE
    WHEN EXTRACT(MONTH FROM CURRENT_DATE) BETWEEN 1 AND 3 THEN 'P1'
    WHEN EXTRACT(MONTH FROM CURRENT_DATE) BETWEEN 4 AND 6 THEN 'P2'
    WHEN EXTRACT(MONTH FROM CURRENT_DATE) BETWEEN 7 AND 9 THEN 'P3'
    ELSE 'P4'
  END AS period_name
)
SELECT
    e.employee_id,
    per.first_name AS teacher_name,
    p.period_name,
    COUNT(DISTINCT ci.course_instance_id) AS no_of_courses
FROM employee e
JOIN person per ON per.person_id = e.person_id
JOIN work_allocation wa ON wa.employee_id = e.employee_id
JOIN planned_activity pa ON pa.planned_activity_id = wa.planned_activity_id
JOIN course_instance ci ON ci.course_instance_id = pa.course_instance_id
JOIN period p ON p.period_id = ci.period_id
JOIN current_period cp ON cp.period_name = p.period_name
WHERE LEFT(ci.instance_id, 4)::int = EXTRACT(YEAR FROM CURRENT_DATE)::int
GROUP BY e.employee_id, per.first_name, p.period_name
HAVING COUNT(DISTINCT ci.course_instance_id) > 2
ORDER BY no_of_courses DESC, e.employee_id;
