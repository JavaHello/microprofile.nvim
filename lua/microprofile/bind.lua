local M = {}
local jdtls = require("microprofile.jdtls")
local util = require("microprofile.util")

local bind_microprofile_request = function(client, command)
  client.handlers[command] = function(_, result)
    return jdtls.execute_command(command, result)
  end
end

M._bind = false
M._bind_count = 0

local function defer_bind(ms)
  if M._bind_count > 10 then
    vim.notify("Failed to bind microprofile requests", vim.log.levels.ERROR)
    return
  end
  M._bind_count = M._bind_count + 1
  vim.defer_fn(function()
    M.try_bind_microprofile_all_request()
  end, ms)
end
M.try_bind_microprofile_all_request = function()
  if M._bind then
    return
  end

  local client = util.get_microprofile_ls_client()
  if client == nil then
    defer_bind(500)
    return
  end
  M.bind_microprofile_all_request(client)
  M._bind = true
end

M.bind_microprofile_all_request = function(client)
  bind_microprofile_request(client, "microprofile/projectInfo")
  bind_microprofile_request(client, "microprofile/propertyDefinition")
  bind_microprofile_request(client, "microprofile/propertyDocumentation")
  bind_microprofile_request(client, "microprofile/jsonSchemaForProjectInfo")
  bind_microprofile_request(client, "microprofile/java/codeActionResolve")
  bind_microprofile_request(client, "microprofile/java/codeAction")
  bind_microprofile_request(client, "microprofile/java/codeLens")
  bind_microprofile_request(client, "microprofile/java/completion")
  bind_microprofile_request(client, "microprofile/java/definition")
  bind_microprofile_request(client, "microprofile/java/diagnostics")
  bind_microprofile_request(client, "microprofile/java/hover")
  bind_microprofile_request(client, "microprofile/java/workspaceSymbols")
  bind_microprofile_request(client, "microprofile/java/fileInfo")
  bind_microprofile_request(client, "microprofile/java/projectLabels")
  bind_microprofile_request(client, "microprofile/java/workspaceLabels")
  bind_microprofile_request(client, "microprofile/propertiesChanged")
end

return M
