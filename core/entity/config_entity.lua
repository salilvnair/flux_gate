local FluxGateConfig = {
    __metadata = {
        table = "fluxgate_config",
        columns = {
            id = { column = "id", id = true },
            config = { column = "config" },
            modified = { column = "modified_timestamp" },
            userId = { column = "user_id" },
            notes = { column = "notes" },
        }
    }
}

return FluxGateConfig