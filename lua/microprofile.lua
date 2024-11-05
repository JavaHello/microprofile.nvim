local M = {}

---@param opts microprofile.Config
M.setup = function(opts)
  require("microprofile.config")._init(opts)
end

---@param jars string|string[]
M.addMicroprofileJar = function(jars)
  require("microprofile.config")._addMicroprofileJar(jars)
end

M.java_extensions = function()
  local bundles = {}
  local config = require("microprofile.config")
  local function bundle_jar(path)
    for _, jar in ipairs(config.jdt_extensions_jars) do
      if vim.endswith(path, jar) then
        return true
      end
    end
  end
  local microprofile_path = config.jdt_extensions_path
    or require("microprofile.vscode").find_one("/redhat.vscode-microprofile-*/jars")
  if microprofile_path then
    for _, bundle in ipairs(vim.split(vim.fn.glob(microprofile_path .. "/*.jar"), "\n")) do
      if bundle_jar(bundle) then
        table.insert(bundles, bundle)
      end
    end
  end
  return bundles
end

return M
