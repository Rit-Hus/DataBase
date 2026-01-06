DROP MATERIALIZED VIEW IF EXISTS m_variance_course_instances;
CREATE MATERIALIZED VIEW m_variance_course_instances AS
WITH InstanceCalculations AS (
    SELECT
        ci.instance_id,
        cl.course_code,
        p.period_name,
        SUM(pa.planned_hours * ta.factor) AS total_planned_hours,
        SUM(COALESCE(wa.allocated_hours, 0) * ta.factor) AS total_allocated_hours
    FROM course_instance ci
    JOIN course_layout cl ON ci.course_layout_id = cl.course_layout_id
    JOIN period p ON ci.period_id = p.period_id
    JOIN planned_activity pa ON pa.course_instance_id = ci.course_instance_id
    JOIN teaching_activity ta ON ta.teaching_activity_id = pa.teaching_activity_id
    LEFT JOIN work_allocation wa ON wa.planned_activity_id = pa.planned_activity_id
    WHERE LEFT(ci.instance_id, 4)::int = EXTRACT(YEAR FROM CURRENT_DATE)::int
    GROUP BY ci.instance_id, cl.course_code, p.period_name
)
SELECT
    instance_id,
    course_code,
    period_name,
    total_planned_hours,
    total_allocated_hours,
    ROUND((ABS(total_planned_hours - total_allocated_hours) / NULLIF(total_planned_hours, 0)) * 100, 2) AS variance_percentage
FROM InstanceCalculations
WHERE (ABS(total_planned_hours - total_allocated_hours) / NULLIF(total_planned_hours, 0)) > 0.15;
