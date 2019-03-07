##########################################################################
##                                                                      ##
##                 CONFIGMGR CLIENT TCP PORT TESTER                     ##
##                                                                      ##
## Author:      Trevor Jones                                            ##
## Blog:        smsagent.blog                                           ##
## Version:     1.0                                                     ##
##                                                                      ##
##########################################################################


# Set the location we are running from
$Source = $PSScriptRoot

# Load the function library
. "$Source\bin\FunctionLibrary.ps1"

# Do PS version check
If ($PSVersionTable.PSVersion.Major -lt 5)
{
    $Content = "ConfigMgr Client TCP Port Tester cannot start because it requires minimum PowerShell 5."
    New-WPFMessageBox -Content $Content -Title "Oops!" -TitleBackground Red -TitleTextForeground White -TitleFontSize 20 -TitleFontWeight Bold -BorderThickness 1 -BorderBrush Red -Sound 'Windows Exclamation'
    Break
}

# Do .Net Version Check
$Release = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full" -Name Release).Release
If ($Release -lt 394802)
{
    $Content = "ConfigMgr Client TCP Port Tester cannot start because it requires minimum .Net Framework 4.6.2."
    New-WPFMessageBox -Content $Content -Title "Oops!" -TitleBackground Red -TitleTextForeground White -TitleFontSize 20 -TitleFontWeight Bold -BorderThickness 1 -BorderBrush Red -Sound 'Windows Exclamation'
    Break
}

# Do Cmdlet Check
Try
{
    $null = Get-Command Test-NetConnection -ErrorAction Stop
}
Catch
{
    $Content = "ConfigMgr Client TCP Port Tester cannot start because the required PowerShell cmdlets are not present."
    New-WPFMessageBox -Content $Content -Title "Oops!" -TitleBackground Red -TitleTextForeground White -TitleFontSize 20 -TitleFontWeight Bold -BorderThickness 1 -BorderBrush Red -Sound 'Windows Exclamation'
    Break 
}

# Load the required assemblies
Add-Type -AssemblyName PresentationFramework,PresentationCore,WindowsBase
Add-Type -Path "$Source\bin\System.Windows.Interactivity.dll"
Add-Type -Path "$Source\bin\ControlzEx.dll"
Add-Type -Path "$Source\bin\MahApps.Metro.dll"

# Load the main window XAML code
[XML]$Xaml = [System.IO.File]::ReadAllLines("$Source\Xaml\App.xaml") 

# Create a synchronized hash table and add the WPF window and its named elements to it
$UI = [System.Collections.Hashtable]::Synchronized(@{})
$UI.Window = [Windows.Markup.XamlReader]::Load((New-Object -TypeName System.Xml.XmlNodeReader -ArgumentList $xaml))
$xaml.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]") | 
    ForEach-Object -Process {
        $UI.$($_.Name) = $UI.Window.FindName($_.Name)
    }

# Set the window icon from a file
$UI.Window.Icon = "$Source\bin\network.ico"

# Add the source to the hash table
$UI.Source = $Source

# Hold the background jobs here. Useful for querying the streams for any errors.
$UI.Jobs = @()
# View the error stream for the first background job, for example
#$UI.Jobs[0].PSInstance.Streams.Error

# Load in the other code libraries.
. "$Source\bin\ClassLibrary.ps1"
. "$Source\bin\EventLibrary.ps1"

# Available tests
$Tests = @(
    "Local Ports"
    "Connectivity to Management Point"
    "Connectivity to Distribution Point"
    "Connectivity to Software Update Point"
    "Custom Port Test"
)

# OC for data binding source
$UI.DataSource = New-Object System.Collections.ObjectModel.ObservableCollection[Object]
$UI.DataSource.Add("False") # [0] ProgressBar Indeterminate
$UI.DataSource.Add("Ready") # [1] Status
$UI.DataSource.Add("Black") # [2] Status foreground colour
$UI.DataSource.Add($null)   # [3] MessageBoxTrigger text
$UI.DataSource.Add($null)   # [4] Client DataGrid
$UI.DataSource.Add($null)   # [5] MP DataGrid
$UI.DataSource.Add($null)   # [6] DP DataGrid
$UI.DataSource.Add($null)   # [7] SUP DataGrid
$UI.DataSource.Add($null)   # [8] MPPingResult
$UI.DataSource.Add($null)   # [9] MPIPAddress
$UI.DataSource.Add($null)   # [10] MPRoundTrip
$UI.DataSource.Add($null)   # [11] DPPingResult
$UI.DataSource.Add($null)   # [12] DPIPAddress
$UI.DataSource.Add($null)   # [13] DPRoundTrip
$UI.DataSource.Add($null)   # [14] SUPPPingResult
$UI.DataSource.Add($null)   # [15] SUPIPAddress
$UI.DataSource.Add($null)   # [16] SUPRoundTrip
$UI.DataSource.Add($Tests)  # [17] Select Test Values

# Set the datacontext of the window to the OC for databinding
$UI.Window.DataContext = $UI.DataSource


# Load the defaults
Try
{
    [xml]$Defaults = Get-Content "$Source\defaults\Defaults.xml" -ErrorAction Stop
}
Catch
{
    $Content = "ConfigMgr Client TCP Port Tester cannot find the default values. Check that .\defaults\Defaults.xml exists."
    New-WPFMessageBox -Content $Content -Title "Oops!" -TitleBackground Red -TitleTextForeground White -TitleFontSize 20 -TitleFontWeight Bold -BorderThickness 1 -BorderBrush Red -Sound 'Windows Exclamation'
    Break
}

