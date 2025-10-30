package model;

/**
 * Model cho loại nghỉ phép (LeaveType).
 * Kế thừa từ BaseModel để có thuộc tính ID.
 */
public class LeaveType extends BaseModel {
    
    // ID (leavetype_id) được kế thừa từ BaseModel (dùng String/int ID)
    private String name;
    private int daysAllowed; // Số ngày cho phép (Ví dụ: 12 ngày phép năm)

    // Constructor trống (nên có)
    public LeaveType() {
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public int getDaysAllowed() {
        return daysAllowed;
    }

    public void setDaysAllowed(int daysAllowed) {
        this.daysAllowed = daysAllowed;
    }
    
}