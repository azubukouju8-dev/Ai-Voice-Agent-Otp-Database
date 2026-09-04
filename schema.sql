CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255),
    username VARCHAR(255),
    email VARCHAR(255),
    phone VARCHAR(20),
    balance DECIMAL(10,2) DEFAULT 0,
    bonus DECIMAL(10,2) DEFAULT 0,
    referral_bonus DECIMAL(10,2) DEFAULT 0,
    roi DECIMAL(10,2) DEFAULT 0,
    plan VARCHAR(100),
    status VARCHAR(50),
    verified TINYINT(1) DEFAULT 0
);

CREATE TABLE otp_codes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    phone VARCHAR(20),
    code VARCHAR(10),
    expires_at DATETIME,
    used TINYINT(1) DEFAULT 0
);
