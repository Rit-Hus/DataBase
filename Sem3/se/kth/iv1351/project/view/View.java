package se.kth.iv1351.project.view;

import java.util.Scanner;
import se.kth.iv1351.project.controller.Controller;
import se.kth.iv1351.project.model.CourseCostDTO;

public class View {
    private Controller controller;

    public View(Controller controller) {
        this.controller = controller;
    }

    public void run() {
        Scanner scanner = new Scanner(System.in);
        while (true) {
            System.out.println("\n--- MVC MENU ---");
            System.out.println("1. Check Cost");
            System.out.println("2. Add Students");
            System.out.println("3. Allocate (Strict Logic)");
            System.out.println("4. Create Exercise");
            System.out.println("5. Deallocate Teacher");
            System.out.println("0. Exit");
            System.out.print("Choice: ");

            try {
                int choice = Integer.parseInt(scanner.next());
                switch (choice) {
                    case 1 -> {
                        System.out.print("Instance ID: ");
                        CourseCostDTO dto = controller.getCostReport(scanner.nextInt());
                        System.out.println(dto != null ? dto : "Not found");
                    }
                    case 2 -> {
                        System.out.print("Instance ID: ");
                        CourseCostDTO dto = controller.addStudents(scanner.nextInt());
                        System.out.println("Updated. " + dto);
                    }
                    case 3 -> {
                        System.out.print("Emp ID: ");
                        int e = scanner.nextInt();
                        System.out.print("Inst ID: ");
                        int i = scanner.nextInt();
                        System.out.print("Act: ");
                        String a = scanner.next();
                        controller.allocateTeacher(e, i, a, 10.0);
                        System.out.println("Success!");
                    }
                    case 4 -> {
                        System.out.print("Inst ID: ");
                        int i = scanner.nextInt();
                        System.out.print("Emp ID: ");
                        int e = scanner.nextInt();
                        controller.createExercise(i, e);
                        System.out.println("Success!");
                    }
case 5 -> {
    System.out.print("Emp ID: "); int e = scanner.nextInt();
    System.out.print("Inst ID: "); int i = scanner.nextInt();
    controller.deallocateTeacher(e, i);
    System.out.println("Deallocation Successful!");
}

                    
                    case 0 -> System.exit(0);
                }
            } catch (Exception e) {
                System.out.println("ERROR: " + e.getMessage());
            }
        }
    }
}