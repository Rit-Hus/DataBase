package se.kth.iv1351.project.controller;

import java.sql.SQLException;

import se.kth.iv1351.project.integration.UniversityDAO;
import se.kth.iv1351.project.model.CourseCostDTO;
import se.kth.iv1351.project.model.TeachingManager;

public class Controller {
    private final UniversityDAO dao;
    private final TeachingManager manager;

    public Controller(UniversityDAO dao) {
        this.dao = dao;
        this.manager = new TeachingManager(dao);
    }

    public CourseCostDTO getCostReport(String instanceId) throws SQLException {
        return dao.readCourseCostData(instanceId);
    }

    public boolean updateStudentCount(String instanceId, int increment) throws Exception {
        return manager.increaseStudents(instanceId, increment);
    }

    public void allocate(int empId, String instId, int plannedActivityId, double hours) throws Exception {
        manager.allocateTeacher(empId, instId, plannedActivityId, hours);
    }

    public boolean deallocate(int empId, int plannedActivityId) throws Exception {
        return manager.deallocateTeacher(empId, plannedActivityId);
    }
}
