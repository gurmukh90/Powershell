############## MACFEE EPO ###############
$ErrorActionPreference = "SilentlyContinue"
$ETinstallpath = (Get-ItemProperty  "Registry::HKLM\SOFTWARE\WOW6432Node\Prism Microsystems\EventTracker\Agent").installpath
if ($MyInvocation.MyCommand.CommandType -eq "ExternalScript")
{ # Powershell script
	$presentpath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
}
else
{ # PS2EXE compiled script
	$presentpath = Split-Path -Parent -Path ([Environment]::GetCommandLineArgs()[0])
}
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
$form0 = New-Object System.Windows.Forms.Form
$Icon = New-Object system.drawing.icon ("$presentpath\EventTracker.ico")
$form0.Icon = $Icon;
$form0.MaximizeBox = $false
$form0.Text = "McAfee ePO Integrator"
$form0.AutoSize = $True
$form0.Size = New-Object System.Drawing.Size(450,300)
$form0.StartPosition = "CenterScreen"
$OKButton0 = New-Object System.Windows.Forms.Button
$OKButton0.Location = New-Object System.Drawing.Point(150,200)
$OKButton0.Size = New-Object System.Drawing.Size(75,23)
$OKButton0.Text = "Next"
$OKButton0.Enabled = $false
$OKButton0.DialogResult = [System.Windows.Forms.DialogResult]::Yes
$form0.DesktopBounds = $false
if ($ETinstallpath -and ($PSVersionTable.PSVersion.Major -ge 5)){
$OKButton0.Enabled = $True
$OKButton0.add_click({
$form0.Visible = $false
$form = New-Object System.Windows.Forms.Form
$Icon = New-Object system.drawing.icon ("$presentpath\EventTracker.ico")
$form.Icon = $Icon;
$form.MaximizeBox = $false
$form.DesktopBounds = $false
$form.Text = "McAfee ePO Integrator"
$form.Size = New-Object System.Drawing.Size(450,250)
$form.StartPosition = "CenterScreen"
$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Point(150,170)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = "OK"
$OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $OKButton
$form.Controls.Add($OKButton)
$OKButton.add_click({
if (($orgvalue.Text -and $uvalue.Text -and $avalue.Text) -or ($cidvalue.Text -and $csvalue.Text -and $tidvalue.Text)){
$details = [pscustomobject]@{
organisation = $orgvalue
username = $uvalue.Text
password = $avalue.Text | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString
ClientID = $cidvalue.Text
ClientSecret = $csvalue.Text
TenantID = $tidvalue.Text
}
}
$details | Export-Clixml "$presentpath\support\details.xml"
if (!(Test-Path $presentpath\Office365)){
New-Item -Path $presentpath\Office365 -ItemType Directory | Out-Null
}
if(!(Test-Path $presentpath\Logs)){
New-Item -Path $presentpath\Logs -ItemType Directory | Out-Null
}
$outpath = "$presentpath\office365"
if ($details){
Stop-Service 'EventTracker Agent' -NoWait | Out-Null
"---------------Logfile Monitor--------------
[FileLogMonitor]
logfile_monitor_activity = true
file_log_name = $outpath\AuditLog.csv
file_log_type = CSV
file_log_enable = true
config_timetick = 1516174300
Date_field_name = StartTime
Time_field_name = 
Date_Time_Format = CUSTOM-MM/DD/YYYY hh:mm:ss tt
No_Of_Fields = 1
Check_Current_DateTime = false
monitorOldLogs = true
file_log_string = *
file_col_name = CmdName
file_log_string = *
file_col_name = CmdName
evt_log_type = 1
file_log_name = $outpath\ThreatLog.csv
file_log_type = CSV
file_log_enable = true
config_timetick = 1516174300
Date_field_name = DetectedUTC
Time_field_name = 
Date_Time_Format = CUSTOM-MM/DD/YYYY hh:mm:ss tt
No_Of_Fields = 1
Check_Current_DateTime = false
monitorOldLogs = true
file_log_string = *
file_col_name = DetectedUTC
file_log_string = *
file_col_name = DetectedUTC
evt_log_type = 1
[End]
---------------Event Filters--------------
[EventSelect]
log_type = 
evt_type = 0
evt_source = EventTracker
evt_category = 0
evt_id = 3230
evt_descr = 
evt_user = 
[End]" | Out-File -FilePath "$ETinstallpath\etaconfig.ini" -Encoding default -Append
$TaskCommand = "$presentpath\McAfee ePO_SQL Reports.exe"
$TaskStartTime = [datetime]::Now.AddMinutes(5) 
$service = new-object -ComObject("Schedule.Service")
$service.Connect()
$rootFolder = $service.GetFolder("\")
$TaskDefinition = $service.NewTask(0)
$TaskDefinition.RegistrationInfo.URI = "\McAfee ePO Reports"
$TaskDefinition.RegistrationInfo.Description = "$TaskDescr"
$TaskDefinition.Settings.Enabled = $true
$TaskDefinition.Settings.AllowDemandStart = $true
$triggers = $TaskDefinition.Triggers
$trigger = $triggers.Create(2)
$trigger.StartBoundary = $TaskStartTime.ToString("yyyy-MM-dd'T'HH:mm:ss")
$TaskDefinition.Principal.LogonType = 
$trigger.Enabled = $true
$trigger.Repetition.Interval = "PT1H"
$Action = $TaskDefinition.Actions.Create(0)
$action.Path = "$TaskCommand"
Register-ScheduledTask -Xml $TaskDefinition.XmlText -TaskName "McAfee ePO Reports" | Out-Null
Start-Sleep -Seconds 10 | Out-Null
if ((Get-Service 'EventTracker Agent').Status -eq "Stopped"){
Start-Service 'EventTracker Agent'| Out-Null}
}
})
$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Point(225,170)
$CancelButton.Size = New-Object System.Drawing.Size(75,23)
$CancelButton.Text = "Cancel"
$CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.CancelButton = $CancelButton
$form.Controls.Add($CancelButton)
$org = New-Object System.Windows.Forms.Label
$org.Location = New-Object System.Drawing.Point(40,50)
$org.Size = New-Object System.Drawing.Size(140,20)
$org.Text = "MaCfee ePO Database"
$form.Controls.Add($org)
$orgvalue = New-Object System.Windows.Forms.TextBox
$orgvalue.Location = New-Object System.Drawing.Point(180,50)
$orgvalue.Size = New-Object System.Drawing.Size(200,20)
$orgvalue.ForeColor = "lightgray"
$orgvalue.Text = "eg. .\SQLEXPRESS or EPOSERVER"
$form.Controls.Add($orgvalue)
$orgvalue.add_click({if($orgvalue.Text -eq "eg. .\SQLEXPRESS or EPOSERVER"){$orgvalue.Text=""};$orgvalue.ForeColor = 'WindowText'})
$Checkbox = New-Object System.Windows.Forms.Checkbox
$Checkbox.Location = New-Object System.Drawing.Point(30,70)
$Checkbox.Size = New-Object System.Drawing.Size(370,20)
$Checkbox.Text = "SQL Authentication"
$form.Controls.Add($Checkbox)
$uurl = New-Object System.Windows.Forms.Label
$uurl.Location = New-Object System.Drawing.Point(40,90)
$uurl.Size = New-Object System.Drawing.Size(130,20)
$uurl.Text = "McAfee ePO SQL User"
$uurl.Visible = $false
$form.Controls.Add($uurl)
$uvalue = New-Object System.Windows.Forms.TextBox
$uvalue.Location = New-Object System.Drawing.Point(180,90)
$uvalue.Size = New-Object System.Drawing.Size(200,20)
$uvalue.ForeColor = 'lightgray'
$uvalue.Text = 'eg. sqluser'
$uvalue.Visible = $false
$form.Controls.Add($uvalue)
$uvalue.add_click({if($uvalue.Text -eq "eg. sqluser"){$uvalue.Text=""};$uvalue.ForeColor = 'WindowText'})
$akey = New-Object System.Windows.Forms.Label
$akey.Location = New-Object System.Drawing.Point(40,110)
$akey.Size = New-Object System.Drawing.Size(70,20)
$akey.Text = "Password"
$akey.Visible = $false
$form.Controls.Add($akey)
$avalue = New-Object Windows.Forms.MaskedTextBox
$avalue.PasswordChar = '*'
$avalue.Location = New-Object System.Drawing.Point(180,110)
$avalue.Size = New-Object System.Drawing.Size(200,20)
$avalue.Visible = $false
$form.Controls.Add($avalue)
$Checkbox.add_click({$akey.Visible = $Checkbox.Checked;$avalue.Visible = $Checkbox.Checked;$uurl.Visible = $Checkbox.Checked;$uvalue.Visible = $Checkbox.Checked})
$form.Topmost = $false
$form.Add_Shown({$form.Select()})
$result = $form.ShowDialog()
})
#$form0.Close()
}
$form0.AcceptButton = $OKButton0
$form0.Controls.Add($OKButton0)
$CancelButton0 = New-Object System.Windows.Forms.Button
$CancelButton0.Location = New-Object System.Drawing.Point(225,200)
$CancelButton0.Size = New-Object System.Drawing.Size(75,23)
$CancelButton0.Text = "Cancel"
$CancelButton0.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form0.CancelButton = $CancelButton0
$form0.Controls.Add($CancelButton0)
#$CancelButton0.add_click({exit})
$preagent = New-Object System.Windows.Forms.Label
$preagent.Location = New-Object System.Drawing.Point(25,40)
$preagent.Size = New-Object System.Drawing.Size(170,20)
$preagent.Text = "•  EventTracker Manager/Agent"
$form0.Controls.Add($preagent)
$preagentButton0 = New-Object System.Windows.Forms.Button
$preagentButton0.Location = New-Object System.Drawing.Point(200,38)
$preagentButton0.Size = New-Object System.Drawing.Size(250,23)
$preagentButton0.Text = "Installed"
$preagentButton0.Enabled = $false
if (!$ETinstallpath){
$preagentButton0.Text = "Not Installed. Click here for install guide."
$preagentButton0.Enabled = $True
$preagentButton0.add_click({[system.Diagnostics.Process]::start("https://www.eventtracker.com/Eventtracker/media/Eventtracker/files/support-docs/EventTracker-Agent-Deployment-User-Manual.pdf")})
}
$form0.Controls.Add($preagentButton0)
$preps = New-Object System.Windows.Forms.Label
$preps.Location = New-Object System.Drawing.Point(25,72)
$preps.Size = New-Object System.Drawing.Size(150,20)
$preps.Text = "•  Powershell 5.0"
$form0.Controls.Add($preps)
$prepsButton0 = New-Object System.Windows.Forms.Button
$prepsButton0.Location = New-Object System.Drawing.Point(200,70)
$prepsButton0.Size = New-Object System.Drawing.Size(250,23)
$prepsButton0.Text = "Installed"
$prepsButton0.Enabled = $false
if ($PSVersionTable.PSVersion.Major -lt 5){
$prepsButton0.Text = "Not Installed. Click here for install guide."
$prepsButton0.Enabled = $True
$prepsButton0.add_click({[system.Diagnostics.Process]::start("https://www.microsoft.com/en-us/download/details.aspx?id=54616")})
}
$form0.Controls.Add($prepsButton0)
$groupBox = New-Object System.Windows.Forms.GroupBox
$groupBox.Location = New-Object System.Drawing.Point(10,10)
$groupBox.size = New-Object System.Drawing.Size(460,110)
$groupBox.text = "Prerequisites"
$form0.Controls.Add($groupBox)
$LinkLabel = New-Object System.Windows.Forms.LinkLabel
$LinkLabel.Location = New-Object System.Drawing.Point(90,170)
$LinkLabel.Size = New-Object System.Drawing.Size(400,20)
$LinkLabel.LinkColor = "BLUE"
$LinkLabel.ActiveLinkColor = "RED"
$LinkLabel.Text = "Please follow the integration guide, for more details."
$LinkLabel.add_Click({[system.Diagnostics.Process]::start("https://www.eventtracker.com/EventTracker/media/EventTracker/Files/support-docs/Integration-Guide-McAfee-ePolicy-Orchestrator.pdf")}) 
$Form0.Controls.Add($LinkLabel) 
$form0.Controls.Add($pre)
$form0.Topmost = $false
$form0.Add_Shown({$form0.Select()})
$result = $form0.ShowDialog()
$Error > $presentpath\Logs\McAfee_ePO_Integrator.log