```sql
CREATE TABLE users (
    user_id VARCHAR(30) PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(150),
    active VARCHAR(3)
);

CREATE TABLE roles (
    role_id INT AUTO_INCREMENT PRIMARY KEY,
    role_name VARCHAR(100) NOT NULL
);


CREATE TABLE user_roles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(30),
    role_id INT,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (role_id) REFERENCES roles(role_id)
);


CREATE INDEX idx_user_roles_user_id ON user_roles(user_id);
CREATE INDEX idx_user_roles_role_id ON user_roles(role_id);

```