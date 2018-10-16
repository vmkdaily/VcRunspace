#### Introduction
Welcome to the `VcRunspace` module! This is an example framework for you to build upon.
We make use of the `PoshRSJob` module to create a Runspace job for each VMware vCenter Server connection.
This module has excellent memory management and uses one of the fastest array types in PowerShell.
Also see the related module, EsxRunspace to gather reports for ESXi hosts instead of vCenter Servers.

#### Help
```

PS C:\> Import-Module c:\temp\VcRunspace -Verbose
VERBOSE: Loading module from path 'c:\temp\VcRunspace\VcRunspace.psd1'.
VERBOSE: Loading module from path 'c:\temp\VcRunspace\VcRunspace.psm1'.
VERBOSE: Importing function 'Invoke-VcRunspace'.
PS C:\>
PS C:\> gcm -Module VcRunspace

CommandType     Name                                               Version    Source
-----------     ----                                               -------    ------
Function        Invoke-VcRunspace                                 1.0.0.2    VcRunspace

PS C:\>
PS C:\> help Invoke-VcRunspace -Full

NAME
    Invoke-VcRunspace

SYNOPSIS


SYNTAX
    Invoke-VcRunspace [[-Server] <String[]>] [-Credential] <PSCredential> [-Brief] [-PassThru] [<CommonParameters>]


DESCRIPTION
    Connect to one or more VMware vCenter Servers using PowerShell Runspace jobs and return a report containing basic information about vCenter.


PARAMETERS
    -Server <String[]>
        String. The IP Address or DNS Name of one or more VMware vCenter Server machines.

        Required?                    false
        Position?                    1
        Default value
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -Credential <PSCredential>
        PSCredential. The login for vCenter Server.

        Required?                    true
        Position?                    2
        Default value
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -Brief [<SwitchParameter>]
        Switch.  Returns a small set of properties (Name, Version, and State).

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -PassThru [<SwitchParameter>]
        Switch. Use the PassThru switch for greater detail on returned object.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS
    none


OUTPUTS
    Object


NOTES


        Script:              Invoke-VcRunspace.ps1
        Author:              Mike Nisk
        Prior Art:           Start-RSJob syntax based on VMTN thread:
                             https://communities.vmware.com/thread/513253

        Supported Versions:  Microsoft PowerShell 3.0 or later (5.1 or better preferred)
                             VMware PowerCLI 6.5.2 or later (PowerCLI 11.x preferred)
                             PoshRSJob 1.7.3.9 or later
                             vCenter Server 6.0 or later

    -------------------------- EXAMPLE 1 --------------------------

    PS C:\>Invoke-VcRunspace -Server vc01.lab.local -Credential (Get-Credential administrator@vsphere.local)

    Get prompted for login information and then return a report for a single vCenter Server.




    -------------------------- EXAMPLE 2 --------------------------

    PS C:\>$credsVC = Get-Credential administrator@vshere.local

    $vcList = @('vc01.lab.local', 'vc02.lab.local', 'vc03.lab.local')
    $report = Invoke-VcRunspace -Server $vcList -Credential $credsVC

    Save a credential to a variable and then return results for several vCenter Servers.




    -------------------------- EXAMPLE 3 --------------------------

    PS C:\>$credsVC = Get-Credential administrator@vshere.local

    $report = Invoke-VcRunspace -Server (gc $home/vc-list.txt) -Credential $credsVC

    Use Get-Content to feed the Server parameter by pointing to a text file. The text file should have one vCenter Server name per line.




    -------------------------- EXAMPLE 4 --------------------------

    PS C:\>Get-Module -ListAvailable -Name @('PoshRSJob','VMware.PowerCLI') | select Name,Version

    Name            Version
    ----            -------
    PoshRSJob       1.7.4.4
    VMware.PowerCLI 11.0.0.10380590

    This example tests the current client for the required modules. The script and parent module does checking for this as well. The version is not too important; latest is greatest.





RELATED LINKS




PS C:\>

```
