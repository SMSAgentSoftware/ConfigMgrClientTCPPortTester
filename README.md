# ConfigMgr Client TCP Port Tester
WPF / PowerShell tool to test port connectivity for SCCM Clients

![ConfigMgr Client TCP Port Tester](https://github.com/SMSAgentSoftware/ConfigMgrClientTCPPortTester/raw/master/Assets/pt1.PNG)

This tool is for TCP port testing on SCCM client systems. It checks the local ports required by the SCCM client as well as connectivity to management point, distribution point and sofware update point servers.
In addition, there is a custom port tester for testing any inbound or outbound port to any destination.

See my [blog](https://smsagent.blog/2019/03/07/configmgr-client-tcp-port-tester/) for more details.

## Requirements
* Windows 8.1 + / Windows Server 2012 R2 +
* PowerShell 5 
* .Net Framework 4.6.2 minimum 

This WPF tool is coded in Xaml and PowerShell and uses the MahApps.Metro open source library.

## Download
A ZIP file can be downloaded from the [TechNet Gallery](https://gallery.technet.microsoft.com/ConfigMgr-Client-TCP-Port-3754ef00)

## Use
To use the tool, extract the ZIP file, right-click the ConfigMgr Client TCP Port Tester.ps1 and run with PowerShell.
