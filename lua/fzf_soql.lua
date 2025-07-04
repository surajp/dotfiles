-- ~/.config/nvim/lua/fzf_soql.lua (fzf.vim version)

if _G._fzf_soql_loaded then
  return _G._fzf_soql_loaded
end

local M = {}

local function get_default_org()
  local config_file = ".sf/config.json"
  if vim.fn.filereadable(config_file) == 0 then
    return nil
  end
  
  local handle = io.open(config_file, "r")
  if not handle then
    return nil
  end
  
  local content = handle:read("*all")
  handle:close()
  
  local success, config = pcall(vim.json.decode, content)
  if not success then
    return nil
  end
  
  return config["target-org"]
end

local function ensure_sobjtypes_dir()
  local sobjtypes_dir = vim.fn.expand("~/.sobjtypes")
  if vim.fn.isdirectory(sobjtypes_dir) == 0 then
    vim.fn.mkdir(sobjtypes_dir, "p")
  end
  return sobjtypes_dir
end

local function get_custom_fields_file(org_id)
  local sobjtypes_dir = ensure_sobjtypes_dir()
  local org_dir = sobjtypes_dir .. "/" .. org_id
  if vim.fn.isdirectory(org_dir) == 0 then
    vim.fn.mkdir(org_dir, "p")
  end
  return org_dir .. "/customFields.json"
end

local function ensure_standard_schema()
  local schema_file = vim.fn.expand("~/.sobjtypes/sf_standard_schema.csv")
  if vim.fn.filereadable(schema_file) == 0 then
    local curl_cmd = string.format(
      'curl -sSL "https://gist.githubusercontent.com/surajp/2282582350226fc9e2a268633b5e06aa/raw/9efc2c60799965ab1554d30ad1987472cbf8c654/sfschema.txt" -o "%s"',
      schema_file
    )
    vim.fn.system(curl_cmd)
  end
  return schema_file
end

local function refresh_custom_fields(custom_fields_file)
  print("Loading data, please wait...")
  local query = "select EntityDefinition.QualifiedApiName,DeveloperName,NamespacePrefix from customfield"
  local cmd = string.format('sfdx data:query -q "%s" -t --json', query)
  
  local output = vim.fn.system(cmd)
  
  -- Write to temp file first, then process with jq to remove null entries
  local temp_file = "/tmp/customFields.json"
  local handle = io.open(temp_file, "w")
  if handle then
    handle:write(output)
    handle:close()
    
    -- Use jq to clean up null entries
    local jq_cmd = string.format(
      'jq \'del(.result.records[] | select(.EntityDefinition.QualifiedApiName == null))\' "%s"',
      temp_file
    )
    local cleaned_output = vim.fn.system(jq_cmd)
    
    -- Write cleaned output to final file
    handle = io.open(custom_fields_file, "w")
    if handle then
      handle:write(cleaned_output)
      handle:close()
    end
    
    -- Clean up temp file
    vim.fn.delete(temp_file)
  end
end

local function should_refresh_data()
  return vim.env.FZF_REFRESH ~= nil or vim.fn.getline('.'):find("REF=1") ~= nil
end

