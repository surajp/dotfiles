local interactive = require('interactive')

local M = {}

-- Define all SFDX commands with consistent naming pattern
function M.setup()
  -- Apex Test Commands
  vim.api.nvim_create_user_command('SfApexTestRun', function()
    vim.cmd('RunAsync sfdx apex:run:test -r human -w 5 -n ' .. vim.fn.expand('%:t:r'))
  end, { desc = 'Run Apex tests for current file' })

  vim.api.nvim_create_user_command('SfApexTestRunCoverage', function()
    vim.cmd('RunAsync sfdx apex:run:test -c -r human -w 5 -n ' .. vim.fn.expand('%:t:r'))
  end, { desc = 'Run Apex tests with coverage for current file' })

  vim.api.nvim_create_user_command('SfApexTestRunDebugCoverage', function()
    vim.cmd('RunAsync sfdx apex:run:test -c -v -r human -w 5 -d /tmp/coverage -n ' .. vim.fn.expand('%:t:r'))
  end, { desc = 'Run Apex tests with debug coverage for current file' })

  vim.api.nvim_create_user_command('SfApexTestRunAll', function()
    vim.cmd('RunAsync sfdx apex:run:test -r human -w 5')
  end, { desc = 'Run all Apex tests' })

  vim.api.nvim_create_user_command('SfApexTestRunWithOrg', function()
    local filename = vim.fn.expand('%:t:r')
    interactive.RunInteractive(
      'sfdx apex:run:test -r human -w 5 -n ' .. filename .. ' -o {org}',
      { { placeholder = 'org', prompt = 'Org name', default = '' } },
      'Running test with output'
    )()
  end, { desc = 'Run Apex tests with org selection' })

  vim.api.nvim_create_user_command('SfApexTestRunCoverageWithOrg', function()
    local filename = vim.fn.expand('%:t:r')
    interactive.RunInteractive(
      'sfdx apex:run:test -c -r human -w 5 -n ' .. filename .. ' -o {org}',
      { { placeholder = 'org', prompt = 'Org name', default = '' } },
      'Running test with coverage and output'
    )()
  end, { desc = 'Run Apex tests with coverage and org selection' })

  -- Apex Execution Commands
  vim.api.nvim_create_user_command('SfApexRun', function()
    vim.cmd('RunAsync sfdx apex:run -f ' .. vim.fn.expand('%'))
  end, { desc = 'Execute anonymous Apex from current file' })

  vim.api.nvim_create_user_command('SfApexRunJson', function()
    vim.cmd('RunAsync sfdx apex:run -f ' .. vim.fn.expand('%') .. ' --json')
  end, { desc = 'Execute anonymous Apex with JSON output' })

  vim.api.nvim_create_user_command('SfApexRunWithOrg', function()
    interactive.RunInteractive(
      'sfdx apex:run -f ' .. vim.fn.expand('%') .. ' -o {org}',
      { { placeholder = 'org', prompt = 'Org name', default = '' } },
      'Running anonymous apex'
    )()
  end, { desc = 'Execute anonymous Apex with org selection' })

  -- Apex Log Commands
  vim.api.nvim_create_user_command('SfApexLogTail', function()
    vim.cmd('RunAsync sfdx apex:tail:log --color')
  end, { desc = 'Tail Apex logs with color' })

  vim.api.nvim_create_user_command('SfApexLogList', function()
    vim.cmd('RunAsync sfdx apex:log:list')
  end, { desc = 'List Apex logs' })

  -- Deploy Commands
  vim.api.nvim_create_user_command('SfProjectDeployStart', function()
    vim.cmd('RunAsync sfdx project:deploy:start')
  end, { desc = 'Deploy all source to default org' })

  vim.api.nvim_create_user_command('SfProjectDeployStartCheck', function()
    vim.cmd('RunAsync sfdx project:deploy:start -c')
  end, { desc = 'Check deploy all source (validation only)' })

  vim.api.nvim_create_user_command('SfProjectDeployFile', function()
    vim.cmd('RunAsync sfdx project:deploy:start -d ' .. vim.fn.expand('%') .. ' -l NoTestRun -w 5')
  end, { desc = 'Deploy current file' })

  vim.api.nvim_create_user_command('SfProjectDeployFileWithOrg', function()
    interactive.RunInteractive(
      'sfdx project:deploy:start -d ' .. vim.fn.expand('%') .. ' -l NoTestRun -w 5 -o {org}',
      { { placeholder = 'org', prompt = 'Org name', default = '' } },
      'Deploying source'
    )()
  end, { desc = 'Deploy current file with org selection' })

  vim.api.nvim_create_user_command('SfProjectDeployValidate', function()
    vim.cmd('RunAsync sfdx project:deploy:validate')
  end, { desc = 'Validate deploy without actual deployment' })

  vim.api.nvim_create_user_command('SfProjectDeployReport', function()
    vim.cmd('RunAsync sfdx project:deploy:report')
  end, { desc = 'Check deploy status' })

  vim.api.nvim_create_user_command('SfProjectDeploySource', function()
    vim.cmd('RunAsync sfdx project:deploy:start --source-dir force-app')
  end, { desc = 'Push source to scratch org' })

  -- Retrieve Commands
  vim.api.nvim_create_user_command('SfProjectRetrieveStart', function()
    vim.cmd('RunAsync sfdx project:retrieve:start')
  end, { desc = 'Retrieve all source from default org' })

  vim.api.nvim_create_user_command('SfProjectRetrieveStartCheck', function()
    vim.cmd('RunAsync sfdx project:retrieve:start -c')
  end, { desc = 'Check retrieve all source (validation only)' })

  vim.api.nvim_create_user_command('SfProjectRetrieveFile', function()
    vim.cmd('RunAsync sfdx project:retrieve:start -d ' .. vim.fn.expand('%'))
  end, { desc = 'Retrieve current file' })

  vim.api.nvim_create_user_command('SfProjectRetrieveFileWithOrg', function()
    interactive.RunInteractive(
      'sfdx project:retrieve:start -d ' .. vim.fn.expand('%') .. ' -o {org}',
      { { placeholder = 'org', prompt = 'Org name', default = '' } },
      'Retrieving source'
    )()
  end, { desc = 'Retrieve current file with org selection' })

  vim.api.nvim_create_user_command('SfProjectRetrieveSource', function()
    vim.cmd('RunAsync sfdx project:retrieve:start --source-dir force-app')
  end, { desc = 'Pull source from scratch org' })

  vim.api.nvim_create_user_command('SfApexClassCreate', function()
    interactive.RunInteractive(
      'sfdx apex:class:generate --name {name} -d {directory}',
      	{ 
	  { placeholder = 'name', prompt = 'Class name', default = '' } ,
	  { placeholder = 'directory', prompt = 'Output directory', default = 'force-app/main/default/classes' }
	}
    )()
  end, { desc = 'Create new Apex class' })

  vim.api.nvim_create_user_command('SfLWCCreate', function()
    interactive.RunInteractive(
      'sfdx lightning:generate:component --type lwc --name {name} -d {directory}',
      {
	{ placeholder = 'name', prompt = 'Component name', default = '' },
        { placeholder = 'directory', prompt = 'Output directory', default = 'force-app/main/default/lwc'  }
      }
    )()
  end, { desc = 'Create new Lightning Web Component' })

end

return M
