do {
## GET PRINTER NAME
$printer = Read-Host -Prompt 'Enter Printer Name'

if ($printer -eq ""){exit}

## RESET VARIABLE VALUES
$result = " "; $findIP = " "; $IP = " "; $pingTest = " "; $pingResult = " "; $model = " "; $display = " "

$ErrorActionPreference = "SilentlyContinue"

## FIND PRINTER IP
$result = (Get-Printer | Where-Object Name -Like "*$printer*" | Select-Object Name,PortName)
$findIP = (Get-PrinterPort -Name ($result).Portname | select PrinterHostAddress)
$IP = ($findIP).PrinterHostAddress

$pingTest = (ping $IP -n 1 | findstr "Approximate round trip times in milli-seconds:")

if ($pingTest -eq "Approximate round trip times in milli-seconds:"){
    $pingResult = "Online"
    ##QUERY SMNP FOR PRINTER MODEL
    $SNMP = New-Object -ComObject olePrn.OleSNMP
    $SNMP.Open($IP, "public")
    $model = $SNMP.Get(".1.3.6.1.2.1.25.3.2.1.3.1")
    $display = $SNMP.Get(".1.3.6.1.2.1.43.16.5.1.2.1.1")
    $SNMP.Close()
}else{
    $pingResult = "Offline"
}

Write-Host -Object "Name    : $(($result).Name) `nIP      : $IP `nPing    : $pingResult `nModel   : $model `nDisplay : $display`n"
} until ($printer -eq "")