$UI.DefaultLocalPorts = @()
foreach ($Port in $Defaults.ConfigMgr_Port_Tester.PortDefaults.LocalPorts)
{
    $UI.DefaultLocalPorts += $port
}
$UI.DefaultManagementPointPorts = @()
foreach ($Port in $Defaults.ConfigMgr_Port_Tester.PortDefaults.ManagementPointPorts)
{
    $UI.DefaultManagementPointPorts += $port
}
$UI.DefaultDistributionPointPorts = @()
foreach ($Port in $Defaults.ConfigMgr_Port_Tester.PortDefaults.DistributionPointPorts)
{
    $UI.DefaultDistributionPointPorts += $port
}
$UI.DefaultSoftwareUpdatePointPorts = @()
foreach ($Port in $Defaults.ConfigMgr_Port_Tester.PortDefaults.SoftwareUpdatePointPorts)
{
    $UI.DefaultSoftwareUpdatePointPorts += $port
}

# Client Grid Datasource
$UI.ClientGridDataSource = New-Object System.Collections.ObjectModel.ObservableCollection[Object]
$ClientGridDataTable = New-Object System.Data.DataTable
[void]$ClientGridDataTable.Columns.AddRange(@(
    [System.Data.DataColumn]::new("Port")
    [System.Data.DataColumn]::new("Icon")
    [System.Data.DataColumn]::new("Purpose")
))
Foreach ($Port in $UI.DefaultLocalPorts.Port)
{
    [void]$ClientGridDataTable.Rows.Add($Port.Name,"$Source\bin\Unknown.bmp",$Port.Purpose)
}
$UI.ClientGridDataSource.Add($ClientGridDataTable)
$UI.ClientGrid.DataContext = $UI.ClientGridDataSource

# Management Point Grid Datasource
$UI.MPGridDataSource = New-Object System.Collections.ObjectModel.ObservableCollection[Object]
$MPGridDataTable = New-Object System.Data.DataTable
[void]$MPGridDataTable.Columns.AddRange(@(
    [System.Data.DataColumn]::new("Port")
    [System.Data.DataColumn]::new("Icon")
    [System.Data.DataColumn]::new("Purpose")
))
Foreach ($Port in $UI.DefaultManagementPointPorts.Port)
{
    [void]$MPGridDataTable.Rows.Add($Port.Name,"$Source\bin\Unknown.bmp",$Port.Purpose)
}
$UI.MPGridDataSource.Add($MPGridDataTable)
$UI.MPGrid.DataContext = $UI.MPGridDataSource

# Distribution Point Grid Datasource
$UI.DPGridDataSource = New-Object System.Collections.ObjectModel.ObservableCollection[Object]
$DPGridDataTable = New-Object System.Data.DataTable
[void]$DPGridDataTable.Columns.AddRange(@(
    [System.Data.DataColumn]::new("Port")
    [System.Data.DataColumn]::new("Icon")
    [System.Data.DataColumn]::new("Purpose")
))
Foreach ($Port in $UI.DefaultDistributionPointPorts.Port)
{
    [void]$DPGridDataTable.Rows.Add($Port.Name,"$Source\bin\Unknown.bmp",$Port.Purpose)
}
$UI.DPGridDataSource.Add($DPGridDataTable)
$UI.DPGrid.DataContext = $UI.DPGridDataSource

# Software Update Point Grid Datasource
$UI.SUPGridDataSource = New-Object System.Collections.ObjectModel.ObservableCollection[Object]
$SUPGridDataTable = New-Object System.Data.DataTable
[void]$SUPGridDataTable.Columns.AddRange(@(
    [System.Data.DataColumn]::new("Port")
    [System.Data.DataColumn]::new("Icon")
    [System.Data.DataColumn]::new("Purpose")
))
Foreach ($Port in $UI.DefaultSoftwareUpdatePointPorts.Port)
{
    [void]$SUPGridDataTable.Rows.Add($Port.Name,"$Source\bin\Unknown.bmp",$Port.Purpose)
}
$UI.SUPGridDataSource.Add($SUPGridDataTable)
$UI.SUPGrid.DataContext = $UI.SUPGridDataSource

# Custom Grid Datasource
$UI.CustomGridDataSource = New-Object System.Collections.ObjectModel.ObservableCollection[Object]
$CustomGridDataTable = New-Object System.Data.DataTable
[void]$CustomGridDataTable.Columns.AddRange(@(
    [System.Data.DataColumn]::new("Port")
    [System.Data.DataColumn]::new("Destination")
    [System.Data.DataColumn]::new("Status")
))
$UI.CustomGridDataSource.Add($CustomGridDataTable)
$UI.CustomGrid.DataContext = $UI.CustomGridDataSource

# Set the initially selected item to Local Ports
$UI.SelectTest.SelectedIndex = 0

# Set the server defaults
$UI.MPName.Text = $Defaults.ConfigMgr_Port_Tester.ServerDefaults.ManagementPoint.Value
$UI.DPName.Text = $Defaults.ConfigMgr_Port_Tester.ServerDefaults.DistributionPoint.Value
$UI.SUPName.Text = $Defaults.ConfigMgr_Port_Tester.ServerDefaults.SoftwareUpdatePoint.Value

# Display the main window
# If code is running in ISE, use ShowDialog()...
if ($psISE)
{
    $null = $UI.window.Dispatcher.InvokeAsync{$UI.window.ShowDialog()}.Wait()
}
# ...otherwise run as an application
Else
{
    # Hide the PowerShell console window
    $windowcode = '[DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);'
    $asyncwindow = Add-Type -MemberDefinition $windowcode -Name Win32ShowWindowAsync -Namespace Win32Functions -PassThru
    $null = $asyncwindow::ShowWindowAsync((Get-Process -PID $pid).MainWindowHandle, 0)
    
    # Run the main window in an application
    $app = New-Object -TypeName Windows.Application
    $app.Properties
    $app.Run($UI.Window)
}