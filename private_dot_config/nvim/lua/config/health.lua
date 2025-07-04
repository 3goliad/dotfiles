local check_version = function()
  local verstr = tostring(vim.version())
  if not vim.version.ge then
    vim.health.error(
      string.format(
        "Neovim out of date: '%s'. Upgrade to latest stable or nightly",
        verstr
      )
    )
    return
  end

  if vim.version.ge(vim.version(), "0.10-dev") then
    vim.health.ok(string.format("Neovim version is: '%s'", verstr))
  else
    vim.health.error(
      string.format(
        "Neovim out of date: '%s'. Upgrade to latest stable or nightly",
        verstr
      )
    )
  end
end

local check_external_reqs = function()
  -- Basic utils: `git`, `make`, `unzip`
  for _, exe in ipairs({ "git", "make", "unzip", "rg" }) do
    local is_executable = vim.fn.executable(exe) == 1
    if is_executable then
      vim.health.ok(string.format("Found executable: '%s'", exe))
    else
      vim.health.warn(string.format("Could not find executable: '%s'", exe))
    end
  end

  return true
end

local check_mason_deps = function()
  local registry = require("mason-registry")
  for _, dep in ipairs(Brown.masondeps) do
    if registry.is_installed(dep) then
      vim.health.ok(string.format("Mason package '%s' is installed", dep))
    else
      vim.health.warn(string.format("Mason package '%s' is not installed", dep))
    end
  end
end

return {
  check = function()
    vim.health.start("personal")
    vim.health.info("System Information: " .. vim.inspect(vim.uv.os_uname()))

    check_version()
    check_external_reqs()
    check_mason_deps()
  end,
}
