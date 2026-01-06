package se.kth.iv1351.project.model;

public class TeacherOverloadException extends Exception {
    private final int e;
    private final String i;
    private final int l;

    public TeacherOverloadException(int e,String i,int l){
        this.e=e;this.i=i;this.l=l;
    }

    public int getEmployeeId(){return e;}
    public String getInstanceId(){return i;}
    public int getLimit(){return l;}
}
