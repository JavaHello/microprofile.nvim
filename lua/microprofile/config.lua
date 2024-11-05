---@class microprofile.Config
---@field ls_path? string The path to the language server jar path.
---@field jdtls_name string The name of the JDTLS language server. default: "jdtls"
---@field java_bin? string The path to the java command.
---@field microprofile_extensions_jar string[] The path to the microprofile extensions jar.
---@field jdt_extensions_path? string The path to the JDT extensions path.
---@field jdt_extensions_jars string[] The JDT extensions jars.

---@type microprofile.Config
local M = {
  ls_path = nil,
  jdtls_name = "jdtls",
  java_bin = nil,
  microprofile_extensions_jar = {},
  jdt_extensions_path = nil,
  jdt_extensions_jars = {
    "org.eclipse.lsp4mp.jdt.core.jar",
    "io.smallrye.common.smallrye-common-constraint.jar",
    "io.smallrye.common.smallrye-common-expression.jar",
    "io.smallrye.common.smallrye-common-function.jar",
    "org.jboss.logging.jboss-logging.jar",
  },
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
