local MiniMisc = require("mini.misc")

local Vitest = {}
local H = {}

Vitest.setup = function()
  _G.Vitest = Vitest
end

Vitest.edit_test_or_subject = function(buf_id)
  local root_dir = MiniMisc.find_root(buf_id, { ".git", "package.json" })
  if root_dir == nil then
    vim.notify("Couldn't find a root dir for this file!", vim.log.levels.ERROR)
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

  local file_name = vim.fs.basename(file_path)

  local target_pattern
  local m_start, m_end = vim.regex("\\v\\.(test|spec)\\."):match_str(file_name)
  if m_start and m_end then
    target_pattern = H.subject_file_name_pattern(
      file_name:sub(0, m_start) .. file_name:sub(m_end)
    )
  else
    target_pattern = H.test_file_name_pattern(file_name)
  end

  local found_file
  for dir in vim.fs.parents(file_path) do
    local results = vim.fs.find(function(name)
      return target_pattern:match(name)
    end, { type = "file", path = dir })

    if next(results) ~= nil then
      found_file = results[1]
      break
    end

    if dir == root_dir then
      break
    end
  end

  if found_file then
    vim.cmd.edit(found_file)
  else
    vim.notify("couldn't identify file! (file: '" .. file_path .. "')")
  end
end

H.subject_file_name_pattern = function(file_name)
  local root_name = vim.fn.fnamemodify(file_name, ":r")
  return vim.re.compile(
    "'" .. root_name .. "' '.' ('m' / 'c')? ('js' / 'ts') 'x'?"
  )
end

H.test_file_name_pattern = function(file_name)
  local root_name = vim.fn.fnamemodify(file_name, ":r")
  return vim.re.compile(
    "'"
      .. root_name
      .. "' ('.test' / '.spec') "
      .. "'.' ('m' / 'c')? ('js' / 'ts') 'x'?"
  )
end

return Vitest
