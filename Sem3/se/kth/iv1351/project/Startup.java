package se.kth.iv1351.project;

import se.kth.iv1351.project.controller.Controller;
import se.kth.iv1351.project.view.View;

public class Startup {
    public static void main(String[] args) {
        try {
            Controller contr = new Controller();
            new View(contr).run();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}