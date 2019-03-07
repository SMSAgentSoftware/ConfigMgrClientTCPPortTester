# ConfigMgr Client TCP Port Tester
WPF / PowerShell tool to test port connectivity for SCCM Clients

![ConfigMgr Client TCP Port Tester](https://github.com/SMSAgentSoftware/ConfigMgrClientTCPPortTester/raw/master/Assets/pt1.PNG)

This tool is for client-side TCP port testing on SCCM client systems. It checks the local ports required by the SCCM client as well as connectivity to management point, distribution point and sofware update point servers.
In addition, there is a custom port tester for tested any inbound or outbound port to any destination.

## Requirements
* Windows 8.1 + / Windows Server 2012 R2 +
* PowerShell 5 
* .Net Framework 4.6.2 minimum 

This WPF tool is coded in Xaml and PowerShell and uses the MahApps.Metro open source library.

## Download
A ZIP file can be downloaded from the [TechNet Gallery](https://gallery.technet.microsoft.com/Delivery-Optimization-3eff74ac)

## Use
To use the tool, extract the ZIP file, right-click the ConfigMgr Client TCP Port Tester.ps1 and run with PowerShell.
To run against the local machine, you must run the tool elevated. To do so, create a shortcut to the ps1 file. Edit the properties of the shortcut and change the target to read:
> PowerShell.exe -ExecutionPolicy Bypass -File "`<pathtoPS1file`>"

Right-click the shortcut and run as administrator, or edit the shortcut properties (under Advanced) to run as administrator.
For completeness, you can also change the icon of the shortcut to the icon file included in the bin directory.
