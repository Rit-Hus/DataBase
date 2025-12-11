package se.kth.iv1351.project.integration;

import java.sql.*;
import se.kth.iv1351.project.model.CourseCostDTO;

public class UniversityDAO {
    private Connection connection;

    public UniversityDAO(Connection connection) {
        this.connection = connection;
    }

    // --- Transaction Helpers (Called by Controller) ---
    public void commit() throws SQLException {
        connection.commit();
    }

    public void rollback() throws SQLException {
        connection.rollback();
    }

    // --- REQ 1: Read Data (Read Only) ---
    public CourseCostDTO getCourseCostData(int instanceId) throws SQLException {
        String query = """
                    SELECT cl.course_code, p.period_name,
                        (SELECT SUM(pa.planned_hours * ta.factor * (avg_sal.val / 160))
                         FROM planned_activity pa
                         JOIN teaching_activity ta ON pa.teaching_activity_id = ta.teaching_activity_id
                         CROSS JOIN (SELECT AVG(salary) as val FROM employee) avg_sal
                         WHERE pa.course_instance_id = ci.course_instance_id
                        ) AS planned_cost,
                        (SELECT SUM(wa.allocated_hours * ta.factor * (e.salary / 160))
                         FROM work_allocation wa
                         JOIN employee e ON wa.employee_id = e.employee_id
                         JOIN planned_activity pa ON wa.planned_activity_id = pa.planned_activity_id
                         JOIN teaching_activity ta ON pa.teaching_activity_id = ta.teaching_activity_id
                         WHERE pa.course_instance_id = ci.course_instance_id
                        ) AS actual_cost
                    FROM course_instance ci
                    JOIN course_layout cl ON ci.course_layout_id = cl.course_layout_id
                    JOIN period p ON ci.period_id = p.period_id
                    WHERE ci.instance_id = ?
                """;
        try (PreparedStatement stmt = connection.prepareStatement(query)) {
            stmt.setInt(1, instanceId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return new CourseCostDTO(
                        rs.getString("course_code"),
                        rs.getString("period_name"),
                        rs.getDouble("planned_cost"),
                        rs.getDouble("actual_cost"));
            }
            return null;
        }
    }

    public void addStudents(int instanceId, int count) throws SQLException {
        String sql = "UPDATE course_instance SET num_students = num_students + ? WHERE instance_id = ?";
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, count);
            stmt.setInt(2, instanceId);
            stmt.executeUpdate();
        }
    }


    public void lockEmployeeForUpdate(int employeeId) throws SQLException {
        String sql = "SELECT employee_id FROM employee WHERE employee_id = ? FOR UPDATE";
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, employeeId);
            stmt.executeQuery();
        }
    }

    public int getCourseCountForEmployeeInPeriod(int employeeId, int instanceId) throws SQLException {
        String sql = """
                    SELECT COUNT(DISTINCT ci.instance_id)
                    FROM work_allocation wa
                    JOIN planned_activity pa ON wa.planned_activity_id = pa.planned_activity_id
                    JOIN course_instance ci ON pa.course_instance_id = ci.course_instance_id
                    WHERE wa.employee_id = ?
                    AND ci.period_id = (SELECT period_id FROM course_instance WHERE instance_id = ?)
                """;
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, employeeId);
            stmt.setInt(2, instanceId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next())
                return rs.getInt(1);
            return 0;
        }
    }

    public int findPlannedActivityId(int instanceId, String activityName) throws SQLException {
        String sql = """
                    SELECT pa.planned_activity_id
                    FROM planned_activity pa
                    JOIN teaching_activity ta ON pa.teaching_activity_id = ta.teaching_activity_id
                    WHERE pa.course_instance_id = (SELECT course_instance_id FROM course_instance WHERE instance_id = ?)
                    AND ta.activity_name = ?
                    LIMIT 1
                """;
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, instanceId);
            stmt.setString(2, activityName);
            ResultSet rs = stmt.executeQuery();
            if (rs.next())
                return rs.getInt(1);
            return -1;
        }
    }

    public void createAllocation(int employeeId, int plannedActivityId, double hours) throws SQLException {
        String sql = "INSERT INTO work_allocation (employee_id, planned_activity_id, allocated_hours) VALUES (?, ?, ?)";
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, employeeId);
            stmt.setInt(2, plannedActivityId);
            stmt.setDouble(3, hours);
            stmt.executeUpdate();
        }
    }

    public int findActivityType(String name) throws SQLException {
        String sql = "SELECT teaching_activity_id FROM teaching_activity WHERE activity_name = ?";
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setString(1, name);
            ResultSet rs = stmt.executeQuery();
            if (rs.next())
                return rs.getInt(1);
            return -1;
        }
    }

    public void createActivityType(String name, double factor) throws SQLException {
        String sql = "INSERT INTO teaching_activity (activity_name, factor) VALUES (?, ?)";
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setString(1, name);
            stmt.setDouble(2, factor);
            stmt.executeUpdate();
        }
    }

    public int getInternalInstanceId(int instanceId) throws SQLException {
        String sql = "SELECT course_instance_id FROM course_instance WHERE instance_id = ?";
        try (PreparedStatement p = connection.prepareStatement(sql)) {
            p.setInt(1, instanceId);
            ResultSet rs = p.executeQuery();
            if (rs.next())
                return rs.getInt(1);
            return -1;
        }
    }

    public int createPlannedActivity(int typeId, int courseInstancePk, double hours) throws SQLException {
        String sql = "INSERT INTO planned_activity (planned_hours, teaching_activity_id, course_instance_id) VALUES (?, ?, ?) RETURNING planned_activity_id";
        try (PreparedStatement p = connection.prepareStatement(sql)) {
            p.setDouble(1, hours);
            p.setInt(2, typeId);
            p.setInt(3, courseInstancePk);
            ResultSet rs = p.executeQuery();
            if (rs.next())
                return rs.getInt(1);
            return -1;
        }
    }



public boolean deleteAllocation(int employeeId, int instanceId) throws SQLException {
    
    String sql = """
        DELETE FROM work_allocation
        WHERE employee_id = ? 
        AND planned_activity_id IN (
            SELECT planned_activity_id 
            FROM planned_activity 
            WHERE course_instance_id = (SELECT course_instance_id FROM course_instance WHERE instance_id = ?)
        )
    """;
    try (PreparedStatement stmt = connection.prepareStatement(sql)) {
        stmt.setInt(1, employeeId);
        stmt.setInt(2, instanceId);
        int rows = stmt.executeUpdate();
        return rows > 0;
    }
}
}