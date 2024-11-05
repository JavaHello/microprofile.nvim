local M = {}
local config = require("microprofile.config")
local vscode = require("microprofile.vscode")
local util = require("microprofile.util")

local root_dir = function()
  return vim.loop.cwd()
end

local microprofilels_path = function()
  if config.ls_path then
    return config.ls_path
  end
  local qls = vscode.find_one("/redhat.vscode-microprofile-*/server")
  if qls then
    return qls
  end
end

local function microprofile_ls_cmd(java_cmd)
  local microprofile_ls_path = microprofilels_path()
  if not microprofile_ls_path then
    vim.notify("Microprofile LS is not installed", vim.log.levels.WARN)
    return
  end
  local classpath = {}
  table.insert(classpath, microprofile_ls_path .. "/org.eclipse.lsp4mp.ls-uber.jar")
  vim.list_extend(classpath, config.microprofile_extensions_jar)

  local cmd = {
    java_cmd or util.java_bin(),
    "-XX:TieredStopAtLevel=1",
    "-Xmx1G",
    "-XX:+UseZGC",
    "-cp",
    table.concat(classpath, util.is_win and ";" or ":"),
    "org.eclipse.lsp4mp.ls.MicroProfileServerLauncher",
  }

  return cmd
end

local ls_config = {
  name = "microprofile_ls",
  filetypes = { "java", "yaml", "jproperties" },
  init_options = {},
  settings = {
    microprofile_ls = {},
  },
  handlers = {},
  commands = {},
  get_language_id = function(bufnr, filetype)
    if filetype == "jproperties" then
      local filename = vim.api.nvim_buf_get_name(bufnr)
      if util.is_microprofile_properties_file(filename) then
        return "microprofile-properties"
      end
    end
    return filetype
  end,
}

---@param opts table<string, any>
M.setup = function(opts)
  ls_config = vim.tbl_deep_extend("keep", ls_config, opts)
  local capabilities = ls_config.capabilities or vim.lsp.protocol.make_client_capabilities()
  capabilities = vim.tbl_deep_extend("keep", capabilities, {
    commands = {
      commandsKind = {
        valueSet = {
          "microprofile.command.configuration.update",
          "microprofile.command.open.uri",
        },
      },
    },
    completion = {
      skipSendingJavaCompletionThroughLanguageServer = false,
    },
    shouldLanguageServerExitOnShutdown = true,
  })
  ls_config.capabilities = capabilities
  if not ls_config.root_dir then
    ls_config.root_dir = root_dir()
  end
  ls_config.cmd = (ls_config.cmd and #ls_config.cmd > 0) and ls_config.cmd or microprofile_ls_cmd(config.java_bin)
  if not ls_config.cmd then
    return
  end
  ls_config.init_options.workspaceFolders = ls_config.root_dir

  local group = vim.api.nvim_create_augroup("microprofile_ls", { clear = true })
  vim.api.nvim_create_autocmd({ "FileType" }, {
    group = group,
    pattern = { "java", "yaml", "jproperties" },
    desc = "Microprofile Language Server",
    callback = function(e)
      if e.file == "java" and vim.bo[e.buf].buftype == "nofile" then
        return
      end
      if vim.endswith(e.file, ".yaml") or vim.endswith(e.file, ".yml") then
        if not util.is_application_yml_file(e.file) then
          return
        end
      elseif vim.endswith(e.file, ".properties") then
        if not util.is_application_properties_file(e.file) then
          return
        end
      end
      vim.lsp.start(ls_config, { bufnr = e.buf })
    end,
  })
end

return M
