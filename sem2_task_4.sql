SELECT
    employee.employee_id,
    person.first_name AS teacher_name,
    period.period_name,
    COUNT(DISTINCT course_instance.instance_id) AS number_of_courses

FROM employee
JOIN person
    ON person.person_id = employee.person_id
JOIN work_allocation
    ON work_allocation.employee_id = employee.employee_id
JOIN planned_activity
    ON planned_activity.planned_activity_id = work_allocation.planned_activity_id
JOIN course_instance
    ON course_instance.course_instance_id = planned_activity.course_instance_id
JOIN period
    ON period.period_id = course_instance.period_id


WHERE period.period_name = 'P1'

GROUP BY
    employee.employee_id,
    person.first_name,
    period.period_name


HAVING COUNT(DISTINCT course_instance.instance_id) > 0

ORDER BY
    employee.employee_id;