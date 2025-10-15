return {
  "Olical/conjure",
  ft = { "scheme", "clojure", "lisp", "racket" },
  lazy = true,
  init = function()
    vim.g["conjure#filetypes"] = { "scheme", "clojure", "lisp", "racket" }
    vim.g["conjure#filetype#scheme"] = "conjure.client.guile.socket"
  end,
}
