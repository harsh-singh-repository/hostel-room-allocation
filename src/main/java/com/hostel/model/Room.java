package com.hostel.model;

public class Room {
    private int roomId;
    private String roomNo;
    private int floorNo;
    private String roomType;
    private int capacity;
    private int occupied;
    private String status;
    private int blockId;
    private String blockName;
    private String gender;

    public int getFreeBeds() {
        return capacity - occupied;
    }

    public boolean isFull() {
        return occupied >= capacity;
    }

    public boolean isMaintenance() {
        return "MAINTENANCE".equals(status);
    }

    /** Used by the room grid: one entry per bed, true = occupied. */
    public boolean[] getBeds() {
        boolean[] beds = new boolean[capacity];
        for (int i = 0; i < capacity; i++) {
            beds[i] = i < occupied;
        }
        return beds;
    }

    public int getRoomId() { return roomId; }
    public void setRoomId(int roomId) { this.roomId = roomId; }
    public String getRoomNo() { return roomNo; }
    public void setRoomNo(String roomNo) { this.roomNo = roomNo; }
    public int getFloorNo() { return floorNo; }
    public void setFloorNo(int floorNo) { this.floorNo = floorNo; }
    public String getRoomType() { return roomType; }
    public void setRoomType(String roomType) { this.roomType = roomType; }
    public int getCapacity() { return capacity; }
    public void setCapacity(int capacity) { this.capacity = capacity; }
    public int getOccupied() { return occupied; }
    public void setOccupied(int occupied) { this.occupied = occupied; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public int getBlockId() { return blockId; }
    public void setBlockId(int blockId) { this.blockId = blockId; }
    public String getBlockName() { return blockName; }
    public void setBlockName(String blockName) { this.blockName = blockName; }
    public String getGender() { return gender; }
    public void setGender(String gender) { this.gender = gender; }
}
