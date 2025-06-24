Brown = {
  keymaps = {
    which_key_spec = {},
  },
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
  self[name].add = function(self, arg)
    local lhs = self.prefix .. arg[1]
    parent:add({ lhs, unpack(arg, 2) })
  end

  for _, mapping in ipairs(options) do
    self[name]:add(mapping)
  end
end
