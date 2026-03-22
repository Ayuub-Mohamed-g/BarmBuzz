<#
STUDENT TASK:
- Define Configuration StudentBaseline
- Use ConfigurationData (AllNodes.psd1)
- DO NOT hardcode passwords here.
#>

Configuration StudentBaseline {
    param(
        [PSCredential]$DomainAdminCredential,
        [PSCredential]$DsrmCredential,
        [PSCredential]$UserCredential
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName ComputerManagementDSC
    Import-DscResource -ModuleName ActiveDirectoryDsc
    Import-DscResource -ModuleName GroupPolicyDsc

    Node $AllNodes.NodeName {
        
        # Proof-of-life
        File TestFolder {
            DestinationPath = 'C:\TEST'
            Type            = 'Directory'
            Ensure          = 'Present'
        }
        File TestFile {
            DestinationPath = 'C:\TEST\test.txt'
            Type            = 'File'
            Ensure          = 'Present'
            Contents        = 'Proof-of-life: DSC created this file.'
            DependsOn       = '[File]TestFolder'
        }

        # 1. Root Domain
        ADDomain BoltonDomain {
            DomainName                = $Node.DomainName
            IsSingleInstance          = 'Yes'
            DomainAdministratorCredential = $DomainAdminCredential
            SafemodeAdministratorPassword = $DsrmCredential
        }

        # 2. Data-Driven OU Structure 
        foreach ($ou in $Node.OUs) {
            ADOrganizationalUnit "OU_$($ou.Name)" {
                Name      = $ou.Name
                Path      = $ou.Path
                DependsOn = '[ADDomain]BoltonDomain'
            }
        }

        # 3. Data-Driven RBAC Groups
        foreach ($group in $Node.Groups) {
            $ouName = $group.Path.Split(',')[0].Split('=')[1]
            ADGroup "Group_$($group.Name)" {
                GroupName  = $group.Name
                Path       = $group.Path
                Category   = 'Security'
                GroupScope = 'Global'
                DependsOn  = if ($ouName -eq 'bolton') { '[ADDomain]BoltonDomain' } else { "[ADOrganizationalUnit]OU_$ouName" }
            }
        }

        # 4. Data-Driven Identity Baseline
        foreach ($user in $Node.Users) {
            $ouName = $user.Path.Split(',')[0].Split('=')[1]
            ADUser "User_$($user.Name)" {
                UserName    = $user.Name
                Path        = $user.Path
                Password    = $UserCredential
                DependsOn   = if ($ouName -eq 'bolton') { '[ADDomain]BoltonDomain' } else { "[ADOrganizationalUnit]OU_$ouName" }
            }

            ADGroupMember "Member_$($user.Name)" {
                GroupName = $user.Group
                Members   = $user.Name
                DependsOn = @("[ADGroup]Group_$($user.Group)", "[ADUser]User_$($user.Name)")
            }
        }

        # 5. Data-Driven Group Policy Creation
        foreach ($gpo in $Node.GPOs) {
            GroupPolicy "GPO_$($gpo.Name)" {
                Name   = $gpo.Name
                Ensure = $gpo.Ensure
                DependsOn = '[ADDomain]BoltonDomain'
            }
        }

        # 6. A* FGPP Requirements (Hard-coded structure representing Tier-0 Security)
        ADFineGrainedPasswordPolicy PwdPolicyAdmins {
            Name               = 'FGPP-ITAdmins'
            Precedence         = 10
            ComplexityEnabled  = $true
            MinPasswordLength  = 15
            MaxPasswordAge     = '30.00:00:00'
            MinPasswordAge     = '1.00:00:00'
            PasswordHistoryCount = 24
            LockoutDuration    = '00:30:00'
            LockoutObservationWindow = '00:15:00'
            LockoutThreshold   = 3
            DependsOn          = '[ADDomain]BoltonDomain'
        }

        ADFineGrainedPasswordPolicySubject PwdPolicyAdminsSubject {
            PolicyName = 'FGPP-ITAdmins'
            Subjects   = 'GG-IT-Admins'
            DependsOn  = @('[ADFineGrainedPasswordPolicy]PwdPolicyAdmins', '[ADGroup]Group_GG-IT-Admins')
        }
    }
}
