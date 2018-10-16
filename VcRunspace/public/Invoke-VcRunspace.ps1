#requires -Version 3
#requires -Modules PoshRSJob,VMware.VimAutomation.Core
Function Invoke-VcRunspace {
  <#

      .DESCRIPTION
        Connect to one or more VMware vCenter Servers using PowerShell Runspace jobs and return a report containing basic information about vCenter.

      .NOTES
        Script:              Invoke-VcRunspace.ps1
        Author:              Mike Nisk
        Prior Art:           Start-RSJob syntax based on VMTN thread:
                             https://communities.vmware.com/thread/513253

        Supported Versions:  Microsoft PowerShell 3.0 or later (5.1 or better preferred)
                             VMware PowerCLI 6.5.2 or later (PowerCLI 11.x preferred)
                             PoshRSJob 1.7.3.9 or later
                             vCenter Server 6.0 or later

      .PARAMETER Server
        String. The IP Address or DNS Name of one or more VMware vCenter Server machines.

      .PARAMETER Credential
        PSCredential. The login for vCenter Server.

      .PARAMETER Brief
        Switch.  Returns a small set of properties (Name, Version, and State).

      .PARAMETER PassThru
        Switch. Use the PassThru switch for greater detail on returned object.
        
      .EXAMPLE
      Invoke-VcRunspace -Server vc01.lab.local -Credential (Get-Credential administrator@vsphere.local)
      
      Get prompted for login information and then return a report for a single vCenter Server.

      .EXAMPLE
      $credsVC = Get-Credential administrator@vshere.local
      $vcList = @('vc01.lab.local', 'vc02.lab.local', 'vc03.lab.local')
      $report = Invoke-VcRunspace -Server $vcList -Credential $credsVC

      Save a credential to a variable and then return results for several vCenter Servers.

      .EXAMPLE
      $credsVC = Get-Credential administrator@vshere.local
      $report = Invoke-VcRunspace -Server (gc $home/vc-list.txt) -Credential $credsVC

      Use Get-Content to feed the Server parameter by pointing to a text file. The text file should have one vCenter Server name per line.

      .Example
      PS C:\> Get-Module -ListAvailable -Name @('PoshRSJob','VMware.PowerCLI') | select Name,Version

      Name            Version
      ----            -------
      PoshRSJob       1.7.4.4
      VMware.PowerCLI 11.0.0.10380590

      This example tests the current client for the required modules. The script and parent module does checking for this as well. The version is not too important; latest is greatest.

      .INPUTS
      none

      .OUTPUTS
      Object
  #>

  [CmdletBinding()]
  Param(

    #String. The IP Address or DNS name of one or more VMware vCenter Server machines.
    [string[]]$Server,

    #PSCredential. The login for vCenter Server.
    [Parameter(Mandatory)]
    [PSCredential]$Credential,
    
    #Switch. Returns a small set of properties.
    [switch]$Brief,
    
    #Switch. Use the PassThru switch for greater detail on returned object.
    [switch]$PassThru
  )

  Process {

    ## FAF array for results
    $Report = [System.Collections.ArrayList]::Synchronized((New-Object -TypeName System.Collections.ArrayList))

    Start-RSJob -ScriptBlock {
      #requires -Module VMware.Vimautomation.Core
      [CmdletBinding()]
      param(
        [string[]]$Server,
        [System.Collections.ArrayList]$Report
      )
      
      Foreach($vc in $Server){

        ## Connect to vCenter
        try {
          $VcImpl = Connect-VIServer -Server $vc -Credential $Using:Credential -wa 0 -ea Stop
        }
        catch{
          Write-Error -Message ('{0}' -f $_.Exception.Message)
          Write-Warning -Message ('Problem connecting to {0} (skipping)!' -f $vc)
          Continue
        }
        
        ## Populate report object
        $Report.Add((New-Object -TypeName PSCustomObject -Property @{
              Name                = [string]$VcImpl.Name
              Version             = [string]$VcImpl.Version
              Build               = [string]$VcImpl.Build
              About               = [VMware.Vim.DynamicData]$VcImpl.ExtensionData.Content.About
        }))

        ## Session cleanup
        try{
          $null = Disconnect-VIServer -Server $vc -Confirm:$false -Force -ErrorAction Stop
        }
        catch{
          Write-Error -Message ('{0}' -f $_.Exception.Message)
        }
      }
    } -ArgumentList $Server, $Report | Wait-RSJob | Remove-RSJob
  
    ## Handle output
    If($null -ne $Report -and $Report.Count -ge 1){
      If($PassThru){
        return $Report
      }
      Else{
        If($Brief){
          $Report | Select-Object -Property Name,Version,Build
        }
        Else{
          ## Default output. Optionally, do some Format-List here, etc.
          $Report | Select-Object -Property Name, Version, Build, About
        }
      }
    }
    Else{
      Write-Warning -Message 'No report results!'
    }
  } #End Process
} #End Function