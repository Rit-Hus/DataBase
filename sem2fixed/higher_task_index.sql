CREATE INDEX IF NOT EXISTS idx_course_instance_instance_id ON course_instance (instance_id);
CREATE INDEX IF NOT EXISTS idx_course_instance_period_id ON course_instance (period_id);
CREATE INDEX IF NOT EXISTS idx_course_instance_layout_id ON course_instance (course_layout_id);
CREATE INDEX IF NOT EXISTS idx_planned_activity_course_instance_id ON planned_activity (course_instance_id);
CREATE INDEX IF NOT EXISTS idx_planned_activity_teaching_activity_id ON planned_activity (teaching_activity_id);
CREATE INDEX IF NOT EXISTS idx_work_allocation_employee_id ON work_allocation (employee_id);
CREATE INDEX IF NOT EXISTS idx_work_allocation_planned_activity_id ON work_allocation (planned_activity_id);
CREATE INDEX IF NOT EXISTS idx_work_allocation_employee_planned ON work_allocation (employee_id, planned_activity_id);
