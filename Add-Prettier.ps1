# Function to write status messages to the console with color coding
function Write-Status {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Status,
        
        [Parameter(Mandatory = $false)]
        [string]$Message = ""
    )

    $Color = switch ($Status.ToLower()) {
        "error" { "Red" }
        "done" { "Green" }
        default { "White" }
    }

    Write-Host
    Write-Host "[" -NoNewline
    Write-Host $Status -ForegroundColor $Color -NoNewline
    Write-Host "] " -NoNewline
    Write-Host $Message
}

# Read the existing package.json file
$packageJsonPath = ".\package.json"
if (-not (Test-Path $packageJsonPath)) {
    Write-Status "error" "package.json not found in current directory. Exiting."
    Write-Host
    exit
}

# Define the path to your Prettier json file
$prettierConfigPath = "C:\path\to\prettier-config\.prettierrc.json"

# Check if Prettier config file exists
if (-not (Test-Path $prettierConfigPath)) {
    Write-Status "error" "Prettier config file not found at $prettierConfigPath. Exiting."
    Write-Host
    exit
}

$localPrettierConfig = ".\.prettierrc.json"

# Check if Prettier config already exists in the current directory
if (-not (Test-Path $localPrettierConfig)) {
    Copy-Item -Path $prettierConfigPath -Destination $localPrettierConfig
    Write-Status "done" ".prettierrc.json copied to current directory from $($prettierConfigPath)"
} else {
    Write-Host
    Write-Host "A Prettier config has been found in the directory. " -NoNewline
    Write-Host "Skipping copy" -ForegroundColor Yellow -NoNewline
    Write-Host "."
}

# Check if Prettier, @ianvs/prettier-plugin-sort-imports, and prettier-plugin-tailwindcss are already installed as dev dependencies
$packageJson = Get-Content ".\package.json" | ConvertFrom-Json
$devDependencies = $packageJson.devDependencies

$prettierInstalled = $devDependencies.PSObject.Properties.Name -contains "prettier"
$sortImportsPluginInstalled = $devDependencies.PSObject.Properties.Name -contains "@ianvs/prettier-plugin-sort-imports"
$tailwindPluginInstalled = $devDependencies.PSObject.Properties.Name -contains "prettier-plugin-tailwindcss"

if (-not $prettierInstalled -or -not $sortImportsPluginInstalled -or -not $tailwindPluginInstalled) {
    Write-Host
    $missingPackages = @()
    if (-not $prettierInstalled) { $missingPackages += "prettier" }
    if (-not $sortImportsPluginInstalled) { $missingPackages += "@ianvs/prettier-plugin-sort-imports" }
    if (-not $tailwindPluginInstalled) { $missingPackages += "prettier-plugin-tailwindcss" }
    
    $missingPackagesStr = $missingPackages -join ", "

    Write-Host "Missing: "
    Write-Host "$missingPackagesStr" -ForegroundColor Cyan
    $installPrettier = Read-Host "Install using pnpm? (Y / N)"

    if ($installPrettier -eq "y" -or $installPrettier -eq "Y") {
        Write-Host "Running command: "
        Write-Host "> " -NoNewline
        Write-Host "pnpm add -D $($missingPackages -join ' ')" -ForegroundColor Cyan
        Write-Host
        Start-Process "cmd.exe" -ArgumentList "/c pnpm add -D $($missingPackages -join ' ')" -NoNewWindow -Wait

        Write-Host
        Write-Status "done" "$missingPackagesStr installed."

        $prettierInstalled = $true
        $sortImportsPluginInstalled = $true
        $tailwindPluginInstalled = $true
    } else {
        Write-Status "error" "$missingPackagesStr will not be installed."
    }
} else {
    Write-Host
    Write-Host "Prettier, @ianvs/prettier-plugin-sort-imports, and prettier-plugin-tailwindcss are already installed as devDependencies. " -NoNewline
    Write-Host "Skipping installation" -ForegroundColor Yellow -NoNewline
    Write-Host "."
}

$packageJson = Get-Content $packageJsonPath | ConvertFrom-Json

# Check if 'scripts' property exists, if not, create it
if (-not $packageJson.PSObject.Properties.Name -contains "scripts") {
    $packageJson | Add-Member -NotePropertyName "scripts" -NotePropertyValue @{}
}

# Define the scripts to add
$scriptsToAdd = @{
    "prettier" = "prettier --check '**/**/*.{js,jsx,ts,tsx,css,json}'"
    "prettier:fix" = "prettier --write '**/**/*.{js,jsx,ts,tsx,css,json}'"
}

Write-Host
Write-Host "Adding or updating scripts in package.json..."

# Add or update the scripts in package.json
$scriptsToAdd.GetEnumerator() | ForEach-Object {
    if ($packageJson.scripts.PSObject.Properties.Name -contains $_.Key) {
        if ($packageJson.scripts.($_.Key) -eq $_.Value) {
            Write-Host "- Script with key '" -NoNewline
            Write-Host "$($_.Key)" -ForegroundColor Cyan -NoNewline
            Write-Host "' " -NoNewline
            Write-Host "already exists with the same value. " -NoNewline
            Write-Host "Skipping" -ForegroundColor Yellow -NoNewline
            Write-Host "."
        } else {
            $packageJson.scripts.($_.Key) = $_.Value
            Write-Host "Existing script with key '" -NoNewline
            Write-Host "$($_.Key)" -ForegroundColor Cyan -NoNewline
            Write-Host "' has been found with a different value. Update the script? (Y / N): " -NoNewline
            $updateScript = Read-Host

            if ($updateScript -eq "Y" -or $updateScript -eq "y") {
                Write-Host "+ " -ForegroundColor Green -NoNewline
                Write-Host "Updated existing script '" -NoNewline
                Write-Host "$($_.Key)" -ForegroundColor Cyan -NoNewline
                Write-Host "'"
            } else {
                Write-Host "Script '" -NoNewline
                Write-Host "$($_.Key)" -ForegroundColor Cyan -NoNewline
                Write-Host "' will not be updated." -ForegroundColor Yellow
            }
        }
    } else {
        $packageJson.scripts | Add-Member -NotePropertyName $_.Key -NotePropertyValue $_.Value
        Write-Host "+ " -ForegroundColor Green -NoNewline
        Write-Host "Added new script " -NoNewline
        Write-Host "'" -NoNewline
        Write-Host "$($_.Key)" -ForegroundColor Cyan -NoNewline
        Write-Host "'"
    }
}

# Save the updated package.json file
$packageJson | ConvertTo-Json -Depth 100 | Set-Content $packageJsonPath
Write-Status "done" "package.json has been updated."

if (-not $prettierInstalled -or -not $sortImportsPluginInstalled -or -not $tailwindPluginInstalled) {
    exit
}

Write-Status "done" "Prettier setup completed."

Write-Host
Write-Host "Running command: "
Write-Host "> " -NoNewline
Write-Host "pnpm prettier" -ForegroundColor Cyan
Start-Process "cmd.exe" -ArgumentList "/c pnpm prettier" -NoNewWindow -Wait

Write-Host
$runPrettierFix = Read-Host "Fix formatting now using Prettier? (Y / N)"

if ($runPrettierFix -eq "Y" -or $runPrettierFix -eq "y") {
    Write-Host "Running command: "
    Write-Host "> " -NoNewline
    Write-Host "pnpm prettier:fix" -ForegroundColor Cyan
    Start-Process "cmd.exe" -ArgumentList "/c pnpm prettier:fix" -NoNewWindow -Wait

    Write-Status "done" "Prettier fix completed."
} else {
    Write-Status "error" "Prettier fix will not be run."
}