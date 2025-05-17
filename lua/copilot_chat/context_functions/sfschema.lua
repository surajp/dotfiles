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
  local command = buildDescribeCommand(objectApiName)
  local output, errorMessage = runCommand(command)

  if not output then
    return {
      uri = 'schema://' .. objectApiName,
      mimetype = 'text/plain',
      data = 'Error fetching schema for ' .. objectApiName .. ': ' .. (errorMessage or 'Unknown error'),
    }
  end

  return {
    uri = 'schema://' .. objectApiName,
    mimetype = 'application/json',
    data = output,
  }
end

--- CopilotChat context function:
--- Use `#schema:Account,Contact` to add schema describe JSON for each object.
return  {
  description = 'Retrieves Salesforce SObject schema (describe) JSON via Salesforce CLI for one or more objects. Usage: #schema:Account,Contact',
  uri = 'schema://{objects}',
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
