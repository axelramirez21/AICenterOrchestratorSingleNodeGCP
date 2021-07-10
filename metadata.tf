### template file ###
### INLINE - Bootstrap Windows Server 2016 ###
data "template_file" "init-orchestrator" {
  template = <<EOF
    if(![System.IO.File]::Exists("C:\Program Files\Google\Compute Engine\metadata_scripts\createorchestratorUser")){

    $setLocalAdminPassword = "${var.set_local_adminpass}"
    if($setLocalAdminPassword -eq "yes") {
    $admin = [ADSI]("WinNT://./administrator, user")
    $admin.SetPassword("${var.admin_password}")
    }

    # create orchestrator local user 
    $orchestratorRole = "${var.orchestrator_local_account_role}"
    if($orchestratorRole -eq "localuser") {
     $localorchestratorRole = "Remote Desktop Users"
    } else { $localorchestratorRole = "Administrators" }

    $UserName="${var.vm_username}"
    $Password="${var.vm_password}"
    $Computer = [ADSI]"WinNT://$Env:COMPUTERNAME,Computer"
    $User = $Computer.Create("User", $UserName)
    $User.SetPassword("$Password")
    $User.SetInfo()
    $User.FullName = "${var.vm_username}"
    $User.SetInfo()
    $User.Put("Description", "UiPath orchestrator Admin Account")
    $User.SetInfo()
    $User.UserFlags = 65536
    $User.SetInfo()
    $Group = [ADSI]("WinNT://$Env:COMPUTERNAME/$localorchestratorRole,Group")
    $Group.add("WinNT://$Env:COMPUTERNAME/$UserName")
    $admin = [ADSI]("WinNT://./administrator, user")
    $admin.SetPassword("${var.vm_password}")
    New-Item "C:\Program Files\Google\Compute Engine\metadata_scripts\createorchestratorUser" -type file
    }

    $LocalTempDir = $env:TEMP; $ChromeInstaller = "ChromeInstaller.exe"; (new-object    System.Net.WebClient).DownloadFile('http://dl.google.com/chrome/install/375.126/chrome_installer.exe', "$LocalTempDir\$ChromeInstaller"); & "$LocalTempDir\$ChromeInstaller" /silent /install; $Process2Monitor =  "ChromeInstaller"; Do { $ProcessesFound = Get-Process | ?{$Process2Monitor -contains $_.Name} | Select-Object -ExpandProperty Name; If ($ProcessesFound) { "Still running: $($ProcessesFound -join ', ')" | Write-Host; Start-Sleep -Seconds 2 } else { rm "$LocalTempDir\$ChromeInstaller" -ErrorAction SilentlyContinue -Verbose } } Until (!$ProcessesFound)

    if(![System.IO.File]::Exists("C:\Program Files\Google\Compute Engine\metadata_scripts\orchinstall")){
    Set-ExecutionPolicy Unrestricted -force
    Invoke-WebRequest https://raw.githubusercontent.com/axelramirez21/UiPathPowershellScripts/main/Install-UiPathOrchestrator.ps1 -OutFile "C:\Program Files\Google\Compute Engine\metadata_scripts\Install-UiPathOrchestrator.ps1"
    powershell.exe -ExecutionPolicy Bypass -File "C:\Program Files\Google\Compute Engine\metadata_scripts\Install-UiPathOrchestrator.ps1" -orchestratorversion "${var.orchestrator_version}" -orchestratorhostname "${var.orchestrator_dns_name}" -passphrase "${var.orchestrator_passphrase}" -databaseservername "${var.orchestrator_databaseservername}" -databasename "${var.orchestrator_databasename}" -databaseusername "${var.orchestrator_databaseusername}" -databaseuserpassword "${var.orchestrator_databaseuserpassword}" -orchestratoradminpassword "${var.orchestrator_orchestratoradminpassword}" -identityServerdbname "${var.identity_server_db_name}" -identitydbserverName "${var.identity_db_server_name}" -identityserverauthenticationMode "${var.identity_server_authentication_mode}" -identityserverdbuser "${var.identity_server_db_user}" -identityserverdbpassword "${var.identity_server_db_password}" -certificatednsnames '${var.certificate_dns_names}'
    New-Item "C:\Program Files\Google\Compute Engine\metadata_scripts\orchinstall" -type file
    #Start-Sleep -Seconds 10 ; Restart-Computer -Force
    }
EOF
}

