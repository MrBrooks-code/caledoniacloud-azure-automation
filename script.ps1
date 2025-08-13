# Example PowerShell script for Azure Automation Runbook
# Replace this with your actual PowerShell script

param(
    [Parameter(Mandatory=$false)]
    [string]$ExampleParameter = "DefaultValue"
)

Write-Output "Starting PowerShell script execution..."
Write-Output "Example parameter value: $ExampleParameter"

# Your PowerShell logic goes here
try {
    # Example: Get current date and time
    $currentDateTime = Get-Date
    Write-Output "Current date and time: $currentDateTime"
    
    # Example: Get Azure context (if running in Azure Automation)
    # $context = Get-AzContext
    # Write-Output "Azure context: $($context.Account.Id)"
    
    Write-Output "Script execution completed successfully."
}
catch {
    Write-Error "An error occurred: $($_.Exception.Message)"
    throw
}