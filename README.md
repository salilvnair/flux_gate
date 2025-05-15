```sql

CREATE TABLE fluxgate_config (
    id INT AUTO_INCREMENT PRIMARY KEY,
    config json NOT NULL,
    modified timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    user_id varchar(50) NOT NULL,
  	notes varchar(255) DEFAULT NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

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

```bash

export LUAJIT_DIR='/usr/local/openresty/luajit'
luarocks --lua-dir=$LUAJIT_DIR --lua-version=5.1 install luasocket
luarocks --lua-dir=$LUAJIT_DIR --lua-version=5.1 install lua-resty-openssl 
luarocks --lua-dir=$LUAJIT_DIR --lua-version=5.1 install lua-resty-http
luarocks --lua-dir=$LUAJIT_DIR --lua-version=5.1 install lua-resty-jwt

```