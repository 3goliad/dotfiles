return {
  check = function()
    vim.health.start("personal")
    vim.health.info("System Information: " .. vim.inspect(vim.uv.os_uname()))

    for _, exe in ipairs({ "git", "make", "unzip", "rg" }) do
      local is_executable = vim.fn.executable(exe) == 1
      if is_executable then
        vim.health.ok(string.format("Found executable: '%s'", exe))
      else
        vim.health.warn(string.format("Could not find executable: '%s'", exe))
      end
    end

    -- exe = purpose
    local external_devtools = {
      stylua = "Lua formatter",
      ["lua-language-server"] = "Lua LSP",
      ruff = "Python formatter",
    }

    for exe, purpose in pairs(external_devtools) do
      local is_executable = vim.fn.executable(exe) == 1
      if is_executable then
        vim.health.ok(string.format("Found '%s'", exe))
      else
        vim.health.warn(string.format("Could not find '%s' (%s)", exe, purpose))
      end
    end
  end,
}
