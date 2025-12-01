
SELECT
    course_instance.instance_id,
    course_layout.course_code,
    period.period_name,

    SUM(planned_activity.planned_hours * teaching_activity.factor) AS total_planned_hours,
    SUM(
        CASE WHEN work_allocation.employee_id IS NOT NULL
             THEN planned_activity.planned_hours * teaching_activity.factor
             ELSE 0 END
    ) AS total_allocated_hours

FROM course_instance
JOIN course_layout
    ON course_instance.course_layout_id = course_layout.course_layout_id
JOIN period
    ON course_instance.period_id = period.period_id
JOIN planned_activity
    ON planned_activity.course_instance_id = course_instance.course_instance_id
JOIN teaching_activity
    ON teaching_activity.teaching_activity_id = planned_activity.teaching_activity_id
LEFT JOIN work_allocation
    ON work_allocation.planned_activity_id = planned_activity.planned_activity_id

GROUP BY
    course_instance.instance_id,
    course_layout.course_code,
    period.period_name

HAVING
    (
        SUM(planned_activity.planned_hours * teaching_activity.factor)
        -
        SUM(
            CASE WHEN work_allocation.employee_id IS NOT NULL
                 THEN planned_activity.planned_hours * teaching_activity.factor
                 ELSE 0 END
        )
    )
    /
    SUM(planned_activity.planned_hours * teaching_activity.factor)
    * 100 > 15;


