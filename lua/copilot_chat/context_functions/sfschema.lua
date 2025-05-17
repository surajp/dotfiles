local function splitCsv(value)
  local results = {}

  for token in string.gmatch(value or '', '([^,]+)') do
    local trimmed = (token:gsub('^%s+', ''):gsub('%s+$', ''))
    if trimmed ~= '' then
      table.insert(results, trimmed)
    end
  end

  return results
end

local function getOrgId()
  local handle = io.popen('sf org display --json | jq -r .result.id')
  if not handle then return nil end
  local orgId = handle:read('*a'):gsub('%s+', '')
  handle:close()
  return orgId ~= '' and orgId or nil
end

local function cachePath(orgId, objectApiName)
  local home = os.getenv('HOME')
  return string.format('%s/.cache/copilotsfschema/%s/%s.json', home, orgId, objectApiName)
end

local function readCache(path)
  local file = io.open(path, 'r')
  if not file then return nil end
  local content = file:read('*a')
  file:close()
  return content ~= '' and content or nil
end

local function writeCache(path, content)
  local dir = path:match('(.+)/')
  os.execute('mkdir -p ' .. dir)
  local file = io.open(path, 'w')
  if not file then return false end
  file:write(content)
  file:close()
  return true
end

local function buildDescribeCommand(objectApiName)
  local jqFilter =
    [[.result = {recordTypeInfos: (.result.recordTypeInfos // [] | map(select(.name != "Master") | {name, developerName})), fields: (.result.fields // [] | map(select(.name | test("__.*__") | not) | {name, label, type, nillable, createable, updateable, picklistValues: (.picklistValues // [] | map({value, label}))}))}]]
  return string.format(
    'sf sobject describe --json --sobject %s | jq \'%s\'',
    objectApiName,
    jqFilter
  )
end

local function runCommand(command)
  local handle = io.popen(command)
  if not handle then
    return nil, 'Failed to start command'
  end

  local output = handle:read('*a')
  handle:close()

  if not output or output == '' then
    return nil, 'Command returned no output'
  end

  return output, nil
end

local function fetchObjectSchema(objectApiName)
  -- Spinner frames
  local spinner_frames = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
  local spinner_ns = vim.api.nvim_create_namespace("sfschema_spinner")
  local buf = vim.api.nvim_get_current_buf()
  local spinner_line = 0
  local spinner_col = 0
  local spinner_extmark = nil
  local spinner_active = true
  local frame = 1

  -- Spinner update function
  local function update_spinner()
    if not spinner_active then return end
    -- Remove previous extmark
    if spinner_extmark then
      pcall(vim.api.nvim_buf_del_extmark, buf, spinner_ns, spinner_extmark)
    end
    spinner_extmark = vim.api.nvim_buf_set_extmark(buf, spinner_ns, spinner_line, spinner_col, {
      virt_text = { { spinner_frames[frame] .. " Fetching schema for " .. objectApiName .. "...", "Comment" } },
      virt_text_pos = "eol",
      hl_mode = "combine",
    })
    frame = frame % #spinner_frames + 1
  end

  -- Start spinner timer
  local timer = vim.uv.new_timer()
  timer:start(0, 100, vim.schedule_wrap(function()
    if spinner_active then
      update_spinner()
    else
      timer:stop()
      timer:close()
      -- Remove spinner extmark
      if spinner_extmark then
        pcall(vim.api.nvim_buf_del_extmark, buf, spinner_ns, spinner_extmark)
      end
    end
  end))

  local orgId = getOrgId()
  if not orgId then
    spinner_active = false
    return {
      uri = 'sfschema://' .. objectApiName,
      mimetype = 'text/plain',
      data = 'Error: unable to determine org id',
    }
  end

  local path = cachePath(orgId, objectApiName)
  local cached = readCache(path)

  if cached then
    spinner_active = false
    return {
      uri = 'sfschema://' .. objectApiName,
      mimetype = 'application/json',
      data = cached,
    }
  end

  local command = buildDescribeCommand(objectApiName)
  local output, errorMessage = runCommand(command)

  spinner_active = false

  if not output then
    return {
      uri = 'sfschema://' .. objectApiName,
      mimetype = 'text/plain',
      data = 'Error fetching schema for ' .. objectApiName .. ': ' .. (errorMessage or 'Unknown error'),
    }
  end

  writeCache(path, output)
  return {
    uri = 'sfschema://' .. objectApiName,
    mimetype = 'application/json',
    data = output,
  }
end

--- CopilotChat context function:
--- Use `#schema:Account,Contact` to add schema describe JSON for each object.
return  {
  description = 'Retrieves Salesforce SObject schema (describe) JSON, for default org, via Salesforce CLI for one or more objects. Usage: #sfschema:Account,Contact',
  uri = 'sfschema://{objects}',
  schema = {
    type = 'object',
    required = { 'objects' },
    properties = {
      objects = {
        type = 'string',
        description = 'Comma-separated SObject API names, e.g. Account,Contact',
      },
    },
  },
  resolve = function(input)
    local objectNames = splitCsv(input.objects)
    local resources = {}

    for _, objectApiName in ipairs(objectNames) do
      table.insert(resources, fetchObjectSchema(objectApiName))
    end

    return resources
  end,
}
