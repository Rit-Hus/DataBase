package se.kth.iv1351.project.controller;

import java.sql.Connection;
import java.sql.SQLException;
import se.kth.iv1351.project.integration.DbConnection;
import se.kth.iv1351.project.integration.UniversityDAO;
import se.kth.iv1351.project.model.CourseCostDTO;

public class Controller {
    private UniversityDAO dao;

    public Controller() throws SQLException {
        Connection conn = DbConnection.getConnection();
        this.dao = new UniversityDAO(conn);
    }

    public CourseCostDTO getCostReport(int instanceId) throws Exception {
        try {
            CourseCostDTO dto = dao.getCourseCostData(instanceId);
            dao.commit(); 
            return dto;
        } catch (SQLException e) {
            dao.rollback();
            throw e;
        }
    }

    public CourseCostDTO addStudents(int instanceId) throws Exception {
        try {
            dao.addStudents(instanceId, 100);
            CourseCostDTO dto = dao.getCourseCostData(instanceId);
            dao.commit();
            return dto;
        } catch (SQLException e) {
            dao.rollback();
            throw e;
        }
    }

    public void allocateTeacher(int empId, int instId, String activity, double hours) throws Exception {
        try {
            dao.lockEmployeeForUpdate(empId);
            
            int currentLoad = dao.getCourseCountForEmployeeInPeriod(empId, instId);
            
            if (currentLoad >= 4) {
                throw new Exception("VIOLATION: Employee " + empId + " is already fully booked.");
            }

            int actId = dao.findPlannedActivityId(instId, activity);
            if (actId == -1) throw new Exception("Activity not found.");

            dao.createAllocation(empId, actId, hours);
            
            dao.commit();
        } catch (Exception e) {
            dao.rollback();
            throw e;
        }
    }

    public void createExercise(int instId, int empId) throws Exception {
        try {
            int typeId = dao.findActivityType("Exercise");
            if (typeId == -1) {
                dao.createActivityType("Exercise", 1.5);
                typeId = dao.findActivityType("Exercise");
            }

            int cPk = dao.getInternalInstanceId(instId);
            if (cPk == -1) throw new Exception("Instance not found");

            int planId = dao.createPlannedActivity(typeId, cPk, 10.0);
            dao.createAllocation(empId, planId, 10.0);
            
            dao.commit();
        } catch (Exception e) {
            dao.rollback();
            throw e;
        }
    }


public void deallocateTeacher(int empId, int instId) throws Exception {
    try {
        boolean success = dao.deleteAllocation(empId, instId);
        if (!success) {
            throw new Exception("No allocation found for this teacher and course instance.");
        }
        dao.commit();
    } catch (Exception e) {
        dao.rollback();
        throw e;
    }
}



}