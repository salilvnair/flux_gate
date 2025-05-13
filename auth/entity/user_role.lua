local UserRole = {
    __metadata = {
        table = "user_roles",
        columns = {
            id = { column = "id", id = true },
            userId = { column = "user_id" },
            roleId = { column = "role_id" }
        }
    }
}
return UserRole