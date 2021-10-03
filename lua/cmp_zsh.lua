local cmp = require'cmp'
local luv = require'luv'

local M = {}

local script_abspath = function()
  -- これでこの関数を呼出したファイルの絶対パスが取得できる
  pprint(debug.getinfo(2, 'S').source:sub(2))
  return debug.getinfo(2, 'S').source:sub(2)
end
local capture_script_path = script_abspath():match('(.*)/lua/cmp_zsh.lua$') .. '/bin/cmp_capture.zsh'

M.new = function()
  local self = setmetatable({}, { __index = M })
  return self
end

M.get_keyword_pattern = function()
  return [[\S\+]]
end

-- -- 利用可能かどうかを返す
-- M.is_available = function()
--   return vim.bo.filetype == 'zsh'
-- end

local line = function(str)
  str = str:gsub('\r', '')
  local s, e, cap = string.find(str, '\n')
  if not s then
    return nil, str
  end
  local l = string.sub(str, 1, s - 1)
  local rest = string.sub(str, e + 1)
  return l, rest
end

-- LSP の仕様に沿ったものを返す
-- https://microsoft.github.io/language-server-protocol/specifications/specification-3-17/#completionItem
-- TODO: documentation
local result = function(words)
  local items = {}
  for _, v in ipairs(words) do
    -- table.insert(items, { label=v.label, documentation = v.documentation })
    table.insert(items, {
      label = v.label,
      documentation = v.documentation,
      dup = 0,
    })
  end
  return { items = items, isIncomplete = true }
end

local pipes = function()
  local stdin = luv.new_pipe(false)
  local stdout = luv.new_pipe(false)
  local stderr = luv.new_pipe(false)
  return { stdin, stdout, stderr }
end

M.complete = function(self, request, callback)
  -- local q = string.sub(request.context.cursor_before_line, request.offset)
  local q = request.context.cursor_before_line
  local stdioe = pipes()
  local handle, pid
  local buf = ''
  local words = {}

  do
    local spawn_params = {
      args = { capture_script_path, q },
      stdio = stdioe
    }

    handle, pid = luv.spawn('zsh', spawn_params, function(code, signal)
      stdioe[1]:close()
      stdioe[2]:close()
      stdioe[3]:close()
      handle:close()
      vim.schedule_wrap(callback)(result(words))
    end)

    if handle == nil then
      debug.log(string.format("start zsh failed: %s", pid))
    end

    luv.read_start(stdioe[2], function(err, chunk)
      assert(not err, err)
      if chunk then
        buf = buf .. chunk
      end
      while true do
        pprint(buf)
        local l, rest = line(buf)
        if l == nil then
          break
        end
        buf = rest
        local pieces = vim.split(l, ' -- ', true)
        if pieces[1] ~= "" then
          if #pieces > 1 then
            table.insert(words, {label = pieces[1], documentation = pieces[2]})
          else
            table.insert(words, {label = pieces[1]})
          end
        end
      end
    end)
  end
end

return M
