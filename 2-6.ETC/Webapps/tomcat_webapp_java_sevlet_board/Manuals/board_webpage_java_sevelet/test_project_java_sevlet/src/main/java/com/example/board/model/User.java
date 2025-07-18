// User.java
package com.example.board.model;

public class User {
    private int id;
    private String userId;
    private String passwordHash;
    private String userEmail;
    private String userName;
    private boolean isAdmin;

    // getter

    public int getId() {
        return id;
    }
    public String getUserId() {
        return userId;
    }
    public String getUserName() { 
        return userName; 
    }
    public String getUserPass() {
        return passwordHash;
    }
    public String getUserEmail() {
        return userEmail;
    }
    public boolean isAdmin() { 
        return isAdmin; 
    }

    // setter
    public void setId(int id) {
        this.id = id;
    }
    public void setUserId(String userId) {
        this.userId = userId;
    }
    public void setUserName(String userName) { 
        this.userName = userName; 
    }
    public void setUserPass(String passwordHash) {
        this.passwordHash = passwordHash;
    }
    public void setUserEmail(String userEmail) {
        this.userEmail = userEmail;
    }
    public void setIsAdmin(boolean isAdmin) { 
        this.isAdmin = isAdmin; 
    }
}


