---@class microprofile.Config
---@field ls_path? string The path to the language server jar path.
---@field jdtls_name string The name of the JDTLS language server. default: "jdtls"
---@field java_cmd? string The path to the java command.
---@field microprofile_extensions_jar string[] The path to the microprofile extensions jar.

---@type microprofile.Config
local M = {
  ls_path = nil,
  jdtls_name = "jdtls",
  java_cmd = nil,
  microprofile_extensions_jar = {},
}

---@param opts microprofile.Config
---@diagnostic disable-next-line: inject-field
M._init = function(opts)
  vim.tbl_deep_extend("keep", opts, M)
end

---@param jars string|string[]
---@diagnostic disable-next-line: inject-field
M._addMicroprofileJar = function(jars)
  if type(jars) == "table" then
    vim.list_extend(M.microprofile_extensions_jar, jars)
  else
    table.insert(M.microprofile_extensions_jar, jars)
  end
end

return M
