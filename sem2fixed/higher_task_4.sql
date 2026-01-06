SELECT
    instance_id,
    course_code,
    period_name,
    total_planned_hours,
    total_allocated_hours,
    variance_percentage
FROM mv_variance_course_instances
ORDER BY variance_percentage DESC;
