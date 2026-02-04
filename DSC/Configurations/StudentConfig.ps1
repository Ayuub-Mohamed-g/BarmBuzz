<#
STUDENT TASK:
- Define Configuration StudentBaseline
- Use ConfigurationData (AllNodes.psd1)
- DO NOT hardcode passwords here.
#>

Configuration StudentBaseline {
    param()

    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Node $AllNodes.NodeName {

        # WEEK 1:
        # Put a simple resource here to prove the pipeline works.
        # Examples:
        # - File resource to create a folder
        # - Registry resource to set a harmless key/value
        #
        # WEEK 2+:
        # Expand toward AD DS, DNS, domain build, then OU/users/groups.
    }
}
