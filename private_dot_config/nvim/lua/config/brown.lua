local M = {}
Brown = M

M.keymaps = {}

function M.keymaps:add(arg)
  local mode = arg.mode or "n"
  arg.mode = nil
  local lhs = arg[1]
  local rhs = arg[2]
  local opts = {}
  for k, v in pairs(arg) do
    if type(k) == "string" then
      opts[k] = v
    end
  end
  vim.keymap.set(mode, lhs, rhs, opts)
end

local KeyGroup = {}
KeyGroup.__index = KeyGroup

function KeyGroup.new(prefix, desc)
  local self = setmetatable({}, KeyGroup)

  self.prefix = prefix
  self.desc = desc

  return self
end

function KeyGroup:add(...)
  local args = { ... }
  for _, arg in ipairs(args) do
    arg[1] = self.prefix .. arg[1]
    M.keymaps:add(arg)
  end
end

M.keymaps.f = KeyGroup.new("<leader>f", "[F]ile")
M.keymaps.t = KeyGroup.new("<leader>t", "[T]oggle")
M.keymaps.w = KeyGroup.new("<leader>w", "[W]indow")
M.keymaps.b = KeyGroup.new("<leader>b", "[B]uffer")
M.keymaps.g = KeyGroup.new("<leader>g", "[G]it")
M.keymaps.s = KeyGroup.new("<leader>s", "[S]earch")

M.which_key_spec = {}
local i = 1
for _, v in pairs(M.keymaps) do
  M.which_key_spec[i] = { v.prefix, group = v.desc }
  i = i + 1
end

M.masondeps = {}
function M:add_dep(mason_dep_name)
  table.insert(self.masondeps, mason_dep_name)
end
