-- ── :DotnetLaunchSettings — scaffold Properties/launchSettings.json ─────────
vim.api.nvim_create_user_command("DotnetLaunchSettings", function()
  require("dotnet.ui.picker").runnable({ prompt = "Add launchSettings.json to:" }, function(csproj)
    if not csproj then return end

    local project_dir  = vim.fn.fnamemodify(csproj, ":h")
    local project_name = vim.fn.fnamemodify(csproj, ":t:r")
    local props_dir    = project_dir .. "/Properties"
    local target       = props_dir .. "/launchSettings.json"

    if vim.fn.filereadable(target) == 1 then
      vim.notify("launchSettings.json already exists — opening it.", vim.log.levels.INFO)
      vim.cmd("edit " .. vim.fn.fnameescape(target))
      return
    end

    vim.fn.mkdir(props_dir, "p")

    local template = string.format([[{
  "$schema": "https://json.schemastore.org/launchsettings.json",
  "profiles": {
    "%s": {
      "commandName": "Project",
      "dotnetRunMessages": true,
      "launchBrowser": false,
      "applicationUrl": "https://localhost:7000;http://localhost:5000",
      "environmentVariables": {
        "ASPNETCORE_ENVIRONMENT": "Development"
      }
    },
    "IIS Express": {
      "commandName": "IISExpress",
      "launchBrowser": true,
      "launchUrl": "",
      "applicationUrl": "https://localhost:44300;http://localhost:5000",
      "environmentVariables": {
        "ASPNETCORE_ENVIRONMENT": "Development"
      }
    }
  }
}
]], project_name)

    local f = io.open(target, "w")
    if not f then
      vim.notify("Failed to write " .. target, vim.log.levels.ERROR)
      return
    end
    f:write(template)
    f:close()

    vim.notify("Created " .. target, vim.log.levels.INFO)
    vim.cmd("edit " .. vim.fn.fnameescape(target))
  end)
end, { desc = "Scaffold Properties/launchSettings.json for nearest .csproj" })
