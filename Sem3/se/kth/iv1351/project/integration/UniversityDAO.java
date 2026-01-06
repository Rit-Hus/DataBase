package se.kth.iv1351.project.integration;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import se.kth.iv1351.project.model.CourseCostDTO;

public class UniversityDAO {
    private final Connection connection;

    public UniversityDAO(Connection connection) {
        this.connection = connection;
    }

    @FunctionalInterface
    public interface TransactionWork<T> {
        T execute() throws Exception;
    }

    public <T> T executeInTransaction(TransactionWork<T> work) throws Exception {
        boolean prev = connection.getAutoCommit();
        try {
            connection.setAutoCommit(false);
            T res = work.execute();
            connection.commit();
            return res;
        } catch (Exception e) {
            connection.rollback();
            throw e;
        } finally {
            connection.setAutoCommit(prev);
        }
    }

    public void lockEmployeeForUpdate(int empId) throws SQLException {
        PreparedStatement s = connection.prepareStatement(
                "SELECT employee_id FROM employee WHERE employee_id = ? FOR UPDATE");
        s.setInt(1, empId);
        ResultSet r = s.executeQuery();
        if (!r.next()) throw new SQLException();
    }

    public void lockCourseInstanceForUpdate(String instanceId) throws SQLException {
        PreparedStatement s = connection.prepareStatement(
                "SELECT course_instance_id FROM course_instance WHERE instance_id = ? FOR UPDATE");
        s.setString(1, instanceId);
        ResultSet r = s.executeQuery();
        if (!r.next()) throw new SQLException();
    }

    public int readConfigValue(String key) throws SQLException {
        PreparedStatement s = connection.prepareStatement(
                "SELECT config_value FROM system_config WHERE config_key = ?");
        s.setString(1, key);
        ResultSet r = s.executeQuery();
        if (!r.next()) throw new SQLException();
        return r.getInt(1);
    }

    public CourseCostDTO readCourseCostData(String instanceId) throws SQLException {
        PreparedStatement s = connection.prepareStatement("""
            SELECT
              cl.course_code,
              ci.instance_id,
              p.period_name,
              COALESCE(SUM(pa.planned_hours * ta.factor), 0) AS planned_units,
              COALESCE(SUM(wa.allocated_hours * ta.factor), 0) AS actual_units
            FROM course_instance ci
            JOIN course_layout cl ON cl.course_layout_id = ci.course_layout_id
            JOIN period p ON p.period_id = ci.period_id
            LEFT JOIN planned_activity pa ON pa.course_instance_id = ci.course_instance_id
            LEFT JOIN teaching_activity ta ON ta.teaching_activity_id = pa.teaching_activity_id
            LEFT JOIN work_allocation wa ON wa.planned_activity_id = pa.planned_activity_id
            WHERE ci.instance_id = ?
            GROUP BY cl.course_code, ci.instance_id, p.period_name
        """);
        s.setString(1, instanceId);
        ResultSet r = s.executeQuery();
        if (!r.next()) return null;

        double plannedKSEK = r.getDouble("planned_units") / 1000.0;
        double actualKSEK = r.getDouble("actual_units") / 1000.0;

        return new CourseCostDTO(
                r.getString("course_code"),
                r.getString("instance_id"),
                r.getString("period_name"),
                plannedKSEK,
                actualKSEK
        );
    }

    public int readTeacherLoad(int empId, String instId) throws SQLException {
        PreparedStatement s = connection.prepareStatement("""
            SELECT COUNT(DISTINCT pa.course_instance_id)
            FROM work_allocation wa
            JOIN planned_activity pa ON wa.planned_activity_id = pa.planned_activity_id
            JOIN course_instance ci ON pa.course_instance_id = ci.course_instance_id
            WHERE wa.employee_id = ?
              AND ci.period_id = (SELECT period_id FROM course_instance WHERE instance_id = ?)
        """);
        s.setInt(1, empId);
        s.setString(2, instId);
        ResultSet r = s.executeQuery();
        return r.next() ? r.getInt(1) : 0;
    }

    public void createAllocation(int empId, int plannedActivityId, double hours) throws SQLException {
        PreparedStatement s = connection.prepareStatement(
                "INSERT INTO work_allocation VALUES (DEFAULT, ?, ?, ?)");
        s.setInt(1, empId);
        s.setInt(2, plannedActivityId);
        s.setDouble(3, hours);
        s.executeUpdate();
    }

    public boolean updateStudentCount(String instanceId, int increment) throws SQLException {
        PreparedStatement s = connection.prepareStatement(
                "UPDATE course_instance SET num_students = num_students + ? WHERE instance_id = ?");
        s.setInt(1, increment);
        s.setString(2, instanceId);
        return s.executeUpdate() > 0;
    }

    public void recomputeAdminExamPlannedHours(String instanceId) throws SQLException {
    PreparedStatement s = connection.prepareStatement("""
        WITH newvals AS (
            SELECT
                pa.planned_activity_id,
                CEIL(
                    CASE ta.activity_name
                        WHEN 'Exam'  THEN 32.0 + 0.725 * ci.num_students
                        WHEN 'Admin' THEN (2.0 * cl.hp) + 28.0 + 0.2 * ci.num_students
                    END
                )::int AS new_hours
            FROM planned_activity pa
            JOIN teaching_activity ta ON ta.teaching_activity_id = pa.teaching_activity_id
            JOIN course_instance ci ON ci.course_instance_id = pa.course_instance_id
            JOIN course_layout cl ON cl.course_layout_id = ci.course_layout_id
            WHERE ci.instance_id = ?
              AND ta.activity_name IN ('Exam', 'Admin')
        )
        UPDATE planned_activity
        SET planned_hours = newvals.new_hours
        FROM newvals
        WHERE planned_activity.planned_activity_id = newvals.planned_activity_id
    """);
    s.setString(1, instanceId);
    s.executeUpdate();
}


    public boolean deallocate(int empId, int plannedActivityId) throws SQLException {
        PreparedStatement s = connection.prepareStatement(
                "DELETE FROM work_allocation WHERE employee_id = ? AND planned_activity_id = ?");
        s.setInt(1, empId);
        s.setInt(2, plannedActivityId);
        return s.executeUpdate() > 0;
    }
}
