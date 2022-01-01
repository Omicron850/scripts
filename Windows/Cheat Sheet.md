<u>__List a server's OU location:__</u>

Get-ADComputer -Identity "{{ server_name }}" -Properties * | select DistinguishedName

<u>__List User's AD Groups:__</u>

Get-ADPrincipalGroupMembership -Identity user | Select name | Sort-Object name

<u>__List Members of AD Group:__</u>

Get-ADGroupMember -Identity {{ AD_Group }} | select name | Sort-Object name

<u>__Find AD users with Change Password at Next Logon enabled:__</u>

Get-ADUser -LDAPFilter "(pwdLastSet=0)" | Select SamAccountName,distinguishedName | Export-Csv {{ path_to_file }}

<u>__Get a list of users, their managers and import to csv file:__</u>

$Users = Get-Content -Path C:\users.txt
Foreach ($User in $Users)
{
Get-ADUser $User -Server {{ domain_controller }} -Properties * | select name,samaccountname,emailaddress,manager,whenchanged,whencreated | Export-Csv -Append -Path {{ path_to_file }}
}

<u>__Get list of last logon date for users:__</u>

$Users = Get-Content -Path C:\users.txt
Foreach ($User in $Users)
{
Get-ADUser $User -Server {{ domain_controller }} | Get-ADObject -Properties LastLogon | select Name, @{Name='LastLogon';Expression={[DateTime]::FromFileTime($_.LastLogon)}} | Export-Csv -Append -Path {{ path_to_file }}
}

<u>__List Active Users in AD:__</u>

Get-ADUser -Filter * -Properties mail | Where { $_.Enabled -eq $True} | Select Name,samaccountname,mail >> {{ path_to_file }}

<u>__Get user's passwordlastset:__</u>

$users = Get-Content -Path {{ path_to_file }}
Foreach ($user in $users)
{
Get-ADUser $user -Server {{ domain_controller }} -Properties * | Select-Object Name, passwordlastset
}

<u>__Get OS version:__</u>

$servers = Get-Content -Path {{ filepath }}
Foreach ($server in $servers)
{
Get-ADComputer $server -Properties Name, operatingSystem | Select Name, operatingSystem
}

<u>__Get list of Domain Controllers:__</u>

Get-ADDomainController -filter * | Select-Object name
