package dal;

import java.util.logging.Level;
import java.util.logging.Logger;
import model.Employee;
import model.Department;
import model.iam.User;

/**
 * Service DAO để đơn giản hóa việc tạo user hoàn chỉnh
 * Bao gồm: Employee, User, và Enrollment
 * 
 * @author System
 */
public class UserServiceDAO {
    
    private static final Logger logger = Logger.getLogger(UserServiceDAO.class.getName());
    private UserDBContext userDB;
    private EmployeeDBContext employeeDB;
    
    public UserServiceDAO() {
        this.userDB = new UserDBContext();
        this.employeeDB = new EmployeeDBContext();
    }
    
    /**
     * Tạo user hoàn chỉnh (Employee + User + Enrollment + UserRole)
     * 
     * @param username Tên đăng nhập
     * @param password Mật khẩu
     * @param displayname Tên hiển thị
     * @param createNewEmployee true nếu tạo Employee mới, false nếu dùng Employee đã có
     * @param employeeId ID của Employee đã có (chỉ dùng khi createNewEmployee = false)
     * @param divisionId ID của Division (chỉ dùng khi createNewEmployee = true)
     * @param supervisorId ID của Supervisor (chỉ dùng khi createNewEmployee = true, có thể null)
     * @param roleId ID của Role để gán cho User
     * @return UserResult chứa thông tin kết quả
     */
    public UserResult createUser(String username, String password, String displayname, 
                                  boolean createNewEmployee, Integer employeeId,
                                  Integer divisionId, Integer supervisorId, Integer roleId) {
        UserResult result = new UserResult();
        
        try {
            // Validate input
            if (username == null || username.trim().isEmpty() ||
                password == null || password.trim().isEmpty() ||
                displayname == null || displayname.trim().isEmpty()) {
                result.setSuccess(false);
                result.setErrorMessage("Vui lòng nhập đầy đủ thông tin.");
                logger.warning("Validation failed: missing required fields");
                return result;
            }
            
            // Kiểm tra độ dài password
            if (password.length() < 6) {
                result.setSuccess(false);
                result.setErrorMessage("Mật khẩu phải có ít nhất 6 ký tự.");
                logger.warning("Validation failed: password too short");
                return result;
            }
            
            // Kiểm tra username đã tồn tại chưa
            if (userDB.existsByUsername(username)) {
                result.setSuccess(false);
                result.setErrorMessage("Username đã tồn tại. Vui lòng chọn username khác.");
                logger.warning("Username already exists: " + username);
                return result;
            }
            
            int finalEmployeeId = 0;
            
            // Xử lý Employee
            if (createNewEmployee) {
                // Tạo Employee mới với Division và Supervisor
                logger.info("Creating new employee with name: " + displayname);
                Employee newEmployee = new Employee();
                newEmployee.setName(displayname);
                
                // Set Division nếu có
                if (divisionId != null && divisionId > 0) {
                    Department dept = new Department();
                    dept.setId(divisionId);
                    newEmployee.setDept(dept);
                }
                
                // Set Supervisor nếu có
                if (supervisorId != null && supervisorId > 0) {
                    Employee supervisor = new Employee();
                    supervisor.setId(supervisorId);
                    newEmployee.setSupervisor(supervisor);
                }
                
                finalEmployeeId = employeeDB.insertAndReturnId(newEmployee);
                
                if (finalEmployeeId <= 0) {
                    result.setSuccess(false);
                    result.setErrorMessage("Không thể tạo Employee. Vui lòng thử lại.");
                    logger.severe("Failed to create employee");
                    return result;
                }
                logger.info("Employee created with ID: " + finalEmployeeId);
            } else {
                // Sử dụng Employee đã có
                if (employeeId == null || employeeId <= 0) {
                    result.setSuccess(false);
                    result.setErrorMessage("Vui lòng chọn Employee hoặc tạo Employee mới.");
                    logger.warning("No employee selected");
                    return result;
                }
                finalEmployeeId = employeeId;
                logger.info("Using existing employee ID: " + finalEmployeeId);
            }
            
            // Tạo User mới
            logger.info("Creating new user with username: " + username);
            User newUser = new User();
            newUser.setUsername(username);
            newUser.setPassword(password);
            newUser.setDisplayname(displayname);
            
            Integer userId = userDB.insertAndReturnId(newUser);
            
            if (userId == null || userId <= 0) {
                result.setSuccess(false);
                result.setErrorMessage("Không thể tạo User. Vui lòng thử lại.");
                logger.severe("Failed to create user - userId is null or <= 0");
                return result;
            }
            logger.info("User created with ID: " + userId);
            
            // Liên kết User với Employee qua Enrollment
            logger.info("Creating enrollment for userId: " + userId + ", employeeId: " + finalEmployeeId);
            boolean enrollmentCreated = userDB.createOrActivateEnrollment(userId, finalEmployeeId);
            
            if (!enrollmentCreated) {
                // Xóa User vừa tạo nếu enrollment thất bại
                logger.warning("Enrollment failed, deleting user with ID: " + userId);
                userDB.deleteById(userId);
                result.setSuccess(false);
                result.setErrorMessage("Không thể liên kết User với Employee. Vui lòng thử lại.");
                return result;
            }
            
            // Gán Role cho User
            if (roleId != null && roleId > 0) {
                logger.info("Assigning role " + roleId + " to user " + userId);
                boolean roleAssigned = userDB.assignRole(userId, roleId);
                if (!roleAssigned) {
                    logger.warning("Failed to assign role, but user and enrollment were created");
                    // Không rollback vì user đã được tạo, chỉ log warning
                } else {
                    logger.info("Role assigned successfully");
                }
            }
            
            // Thành công
            result.setSuccess(true);
            result.setUserId(userId);
            result.setEmployeeId(finalEmployeeId);
            result.setUser(newUser);
            logger.info("=== User creation completed successfully ===");
            
        } catch (Exception e) {
            logger.severe("=== User creation failed ===");
            logger.log(Level.SEVERE, "Error creating user", e);
            result.setSuccess(false);
            result.setErrorMessage("Có lỗi xảy ra: " + e.getMessage());
        } finally {
            // Đóng connection sau khi hoàn thành tất cả các thao tác
            if (userDB != null) {
                try {
                    userDB.closeConnection();
                } catch (Exception e) {
                    logger.warning("Error closing userDB connection: " + e.getMessage());
                }
            }
            if (employeeDB != null) {
                try {
                    employeeDB.closeConnection();
                } catch (Exception e) {
                    logger.warning("Error closing employeeDB connection: " + e.getMessage());
                }
            }
        }
        
        return result;
    }
    
    /**
     * Class để chứa kết quả tạo user
     */
    public static class UserResult {
        private boolean success;
        private String errorMessage;
        private Integer userId;
        private Integer employeeId;
        private User user;
        
        public boolean isSuccess() {
            return success;
        }
        
        public void setSuccess(boolean success) {
            this.success = success;
        }
        
        public String getErrorMessage() {
            return errorMessage;
        }
        
        public void setErrorMessage(String errorMessage) {
            this.errorMessage = errorMessage;
        }
        
        public Integer getUserId() {
            return userId;
        }
        
        public void setUserId(Integer userId) {
            this.userId = userId;
        }
        
        public Integer getEmployeeId() {
            return employeeId;
        }
        
        public void setEmployeeId(Integer employeeId) {
            this.employeeId = employeeId;
        }
        
        public User getUser() {
            return user;
        }
        
        public void setUser(User user) {
            this.user = user;
        }
    }
}