local function get_preceding_word()
  local line = vim.fn.getline('.')
  local col = vim.fn.col('.') - 1
  local before_cursor = line:sub(1, col)
  
  -- Get the last word before cursor
  local words = vim.split(vim.trim(before_cursor), "%s+")
  return words[#words] or ""
end

function M.fzf_soql()
  -- Get default org
  local org_id = get_default_org()
  if not org_id then
    print("Error: No default org set in .sf/config.json")
    return
  end
  
  -- Setup file paths
  local custom_fields_file = get_custom_fields_file(org_id)
  local schema_file = ensure_standard_schema()
  
  -- Check if we need to refresh data
  if vim.fn.filereadable(custom_fields_file) == 0 or should_refresh_data() then
    refresh_custom_fields(custom_fields_file)
  end
  
  -- Determine context (FROM clause or field selection)
  local preceding_word = get_preceding_word():lower()
  local is_from_context = (preceding_word == "from")
  
  -- Create source command for FZF
  local source_cmd
  if is_from_context then
    -- For FROM context, return object names only
    source_cmd = string.format([[
      {
        jq -r '.result.records[] | "\(.EntityDefinition.QualifiedApiName)"' "%s"
        jq -Rr 'split(",") | .[0]' "%s"
      } | sort -u
    ]], custom_fields_file, schema_file)
  else
    -- For field context, return field names
    source_cmd = string.format([[
      {
        jq -r '.result.records[] | "\(.EntityDefinition.QualifiedApiName)\(if .NamespacePrefix != null then ".\(.NamespacePrefix)__" else "." end)\(.DeveloperName)__c"' "%s"
        jq -Rr 'split(",") | "\(.[0]).\(.[1])"' "%s"
      } | sort -u
    ]], custom_fields_file, schema_file)
  end
  
  -- Create a Lua function to handle the selection
  local function handle_selection(selected)
    local selection = selected
    if not is_from_context and selection:find('%.') then
      selection = selection:gsub('^[^.]*%.', '')
    end
    
    local line = vim.fn.getline('.')
    local col = vim.fn.col('.') - 1
    local new_line = line:sub(1, col) .. selection .. line:sub(col + 1)
    vim.fn.setline('.', new_line)
    vim.fn.cursor(vim.fn.line('.'), col + #selection + 1)
  end

  -- make handle_selection into a command that fzf can call
  vim.cmd('command! -nargs=1 FzfSoqlSelection lua _G._soql_selection_handler(<q-args>)')

  -- Store the function globally so fzf can access it
  _G._soql_selection_handler = handle_selection
  
  -- Call fzf with the source command
  vim.fn['fzf#run']({
    source = source_cmd,
    sink = 'FzfSoqlSelection',
    options = '--prompt="SOQL> " --height=40% --layout=reverse --border --preview="__fzf_soql_preview {1}'..org_id..'" --preview-window="right:wrap" --bind="ctrl-z:ignore,alt-j:preview-down,alt-k:preview-up"'
  })
end


local function fzf_soql_preview(object_field, org_id)
  local object_name = object_field:match("^([^.]*)")
  local field_name = object_field:match("%.(.*)$")
  
  if not object_name or not field_name then
    return "Invalid field format"
  end
  
  local org_dir = vim.fn.expand("~/.sobjtypes/" .. org_id .. "/customFields")
  if vim.fn.isdirectory(org_dir) == 0 then
    vim.fn.mkdir(org_dir, "p")
  end
  
  local object_fields_file = org_dir .. "/" .. object_name .. ".json"
  
  -- Check if file exists and has content
  if vim.fn.filereadable(object_fields_file) == 1 and vim.fn.getfsize(object_fields_file) > 0 then
    local handle = io.open(object_fields_file, "r")
    if handle then
      local content = handle:read("*all")
      handle:close()
      
      local success, data = pcall(vim.json.decode, content)
      if success and data.result and data.result.fields then
        for _, field in ipairs(data.result.fields) do
          if field.name == field_name then
            local preview_lines = {
              "Field: " .. field.name,
              "Type: " .. field.type,
              "Label: " .. field.label,
              "Length: " .. (field.length and tostring(field.length) or "N/A"),
              "Required: " .. (field.nillable == false and "true" or "false"),
              "Description: " .. (field.inlineHelpText or "N/A"),
            }
            
            if field.picklistValues and #field.picklistValues > 0 then
              local values = {}
              for _, pv in ipairs(field.picklistValues) do
                table.insert(values, pv.value)
              end
              table.insert(preview_lines, "Picklist Values: " .. table.concat(values, ", "))
            else
              table.insert(preview_lines, "Picklist Values: N/A")
            end
            
            if field.referenceTo and #field.referenceTo > 0 then
              table.insert(preview_lines, "Reference To: " .. table.concat(field.referenceTo, ", "))
            else
              table.insert(preview_lines, "Reference To: N/A")
            end
            
            table.insert(preview_lines, "Formula: " .. (field.calculatedFormula or "N/A"))
            table.insert(preview_lines, "IdLookup: " .. tostring(field.idLookup or false))
            
            return table.concat(preview_lines, "\n")
          end
        end
      end
    end
  end
  
  -- If file doesn't exist or field not found, fetch object description
  local target_org_flag = ""
  if org_id ~= "default" then
    target_org_flag = "-o " .. org_id
  end
  
  local describe_cmd = string.format('sfdx sobject:describe --sobject "%s" --json %s', object_name, target_org_flag)
  local output = vim.fn.system(describe_cmd)
  
  if vim.v.shell_error ~= 0 then
    return "Error retrieving object description for " .. object_name
  end
  
  -- Save the output to file for caching
  local handle = io.open(object_fields_file, "w")
  if handle then
    handle:write(output)
    handle:close()
  end
  
  -- Parse and return field information
  local success, data = pcall(vim.json.decode, output)
  if success and data.result and data.result.fields then
    for _, field in ipairs(data.result.fields) do
      if field.name == field_name then
        local preview_lines = {
          "Field: " .. field.name,
          "Type: " .. field.type,
          "Label: " .. field.label,
          "Length: " .. (field.length and tostring(field.length) or "N/A"),
          "Required: " .. (field.nillable == false and "true" or "false"),
          "Description: " .. (field.inlineHelpText or "N/A"),
        }
        
        if field.picklistValues and #field.picklistValues > 0 then
          local values = {}
          for _, pv in ipairs(field.picklistValues) do
            table.insert(values, pv.value)
          end
          table.insert(preview_lines, "Picklist Values: " .. table.concat(values, ", "))
        else
          table.insert(preview_lines, "Picklist Values: N/A")
        end
        
        if field.referenceTo and #field.referenceTo > 0 then
          table.insert(preview_lines, "Reference To: " .. table.concat(field.referenceTo, ", "))
        else
          table.insert(preview_lines, "Reference To: N/A")
        end
        
        table.insert(preview_lines, "Formula: " .. (field.calculatedFormula or "N/A"))
        table.insert(preview_lines, "IdLookup: " .. tostring(field.idLookup or false))
        
        return table.concat(preview_lines, "\n")
      end
    end
  end
  
  return "Field information not available"
end

-- Export the preview function globally for fzf to use
_G._fzf_soql_preview = fzf_soql_preview

_G._fzf_soql_loaded = M
return M
