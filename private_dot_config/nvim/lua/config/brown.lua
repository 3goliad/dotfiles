Brown = {
  keymaps = {
    which_key_spec = {},
  },
  masondeps = {},
}

function Brown.keymaps:add(arg)
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

function Brown.keymaps:add_group(name, options)
  if self[name] ~= nil then
    error("Key group name '" .. tostring(name) .. "' is taken")
  end

  local desc = options.desc
  local prefix = options.prefix or ("<leader>" .. name)
  table.insert(self.which_key_spec, { prefix, group = desc })
  self[name] = { desc = desc, prefix = prefix }

  local parent = self
  self[name].add = function(self, ...)
    local args = { ... }
    for _, arg in ipairs(args) do
      local lhs = self.prefix .. arg[1]
      parent:add({ lhs, unpack(arg, 2) })
    end
  end

  for _, mapping in ipairs(options) do
    self[name]:add(mapping)
  end
end

Brown.keymaps:add_group("f", {
  desc = "[F]ile",
})
Brown.keymaps:add_group("t", {
  desc = "[T]oggle",
})
Brown.keymaps:add_group("w", {
  desc = "[W]indow",
})
Brown.keymaps:add_group("b", {
  desc = "[B]uffer",
})

function Brown:add_dep(mason_dep_name)
  table.insert(self.masondeps, mason_dep_name)
end
