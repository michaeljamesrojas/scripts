# Define the base URL for raw content
$baseUrl = "https://raw.githubusercontent.com/michaeljamesrojas/scripts/main"

# Fetch the list of files from the repository
Write-Host "Available scripts:"
Write-Host

# Fetch and parse the JSON
$scripts = (Invoke-RestMethod 'https://api.github.com/repos/michaeljamesrojas/scripts/contents' | Where-Object {$_.name -like '*.sh'}).name

# Display numbered list of scripts
$scripts | ForEach-Object -Begin {$i=1} -Process {Write-Host ("{0}. {1}" -f $i++, $_)}

# Prompt user to choose a script
do {
    $choice = Read-Host "Enter the number of the script you want to execute"
} while (-not ($choice -match '^\d+$' -and [int]$choice -ge 1 -and [int]$choice -le $scripts.Count))

# Get the selected script name
$selectedScript = $scripts[[int]$choice - 1]

# Ask for confirmation
$confirm = Read-Host "Do you really want to execute $selectedScript? (y/n)"

if ($confirm -ne "y") {
    Write-Host "Execution cancelled."
    exit
}

# Execute the chosen script directly from the raw URL
$scriptUrl = "$baseUrl/$selectedScript"
Write-Host "Fetching and executing script: $selectedScript"
Write-Host

try {
    Invoke-Expression (Invoke-WebRequest -Uri $scriptUrl -UseBasicParsing).Content
}
catch {
    Write-Host "Error: Failed to fetch or execute the script."
    exit 1
}
