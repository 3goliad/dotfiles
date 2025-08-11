-- vim.o.makeprg = "bundle exec rubocop --format emacs"
-- vim.o.errorformat = "%f:%l:%c: %t: %m," .. vim.o.errorformat

Brown.keymaps.m:add({
  "tt",
  function()
    local root_dir = MiniMisc.find_root(0, { ".git", "Gemfile" })
    if root_dir == nil then
      vim.notify(
        "Couldn't find a root dir for this file!",
        vim.log.levels.ERROR
      )
      return
    end

    local file_path = vim.fs.relpath(root_dir, vim.api.nvim_buf_get_name(0))
    if file_path == nil then
      vim.notify(
        "file path '" .. file_path .. "' is not under '" .. root_dir .. "'",
        vim.log.levels.ERROR
      )
      return
    end

    local is_app_project = vim.fn.isdirectory(root_dir .. "/app")
    local spec_name = string.match(file_path, "^spec/(.*)_spec.rb$")

    if spec_name then
      if is_app_project then
        if vim.startswith(spec_name, "lib/") then
          vim.cmd.edit(root_dir .. "/" .. spec_name .. ".rb")
        else
          vim.cmd.edit(root_dir .. "/app/" .. spec_name .. ".rb")
        end
      else
        vim.cmd.edit(root_dir .. "/lib/" .. spec_name .. ".rb")
      end
      return
    end

    local file_name
    if is_app_project then
      if vim.startswith(file_path, "app/") then
        file_name = string.match(file_path, "^app/(.*).rb$")
      else
        file_name = string.match(file_path, "^(.*).rb$")
      end
    else
      file_name = string.match(file_path, "^lib/(.*).rb$")
    end
    if file_name then
      vim.cmd.edit(root_dir .. "/spec/" .. file_name .. "_spec.rb")
      return
    end

    vim.notify("couldn't identify file! (file: '" .. file_path .. "')")
  end,
  desc = "[T]oggle [T]est file",
  buffer = true,
})
