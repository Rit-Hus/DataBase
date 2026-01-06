package se.kth.iv1351.project;

import java.sql.SQLException;
import se.kth.iv1351.project.controller.Controller;
import se.kth.iv1351.project.integration.*;
import se.kth.iv1351.project.view.View;

public class Startup {
    public static void main(String[] args) {
        try {
            UniversityDAO dao = new UniversityDAO(DbConnection.getConnection());
            
            Controller contr = new Controller(dao);
            
            new View(contr).run();

        } catch (SQLException | ClassNotFoundException e) {
            System.err.println("The application failed to start.");
            System.err.println("Reason: " + e.getMessage());
        }
    }
}