package com.hostel.model;

import java.util.Date;

public class RoomRequest {
    private int reqId;
    private int studentId;
    private String studentName;
    private String rollNo;
    private String currentRoom;
    private String reqType;
    private String newType;
    private String reason;
    private String status;
    private String adminNote;
    private Date createdAt;
    private Date resolvedAt;

    public int getReqId() { return reqId; }
    public void setReqId(int reqId) { this.reqId = reqId; }
    public int getStudentId() { return studentId; }
    public void setStudentId(int studentId) { this.studentId = studentId; }
    public String getStudentName() { return studentName; }
    public void setStudentName(String studentName) { this.studentName = studentName; }
    public String getRollNo() { return rollNo; }
    public void setRollNo(String rollNo) { this.rollNo = rollNo; }
    public String getCurrentRoom() { return currentRoom; }
    public void setCurrentRoom(String currentRoom) { this.currentRoom = currentRoom; }
    public String getReqType() { return reqType; }
    public void setReqType(String reqType) { this.reqType = reqType; }
    public String getNewType() { return newType; }
    public void setNewType(String newType) { this.newType = newType; }
    public String getReason() { return reason; }
    public void setReason(String reason) { this.reason = reason; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getAdminNote() { return adminNote; }
    public void setAdminNote(String adminNote) { this.adminNote = adminNote; }
    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }
    public Date getResolvedAt() { return resolvedAt; }
    public void setResolvedAt(Date resolvedAt) { this.resolvedAt = resolvedAt; }
}
