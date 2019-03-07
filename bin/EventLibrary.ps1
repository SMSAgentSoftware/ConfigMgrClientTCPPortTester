#############################
##                         ##
## Defines event handlers  ##
##                         ##
#############################

# Bring the main window to the front once loaded
$UI.Window.Add_Loaded({
    $This.Activate()
})

# Bring relevant groupbox into visibility
$UI.SelectTest.Add_SelectionChanged({
    If ($This.SelectedValue -eq "Local Ports")
    {
        $UI.Client.Visibility = "Visible"
        $UI.MP.Visibility = "Collapsed"
        $UI.DP.Visibility = "Collapsed"
        $UI.SUP.Visibility = "Collapsed"
        $UI.Custom.Visibility = "Collapsed"
    }
    If ($This.SelectedValue -eq "Connectivity to Management Point")
    {
        $UI.Client.Visibility = "Collapsed"
        $UI.MP.Visibility = "Visible"
        $UI.DP.Visibility = "Collapsed"
        $UI.SUP.Visibility = "Collapsed"
        $UI.Custom.Visibility = "Collapsed"
    }
    If ($This.SelectedValue -eq "Connectivity to Distribution Point")
    {
        $UI.Client.Visibility = "Collapsed"
        $UI.MP.Visibility = "Collapsed"
        $UI.DP.Visibility = "Visible"
        $UI.SUP.Visibility = "Collapsed"
        $UI.Custom.Visibility = "Collapsed"
    }
    If ($This.SelectedValue -eq "Connectivity to Software Update Point")
    {
        $UI.Client.Visibility = "Collapsed"
        $UI.MP.Visibility = "Collapsed"
        $UI.DP.Visibility = "Collapsed"
        $UI.SUP.Visibility = "Visible"
        $UI.Custom.Visibility = "Collapsed"
    }
    If ($This.SelectedValue -eq "Custom Port Test")
    {
        $UI.Client.Visibility = "Collapsed"
        $UI.MP.Visibility = "Collapsed"
        $UI.DP.Visibility = "Collapsed"
        $UI.SUP.Visibility = "Collapsed"
        $UI.Custom.Visibility = "Visible"
    }
})

# Client GO button clicked
$UI.ClientGo.Add_Click({

    # Reset OC values
    $UI.DataSource[0] = $true
    $UI.DataSource[1] = "Running..."
    $UI.DataSource[2] = "Blue"
    $UI.DataSource[3] = $null

    # Reset port status
    Foreach ($Port in $Defaults.ConfigMgr_Port_Tester.PortDefaults.LocalPorts.Port.name)
    {
        $UI.ClientGridDataSource[0].Select("Port = '$Port'")[0].Icon = "$($UI.Source)\bin\Unknown.bmp"
    }
    
    # Main code to run in background job
    $Code = {
        Param($UI)
        
        Check-ClientPorts

    }

    # Start a background job
    # Using code, parameters and functions
    $Job = [BackgroundJob]::New($Code,@($UI),@("Function:\Check-ClientPorts"))
    $UI.Jobs += $Job
    $Job.Start()

})


# Managemet Point GO button clicked
$UI.MPGo.Add_Click({

    # Reset OC values
    $UI.DataSource[0] = $true
    $UI.DataSource[1] = "Running..."
    $UI.DataSource[2] = "Blue"
    $UI.DataSource[3] = $null
    $UI.DataSource[8] = $null
    $UI.DataSource[9] = $null
    $UI.DataSource[10] = $null

    # Reset port status
    Foreach ($Port in $Defaults.ConfigMgr_Port_Tester.PortDefaults.ManagementPointPorts.Port.name)
    {
        $UI.MPGridDataSource[0].Select("Port = '$Port'")[0].Icon = "$($UI.Source)\bin\Unknown.bmp"
    }
    
    # Main code to run in background job
    $Code = {
        Param($UI,$ManagementPoint)
        
        Check-MPPorts -ManagementPoint $ManagementPoint

    }

    $ManagementPoint = $UI.MPName.Text

    # Start a background job
    $Job = [BackgroundJob]::New($Code,@($UI,$ManagementPoint),@("Function:\Check-MPPorts"))
    $UI.Jobs += $Job
    $Job.Start()

})

