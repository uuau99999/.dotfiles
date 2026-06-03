local M = {}

local eslint_config_files = {
  ".eslintrc",
  ".eslintrc.js",
  ".eslintrc.cjs",
  ".eslintrc.yaml",
  ".eslintrc.yml",
  ".eslintrc.json",
  "eslint.config.js",
  "eslint.config.mjs",
  "eslint.config.cjs",
  "eslint.config.ts",
  "eslint.config.mts",
  "eslint.config.cts",
}

local package_lock_files = {
  "package-lock.json",
  "yarn.lock",
  "pnpm-lock.yaml",
  "bun.lockb",
  "bun.lock",
}

local js_filetypes = {
  javascript = true,
  javascriptreact = true,
  typescript = true,
  typescriptreact = true,
  vue = true,
}

local function stat(path)
  return path and vim.uv.fs_stat(path) or nil
end

local function path_exists(path)
  return stat(path) ~= nil
end

local function search_path(path)
  if not path or path == "" then
    return vim.fn.getcwd()
  end

  local path_stat = stat(path)
  if path_stat and path_stat.type == "file" then
    return vim.fs.dirname(path)
  end

  return path
end

local function read_package_json(path)
  local ok, lines = pcall(vim.fn.readfile, path)
  if not ok then
    return nil
  end

  local ok_json, package = pcall(vim.json.decode, table.concat(lines, "\n"))
  if ok_json and type(package) == "table" then
    return package
  end
end

local function has_dependency(package, name)
  for _, field in ipairs({ "dependencies", "devDependencies", "peerDependencies", "optionalDependencies" }) do
    local deps = package[field]
    if type(deps) == "table" and deps[name] ~= nil then
      return true
    end
  end

  return false
end

local function has_package_json_eslint_config(path)
  local package = read_package_json(path)
  return package and package.eslintConfig ~= nil
end

function M.is_js_filetype(filetype)
  return js_filetypes[filetype] == true
end

function M.find_workspace_root(path)
  return vim.fs.root(path, package_lock_files)
    or vim.fs.root(path, ".git")
    or vim.fs.root(path, "package.json")
    or vim.fn.getcwd()
end

function M.find_eslint_config(path)
  local current = search_path(path)
  local workspace_root = M.find_workspace_root(current)
  local stop_dir = workspace_root and vim.fs.dirname(workspace_root)

  while current and current ~= "" do
    for _, config_file in ipairs(eslint_config_files) do
      if path_exists(vim.fs.joinpath(current, config_file)) then
        return current
      end
    end

    if has_package_json_eslint_config(vim.fs.joinpath(current, "package.json")) then
      return current
    end

    if stop_dir and current == stop_dir then
      return nil
    end

    local parent = vim.fs.dirname(current)
    if not parent or parent == current then
      return nil
    end
    current = parent
  end
end

function M.find_eslint_package(path)
  local current = search_path(path)

  for _, node_modules in
    ipairs(vim.fs.find("node_modules", {
      path = current,
      upward = true,
      type = "directory",
      limit = math.huge,
    }))
  do
    local eslint_dir = vim.fs.joinpath(node_modules, "eslint")
    local eslint_package = vim.fs.joinpath(eslint_dir, "package.json")
    local eslint_api = vim.fs.joinpath(eslint_dir, "lib", "api.js")
    local eslint_class = vim.fs.joinpath(eslint_dir, "lib", "eslint", "eslint.js")
    if path_exists(eslint_package) then
      if path_exists(eslint_api) or path_exists(eslint_class) then
        return eslint_package
      end
    end
  end
end

function M.has_pnp_eslint(path)
  local current = search_path(path)

  for _, package_json in
    ipairs(vim.fs.find("package.json", {
      path = current,
      upward = true,
      type = "file",
      limit = math.huge,
    }))
  do
    local root = vim.fs.dirname(package_json)
    local has_pnp = path_exists(vim.fs.joinpath(root, ".pnp.cjs")) or path_exists(vim.fs.joinpath(root, ".pnp.js"))
    local package = has_pnp and read_package_json(package_json) or nil
    if package and has_dependency(package, "eslint") then
      return true
    end
  end

  return false
end

function M.has_eslint_package(path)
  return M.find_eslint_package(path) ~= nil or M.has_pnp_eslint(path)
end

function M.should_use_eslint(path)
  return M.find_eslint_config(path) ~= nil and M.has_eslint_package(path)
end

return M
