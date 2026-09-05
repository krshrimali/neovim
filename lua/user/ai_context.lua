-- AI context builder: sends function + enclosing type signature + diagnostics to sidekick
local M = {}

-- Node types that represent a function/method
local FUNCTION_TYPES = {
  function_definition = true,
  function_declaration = true,
  method_definition = true,
  method_declaration = true,
  function_item = true, -- Rust
  fn_item = true, -- Rust (some grammars)
  ["function"] = true,
  local_function = true,
}

-- Node types that represent an enclosing type/class/impl block
local ENCLOSING_TYPE_TYPES = {
  impl_item = true, -- Rust: impl Foo / impl Trait for Foo
  trait_item = true, -- Rust: trait Foo
  class_definition = true, -- Python: class Foo(Bar):
  class_declaration = true, -- TS/JS/Java/C++
  class_specifier = true, -- C++: class Foo {
  struct_item = true, -- Rust: struct Foo (when methods inside)
}

-- Extract the "header" of a node: everything up to and including the first { or :
-- Falls back to just the first line if neither is found within a few lines.
local function node_header(bufnr, node)
  local sr, sc, er, _ = node:range()
  -- Grab up to 5 lines to find the opening delimiter
  local max_line = math.min(sr + 4, er)
  local lines = vim.api.nvim_buf_get_lines(bufnr, sr, max_line + 1, false)
  local header_lines = {}
  for _, line in ipairs(lines) do
    table.insert(header_lines, line)
    -- Stop after the line that opens the block
    if line:match "{%s*$" or line:match ":%s*$" then break end
  end
  return table.concat(header_lines, "\n")
end

-- Walk up the AST from a node to find an enclosing type block
local function find_enclosing_type(node)
  local parent = node:parent()
  while parent do
    if ENCLOSING_TYPE_TYPES[parent:type()] then return parent end
    parent = parent:parent()
  end
  return nil
end

-- Collect diagnostics within a line range and format them as a string
local function diagnostics_in_range(bufnr, sr, er)
  local all = vim.diagnostic.get(bufnr)
  local in_range = vim.tbl_filter(function(d) return d.lnum >= sr and d.lnum <= er end, all)
  if #in_range == 0 then return nil end

  local severity_label = { [1] = "ERROR", [2] = "WARN", [3] = "INFO", [4] = "HINT" }
  local lines = {}
  for _, d in ipairs(in_range) do
    local sev = severity_label[d.severity] or "DIAG"
    table.insert(lines, string.format("  line %d [%s]: %s", d.lnum + 1, sev, d.message))
  end
  return table.concat(lines, "\n")
end

function M.send_function_with_context()
  local ok, parser = pcall(vim.treesitter.get_parser, 0)
  if not ok or not parser then
    vim.notify("Treesitter parser not available for this filetype", vim.log.levels.ERROR)
    return
  end
  parser:parse()

  local node = vim.treesitter.get_node()
  if not node then
    vim.notify("No treesitter node at cursor", vim.log.levels.WARN)
    return
  end

  -- Walk up to find enclosing function
  while node do
    if FUNCTION_TYPES[node:type()] then break end
    node = node:parent()
  end
  if not node then
    vim.notify("No parent function found", vim.log.levels.WARN)
    return
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local sr, _, er, _ = node:range()
  local fn_lines = vim.api.nvim_buf_get_lines(bufnr, sr, er + 1, false)
  local fn_text = table.concat(fn_lines, "\n")
  local path = vim.fn.fnamemodify(vim.fn.expand "%", ":.")

  -- Build context parts
  local parts = {}

  -- 1. Enclosing type signature (class/impl/trait)
  local enclosing = find_enclosing_type(node)
  if enclosing then
    local header = node_header(bufnr, enclosing)
    table.insert(parts, "-- context: enclosing type\n" .. header)
  end

  -- 2. Function with file location
  table.insert(parts, string.format("-- %s:%d-%d\n%s", path, sr + 1, er + 1, fn_text))

  -- 3. Diagnostics in function range
  local diag_str = diagnostics_in_range(bufnr, sr, er)
  if diag_str then table.insert(parts, "-- diagnostics\n" .. diag_str) end

  local msg = table.concat(parts, "\n\n")
  -- Pass as `text` (sidekick.Text[]) to bypass template rendering,
  -- which would misinterpret `{...}` in Rust/C code as context variables.
  local text = vim.tbl_map(function(line) return { { line } } end, vim.split(msg, "\n", { plain = true }))
  require("sidekick.cli").send { text = text }
end

return M