### CLEAN WINDOWS NO ORCHESTRATOR ####
data "template_file" "init-clean" {
  template = <<EOF
    if(![System.IO.File]::Exists("C:\Program Files\Google\Compute Engine\metadata_scripts\createorchestratorUser")){

    $setLocalAdminPassword = "${var.set_local_adminpass}"
    if($setLocalAdminPassword -eq "yes") {
    $admin = [ADSI]("WinNT://./administrator, user")
    $admin.SetPassword("${var.admin_password}")
    }

    # create orchestrator local user
    $orchestratorRole = "${var.orchestrator_local_account_role}"
    if($orchestratorRole -eq "localuser") {
     $localorchestratorRole = "Remote Desktop Users"
    } else { $localorchestratorRole = "Administrators" }

    $UserName="${var.vm_username}"
    $Password="${var.vm_password}"
    $Computer = [ADSI]"WinNT://$Env:COMPUTERNAME,Computer"
    $User = $Computer.Create("User", $UserName)
    $User.SetPassword("$Password")
    $User.SetInfo()
    $User.FullName = "${var.vm_username}"
    $User.SetInfo()
    $User.Put("Description", "UiPath orchestrator Admin Account")
    $User.SetInfo()
    $User.UserFlags = 65536
    $User.SetInfo()
    $Group = [ADSI]("WinNT://$Env:COMPUTERNAME/$localorchestratorRole,Group")
    $Group.add("WinNT://$Env:COMPUTERNAME/$UserName")
    $admin = [ADSI]("WinNT://./administrator, user")
    $admin.SetPassword("${var.vm_password}")
    New-Item "C:\Program Files\Google\Compute Engine\metadata_scripts\createorchestratorUser" -type file
    }

    $LocalTempDir = $env:TEMP; $ChromeInstaller = "ChromeInstaller.exe"; (new-object    System.Net.WebClient).DownloadFile('http://dl.google.com/chrome/install/375.126/chrome_installer.exe', "$LocalTempDir\$ChromeInstaller"); & "$LocalTempDir\$ChromeInstaller" /silent /install; $Process2Monitor =  "ChromeInstaller"; Do { $ProcessesFound = Get-Process | ?{$Process2Monitor -contains $_.Name} | Select-Object -ExpandProperty Name; If ($ProcessesFound) { "Still running: $($ProcessesFound -join ', ')" | Write-Host; Start-Sleep -Seconds 2 } else { rm "$LocalTempDir\$ChromeInstaller" -ErrorAction SilentlyContinue -Verbose } } Until (!$ProcessesFound)

    if(![System.IO.File]::Exists("C:\Program Files\Google\Compute Engine\metadata_scripts\orchinstall")){
    Set-ExecutionPolicy Unrestricted -force
    Invoke-WebRequest https://raw.githubusercontent.com/UiPath/Infrastructure/master/Setup/Install-UiPathOrchestrator.ps1 -OutFile "C:\Program Files\Google\Compute Engine\metadata_scripts\Install-UiPathOrchestrator.ps1"
    New-Item "C:\Program Files\Google\Compute Engine\metadata_scripts\orchinstall" -type file
    #Start-Sleep -Seconds 10 ; Restart-Computer -Force
    }
EOF
}

### AI CENTER ####
data "template_file" "aicenter-pre-requisites" {
  template   = <<EOF
#!/bin/bash
sudo apt-get update
sudo apt-get upgrade
sudo apt-get dist-upgrade
curl -fsSL https://raw.githubusercontent.com/UiPath/Infrastructure/main/ML/ml_prereq_all.sh | sudo bash -s -- --env gpu
EOF
}