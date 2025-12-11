package se.kth.iv1351.project.model;

public class CourseCostDTO {
    private String courseCode;
    private String period;
    private double plannedCost;
    private double actualCost;

    public CourseCostDTO(String code, String period, double planned, double actual) {
        this.courseCode = code;
        this.period = period;
        this.plannedCost = planned;
        this.actualCost = actual;
    }

    public String toString() {
        return String.format("%-10s %-10s %-15.2f %-15.2f", courseCode, period, plannedCost, actualCost);
    }
}