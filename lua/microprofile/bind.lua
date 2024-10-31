local M = {}
local jdtls = require("microprofile.jdtls")

local bind_qute_request = function(client, command)
  client.handlers[command] = function(_, result)
    return jdtls.execute_command(command, result)
  end
end

M.bind_qute_all_request = function(client)
  bind_qute_request(client, "microprofile/projectInfo")
  bind_qute_request(client, "microprofile/propertyDefinition")
  bind_qute_request(client, "microprofile/propertyDocumentation")
  bind_qute_request(client, "microprofile/jsonSchemaForProjectInfo")
  bind_qute_request(client, "microprofile/java/codeActionResolve")
  bind_qute_request(client, "microprofile/java/codeAction")
  bind_qute_request(client, "microprofile/java/codeLens")
  bind_qute_request(client, "microprofile/java/completion")
  bind_qute_request(client, "microprofile/java/definition")
  bind_qute_request(client, "microprofile/java/diagnostics")
  bind_qute_request(client, "microprofile/java/hover")
  bind_qute_request(client, "microprofile/java/workspaceSymbols")
  bind_qute_request(client, "microprofile/java/fileInfo")
  bind_qute_request(client, "microprofile/java/projectLabels")
  bind_qute_request(client, "microprofile/java/workspaceLabels")
  bind_qute_request(client, "microprofile/propertiesChanged")
end

return M
