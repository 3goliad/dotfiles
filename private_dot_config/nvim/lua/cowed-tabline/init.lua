local M = {}

M.tabpage_name_var = "__CowedTabLine_Name"

function M.get_tab_name(tab_id)
  tab_id = tab_id or 0

  local name = vim.t[tab_id][M.tabpage_name_var]
  if name then
    return name
  end

  local tab_win = vim.api.nvim_tabpage_get_win(tab_id)
  local git_dir = vim.w[tab_win].fugitive_status
  if git_dir then
    local git_repo = vim.fs.dirname(git_dir)
    return "[Git] " .. vim.fs.basename(git_repo)
  end

  local tab_cwd = vim.fn.getcwd(-1, vim.api.nvim_tabpage_get_number(tab_id))
  return vim.fs.basename(tab_cwd)
end

function M.set_tab_name(name, tab_id)
  tab_id = tab_id or 0
  vim.t[tab_id][M.tabpage_name_var] = name
end

function M.find_tab_id_by_name(name)
  local tabpages = vim.api.nvim_list_tabpages()
  for _, tab_id in ipairs(tabpages) do
    if M.get_tab_name(tab_id) == name then
      return tab_id
    end
  end

  return nil
end

function M.render()
  local tabpages = vim.api.nvim_list_tabpages()
  local current = vim.api.nvim_get_current_tabpage()

  local s = ""
  for _, tab_id in ipairs(tabpages) do
    if tab_id == current then
      s = s .. "%#TabLineSel#"
    else
      s = s .. "%#TabLine#"
    end

    s = s .. "%" .. vim.api.nvim_tabpage_get_number(tab_id) .. "T"
    local tab_name = M.get_tab_name(tab_id)
    s = s .. " " .. tab_name .. " "
  end

  s = s .. "%#TabLineFill#%T"

  return s
end

function M.setup()
  vim.o.tabline = "%!v:lua.require'cowed-tabline'.render()"
end

return M
