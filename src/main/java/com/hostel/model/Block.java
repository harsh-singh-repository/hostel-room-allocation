package com.hostel.model;

public class Block {
    private int blockId;
    private String blockName;
    private String gender;
    private String wardenName;
    private String description;
    private int totalRooms;
    private int totalBeds;
    private int occupiedBeds;

    public int getFreeBeds() {
        return Math.max(totalBeds - occupiedBeds, 0);
    }

    public int getOccupancyPct() {
        return totalBeds == 0 ? 0 : Math.round(occupiedBeds * 100f / totalBeds);
    }

    public String getGenderLabel() {
        return "F".equals(gender) ? "Girls" : "Boys";
    }

    public int getBlockId() { return blockId; }
    public void setBlockId(int blockId) { this.blockId = blockId; }
    public String getBlockName() { return blockName; }
    public void setBlockName(String blockName) { this.blockName = blockName; }
    public String getGender() { return gender; }
    public void setGender(String gender) { this.gender = gender; }
    public String getWardenName() { return wardenName; }
    public void setWardenName(String wardenName) { this.wardenName = wardenName; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public int getTotalRooms() { return totalRooms; }
    public void setTotalRooms(int totalRooms) { this.totalRooms = totalRooms; }
    public int getTotalBeds() { return totalBeds; }
    public void setTotalBeds(int totalBeds) { this.totalBeds = totalBeds; }
    public int getOccupiedBeds() { return occupiedBeds; }
    public void setOccupiedBeds(int occupiedBeds) { this.occupiedBeds = occupiedBeds; }
}
