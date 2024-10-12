# Define the base URL for raw content
$baseUrl = "https://raw.githubusercontent.com/michaeljamesrojas/scripts/main"

# Fetch the list of files from the repository
Write-Host "Available scripts:"
Write-Host

$repoContents = Invoke-RestMethod -Uri "https://api.github.com/repos/michaeljamesrojas/scripts/contents"
$scripts = $repoContents | Where-Object { $_.name -like "*.ps1" } | Select-Object -ExpandProperty name

# Display numbered list of scripts with spacing
for ($i = 0; $i -lt $scripts.Count; $i++) {
    Write-Host ("{0}. {1}" -f ($i+1), $scripts[$i])
}

# Prompt user to choose a script
$choice = Read-Host "Enter the number of the script you want to execute"

# Validate user input
if (-not ($choice -match '^\d+$') -or [int]$choice -lt 1 -or [int]$choice -gt $scripts.Count) {
    Write-Host "Invalid choice. Please enter a number between 1 and $($scripts.Count)."
    exit
}

# Get the selected script name
$selectedScript = $scripts[[int]$choice - 1]

# Ask for confirmation
Write-Host
$confirm = Read-Host "Do you really want to execute $selectedScript? (y/n)"
Write-Host

if ($confirm -notmatch '^[Yy]$') {
    Write-Host "Execution cancelled."
    exit
}

# Execute the chosen script directly from the raw URL
$scriptUrl = "$baseUrl/$selectedScript"
Write-Host "Fetching and executing script: $selectedScript"
Write-Host

try {
    $scriptContent = Invoke-RestMethod -Uri $scriptUrl
    Invoke-Expression $scriptContent
}
catch {
    Write-Host "Error: Failed to fetch or execute the script."
    exit
}
