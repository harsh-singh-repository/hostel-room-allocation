package com.hostel.model;

import java.math.BigDecimal;

public class DashboardStats {
    private int totalBeds;
    private int occupiedBeds;
    private int pendingApplications;
    private int waitlisted;
    private int totalStudents;
    private int pendingRequests;
    private BigDecimal feeCollected = BigDecimal.ZERO;
    private BigDecimal feeDue = BigDecimal.ZERO;

    public int getFreeBeds() {
        return Math.max(totalBeds - occupiedBeds, 0);
    }

    public int getOccupancyPct() {
        return totalBeds == 0 ? 0 : Math.round(occupiedBeds * 100f / totalBeds);
    }

    public int getTotalBeds() { return totalBeds; }
    public void setTotalBeds(int totalBeds) { this.totalBeds = totalBeds; }
    public int getOccupiedBeds() { return occupiedBeds; }
    public void setOccupiedBeds(int occupiedBeds) { this.occupiedBeds = occupiedBeds; }
    public int getPendingApplications() { return pendingApplications; }
    public void setPendingApplications(int pendingApplications) { this.pendingApplications = pendingApplications; }
    public int getWaitlisted() { return waitlisted; }
    public void setWaitlisted(int waitlisted) { this.waitlisted = waitlisted; }
    public int getTotalStudents() { return totalStudents; }
    public void setTotalStudents(int totalStudents) { this.totalStudents = totalStudents; }
    public int getPendingRequests() { return pendingRequests; }
    public void setPendingRequests(int pendingRequests) { this.pendingRequests = pendingRequests; }
    public BigDecimal getFeeCollected() { return feeCollected; }
    public void setFeeCollected(BigDecimal feeCollected) { this.feeCollected = feeCollected; }
    public BigDecimal getFeeDue() { return feeDue; }
    public void setFeeDue(BigDecimal feeDue) { this.feeDue = feeDue; }
}
