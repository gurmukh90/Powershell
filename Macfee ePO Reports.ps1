if ([System.Net.ServicePointManager]::CertificatePolicy.ToString() -ne 'IgnoreCerts')
{
    $Domain = [AppDomain]::CurrentDomain
    $DynAssembly = New-Object System.Reflection.AssemblyName('IgnoreCerts')
    $AssemblyBuilder = $Domain.DefineDynamicAssembly($DynAssembly, [System.Reflection.Emit.AssemblyBuilderAccess]::Run)
    $ModuleBuilder = $AssemblyBuilder.DefineDynamicModule('IgnoreCerts', $false)
    $TypeBuilder = $ModuleBuilder.DefineType('IgnoreCerts', 'AutoLayout, AnsiClass, Class, Public, BeforeFieldInit', [System.Object], [System.Net.ICertificatePolicy])
    $TypeBuilder.DefineDefaultConstructor('PrivateScope, Public, HideBySig, SpecialName, RTSpecialName') | Out-Null
    $MethodInfo = [System.Net.ICertificatePolicy].GetMethod('CheckValidationResult')
    $MethodBuilder = $TypeBuilder.DefineMethod($MethodInfo.Name, 'PrivateScope, Public, Virtual, HideBySig, VtableLayoutMask', $MethodInfo.CallingConvention, $MethodInfo.ReturnType, ([Type[]] ($MethodInfo.GetParameters() | % {$_.ParameterType})))
    $ILGen = $MethodBuilder.GetILGenerator()
    $ILGen.Emit([Reflection.Emit.Opcodes]::Ldc_I4_1)
    $ILGen.Emit([Reflection.Emit.Opcodes]::Ret)
    $TypeBuilder.CreateType() | Out-Null
    # Disable SSL certificate validation
    [System.Net.ServicePointManager]::CertificatePolicy = New-Object IgnoreCerts
}
$credential = Get-Credential -UserName "admin" -Message "enter credentail"
(Invoke-RestMethod -Uri "https://192.168.1.68:8443/remote/core.help?:output=json" -Credential $credential | Select-String -Pattern "(?s)(?<=OK:).*").Matches.Value | ConvertFrom-Json
$DATA = (Invoke-RestMethod -Uri "https://192.168.1.68:8443/remote/core.listQueries?:output=json" -Credential $credential | Select-String -Pattern "(?s)(?<=OK:).*").Matches.Value |ConvertFrom-Json
((Invoke-RestMethod -Uri "https://192.168.1.68:8443/remote/core.listQueries?:output=json" -Credential $credential | Select-String -Pattern "(?s)(?<=OK:).*").Matches.Value |ConvertFrom-Json | Select-Object -Property id,name)
(Invoke-RestMethod -Uri "https://192.168.1.68:8443/remote/core.executeQuery?:output=json&target=OrionAuditLog" -Credential $credential | Select-String -Pattern "(?s)(?<=OK:).*").Matches.Value |ConvertFrom-Json
(Invoke-RestMethod -Uri "https://192.168.1.68:8443/remote/core.executeQuery?:output=json&target=EPOEvents" -Credential $credential | Select-String -Pattern "(?s)(?<=OK:).*").Matches.Value |ConvertFrom-Json
(Invoke-RestMethod -Uri "https://192.168.1.68:8443/remote/core.executeQuery?:output=json&queryId=14" -Credential $credential | Select-String -Pattern "(?s)(?<=OK:).*").Matches.Value |ConvertFrom-Json
((Invoke-RestMethod -Uri "https://192.168.1.68:8443/remote/core.listTables?:output=json" -Credential $credential | Select-String -Pattern "(?s)(?<=OK:).*").Matches.Value |ConvertFrom-Json).target