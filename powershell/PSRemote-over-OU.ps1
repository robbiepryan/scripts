#OU Name to target - You can find this by enabling Advanced settings in Active Directory Users and Computers and selecting Attributes when right clicking an OU to view properties
$OU = "OU=YourOU,DC=YourDC,DC=com"

#Define your script to run on the workstations here
$Script = "ipconfig /flushdns"

#Connectivity Timeout
$timeoutSeconds = 20

#Get the computer names from the AD OU Group
$ComputerNames = Get-ADComputer -Filter * -SearchBase $OU | Select Name


#Loop through all the computers to execute the script with Color Highlighting
foreach ($Computer in $Computers) {
    #Color Highlight successful connections
    if (Test-WSMan -ComputerName $Computer.Name -Authentication default -ErrorAction SilentlyContinue) {
        Write-Host $Computer.Name -ForegroundColor Green
        
        #Execute the command on the machine using PSRemoting
        Invoke-Command -ComputerName $Computer.Name -ScriptBlock {
            $Script
        }

        #If you wanted to use PSExec instead (In the event PSRemoting will not allow an action) you can use the following block
        
        #Get and set the address to run PSExec against
        #$Address = '\\' + $Computer.Name
        #psexec $Address $Script
    }
    #Color highlighting machines that we were unable to connect to also push them to a text file for review after script
    else {
        Write-Host $Computer.Name -ForegroundColor Red
        Add-Content -path C:\Error_Computers.txt -Value "`r`n$Computer.Name"
    }
}