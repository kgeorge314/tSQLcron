$symbols = [PSCustomObject] @{
    PASS = ([char]8730)
    FAIL = 'X'
}

# Import SQLServer PS Module if needed
    if (!(Get-Module -Name SqlServer -ListAvailable)) {
        $null = Install-Module -Name SqlServer -Scope CurrentUser -AllowClobber
    }

    $null = Import-Module -Name SqlServer

# Use the Enviroment Value of fallback to the .env file 
    if($env:SA_PASSWORD){
        $Password = $env:SA_PASSWORD
    }else{
        $Password = (ConvertFrom-StringData -StringData (Get-Content $PSScriptRoot\..\.env -Raw)).SQL_SERVER_PASSWORD
    }

# Setup Parameters for connecting to SQL Server
    $Parameters = @{
        ServerInstance = 'localhost,14333';
        Database       = 'tSQLcron';
        Username       = 'sa';
        Password       = $Password;
        Query          = ''
    }

# Execute tSQLt.RunAll 
    Write-host "Executing Test Cases [tSQLt.RunAll]"
    try {
        $Parameters.Query = 'EXEC tSQLt.RunAll'
        $null = Invoke-Sqlcmd @Parameters -ErrorAction SilentlyContinue
    }
    catch {
        # Left Blank Intentionally, we handle failures later

    }

# Render the Results of tSQLt Test Run
    Write-host "Capturing Results tSQLt.TestResult"

    $Parameters.Query = 'SELECT Name, Result FROM tSQLt.TestResult'
    $TestCaseResults = Invoke-Sqlcmd @Parameters

    $ExitCode = 0
    # Iterate over Test Results and Format
    foreach ($t in $TestCaseResults) {
        if ($t.Result -eq 'Success') {
            Write-Host "$($symbols.PASS) - [PASS] - $($t.Name)" -ForegroundColor Green
        }
        else {
            Write-Host "$($symbols.FAIL) - [FAIL] - $($t.Name)" -ForegroundColor Red
            $ExitCode = 1
        }
    }

# Set EXITCODE so that GitHub Action will Pass or Fail
EXIT $ExitCode