# Distribution Point GO button clicked
$UI.DPGo.Add_Click({

    # Reset OC values
    $UI.DataSource[0] = $true
    $UI.DataSource[1] = "Running..."
    $UI.DataSource[2] = "Blue"
    $UI.DataSource[3] = $null
    $UI.DataSource[11] = $null
    $UI.DataSource[12] = $null
    $UI.DataSource[13] = $null

    # Reset port status
    Foreach ($Port in $Defaults.ConfigMgr_Port_Tester.PortDefaults.DistributionPointPorts.Port.name)
    {
        $UI.DPGridDataSource[0].Select("Port = '$Port'")[0].Icon = "$($UI.Source)\bin\Unknown.bmp"
    }
    
    # Main code to run in background job
    $Code = {
        Param($UI,$DistributionPoint)
        
        Check-DPPorts -DistributionPoint $DistributionPoint

    }

    $DistributionPoint = $UI.DPName.Text

    # Start a background job
    $Job = [BackgroundJob]::New($Code,@($UI,$DistributionPoint),@("Function:\Check-DPPorts"))
    $UI.Jobs += $Job
    $Job.Start()

})

# Software Update Point GO button clicked
$UI.SUPGo.Add_Click({

    # Reset OC values
    $UI.DataSource[0] = $true
    $UI.DataSource[1] = "Running..."
    $UI.DataSource[2] = "Blue"
    $UI.DataSource[3] = $null
    $UI.DataSource[14] = $null
    $UI.DataSource[15] = $null
    $UI.DataSource[16] = $null

    # Reset port status
    Foreach ($Port in $Defaults.ConfigMgr_Port_Tester.PortDefaults.SoftwareUpdatePointPorts.Port.name)
    {
        $UI.SUPGridDataSource[0].Select("Port = '$Port'")[0].Icon = "$($UI.Source)\bin\Unknown.bmp"
    }
    
    # Main code to run in background job
    $Code = {
        Param($UI,$SoftwareUpdatePoint)
        
        Check-SUPPorts -SoftwareUpdatePoint $SoftwareUpdatePoint

    }

    $SoftwareUpdatePoint = $UI.SUPName.Text

    # Start a background job
    $Job = [BackgroundJob]::New($Code,@($UI,$SoftwareUpdatePoint),@("Function:\Check-SUPPorts"))
    $UI.Jobs += $Job
    $Job.Start()

})

# Change the CustomDestination state when direction changed
$UI.CustomDirection.Add_SelectionChanged({
    If ($This.SelectedValue.Content -eq "INBOUND")
    {
        $UI.CustomDestination.Text = "Local"
        $UI.CustomDestination.IsEnabled = $False
    }
    If ($This.SelectedValue.Content -eq "OUTBOUND")
    {
        $UI.CustomDestination.Text = $null
        $UI.CustomDestination.IsEnabled = "True"
    }
})

# Add a new row to the custom grid
$UI.CustomAdd.Add_Click({
    [void]$UI.CustomGridDataSource[0].Rows.Add($UI.CustomPort.Text,$UI.CustomDestination.Text,"$Source\bin\Unknown.bmp")
})

# Clear the custom data grid
$UI.CustomClear.Add_Click({
    $UI.CustomGridDataSource[0].Clear()
})

# Custom Ports GO button clicked
$UI.CustomGo.Add_Click({

    # Reset OC values
    $UI.DataSource[0] = $true
    $UI.DataSource[1] = "Running..."
    $UI.DataSource[2] = "Blue"
    $UI.DataSource[3] = $null

    # Reset port status
    Foreach ($Row in $UI.CustomGridDataSource[0].Rows)
    {
        $Row.Status = "$($UI.Source)\bin\Unknown.bmp"
    }
    
    # Main code to run in background job
    $Code = {
        Param($UI)
        
        Check-CustomPorts

    }

    # Start a background job
    $Job = [BackgroundJob]::New($Code,@($UI),@("Function:\Check-CustomPorts"))
    $UI.Jobs += $Job
    $Job.Start()
})