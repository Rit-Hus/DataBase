package se.kth.iv1351.project.model;

public class CourseCostDTO {
    private final String courseCode;
    private final String instanceId;
    private final String period;
    private final double plannedCostKSEK;
    private final double actualCostKSEK;

    public CourseCostDTO(String courseCode, String instanceId, String period, double plannedCostKSEK, double actualCostKSEK) {
        this.courseCode = courseCode;
        this.instanceId = instanceId;
        this.period = period;
        this.plannedCostKSEK = plannedCostKSEK;
        this.actualCostKSEK = actualCostKSEK;
    }

    public String getCourseCode() {
        return courseCode;
    }

    public String getInstanceId() {
        return instanceId;
    }

    public String getPeriod() {
        return period;
    }

    public double getPlannedCostKSEK() {
        return plannedCostKSEK;
    }

    public double getActualCostKSEK() {
        return actualCostKSEK;
    }
}
