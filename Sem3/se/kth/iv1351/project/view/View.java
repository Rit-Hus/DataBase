package se.kth.iv1351.project.view;

import java.util.Scanner;
import se.kth.iv1351.project.controller.Controller;
import se.kth.iv1351.project.model.CourseCostDTO;
import se.kth.iv1351.project.model.TeacherOverloadException;

public class View {
    private final Controller controller;

    public View(Controller controller) {
        this.controller = controller;
    }

    public void run() {
        try (Scanner scanner = new Scanner(System.in)) {
            while (true) {
                System.out.println("\n--- UNIVERSITY MANAGEMENT SYSTEM ---");
                System.out.println("1. View Course Cost Report (Req #1)");
                System.out.println("2. Increase Students by 100 (Req #2)");
                System.out.println("3. Allocate Teacher (Req #3)");
                System.out.println("4. Deallocate Teacher (Req #3)");
                System.out.println("5. Exit");
                System.out.print("Select an option: ");

                if (!scanner.hasNextInt()) {
                    scanner.next();
                    continue;
                }

                int choice = scanner.nextInt();
                if (choice == 5) break;

                try {
                    switch (choice) {
                        case 1 -> {
                            System.out.print("Enter Instance ID: ");
                            String id = scanner.next();
                            printCostTable(controller.getCostReport(id));
                        }
                        case 2 -> {
                            System.out.print("Enter Instance ID: ");
                            String id = scanner.next();
                            boolean ok = controller.updateStudentCount(id, 100);
                            if (!ok) {
                                System.out.println("No record found.");
                            } else {
                                printCostTable(controller.getCostReport(id));
                            }
                        }
                        case 3 -> {
                            System.out.print("Emp ID: ");
                            int e = scanner.nextInt();
                            System.out.print("Inst ID: ");
                            String i = scanner.next();
                            System.out.print("Act ID: ");
                            int a = scanner.nextInt();
                            System.out.print("Hours: ");
                            double h = scanner.nextDouble();

                            try {
                                controller.allocate(e, i, a, h);
                                System.out.println("Allocation successful.");
                            } catch (TeacherOverloadException ex) {
                                System.out.println("ERROR: Teacher " + ex.getEmployeeId()
                                        + " exceeds max course instances per period (" + ex.getLimit() + ").");
                            }
                        }
                        case 4 -> {
                            System.out.print("Enter Emp ID to remove: ");
                            int empId = scanner.nextInt();
                            System.out.print("Enter Activity ID to remove: ");
                            int actId = scanner.nextInt();

                            boolean removed = controller.deallocate(empId, actId);
                            System.out.println(removed ? "Deallocation successful." : "No matching allocation found.");
                        }
                        default -> System.out.println("Invalid option.");
                    }
                } catch (Exception e) {
                    System.out.println("Error: " + (e.getMessage() == null ? e.getClass().getSimpleName() : e.getMessage()));
                }
            }
        }
    }

    private void printCostTable(CourseCostDTO dto) {
        if (dto == null) {
            System.out.println("No record found.");
            return;
        }

        System.out.println("---------------------------------------------------------------");
        System.out.printf("%-12s | %-12s | %-6s | %-15s | %-15s%n",
                "Course Code", "Instance", "Period", "Planned (KSEK)", "Actual (KSEK)");
        System.out.println("---------------------------------------------------------------");

        System.out.printf("%-12s | %-12s | %-6s | %-15.2f | %-15.2f%n",
                dto.getCourseCode(),
                dto.getInstanceId(),
                dto.getPeriod(),
                dto.getPlannedCostKSEK(),
                dto.getActualCostKSEK());

        System.out.println("---------------------------------------------------------------");
    }
}
