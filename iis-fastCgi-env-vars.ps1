# Store the output of the appcmd command in a variable
$output = & "$env:windir\system32\inetsrv\appcmd" list config /section:system.webServer/fastCgi

# Use regular expression to find the application with the desired fullPath
$pattern = '<application fullPath="D:\\PHP\\8\.1\.6_64\\php-cgi\.exe">.*?</application>'
$match = [regex]::Match($output, $pattern)

if ($match.Success) {
    # Extract the matched application block
    $applicationBlock = $match.Value

    # Use regular expression to extract environment variables from the application block
    $envPattern = '(?<=<environmentVariable name=")[^"]+'
    $envMatches = [regex]::Matches($applicationBlock, $envPattern)

    # Store extracted environment variables in an array
    $environmentVariables = $envMatches | ForEach-Object { $_.Value }

    # Print the extracted environment variables
    $environmentVariables
} else {
    Write-Host "No application found with the specified fullPath."
}


# Define the full path of the application
$applicationFullPath = "D:\PHP\8.1.6_64\php-cgi.exe"

# Define the environment variable name and value
$variableName = "ENV_VARIABLE2"
$variableValue = "The value of ENV_VARIABLE."
$appCmd = "C:\windows\system32\inetsrv\appcmd.exe"

# Set the environment variable for the application process
[Environment]::SetEnvironmentVariable($variableName, $variableValue, "Process")

# Verify that the environment variable is set for the process
$processEnv = [Environment]::GetEnvironmentVariable($variableName, "Process")
if ($processEnv -eq $variableValue) {
    Write-Host "Environment variable '$variableName' set for the application process '$applicationFullPath'."
    
    # Set the environment variable for the FastCGI application in IIS
    $iisConfigCommand = "$appCmd set config /section:system.webServer/fastCgi /+""[fullPath='$applicationFullPath'].environmentVariables.[name='$variableName',value='$variableValue']"""
    Invoke-Expression $iisConfigCommand
    Write-Host "Environment variable '$variableName' set for the FastCGI application in IIS."
} else {
    Write-Host "Failed to set the environment variable for the application process."
}
