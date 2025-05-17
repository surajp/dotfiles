local chroma_proj_dir = vim.fn.expand("~/projects/pyproj/chroma-rag/")
local memory = {
  description = 'Queries the ChromaDB semantic store via a Python script and returns the raw result as markdown.',
  uri = 'memory://{query}',
  schema = {
    type = 'object',
    properties = {
      query = {
	type = 'string',
	description = 'The semantic search query string.',
      },
    },
    required = { 'query' },
  },
  resolve = function(input)
    if not input or input == "" then return nil end
    local cmd = string.format("%s/.venv/bin/python3 %s/semantic_store.py query_raw %s", chroma_proj_dir,chroma_proj_dir,vim.fn.shellescape(input.query))
    local result = vim.fn.system(cmd)
    -- vim.notify(vim.inspect(result))
	--    local memoryResults = {}
	--    for _, line in ipairs(vim.split(result, '\n\n')) do
	--      local current = {
	--      	uri = 'memory://' .. input.query .. '#' .. vim.fn.sha256(line),
	-- mimetype = 'text/markdown',
	-- data = line
	--      }
	--      table.insert(memoryResults, current)
	--    end
    -- return memoryResults
    return {{
      uri = 'memory://' .. input.query,
      mimetype = 'text/plain',
      data = result
    }}
  end,
}
return memory
