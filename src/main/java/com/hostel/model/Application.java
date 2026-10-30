package com.hostel.model;

import java.util.Date;

public class Application {
    private int appId;
    private int studentId;
    private String studentName;
    private String rollNo;
    private String gender;
    private Integer yearOfStudy;
    private Integer preferredBlockId;
    private String preferredBlockName;
    private String preferredType;
    private String status;
    private String remarks;
    private Date appliedOn;
    private Date decidedOn;

    public boolean isOpen() {
        return "PENDING".equals(status) || "WAITLISTED".equals(status);
    }

    public int getAppId() { return appId; }
    public void setAppId(int appId) { this.appId = appId; }
    public int getStudentId() { return studentId; }
    public void setStudentId(int studentId) { this.studentId = studentId; }
    public String getStudentName() { return studentName; }
    public void setStudentName(String studentName) { this.studentName = studentName; }
    public String getRollNo() { return rollNo; }
    public void setRollNo(String rollNo) { this.rollNo = rollNo; }
    public String getGender() { return gender; }
    public void setGender(String gender) { this.gender = gender; }
    public Integer getYearOfStudy() { return yearOfStudy; }
    public void setYearOfStudy(Integer yearOfStudy) { this.yearOfStudy = yearOfStudy; }
    public Integer getPreferredBlockId() { return preferredBlockId; }
    public void setPreferredBlockId(Integer preferredBlockId) { this.preferredBlockId = preferredBlockId; }
    public String getPreferredBlockName() { return preferredBlockName; }
    public void setPreferredBlockName(String preferredBlockName) { this.preferredBlockName = preferredBlockName; }
    public String getPreferredType() { return preferredType; }
    public void setPreferredType(String preferredType) { this.preferredType = preferredType; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getRemarks() { return remarks; }
    public void setRemarks(String remarks) { this.remarks = remarks; }
    public Date getAppliedOn() { return appliedOn; }
    public void setAppliedOn(Date appliedOn) { this.appliedOn = appliedOn; }
    public Date getDecidedOn() { return decidedOn; }
    public void setDecidedOn(Date decidedOn) { this.decidedOn = decidedOn; }
}
