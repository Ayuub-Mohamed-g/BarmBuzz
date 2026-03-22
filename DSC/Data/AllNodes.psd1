@{
    AllNodes = @(
        @{
            NodeName   = 'localhost'
            Role       = 'DC'
            DomainName = 'bolton.barmbuzz.test'
            
            OUs = @(
                @{ Name = 'Users'; Path = 'DC=bolton,DC=barmbuzz,DC=test' }
                @{ Name = 'Computers'; Path = 'DC=bolton,DC=barmbuzz,DC=test' }
                @{ Name = 'IT-Admins'; Path = 'DC=bolton,DC=barmbuzz,DC=test' }
                @{ Name = 'Derby'; Path = 'DC=bolton,DC=barmbuzz,DC=test' }
                @{ Name = 'Nottingham'; Path = 'OU=Derby,DC=bolton,DC=barmbuzz,DC=test' }
            )

            Groups = @(
                @{ Name = 'GG-Staff'; Path = 'OU=Users,DC=bolton,DC=barmbuzz,DC=test' }
                @{ Name = 'GG-IT-Admins'; Path = 'OU=IT-Admins,DC=bolton,DC=barmbuzz,DC=test' }
            )

            Users = @(
                @{ Name = 'JohnDoe'; Path = 'OU=Users,DC=bolton,DC=barmbuzz,DC=test'; Group = 'GG-Staff' }
                @{ Name = 'AdminJane'; Path = 'OU=IT-Admins,DC=bolton,DC=barmbuzz,DC=test'; Group = 'GG-IT-Admins' }
            )

            GPOs = @(
                @{ Name = 'Baseline Security'; Ensure = 'Present' }
                @{ Name = 'Derby Regional Policy'; Ensure = 'Present' }
            )
        }
    )
}
