local M = {}
local util = require("microprofile.util")
local MICROPROFILE_SCHEMA = "microprofile"
local MICROPROFILE_SCHEMA_PREFIX = MICROPROFILE_SCHEMA .. "://schema"
M._load_count = 0
M.cache = {}

M.registerYamlSchema = function(buf)
  local uri = vim.uri_from_bufnr(buf)
  local file = vim.uri_to_fname(uri)
  if util.is_application_yml_file(uri) then
    local yamlls = util.get_client("yamlls")
    if M._load_count > 10 then
      vim.notify("Failed to register YAML schema", vim.log.levels.ERROR)
      return
    end
    if yamlls == nil then
      M._load_count = M._load_count + 1
      vim.defer_fn(function()
        M.registerYamlSchema(buf)
      end, 500)
      return
    end
    if not yamlls then
      vim.notify("YAML Language Server not found.")
      return
    end
    local microprofilels = util.get_client("microprofile_ls")
    if not microprofilels then
      vim.notify("MicroProfile Language Server not found.")
      return
    end
    if M.cache[uri] then
      -- Already registered
      return
    end

    microprofilels:request(
      "microprofile/jsonSchemaForProjectInfo",
      { uri = uri, scopes = {
        1,
        2,
      } },
      function(err, result)
        if err then
          vim.notify("Failed to get JSON schema: " .. vim.inspect(err), vim.log.levels.ERROR)
          return
        end
        M.cache[uri] = true
        -- local jsonSchema = vim.json.decode(result.jsonSchema)
        local tmpfile = vim.fn.tempname() .. ".json"
        vim.fn.writefile({ result.jsonSchema }, tmpfile, "s")

        ---@type table<string, any>
        ---@diagnostic disable-next-line: assign-type-mismatch
        local yaml = yamlls.config.settings.yaml or {}
        if not yaml.schemas then
          yaml.schemas = {}
        end
        yaml.schemas[tmpfile] = { file }
        yamlls.config.settings.yaml = yaml
        yamlls:notify("workspace/didChangeConfiguration", { settings = yamlls.config.settings })
      end
    )
  end
end
return M
