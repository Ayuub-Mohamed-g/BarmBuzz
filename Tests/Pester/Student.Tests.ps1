Describe "Student Custom A* Validation Tests" {
    BeforeAll {
        param($RepoRoot, $EvidenceDir)
        Set-StrictMode -Version Latest
        $ErrorActionPreference = 'Stop'

        if (-not $RepoRoot) {
            $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
        }

        # Attempt to load RSAT modules quietly
        Import-Module ActiveDirectory -ErrorAction SilentlyContinue
        Import-Module GroupPolicy -ErrorAction SilentlyContinue
    }

    Context "Architectural OUs and Groups (RBAC) Validation" {
        It "Validates that the IT-Admins OU exists for Privileged Identity Management" {
            if (Get-Command Get-ADOrganizationalUnit -ErrorAction SilentlyContinue) {
                $ou = Get-ADOrganizationalUnit -Filter "Name -eq 'IT-Admins'" -ErrorAction SilentlyContinue
                $ou | Should -Not -BeNullOrEmpty -Because "The IT-Admins OU is required for the A* Tiered administration model."
            }
        }

        It "Validates that the GG-IT-Admins global security group exists" {
            if (Get-Command Get-ADGroup -ErrorAction SilentlyContinue) {
                $group = Get-ADGroup -Filter "Name -eq 'GG-IT-Admins'" -ErrorAction SilentlyContinue
                $group | Should -Not -BeNullOrEmpty -Because "GG-IT-Admins is required for Role-Based Access Control."
            }
        }
    }

    Context "Fine-Grained Password Policy (FGPP) Validation" {
        It "Validates that the FGPP for IT Admins exists and enforces complexity" {
            if (Get-Command Get-ADFineGrainedPasswordPolicy -ErrorAction SilentlyContinue) {
                $fgpp = Get-ADFineGrainedPasswordPolicy -Filter "Name -eq 'FGPP-ITAdmins'" -ErrorAction SilentlyContinue
                $fgpp | Should -Not -BeNullOrEmpty -Because "FGPP-ITAdmins must be configured for the A* Security Requirement."
                $fgpp.Precedence | Should -Be 10 -Because "Precedence must be 10 as specified in the DSC configuration."
                $fgpp.ComplexityEnabled | Should -BeTrue -Because "Admin passwords must have complexity enabled."
            }
        }
    }

    Context "Group Policy Object (GPO) Validation" {
        It "Validates that the Baseline Security GPO exists" {
            if (Get-Command Get-GPO -ErrorAction SilentlyContinue) {
                $gpo = Get-GPO -Name "Baseline Security" -ErrorAction SilentlyContinue
                $gpo | Should -Not -BeNullOrEmpty -Because "The Baseline Security GPO must exist."
            }
        }

        It "Validates that the Derby Regional Policy exists" {
            if (Get-Command Get-GPO -ErrorAction SilentlyContinue) {
                $gpo = Get-GPO -Name "Derby Regional Policy" -ErrorAction SilentlyContinue
                $gpo | Should -Not -BeNullOrEmpty -Because "The Derby Regional Policy GPO must exist."
            }
        }
    }
}
