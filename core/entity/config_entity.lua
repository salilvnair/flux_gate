local FluxGateConfig = {
    __metadata = {
        table = "fluxgate_config",
        id = "id",
        columns = {
            id = { column = "id", id = true },
            config = { column = "config" },
            modified = { column = "modified" },
            userId = { column = "user_id" },
            notes = { column = "notes" },
        }
    }
}

return FluxGateConfig