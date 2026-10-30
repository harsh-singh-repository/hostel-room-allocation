package com.hostel.model;

import java.math.BigDecimal;
import java.util.Date;

public class Allocation {
    private int allocId;
    private Date allocDate;
    private int studentId;
    private String studentName;
    private String email;
    private String rollNo;
    private String course;
    private Integer yearOfStudy;
    private String phone;
    private int roomId;
    private String roomNo;
    private String roomType;
    private int floorNo;
    private String blockName;
    private BigDecimal feeTotal = BigDecimal.ZERO;
    private BigDecimal feeDue = BigDecimal.ZERO;

    public BigDecimal getFeePaid() {
        return feeTotal.subtract(feeDue);
    }

    public int getPaidPct() {
        if (feeTotal.signum() == 0) {
            return 100;
        }
        return getFeePaid().multiply(BigDecimal.valueOf(100))
                .divide(feeTotal, 0, java.math.RoundingMode.HALF_UP).intValue();
    }

    public boolean isFeeCleared() {
        return feeDue.signum() == 0;
    }

    public int getAllocId() { return allocId; }
    public void setAllocId(int allocId) { this.allocId = allocId; }
    public Date getAllocDate() { return allocDate; }
    public void setAllocDate(Date allocDate) { this.allocDate = allocDate; }
    public int getStudentId() { return studentId; }
    public void setStudentId(int studentId) { this.studentId = studentId; }
    public String getStudentName() { return studentName; }
    public void setStudentName(String studentName) { this.studentName = studentName; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getRollNo() { return rollNo; }
    public void setRollNo(String rollNo) { this.rollNo = rollNo; }
    public String getCourse() { return course; }
    public void setCourse(String course) { this.course = course; }
    public Integer getYearOfStudy() { return yearOfStudy; }
    public void setYearOfStudy(Integer yearOfStudy) { this.yearOfStudy = yearOfStudy; }
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
    public int getRoomId() { return roomId; }
    public void setRoomId(int roomId) { this.roomId = roomId; }
    public String getRoomNo() { return roomNo; }
    public void setRoomNo(String roomNo) { this.roomNo = roomNo; }
    public String getRoomType() { return roomType; }
    public void setRoomType(String roomType) { this.roomType = roomType; }
    public int getFloorNo() { return floorNo; }
    public void setFloorNo(int floorNo) { this.floorNo = floorNo; }
    public String getBlockName() { return blockName; }
    public void setBlockName(String blockName) { this.blockName = blockName; }
    public BigDecimal getFeeTotal() { return feeTotal; }
    public void setFeeTotal(BigDecimal feeTotal) { this.feeTotal = feeTotal == null ? BigDecimal.ZERO : feeTotal; }
    public BigDecimal getFeeDue() { return feeDue; }
    public void setFeeDue(BigDecimal feeDue) { this.feeDue = feeDue == null ? BigDecimal.ZERO : feeDue; }
}
