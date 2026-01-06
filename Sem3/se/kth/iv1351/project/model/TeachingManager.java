package se.kth.iv1351.project.model;

import se.kth.iv1351.project.integration.UniversityDAO;

public class TeachingManager {
    private final UniversityDAO dao;

    public TeachingManager(UniversityDAO dao) {
        this.dao = dao;
    }

    public void allocateTeacher(int e, String i, int p, double h) throws Exception {
        dao.executeInTransaction(() -> {
            dao.lockEmployeeForUpdate(e);
            int l = dao.readConfigValue("max_teaching_load");
            if (dao.readTeacherLoad(e, i) >= l) throw new TeacherOverloadException(e, i, l);
            dao.createAllocation(e, p, h);
            return null;
        });
    }

    public boolean deallocateTeacher(int e, int p) throws Exception {
        return dao.executeInTransaction(() -> dao.deallocate(e, p));
    }

    public boolean increaseStudents(String i, int inc) throws Exception {
        return dao.executeInTransaction(() -> {
            dao.lockCourseInstanceForUpdate(i);
            boolean ok = dao.updateStudentCount(i, inc);
            if (ok) dao.recomputeAdminExamPlannedHours(i);
            return ok;
        });
    }
}
