

#This will launch the script under Administrator account if it is not under it.

# if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { 

#     write-host "Running as administrator..."; Start-Process PowerShell -Verb RunAs "-NoProfile -executionpolicy bypass -Command `"cd '$pwd';  & '$PSCommandPath';pause;`""; pause; exit 

# }

# GUI definition - Main Window - generated in VS
$mainWindowXML = @"
<Window x:Name="InstallerWindow" x:Class="WpfApp1.MainWindow" WindowStartupLocation="CenterScreen"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:WpfApp1"
        mc:Ignorable="d"
        Topmost="True"
        ResizeMode="CanMinimize"
        
        Title="IAG Installer - <company name> Inc." Height="500" Width="707">
         <Grid  x:Name="MainWindowGrid" Background="#FF474E61" HorizontalAlignment="Stretch" Height="Auto" Margin="0,0,0,0" VerticalAlignment="Stretch" Width="Auto">
        <Frame x:Name="MainWindowFrame" Content="Frame" HorizontalAlignment="Stretch" Height="Auto" Margin="0,0,0,0" VerticalAlignment="Stretch" Width="Auto" NavigationUIVisibility="Hidden"/>
        </Grid>
</Window>



"@


# GUI definition - Inner Window inside Main Window.

$inputPageXML = @"

<Page
      xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
      xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
      xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006" 
      xmlns:d="http://schemas.microsoft.com/expression/blend/2008" 
      xmlns:local="clr-namespace:InstallerWindow"
      xmlns:System="clr-namespace:System;assembly=System.Runtime" x:Class="InstallerWindow.InputPage"
      mc:Ignorable="d" 
      d:DesignHeight="500" d:DesignWidth="707"
      Title="InputPage">

    <Grid x:Name="InputPageGrid" HorizontalAlignment="Stretch" VerticalAlignment="Stretch">
        <Button x:Name="InputPageCancel" Content="Cancel" HorizontalAlignment="Right" Margin="0,0,93,10" VerticalAlignment="Bottom" Width="63" />
        <Image x:Name="ISSQ_Image" HorizontalAlignment="Left" Margin="22,0,0,0" VerticalAlignment="Bottom"  Grid.RowSpan="1" Stretch="Uniform" Height="43" Width="165" />



        <TabControl x:Name="InputTabControl" Canvas.Top="5" Margin="0,0,0,51" TabStripPlacement="Top">
            <TabItem x:Name="OptionsTab" Header="Install Options" IsSelected="True" FontWeight="Bold"  >
                <Grid x:Name="OptionsGrid" Background="#FFF9F9F9" Visibility="Visible" HorizontalAlignment="Stretch">
                    <TextBlock HorizontalAlignment="Left" Margin="47,27,0,0" Text="Choose Items to Install" TextWrapping="Wrap" VerticalAlignment="Top" Width="319" FontWeight="Bold"/>
                    <CheckBox x:Name="DBCheckBox" Content="Database" HorizontalAlignment="Left" Margin="47,69,0,0" VerticalAlignment="Top" FontWeight="Normal"/>
                    <CheckBox x:Name="WebsitesCheckbox" Content="Websites" HorizontalAlignment="Left" Margin="47,99,0,0" VerticalAlignment="Top" FontWeight="Normal"/>
                    <CheckBox x:Name="ServicesCheckbox" Content="Services" HorizontalAlignment="Left" Margin="47,127,0,0" VerticalAlignment="Top" FontWeight="Normal"/>


                </Grid>
            </TabItem>
            <TabItem x:Name="DatabaseTab" Header="Database"  IsSelected="False" >
                <Grid x:Name="DatabaseGrid" Background="#FFF9F9F9" Visibility="Visible">
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="47*"/>
                        <ColumnDefinition Width="3*"/>
                        <ColumnDefinition Width="651*"/>
                    </Grid.ColumnDefinitions>

                    <Label Content="Enter SQL Details to connect to Database" HorizontalAlignment="Left" Margin="1,24,0,0" VerticalAlignment="Top" FontWeight="Bold" Grid.ColumnSpan="2" Width="266" Grid.Column="1" Height="26"/>
                    <Label Content="Database Username" HorizontalAlignment="Left" Margin="0,83,0,0" VerticalAlignment="Top" Grid.Column="2" Height="26" Width="116"/>
                    <TextBox x:Name="DBUserName" HorizontalAlignment="Left" Margin="142,87,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="171" Text="sa" Grid.Column="2" Height="22" ToolTip="Please ensure username has sysadmin privileges."/>
                    <Label Content="Database Password" HorizontalAlignment="Left" Margin="0,106,0,0" VerticalAlignment="Top" Grid.Column="2" Height="26" Width="112"/>
                    <PasswordBox x:Name="DBPassword" HorizontalAlignment="Left" Margin="142,111,0,0" VerticalAlignment="Top" Width="171" Grid.Column="2" Height="21"/>
                    <Button x:Name="TestSQLConnectionButton" Content="Test SQL Connection" HorizontalAlignment="Left" Margin="318,111,0,0" VerticalAlignment="Top" Width="106" FontSize="10" Grid.Column="2" Height="21"/>
                    <Label x:Name="DBServerIPLabel" Content="Database Server IP, Port" HorizontalAlignment="Left" Margin="0,55,0,0" VerticalAlignment="Top" Grid.Column="2" Height="26" Width="142"/>
                    <ComboBox x:Name="DBIPComboBox" HorizontalAlignment="Left" Margin="142,57,0,0" VerticalAlignment="Top" Width="171" IsEditable="True" Grid.Column="2" Height="22"/>

                    <TextBlock HorizontalAlignment="Left" Margin="0,160,0,0" Text="Choose DBs to Install" TextWrapping="Wrap" VerticalAlignment="Top" Width="225" FontWeight="Bold" Grid.Column="1" Grid.ColumnSpan="2" Height="16"/>
                    <Label Content="IAG Database Name" HorizontalAlignment="Left" Margin="0,181,0,0" VerticalAlignment="Top" Grid.Column="2" Height="26" Width="119"/>
                    <TextBox x:Name="IAMDBName" HorizontalAlignment="Left" Margin="142,185,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="171" Text="IAM" Grid.Column="2" Height="22" />
                    <Label Content="Global Database Name" HorizontalAlignment="Left" Margin="0,212,0,0" VerticalAlignment="Top" Grid.Column="2" Height="26" Width="132"/>
                    <TextBox x:Name="GlobalDBName" HorizontalAlignment="Left" Margin="142,216,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="171" Text="Global" Grid.Column="2" Height="22"/>
                    <TextBox x:Name="DBPort" Grid.Column="2" HorizontalAlignment="Left" Margin="318,57,0,0" Text="1433" TextWrapping="Wrap" VerticalAlignment="Top" Width="53" Height="22" ToolTip="Default value is 1433"/>


                </Grid>
            </TabItem>
            <TabItem x:Name="WebsitesTab" Header="Websites" IsSelected="False" >
                <Grid x:Name="WebsitesGrid" Background="#FFF9F9F9" Visibility="Visible" HorizontalAlignment="Stretch" VerticalAlignment="Stretch">
                    <TextBox x:Name="GlobalUIURL" HorizontalAlignment="Left" Margin="45,168,0,0" Text="portal.orsustest.com" TextWrapping="Wrap" VerticalAlignment="Top" Width="228"/>
                    <TextBox x:Name="GlobalAPIURL" HorizontalAlignment="Left" Margin="45,197,0,0" Text="apiportal.orsustest.com" TextWrapping="Wrap" VerticalAlignment="Top" Width="228"/>
                    <TextBlock HorizontalAlignment="Left" Margin="285,148,0,0" Text="App Pools" TextWrapping="Wrap" VerticalAlignment="Top" Width="166" FontWeight="Bold"/>
                    <TextBox x:Name="GlobalUIURL_apppool" HorizontalAlignment="Left" Margin="285,168,0,0" Text="UI_Global" TextWrapping="Wrap" VerticalAlignment="Top" Width="206"/>
                    <TextBox x:Name="globalapiurl_apppool" HorizontalAlignment="Left" Margin="285,197,0,0" Text="API_Global" TextWrapping="Wrap" VerticalAlignment="Top" Width="206"/>
                    <TextBox x:Name="IAMUIURL" HorizontalAlignment="Left" Margin="45,227,0,0" Text="iam.orsustest.com" TextWrapping="Wrap" VerticalAlignment="Top" Width="228"/>
                    <TextBox x:Name="IAMUIURL_apppool" HorizontalAlignment="Left" Margin="285,227,0,0" Text="UI_IAM" TextWrapping="Wrap" VerticalAlignment="Top" Width="206"/>
                    <TextBlock HorizontalAlignment="Left" Margin="47,148,0,0" Text="WebSites to create in IIS" TextWrapping="Wrap" VerticalAlignment="Top" Width="166" FontWeight="Bold"/>
                    <TextBox x:Name="IAMAPIURL" HorizontalAlignment="Left" Margin="45,258,0,0" Text="apiiam.orsustest.com" TextWrapping="Wrap" VerticalAlignment="Top" Width="228"/>
                    <TextBox x:Name="IAMAPIURL_apppool" HorizontalAlignment="Left" Margin="285,258,0,0" Text="API_IAM" TextWrapping="Wrap" VerticalAlignment="Top" Width="206"/>
                    <TextBlock HorizontalAlignment="Left" Margin="47,29,0,0" Text="Path to Install Websites" TextWrapping="Wrap" VerticalAlignment="Top" Width="164" FontWeight="Normal" TextAlignment="Left" Height="15"/>
                    <TextBox x:Name="websitePath" HorizontalAlignment="Left" Margin="218,26,0,0" Text="C:\Live\Orsus1" TextWrapping="Wrap" VerticalAlignment="Top" Width="273"/>
                    <TextBlock HorizontalAlignment="Left" Margin="47,85,0,0" Text="Web Server IP" TextWrapping="Wrap" VerticalAlignment="Top" Width="164" FontWeight="Normal" TextAlignment="Left" Height="15"/>
                    <ComboBox x:Name="websiteIPComboBox" HorizontalAlignment="Left" Margin="218,84,0,0" VerticalAlignment="Top" Width="199" IsEditable="True" Height="22" ></ComboBox>
                    <Button x:Name="WebsitesSelectfolderbutton" Content="  ...  " HorizontalAlignment="Left" Margin="496,26,0,0" VerticalAlignment="Top" RenderTransformOrigin="0.252,0.098" Height="18"/>
                    <TextBlock HorizontalAlignment="Left" Margin="532,115,0,0" Text="Log Level:" TextWrapping="Wrap" VerticalAlignment="Top" Width="63" FontWeight="Normal" TextAlignment="Left" Height="20"/>
                    <ComboBox x:Name="AppLogLevels" HorizontalAlignment="Left" Margin="595,113,0,0" VerticalAlignment="Top" Width="80" IsEditable="False" Height="22" />
                    <TextBlock HorizontalAlignment="Left" Margin="47,54,0,0" Text="File Upload Directory Path" TextWrapping="Wrap" VerticalAlignment="Top" Width="164" FontWeight="Normal" TextAlignment="Left" Height="15"/>
                    <TextBox x:Name="FileUploadDirPath" HorizontalAlignment="Left" Margin="218,51,0,0" Text="C:\Live\Orsus\FileUploads" TextWrapping="Wrap" VerticalAlignment="Top" Width="273"/>
                    <Button x:Name="FileUploadDirSelectfolderbutton" Content="  ...  " HorizontalAlignment="Left" Margin="496,51,0,0" VerticalAlignment="Top" RenderTransformOrigin="0.252,0.098" Height="18"/>
                    <TextBlock x:Name="SSLCertLabel" HorizontalAlignment="Left" Margin="47,319,0,0" Text="SSL Certificate path" TextWrapping="Wrap" VerticalAlignment="Top" Width="164" FontWeight="Normal" TextAlignment="Left" Height="15"/>
                    <TextBox x:Name="SSLCertPath" HorizontalAlignment="Left" Margin="218,316,0,0" Text="" TextWrapping="Wrap" VerticalAlignment="Top" Width="273" Height="34"/>
                    <Button x:Name="SSLCertSelectfilebutton" Content=" Select File " HorizontalAlignment="Left" Margin="496,316,0,0" VerticalAlignment="Top" RenderTransformOrigin="0.252,0.098" Height="18" Visibility="Visible"/>
                    <TextBlock HorizontalAlignment="Left" Margin="47,117,0,0" Text="Application Log Location" TextWrapping="Wrap" VerticalAlignment="Top" Width="164" FontWeight="Normal" TextAlignment="Left" Height="18"/>
                    <TextBox x:Name="AppLogPath" HorizontalAlignment="Left" Margin="218,114,0,0" Text="C:\Live\ORSUS\Logs" TextWrapping="Wrap" VerticalAlignment="Top" Width="273" Height="18"/>
                    <Button x:Name="AppLogLocationButton" Content="  ...  " HorizontalAlignment="Left" Margin="496,114,0,0" VerticalAlignment="Top" RenderTransformOrigin="0.252,0.098" Height="18"/>
                    <CheckBox x:Name="SSLCheckBox" Content="Enable HTTPS" HorizontalAlignment="Left" Margin="45,294,0,0" VerticalAlignment="Top" ClickMode="Release" IsChecked="True"/>
                    <TextBlock x:Name="PFXPwdLabel" HorizontalAlignment="Left" Margin="47,357,0,0" Text="PFX Password (Optional)" TextWrapping="Wrap" VerticalAlignment="Top"/>
                    <PasswordBox x:Name="PFXPwdBox" HorizontalAlignment="Left" Margin="218,355,0,0" VerticalAlignment="Top" Width="273" ToolTip="If empty, no password is considered." Password="123"/>

                </Grid>
            </TabItem>

            <TabItem x:Name="ServicesTab" Header="Services" IsSelected="False" >
                <Grid x:Name="ServicesGrid" Background="#FFF9F9F9">
                    <TextBlock HorizontalAlignment="Left" Margin="47,44,0,0" Text="Windows Services will be created based on the following inputs." TextWrapping="Wrap" VerticalAlignment="Top" Height="20" Width="335" Foreground="#FF1700F1"/>
                    <TextBlock HorizontalAlignment="Left" Margin="47,105,0,0" Text="Path to Install" TextWrapping="Wrap" VerticalAlignment="Top"/>
                    <TextBox x:Name="ServicesPath" HorizontalAlignment="Left" Margin="124,104,0,0" Text="C:\Live\Orsus\" TextWrapping="Wrap" VerticalAlignment="Top" Width="265"/>
                    <Button x:Name="ServicesSelectfolderbutton" Content="Select Folder" HorizontalAlignment="Left" Margin="394,103,0,0" VerticalAlignment="Top" RenderTransformOrigin="0.252,0.098" Width="79"/>
                    <Label x:Name="ServicesServerIPLabel" Content="Services Server IP" HorizontalAlignment="Left" Margin="43,142,0,0" VerticalAlignment="Top" Height="26" Width="105"/>
                    <ComboBox x:Name="ServicesIPComboBox" HorizontalAlignment="Left" Margin="153,144,0,0" VerticalAlignment="Top" Width="171" IsEditable="True" Height="22"/>
                    <TextBlock x:Name="ServicesLogLocationName" HorizontalAlignment="Left" Margin="48,181,0,0" Text="Services Log Location" TextWrapping="Wrap" VerticalAlignment="Top" Width="121" FontWeight="Normal" TextAlignment="Left" Height="18"/>
                    <TextBox x:Name="ServicesLogPath" HorizontalAlignment="Left" Margin="174,180,0,0" Text="C:\Live\ORSUS\Logs" TextWrapping="Wrap" VerticalAlignment="Top" Width="318" Height="19"/>
                    <Button x:Name="ServicesLogLocationButton" Content="  ...  " HorizontalAlignment="Left" Margin="497,180,0,0" VerticalAlignment="Top" RenderTransformOrigin="0.252,0.098" Height="18"/>
                    <TextBox x:Name="GlobalUIURL_Services" HorizontalAlignment="Left" Margin="47,234,0,0" Text="portal.orsustest.com" TextWrapping="Wrap" VerticalAlignment="Top" Width="228"/>
                    <TextBox x:Name="GlobalAPIURL_Services" HorizontalAlignment="Left" Margin="47,263,0,0" Text="apiportal.orsustest.com" TextWrapping="Wrap" VerticalAlignment="Top" Width="228"/>
                    <TextBox x:Name="IAMUIURL_Services" HorizontalAlignment="Left" Margin="47,293,0,0" Text="iam.orsustest.com" TextWrapping="Wrap" VerticalAlignment="Top" Width="228"/>
                    <TextBlock HorizontalAlignment="Left" Margin="49,214,0,0" Text="Websites created in IIS" TextWrapping="Wrap" VerticalAlignment="Top" Width="166" FontWeight="Bold"/>
                    <TextBox x:Name="IAMAPIURL_Services" HorizontalAlignment="Left" Margin="47,324,0,0" Text="apiiam.orsustest.com" TextWrapping="Wrap" VerticalAlignment="Top" Width="228"/>
                </Grid>
            </TabItem>
            <TabItem x:Name="StatusTab" Header="System Status" IsSelected="False">
                <Grid x:Name="StatusGrid" Background="#FFF9F9F9" Visibility="Visible">
                    <TextBlock HorizontalAlignment="Left" Margin="51,22,0,0" Text="System Status" TextWrapping="Wrap" VerticalAlignment="Top" Height="21" Width="335" Foreground="Black" FontWeight="Bold"/>
                    <ScrollViewer Margin="30,43,22,34">
                        <StackPanel>
                            <Label x:Name="IIS_Status" Content="IIS Status"/>
                            <Label x:Name="SQLServer_Status" Content="SQL Server Status"/>
                            <Label x:Name="dotNet_Status" Content="dot Net Status"/>
                        </StackPanel>

                    </ScrollViewer>
                </Grid>
            </TabItem>
            <TabItem x:Name="SummaryTab" Header="Configuration Summary" FontWeight="Normal" Visibility="Visible" FontStyle="Italic">
                <Grid x:Name="SummaryGrid" Background="#FFF9F9F9" Visibility="Visible">
                    <TextBlock HorizontalAlignment="Left" Margin="38,27,0,0" Text="Summary of Configuration:" TextWrapping="Wrap" VerticalAlignment="Top" FontSize="14" FontWeight="Bold"/>
                    <Button x:Name="SummaryPageInstall" Content="Apply" HorizontalAlignment="Right" Margin="0,0,10,10" VerticalAlignment="Bottom" Width="63" Visibility="Collapsed"/>
                    <Button x:Name="SummaryPageBack" Content="Back" HorizontalAlignment="Right" Margin="0,0,78,10" VerticalAlignment="Bottom" Width="63" Visibility="Collapsed"/>
                    <ScrollViewer  Margin="38,66,10,42" Background="#FFE5E5E5">
                        <StackPanel>
                            <TextBlock x:Name="DBSummary" Text="DBSummary" TextWrapping="Wrap" FontWeight="Normal"/>
                            <TextBlock x:Name="WebsitesSummary" Text="WebsiteSummary" TextWrapping="Wrap" FontWeight="Normal"/>
                        </StackPanel>
                    </ScrollViewer>
                    <TextBlock HorizontalAlignment="Left" Margin="38,0,0,6" Text="Install Status:" TextWrapping="Wrap" VerticalAlignment="Bottom" FontWeight="Bold" FontSize="14"/>
                    <TextBlock x:Name="InstallStatus" HorizontalAlignment="Left" Margin="141,0,0,7" Text="Click Apply to start installation." TextWrapping="Wrap" VerticalAlignment="Bottom" FontSize="13"/>
                </Grid>
            </TabItem>
        </TabControl>
        <Button x:Name="InputPageApply" Content="Summary" HorizontalAlignment="Right" Margin="0,0,10,10" VerticalAlignment="Bottom" Width="63" Visibility="Visible" />
        <Image x:Name="Orsus_logo" HorizontalAlignment="Right" VerticalAlignment="Top" Height="23" Width="23"/>
    </Grid>
</Page>


"@




#========================================================
# Code to clean xml and convert to PS Objects. - This function creates all elements into PS objects.
#========================================================


function Get-XamlObject {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0,
            Mandatory = $true,
            ValuefromPipelineByPropertyName = $true,
            ValuefromPipeline = $true)]
        [Alias("FullName")]
        [System.String[]]$xmls
    )

    BEGIN {
        Set-StrictMode -Version Latest
        $expandedParams = $null
        $PSBoundParameters.GetEnumerator() | ForEach-Object { $expandedParams += ' -' + $_.key + ' '; $expandedParams += $_.value }
        Write-Verbose "Starting: $($MyInvocation.MyCommand.Name)$expandedParams"
        $output = @{ }
		
        Add-Type -AssemblyName presentationframework, presentationcore, System.Windows.Forms
    } #BEGIN

    PROCESS {
        try {
            foreach ($xamlFile in $xmls) {
                #Wait-Debugger
                #Change content of Xaml file to be a set of powershell GUI objects
				
                [xml]$xaml = $xamlfile -replace 'mc:Ignorable="d"', '' -replace "x:N", 'N' -replace 'x:Class=".*?"', '' -replace 'd:DesignHeight="\d*?"', '' -replace 'd:DesignWidth="\d*?"', ''
                $tempform = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $xaml -ErrorAction Stop))

                #Grab named objects from tree and put in a flat structure using Xpath
                $namedNodes = $xaml.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]")
                $namedNodes | ForEach-Object {
                    $output.Add($_.Name, $tempform.FindName($_.Name))
                } #foreach-object
            } #foreach xamlpath
        } #try
        catch {
            throw $error[0]
        } #catch
    } #PROCESS

    END {
        Write-Output $output
        Write-Verbose "Finished: $($MyInvocation.Mycommand)"
    } #END
}




#========================================================

#Set Starting path and create Synchronised hash table to be read across multiple runspaces (threads).
$script:wpf = [hashtable]::Synchronized(@{ })


# Join all xml elements and get PS objects into $wpf
[System.String[]] $inputxmls = $mainWindowXML, $inputPageXML
$wpf = $inputxmls | Get-XamlObject


# AI_GetMsiProperty is an Advanced Installer module, to read it's variables into this PS Script. 
# APPDIR  is the path where files are configured to be extracted: C:\Program Files\ISSQUARED Inc\ORSUS IAG\

# $appdir = AI_GetMsiProperty APPDIR
$appdir = "C:\Program Files\ISSQUARED Inc\ORSUS IAG\"

$LogFilePath = $appdir

# Logos are extracted from the exe, when not found, installer fails.

$iconfile = "$appdir\Assets\orsus.ico"
$orsus_logo = "$appdir\Assets\Orsus-Logo.png"
$issq_imageFile = "$appdir\Assets\ISSQ-Logo.png"

# Navigate to input page window when run.
$wpf.mainwindowframe.NavigationService.Navigate($wpf.inputpagegrid) | Out-Null

$wpf.installerwindow.icon = $iconfile
$wpf.ISSQ_Image.Source = $issq_imageFile
$wpf.orsus_logo.source = $orsus_logo
$wpf.databasetab.visibility = "collapsed"  
$wpf.DatabaseGrid.visibility = "collapsed"

$wpf.websitestab.visibility = "collapsed"
$wpf.WebsitesGrid.visibility = "collapsed"

$wpf.ServicesTab.visibility = "collapsed"
$wpf.ServicesGrid.visibility = "collapsed"

$wpf.SummaryTab.visibility = "collapsed"
$wpf.SummaryGrid.visibility = "collapsed"

$wpf.DBSummary.Visibility = "Collapsed"
$wpf.WebsitesSummary.Visibility = "Collapsed"

$wpf.InputPageApply.Visibility = "hidden"
        
        


$wpf.package_path = "$appdir\Package"

$iamsourcefiles = join-path $wpf.package_path "\IAM"
$globalsourcefiles = join-path $wpf.package_path "\Global"
$hrsourcefiles = join-path $wpf.package_path "\HR"    
$wpf.PostScriptsPath = join-path $wpf.package_path "\Post_Scripts"
$wpf.IAMservicesPath = join-path $wpf.package_path "\IAM\WinServices"
$wpf.GlobalservicesPath = join-path $wpf.package_path "\Global\WinServices"

$website_destination = $wpf.websitepath.text
$ServicesDestination = $wpf.servicespath.text

$iamdestinationfiles = "$website_destination\IAM"
$globaldestinationfiles = "$website_destination\Global"
$wpf.iamsourcedbfolder = Join-Path $iamsourcefiles "\DB"
$wpf.globalsourcedbfolder = "$globalsourcefiles\DB"
$wpf.hrsourcefolder = "$hrsourcefiles\DB"
       
$wpf.server = $wpf.DBIPComboBox.Text
$wpf.ServicesServerIP = $wpf.ServicesIPComboBox.Text
        
#[System.Windows.MessageBox]::Show($dbserverip, 'Installation Status.')
$wpf.username = $wpf.DBUserName.Text
$wpf.password = $wpf.DBPassword.Password

$wpf.iamdatabase = $wpf.IAMDBName.Text
$wpf.globaldatabase = $wpf.GlobalDBName.Text

$wpf.PFXPassword = $wpf.PFXPwdBox.password
$wpf.PFXPath = $wpf.SSLCertPath.text

# DAC framework is a prerequisite, not included in installer, fails when not found.
$wpf.sqlpackage_path = "C:\Program Files\Microsoft SQL Server\150\DAC\bin\"

$stop_install = "False"
$validation = "null"



$wpf.database_install_status = "Empty";
$wpf.websites_install_status = "Empty";
$wpf.services_install_status = "Empty";



# load IP addresses beforehand for use when required.
function webIPComboBoxSource {
    $webips = @(get-netipaddress | Select-Object ipaddress | Where-Object { $_ -notmatch ':' -and ($_ -notmatch '169.*.*.*' -and $_ -notmatch '127.0.0.1') })
    $wpf.websiteIPComboBox.ItemsSource = $webips
    $wpf.websiteIPComboBox.displaymemberpath = 'ipaddress'
    $wpf.websiteipcombobox.selectedindex = 0
	
	
}
webIPComboBoxSource

function DBIPComboBoxSource {
    $DBips = @(get-netipaddress | Select-Object ipaddress | Where-Object { $_ -notmatch ':' -and ($_ -notmatch '169.*.*.*' -and $_ -notmatch '127.0.0.1') })
    $wpf.DBIPComboBox.ItemsSource = $DBips
    $wpf.DBIPComboBox.displaymemberpath = 'ipaddress'
    $wpf.DBipcombobox.selectedindex = 0
	
	
}
DBIPComboBoxSource


function ServicesIPComboBoxSource {
    $ServicesIPs = @(get-netipaddress | Select-Object ipaddress | Where-Object { $_ -notmatch ':' -and ($_ -notmatch '169.*.*.*' -and $_ -notmatch '127.0.0.1') })
    $wpf.ServicesIPComboBox.ItemsSource = $ServicesIPs
    $wpf.ServicesIPComboBox.displaymemberpath = 'ipaddress'
    $wpf.ServicesIPComboBox.selectedindex = 0
	
	
}
ServicesIPComboBoxSource



function Stop-Install($message) {
    
    $stop_install = "True"
    $wpf.InstallerWindow.Close() | Out-Null   
    

}




function Test-SqlConnection {
    param(
        
        [string]$ServerName,
        [string]$DatabaseName,
        [pscredential]$Credential
    )

    $ErrorActionPreference = 'Stop'

    try {
        $DBuserName = $wpf.dbusername.text
        $DBpassword = $wpf.dbpassword.password
        $DBServerName = $wpf.dbipcombobox.text
        $DBportnumber = $wpf.dbport.text
        if ($DBportnumber -eq '') { $DBportnumber = 1433 }
        $connectionString = 'Data Source={0},{4};database={1};User ID={2};Password={3}' -f $DBServerName, $DatabaseName, $DBuserName, $DBpassword, $DBportnumber
        $sqlConnection = New-Object System.Data.SqlClient.SqlConnection $ConnectionString
        $sqlConnection.Open()
        ## This will run if the Open() method does not throw an exception
        return $true
    }
    catch {
        return $false
    }
    finally {
        ## Close the connection when we're done
        $sqlConnection.Close()
    }
}



# To display in summary page.
function database_summary {
	
    $username = $wpf.dbusername.text
    $dbserverip = $wpf.DBIPComboBox.text
    $dbserverPort = $wpf.dbport.text
    $db1 = $wpf.globaldbname.text
    $db2 = $wpf.iamdbname.text
	
    return "
    Database details:

    DB Server IP, Port:   $dbserverip, $dbserverport 
    Username:       $userName 
    Databases:      $db1, $db2
    "
	
}
# function System_summary {
	
    
#     $iisstatus =  (get-wmiobject Win32_Service -Filter "name='IISADMIN'").state
#     $sqlstatus = (Get-service  | where {($_.name -like "MSSQL$*" -or $_.name -like "MSSQLSERVER" -or $_.name -like "SQL Server (*") }).status
#     $dotnetversion = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full").version
	
#     return "
#     IIS Status: $iisstatus
#     SQL Server Status: $sqlstatus
#     .Net Version: $dotnetversion
#     "
	
# }


function websites_summary {
	
    $site1 = $wpf.GlobalUIURL.text
    $site2 = $wpf.GlobalAPIURL.text
    $site3 = $wpf.IAMUIURL.text
    $site4 = $wpf.IAMAPIURL.text
    $websiteInstallPath = $wpf.websitepath.text
    $websiteFileUploadDirPath = $wpf.FileUploadDirPath.text
    $webserverIP = $wpf.websiteIPComboBox.text
    $applicationLogLevel = $wpf.AppLogLevels.text
    $PFXPath = $wpf.sslcertpath.text

    if ($PFXPath -eq '') {
        $sslcertPath = "No SSL Certificate selected."
    }

    return "
    Websites Configuration:

    Install Location: $websiteinstallpath
    File Upload Directory: $websitefileuploaddirpath
    Web Server IP : $webserverip
    SSL Certificate : $PFXpath
    Application Log Level : $applicationloglevel

    Websites to be installed: `r`n
    $site1
    $site2
    $site3
    $site4 
    `r`n
    "
}

# Update summary on the spot when data is changed.
function UpdateSummary {
    
    $wpf.DBSummary.text = database_summary
    $wpf.WebsitesSummary.text = websites_summary
    
}
function UpdateSystemStatus {

    $iisstatus = (get-wmiobject Win32_Service -Filter "name='IISADMIN'").state
    $sqlstatus = (Get-service  | where { ($_.name -like "MSSQL$*" -or $_.name -like "MSSQLSERVER" -or $_.name -like "SQL Server (*") }).status
    $dotnetversion = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full").version
	
    
    $wpf.IIS_Status.content = "IIS : $iisstatus"
    $wpf.SQLServer_Status.content = "SQL Server : $sqlstatus"
    $wpf.dotNet_Status.content = ".Net Version : $dotnetversion"
    
}
UpdateSystemStatus

#$wpf.SummaryTab.add_gotfocus( {
#        #[System.Windows.MessageBox]::Show('focus', 'Installation Status.')
#        UpdateSummary
#
#    
#    })

	
#region checkbox-functionality

function checkbox_actions {
	
    if ($wpf.dbcheckbox.IsChecked -or $wpf.WebsitesCheckbox.IsChecked -or $wpf.ServicesCheckbox.IsChecked ) { 
      
        $wpf.inputpageapply.visibility = "visible" 
       
        $wpf.databasetab.visibility = "visible"
        $wpf.DatabaseGrid.visibility = "visible"
        
        $wpf.DBSummary.Visibility = "visible"

        UpdateSummary
        UpdateSystemStatus
    
    }
    else {
        $wpf.InputPageApply.Visibility = "hidden"

        $wpf.databasetab.visibility = "collapsed"
        $wpf.DatabaseGrid.visibility = "collapsed"

        $wpf.SummaryTab.visibility = "collapsed"
        $wpf.SummaryGrid.visibility = "collapsed"

        $wpf.InputPageApply.Content = "Summary"
    }
	
        
}



function AppLogLevelsComboBoxSource {
    
    $loglevels = @( "DEBUG", "INFO", "WARN", "ERROR")
    $wpf.AppLogLevels.ItemsSource = $loglevels
    $wpf.AppLogLevels.SelectedIndex = 1
    
}
AppLogLevelsComboBoxSource


$wpf.dbcheckbox.add_checked( {
        $wpf.databasetab.visibility = "visible"
        $wpf.DatabaseGrid.visibility = "visible"
        $wpf.DBSummary.Visibility = "visible"
        checkbox_actions
	
    })

$wpf.dbcheckbox.add_unchecked( {
        $wpf.databasetab.visibility = "collapsed"
        $wpf.DatabaseGrid.visibility = "collapsed"
        $wpf.DBSummary.Visibility = "Collapsed"
        checkbox_actions
	
    })

$wpf.WebsitesCheckbox.add_checked( {
        
        $wpf.websitestab.visibility = "visible"
        $wpf.WebsitesGrid.visibility = "visible"
        $wpf.WebsitesSummary.Visibility = "visible"
        checkbox_actions
	
    })

$wpf.WebsitesCheckbox.add_unchecked( {
	
        $wpf.websitestab.visibility = "collapsed"
        $wpf.WebsitesGrid.visibility = "collapsed"
        $wpf.WebsitesSummary.Visibility = "Collapsed"
        checkbox_actions
	
    })

$wpf.ServicesCheckbox.add_checked( {
        
        $wpf.ServicesTab.visibility = "visible"
        $wpf.ServicesGrid.visibility = "visible"
        
        checkbox_actions

	
    })

$wpf.ServicesCheckbox.add_unchecked( {
        $wpf.ServicesTab.visibility = "collapsed"
        $wpf.ServicesGrid.visibility = "collapsed"
        
        checkbox_actions
	
	
    })
	

$wpf.SSLCheckBox.add_checked( {

        $wpf.SSLCertLabel.visibility = "visible"
        $wpf.SSLCertPath.visibility = "visible"
        $wpf.SSLCertSelectfilebutton.visibility = "visible"
        $wpf.PFXPwdLabel.visibility = "visible"
        $wpf.PFXPwdBox.visibility = "visible"
        
    })

$wpf.SSLCheckBox.add_unchecked( {
        $wpf.SSLCertLabel.visibility = "hidden"
        $wpf.SSLCertPath.visibility = "hidden"
        $wpf.SSLCertSelectfilebutton.visibility = "hidden"
        $wpf.PFXPwdLabel.visibility = "hidden"
        $wpf.PFXPwdBox.visibility = "hidden"
    })
#endregion checkbox-functionality


#region navigation


# Test SQL Connectivity	
$wpf.testsqlconnectionbutton.add_Click( {
		
        if (Test-SqlConnection) { [System.Windows.MessageBox]::Show('Connection Successful.                            ', 'Test SQL Connection') }
        else { [System.Windows.MessageBox]::Show('Connection Failed.                            ', 'Test SQL Connection') }
    })


$wpf.WebsitesSelectfolderbutton.add_Click( {
        
        
        $browser = New-Object System.Windows.Forms.FolderBrowserDialog
        $null = $browser.ShowDialog()
        $wpf.websitePath.text = $browser.SelectedPath
        
        
    })
    
$wpf.FileUploadDirSelectfolderbutton.add_Click( {
        
        
        $browser = New-Object System.Windows.Forms.FolderBrowserDialog
        $null = $browser.ShowDialog()
        $wpf.FileUploadDirPath.text = $browser.SelectedPath
        
        
    })

$wpf.AppLogLocationButton.add_Click( {
        
        
        $browser = New-Object System.Windows.Forms.FolderBrowserDialog
        $null = $browser.ShowDialog()
        $wpf.AppLogPath.text = $browser.SelectedPath
        
        
    })

$wpf.ServicesLogLocationButton.add_Click( {
        
        
        $browser = New-Object System.Windows.Forms.FolderBrowserDialog
        $null = $browser.ShowDialog()
        $wpf.ServicesLogPath.text = $browser.SelectedPath
        
        
    })

$wpf.SSLCertSelectfilebutton.add_Click( {

        $sslBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{
            InitialDirectory = [Environment]::GetFolderPath('Desktop')
            Filter           = 'PFX Files (*.pfx)|*.pfx| All Files(*.*)|*.*'
        }
        $null = $sslBrowser.ShowDialog()
        
        $wpf.SSLCertPath.text = $sslbrowser.FileName


    })

$wpf.ServicesSelectfolderbutton.add_Click( {
        
        
        $browser = New-Object System.Windows.Forms.FolderBrowserDialog
        $null = $browser.ShowDialog()
        $ServicesPath = $browser.SelectedPath
        $wpf.ServicesPath.text = $ServicesPath
        
    })
	
#endregion navigation

#Validation of inputs before making changes.
function validate-inputs {
    param($db, $web, $services)
    #website-install validation

    if ($db -eq 1) {
        if (!$wpf.dbpassword.password ) {
            $wpf.databasetab.IsSelected = "True"
            
            [System.Windows.MessageBox]::Show('Please input SQL Password.                            ', 'IAG Installer.')
            
            $result = "Fail"
            # continue
            return $result
        }
        
       else{
           
        $sql_pwd_valid = invoke-expression Test-SqlConnection
       
        if ($sql_pwd_valid -eq $false) {
            $wpf.databasetab.IsSelected = "True"
            [System.Windows.MessageBox]::Show('SQL Password is incorrect!                            ', 'IAG Installer.')
            $result = "Fail"
            # continue
            return $result
            
        }

        $result = "Pass"
    }
    }

    if ($web -eq 1) {

        $user_Website_path = $wpf.websitepath.text
        write-host inside web validation
        if (!((test-path -path "$user_website_path\IAM") -or (test-path -path "$user_website_path\Global") -or (test-path -path "$user_website_path\HR"))) {

            $result = "pass"

        }
        elseif ($wpf.SSLCheckBox.ischecked) {
            
            if (!$wpf.SSLCertPath.text) {
                [System.Windows.MessageBox]::Show('Please select pfx certificate to import.       ', 'IAG Installer.')
            
                $result = "fail"
                return $result
        
            }
            #validate certificate password
            write-host $wpf.SSLCertPath.text
            $certPass = $wpf.PFXPwdBox.password
            $CertPath = $wpf.PFXPath 

            #$certPath = "C:\Users\pkeelu\Documents\Work Documents\GUIDemo\SSL-SelfSignedCert\orsustest.pfx"  
            #$certPass = "pass1232"  
            
            $certificateObject = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
            $certificateObject.Import($certpath, $certpass, [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::DefaultKeySet)
            $pfxThumbprint = $certificateObject.Thumbprint

            $certPath
            $certPass
            write-host $pfxThumbprint

            [System.Windows.MessageBox]::Show("$pfxThumbprint $certPass Please input correct pfx password!       ", 'IAG Installer.')
           
            if ($pfxThumbprint) {
                $result = "pass"

            }
            else {
                [System.Windows.MessageBox]::Show('Please input correct pfx password!       ', 'IAG Installer.')

                $result = "fail"
                return $result
            }
        }
        else {

            write-host "Folder not empty, Please choose different folder."
            $wpf.websitesTab.IsSelected = "True"
            [System.Windows.MessageBox]::Show('Installation folder not empty, Please choose different folder.       ', 'IAG Installer.')
            $result = "fail"
            return $result
        }

    }
    if ($services -eq 1) {

        if (Test-Path -Path $ServicesDestination) {


            $exes = Get-ChildItem -Path $ServicesDestination -Filter *.exe -Recurse -ErrorAction SilentlyContinue -Force | select-object fullname -expandproperty fullname
	
            # write-host $exes
            
            
            foreach ($exe in $exes) {
            
                $binaryPath = $exe
                $dirpath = split-path $binaryPath
                $dir = split-path $dirpath -leaf
                $serviceName = "ISSQ ORSUS-IAG $dir"

                $serviceCheck = Get-Service $serviceName -ErrorAction SilentlyContinue

                if ($serviceCheck.length) {
                    [System.Windows.MessageBox]::Show("Please delete $servicename to continue.       ", 'IAG Installer.')
                    $result = "fail"
                    return $result

                }
                
            }

        }

    }

    
    return $result
    
}               

function install-Database {

    $wpf.LogFilePath = $LogFilePath
    # All information should be inside shared $wpf variable for runspaces to access.
    $wpf.server = $wpf.DBIPComboBox.Text
        
    $wpf.username = $wpf.DBUserName.Text
    $wpf.password = $wpf.DBPassword.Password

    $wpf.iamdatabase = $wpf.IAMDBName.Text
    $wpf.globaldatabase = $wpf.GlobalDBName.Text
	 

    $wpf.InstallStatus.Text = ''


    # Runspace Creation - configuration.
    $runspace = [runspacefactory]::CreateRunspace()
    $powerShell = [powershell]::Create()
    $powerShell.runspace = $runspace
    $runspace.ThreadOptions = 'ReuseThread'
    $runspace.ApartmentState = 'STA'
    $runspace.Open()
    $runspace.SessionStateProxy.SetVariable("wpf", $wpf)


    # Commands to run inside runspace.
    [void]$PowerShell.AddScript( {

            $LogFilePath = $wpf.LogFilePath
            # $logfile = "$LogFilePath" + (Get-date -Format dd_MM_yyyy) + ".log"
            function updatestatus($message) {
				
                $wpf.installstatus.Dispatcher.Invoke([action] {
                        $wpf.InstallStatus.Text = $message
                    })
            }

            Function WriteLog($message) {

                Write-Host (Get-Date).ToString() + $message
                $logfile = "$LogFilePath" + (Get-date -Format dd_MM_yyyy) + ".log"
                Add-Content $logfile ((Get-Date).ToString() + " [Database:] " + $message)
            
            } 

            # [System.Windows.MessageBox]::Show(" database started" , "IAG Installer" , 0, 64)
        
            $server = $wpf.server 
        
            $username = $wpf.username 
            $password = $wpf.password 
    
            $iamdatabase = $wpf.iamdatabase
            $globaldatabase = $wpf.globaldatabase 
            $sqlpackage_path = $wpf.sqlpackage_path
            $PostScriptsPath = $wpf.PostScriptsPath
            $hrsourcefolder = $wpf.hrsourcefolder
            $hrdatabase = 'HR'
            $iamsourcedbfolder = $wpf.iamsourcedbfolder
            $globalsourcedbfolder = $wpf.globalsourcedbfolder
            
            updatestatus("Importing DB...")
            writelog "Importing DB..." 
			
            
    
            #Deleting old databases:
            updatestatus("Deleting old databases...")
            writelog "Deleting old databases..." 
            writelog "
            values are: 
          
sqlpackage_path = $sqlpackage_path
PostScriptsPath  = $PostScriptsPath 
hrsourcefolder = $hrsourcefolder
hrdatabase  = $hrdatabase 
iamsourcedbfolder  = $iamsourcedbfolder 
globalsourcedbfolder  = $globalsourcedbfolder 
            
            " 

            writelog "Deleting old databases..." 

            try {

                invoke-sqlcmd -ServerInstance $server -U $username -P $password -Query "alter database $hrdatabase set single_user with rollback immediate;" -erroraction silentlycontinue
                invoke-sqlcmd -ServerInstance $server -U $username -P $password -Query "alter database $iamdatabase set single_user with rollback immediate;" -erroraction silentlycontinue
                invoke-sqlcmd -ServerInstance $server -U $username -P $password -Query "alter database $globaldatabase set single_user with rollback immediate;" -erroraction silentlycontinue

                invoke-sqlcmd -ServerInstance $server -U $username -P $password -Query "Drop database $hrdatabase;" -erroraction silentlycontinue
                invoke-sqlcmd -ServerInstance $server -U $username -P $password -Query "Drop database $iamdatabase;" -erroraction silentlycontinue
                invoke-sqlcmd -ServerInstance $server -U $username -P $password -Query "Drop database $globaldatabase;" -erroraction silentlycontinue
		

            }
            catch {

                writelog "Deleting old databases failed. Error: " $error
                updatestatus("Deleting old databases failed.")
            }        
            
            updatestatus("$iamdatabase $globaldatabase databases deleted.")
		
            # updatestatus("Importing HR Database")
		
            # set-location $hrsourcefolder
            # $hrdbpath = Get-ChildItem -Path . -Filter *.sql -Recurse -ErrorAction SilentlyContinue -Force | select-object fullname -first 1 -expandproperty fullname
            # sqlcmd -S $server -U $username -P $password -i $hrdbpath
            # updatestatus("HR Database imported.")
            # writelog "HR Database imported."
		
		
            updatestatus("importing Global and IAM Database	"	)
            writelog "Importing Global and IAM databases..."

           

            $iamconn = "Data Source=$server;Initial Catalog=$iamdatabase;Integrated Security=false;user id=$username;password=$password"
            $globalconn = "Data Source=$server;Initial Catalog=$globaldatabase;Integrated Security=false;user id=$username;password=$password"
	
            set-location $iamsourcedbfolder
            $iamdacpac = Get-ChildItem -Path . -Filter *.dacpac -Recurse -ErrorAction SilentlyContinue -Force | select-object fullname -first 1 -expandproperty fullname
		
            set-location $globalsourcedbfolder
            $globaldacpac = Get-ChildItem -Path . -Filter *.dacpac -Recurse -ErrorAction SilentlyContinue -Force | select-object fullname -first 1 -expandproperty fullname
		
            $prop = 'DoNotDropObjectTypes=Users;Permissions;RoleMembership;'
		
            updatestatus("Creating IAM and Global Databases. This process takes few minutes, Please wait...")
            writelog "Creating IAM and Global Databases. This process takes few minutes, Please wait..."
            write-host "`r`n"
            
		
            set-location $sqlpackage_path
            # Wait-Debugger

            writelog "values are:
            
            iamconn = $iamconn
            globalconn = $globalconn
            iamdacpac = $iamdacpac
            globaldacpac = $globaldacpac
            sqlpackage_path = $sqlpackage_path
            "
                
            # $iaminstalloutput = ./sqlpackage.exe /sourcefile:$iamdacpac /action:Publish /properties:BlockOnPossibleDataLoss=false /properties:GenerateSmartDefaults=True /properties:DropObjectsNotInSource=True /properties:RegisterDataTierApplication=True /properties:BlockWhenDriftDetected=False /properties:'DoNotDropObjectTypes=Users;Permissions;RoleMembership;' /TargetConnectionString:$iamconn 2>&1  # 2>&1
            #./sqlpackage.exe /sourcefile:$iamdacpac /action:Publish /properties:BlockOnPossibleDataLoss=false /properties:GenerateSmartDefaults=True /properties:DropObjectsNotInSource=True /properties:RegisterDataTierApplication=True /properties:BlockWhenDriftDetected=False '/properties:DoNotDropObjectTypes=Users;Permissions;RoleMembership;' /TargetConnectionString:$iamconn 2>&1   | $iamsqlpackage # 2>&1 redirects error as well into the variable.
            # $globalinstalloutput = ./sqlpackage.exe /sourcefile:$globaldacpac /action:Publish /properties:BlockOnPossibleDataLoss=false /properties:GenerateSmartDefaults=True /properties:DropObjectsNotInSource=True /properties:RegisterDataTierApplication=True /properties:BlockWhenDriftDetected=False /properties:'DoNotDropObjectTypes=Users;Permissions;RoleMembership;' /TargetConnectionString:$globalconn 2>&1  # | $globalsqlpackage
		

            try {
                
                # ./sqlpackage.exe /sourcefile:$globaldacpac /action:Publish /properties:BlockOnPossibleDataLoss=false /properties:GenerateSmartDefaults=True /properties:DropObjectsNotInSource=True /properties:RegisterDataTierApplication=True /properties:BlockWhenDriftDetected=False /properties:$prop /TargetConnectionString:$globalconn  | Tee-Object -Variable globalinstalloutput
                # ./sqlpackage.exe /sourcefile:$iamdacpac /action:Publish /properties:BlockOnPossibleDataLoss=false /properties:GenerateSmartDefaults=True /properties:DropObjectsNotInSource=True /properties:RegisterDataTierApplication=True /properties:BlockWhenDriftDetected=False /properties:$prop /TargetConnectionString:$iamconn | Tee-Object -Variable iaminstalloutput
		
            }
            catch {
                
                writelog "Importing databases failed"
                writelog $iaminstalloutput
                writelog $globalinstalloutput
                [System.Windows.MessageBox]::Show(" database failed" , "IAG Installer" , 0, 64)
                return
            }
            
            writelog $iaminstalloutput
            writelog $globalinstalloutput
            # Wait-Debugger

            [string]$iaminstalloutput = $iaminstalloutput
            [string]$globalinstalloutput = $globalinstalloutput

            # if (($iaminstalloutput -notmatch "Successfully published database") -or ($globalinstalloutput -notmatch "Successfully published database")) { 
            # if (($iaminstalloutput -notlike "*Successfully published database*") -or ($globalinstalloutput -notlike "*Successfully published database*")) { 

        
            #     updatestatus("Aborting installation due to failure.")
            #     writelog  "Aborting script due to failure."
            #     return
            # }
		
            updatestatus("$iamdatabase Imported with $username and it's password.")
            updatestatus("$globaldatabase Imported with $username and it's password.")
            updatestatus("IAM and Global imported.")
            writelog "IAM and Global imported."
		
		
            write-host "`r`n"
            #write-host "Running pre-deployment Scripts. "
            #
            #sqlcmd -S $server -U $username -P $password -d $database -i Script.PreDeployment.sql
            #write-host "`r`n"
            updatestatus("Running post-deployment scripts.")
            writelog "Running post-deployment scripts."
            # Wait-Debugger
		
            set-location $PostScriptsPath
            $scripts = Get-ChildItem -Path . -Filter *.sql -Recurse -ErrorAction SilentlyContinue -Force  | select-object fullname  -expandproperty fullname
		
            writelog "
            values are:
            $PostScriptsPath
            $scripts

            
            "
            $FileText = [System.IO.File]::ReadAllText("$scripts").Replace("Global", $globaldatabase)
            [System.IO.File]::WriteAllText("$scripts", $FileText)

            try {
                foreach ($script in $scripts) {
			
                    sqlcmd -S $server -U $username -P $password -d $globaldatabase -i $script | Tee-Object -Variable postscriptsoutput
                    writelog $PostScriptsoutput
                    write-host "$script  executed."
                    updatestatus("$script executed."	)
                }
		
            }
            catch {
                writelog "Postscripts execution failed : $error"
                writelog "error: $postscriptsoutput"
            }
           
   
		
		
		
            updatestatus("Post Deployment Scripts Installed."	)
            write-host "Post deployment scrips installed."

            writelog "Deleting old databases..."

            try {
                
                # invoke-sqlcmd -ServerInstance $server -U $username -P $password -Query "Drop database $hrdatabase;" -erroraction silentlycontinue
            }
            catch {
                # writelog "HR databases deletion failed. : $error"
            }


            # write-host "HR database deleted."
            updatestatus("Database Installation Completed.")
            # [System.Windows.MessageBox]::Show(" database completed" , "IAG Installer" , 0, 64)

            # $wpf.InputPageApply.Dispatcher.Invoke([action] {
            #         $wpf.InputPageApply.Content = "Finish"
            #         $wpf.InputPageApply.visibility = "visible"
            #     })

            
            $wpf.database_install_status = "Completed"

        })

    #Launch Runspace script.
    $DatabaseAsyncObject = $PowerShell.BeginInvoke()

    #Dispose runspace when execution is finished - hence freeing resources.
    If ($wpf.DatabaseAsyncObject.isCompleted) {
        [void]$wpf.Powershell.EndInvoke($wpf.DatabaseAsyncObject)
        $wpf.Powershell.runspace.close()
        $wpf.Powershell.runspace.dispose()

        # $wpf.databaseInstallStatus = "Completed"
    }
		
    # $wpf.db_install_status = "completed"
	
}

function install-websites {
    
    $wpf.LogFilePath = $LogFilePath
    
    $wpf.user_Website_path = $wpf.websitepath.text
    $wpf.iamdestinationfiles = $wpf.user_Website_path + "\IAM"
    $wpf.globaldestinationfiles = $wpf.user_Website_path + "\Global"

    $wpf.iamsourcefiles = $iamsourcefiles
    $wpf.globalsourcefiles = $globalsourcefiles
	
    #====INFO=====#
    #GlobalAPIURL = apiportal.orsustest.com
    #IAMAPIURL = apiiam.orsustest.com
    #GLOBALUIURL = portal.orsustest.com
    #IAMUIURL = iam.orsustest.com

    #====INFO=====#
	
    $wpf.globalapiurl_name = $wpf.GlobalAPIURL.text 
    $wpf.IAMAPIURL_name = $wpf.IAMAPIURL.text 
    $wpf.GlobalUIURL_name = $wpf.GlobalUIURL.text 
    $wpf.IAMUIURL_name = $wpf.IAMUIURL.text 

    $wpf.globalapiurl = "http://" + $wpf.GlobalAPIURL.text + "/api/"
    $wpf.IAMAPIURL = "http://" + $wpf.IAMAPIURL.text + "/api/"
    $wpf.GlobalUIURL = "http://" + $wpf.GlobalUIURL.text + "/"
    $wpf.IAMUIURL = "http://" + $wpf.IAMUIURL.text + "/"

    


    $wpf.globalapiurl_apppool = $wpf.globalapiurl_apppool.text
    $wpf.IAMAPIURL_apppool = $wpf.IAMAPIURL_apppool.text
    $wpf.GlobalUIURL_apppool = $wpf.GlobalUIURL_apppool.text
    $wpf.IAMUIURL_apppool = $wpf.IAMUIURL_apppool.text


    $wpf.TrustedIPs = $wpf.websiteIPComboBox.text 
    $wpf.FileUploadDir = $wpf.FileUploadDirpath.text
    $wpf.LogFolder = $wpf.ApplogPath.text
    $wpf.applicationLogLevel = $wpf.apploglevels.text

    $wpf.datasource = $wpf.DBIPComboBox.text
    $wpf.iam_catalog = $wpf.IAMDBName.text
    $wpf.global_catalog = $wpf.GlobalDBName.text

    $wpf.username = $wpf.DBUserName.Text
    $wpf.password = $wpf.DBPassword.Password

    $wpf.fileuploads = $wpf.FileUploadDirPath.text
    $wpf.PFXPassword = $wpf.PFXPwdBox.password

    

   
    $runspace = [runspacefactory]::CreateRunspace()
    $powerShell = [powershell]::Create()
    $powerShell.runspace = $runspace
    $runspace.ThreadOptions = 'ReuseThread'
    $runspace.ApartmentState = 'STA'
    $runspace.Open()
    $runspace.SessionStateProxy.SetVariable("wpf", $wpf)

    [void]$PowerShell.AddScript( {
        
            $LogFilePath = $wpf.LogFilePath
            # $logfile = "$LogFilePath" + (Get-date -Format dd_MM_yyyy) + ".log"
            # Start-Transcript -Path $LogFile -Append
            function updatestatus($message) {
				
                $wpf.installstatus.Dispatcher.Invoke([action] {
                        $wpf.InstallStatus.Text = $message
                    })
            }
            
            Function WriteLog($message) {

                Write-Host (Get-Date).ToString() + $message
                $logfile = "$LogFilePath" + (Get-date -Format dd_MM_yyyy) + ".log"
                Add-Content $logfile ((Get-Date).ToString() + " [websites:] " + $message)
            
            } 

            # [System.Windows.MessageBox]::Show(" website started" , "IAG Installer" , 0, 64)

            $user_Website_path = $wpf.user_Website_path
            $iamdestinationfiles = $wpf.iamdestinationfiles
            $globaldestinationfiles = $wpf.globaldestinationfiles

            $iamsourcefiles = $wpf.iamsourcefiles
            $globalsourcefiles = $wpf.globalsourcefiles
                
            #====INFO=====#
            #GlobalAPIURL = apiportal.orsustest.com
            #IAMAPIURL = apiiam.orsustest.com
            #GLOBALUIURL = portal.orsustest.com
            #IAMUIURL = iam.orsustest.com
            
            #====INFO=====#
                
            $globalapiurl = $wpf.globalapiurl 
            $IAMAPIURL = $wpf.IAMAPIURL 
            $GlobalUIURL = $wpf.GlobalUIURL
            $IAMUIURL = $wpf.IAMUIURL 
                
                
            $globalapiurl_name = $wpf.globalapiurl_name
            $IAMAPIURL_name = $wpf.IAMAPIURL_name 
            $GlobalUIURL_name = $wpf.GlobalUIURL_name 
            $IAMUIURL_name = $wpf.IAMUIURL_name 
                
                
            $globalapiurl_apppool = $wpf.globalapiurl_apppool
            $IAMAPIURL_apppool = $wpf.IAMAPIURL_apppool 
            $GlobalUIURL_apppool = $wpf.GlobalUIURL_apppool 
            $IAMUIURL_apppool = $wpf.IAMUIURL_apppool 
                
                
            $TrustedIPs = $wpf.TrustedIPs 
            $FileUploadDir = $wpf.FileUploadDir
            $LogFolder = $wpf.LogFolder 
            $applicationLogLevel = $wpf.applicationLogLevel
                
            $datasource = $wpf.datasource 
            $iam_catalog = $wpf.iam_catalog 
            $global_catalog = $wpf.global_catalog
                
            $username = $wpf.username
            $password = $wpf.password
                
            $fileuploads = $wpf.fileuploads 

            $certPass = $wpf.PFXPassword
            $CertPath = $wpf.PFXPath 



            #Logging all variables to Log
            writelog "user_Website_path = $user_Website_path " 
            writelog "iamdestinationfiles = $iamdestinationfiles " 
            writelog "globaldestinationfiles= $globaldestinationfiles"  
            writelog "iamsourcefiles = $iamsourcefiles " 
            writelog "globalsourcefiles = $globalsourcefiles " 
            writelog "globalapiurl = $globalapiurl " 
            writelog "IAMAPIURL = $IAMAPIURL " 
            writelog "GlobalUIURL = $GlobalUIURL " 
            writelog "IAMUIURL = $IAMUIURL " 
            writelog "globalapiurl_name = $globalapiurl_name " 
            writelog "IAMAPIURL_name = $IAMAPIURL_name " 
            writelog "GlobalUIURL_name = $GlobalUIURL_name " 
            writelog "IAMUIURL_name = $IAMUIURL_name " 
            writelog "globalapiurl_apppool = $globalapiurl_apppool " 
            writelog "IAMAPIURL_apppool = $IAMAPIURL_apppool " 
            writelog "GlobalUIURL_apppool = $GlobalUIURL_apppool " 
            writelog "IAMUIURL_apppool = $IAMUIURL_apppool " 
            writelog "TrustedIPs = $TrustedIPs " 
            writelog "FileUploadDir = $FileUploadDir " 
            writelog "LogFolder = $LogFolder " 
            writelog "applicationLogLevel = $applicationLogLevel " 
            writelog "datasource = $datasource " 
            writelog "iam_catalog = $iam_catalog " 
            writelog "global_catalog = $global_catalog " 
            writelog "username = $username " 
            # writelog "password = $password " 
            writelog "fileuploads = $fileuploads " 
    
            #Folders are Pre-validated.


            #if (!((test-path -path "$user_website_path\IAM") -or (test-path -path "$user_website_path\Global") -or (test-path -path "$user_website_path\HR"))) {

            #[System.Windows.MessageBox]::Show('copying files.                            ', 'IAG Installer.')

            updatestatus("Copying files... Please wait as it will take few minutes...")
            writelog "Copying files... Please wait as it will take few minutes..." 

            $source = $iamsourcefiles ; $destination = "$user_website_path\IAM"
            writelog "$source $destination"
            Copy-Item $source $destination -Recurse
            write-host $source $destination

            $source = $globalsourcefiles ; $destination = "$user_website_path\Global"
            writelog "$source $destination"
            Copy-Item $source $destination -Recurse
            write-host $source $destination


            updatestatus("changing configurations... appsettings.config in IAM and Global.")
            write-host "changing configurations..."
	
            #Appsettings.config in  IAM and Global
	
            $iamconfigs = Get-ChildItem -Path $iamdestinationfiles -Filter appsettings.config -Recurse -ErrorAction SilentlyContinue -Force  | select-object fullname -expandproperty fullname #-first 1
            $globalconfigs = Get-ChildItem -Path $globaldestinationfiles -Filter appsettings.config -Recurse -ErrorAction SilentlyContinue -Force  | select-object fullname -expandproperty fullname #-first 1
            $log4netconfig = Get-ChildItem -Path $user_Website_path -Filter log4net.config -Recurse -ErrorAction SilentlyContinue -Force  | select-object fullname -expandproperty fullname #-first 1
            $configs = $iamconfigs + $globalconfigs 
	
	
	
            foreach ($config in $configs) {
		
                $configfile = $config
                $config = [xml](get-content $config )
		
                ($config.appsettings.add | Where-Object { $_.key -eq "GlobalAPIURL" }).value = $GlobalAPIURL 
                ($config.appsettings.add | Where-Object { $_.key -eq "IAMAPIURL" }).value = $IAMAPIURL 
                ($config.appsettings.add | Where-Object { $_.key -eq "GlobalUIURL" }).value = $GlobalUIURL 
                ($config.appsettings.add | Where-Object { $_.key -eq "IAMUIURL" }).value = $IAMUIURL 
                ($config.appsettings.add | Where-Object { $_.key -eq "TrustedIPs" }).value = $TrustedIPs 
                ($config.appsettings.add | Where-Object { $_.key -eq "FileUploadDir" }).value = $FileUploadDir 
                ($config.appsettings.add | Where-Object { $_.key -eq "LogFolder" }).value = $LogFolder 

                $config.Save($configfile);
                updatestatus(" $configfile updated.")
                write-host "$configfile updated."
            }
	
           
	
            #changing connections.config
            updatestatus("Changing connections.config in IAM and Global.")
	
            $iamconfigs = Get-ChildItem -Path $iamdestinationfiles -Filter connections.config -Recurse -ErrorAction SilentlyContinue -Force  | select-object fullname -expandproperty fullname #-first 1
            $globalconfigs = Get-ChildItem -Path $globaldestinationfiles -Filter connections.config -Recurse -ErrorAction SilentlyContinue -Force  | select-object fullname -expandproperty fullname #-first 1
            $configs = $iamconfigs + $globalconfigs
	
   
	
            $iamconnString = "Data Source=$datasource;Initial Catalog=$iam_catalog;User Id=$username;Password=$password;MultipleActiveResultSets=True"
            $globalconnString = "Data Source=$datasource;Initial Catalog=$global_catalog;User Id=$username;Password=$password;MultipleActiveResultSets=True"
	
            write-host "$iamconnstring $globalconnstring"
	
            foreach ($config in $configs) {
		
                $configfile = $config
                $config = [xml](get-content $config )
		
                ($config.connectionstrings.add | Where-Object { $_.name -eq "IAMContext" }).connectionString = $iamconnString 
                ($config.connectionstrings.add | Where-Object { $_.name -eq "GlobalContext" }).connectionString = $globalconnString 
                $config.Save($configfile);
                updatestatus(" $configfile updated.")
                write-host "$configfile updated."
            }
	
            #changing log level

            foreach ($config in $log4netconfig) {
		
                $configfile = $config
                $config = [xml](get-content $config )
		
                ($config.configuration.log4net.appender | Where-Object { $_.name -eq "LogFileAppender" } ).filter.levelmin.value = $applicationLogLevel
                $config.Save($configfile);
                updatestatus(" $configfile updated.")
                write-host "$configfile updated."
            }


            #installing websites
            Import-Module WebAdministration

            $globaldestinationfiles = [regex]::escape($globaldestinationfiles)
            $iamdestinationfiles = [regex]::escape($iamdestinationfiles)


            $globaldestinationfiles = $globaldestinationfiles.replace("\ ", " ")
            $iamdestinationfiles = $iamdestinationfiles.replace("\ ", " ")

            write-host $iamdestinationfiles
            write-host $globaldestinationfiles

            
            $IAG_Websites = @"
{
    "websites":
    [
        {
            "name":"$globaluiurl_name",
            "app_pool":"$GlobalUIURL_apppool",
            "directory":"$globaldestinationfiles\\UI",
            "fileuploaddir":""
        },
        {
            "name":"$globalapiurl_name",
            "app_pool":"$globalapiurl_apppool",
            "directory":"$globaldestinationfiles\\API",
            "fileuploaddir":"nofileuploads"
        },
        {
            "name":"$iamuiurl_name",
            "app_pool":"$IAMUIURL_apppool",
            "directory":"$iamdestinationfiles\\UI",
            "fileuploaddir":""
        },
        {
            "name":"$iamapiurl_name",
            "app_pool":"$IAMAPIURL_apppool",
            "directory":"$iamdestinationfiles\\API",
            "fileuploaddir":"nofileuploads"
        }
    ]
}
"@

            write-host $IAG_Websites    
            $inputs = $IAG_Websites | ConvertFrom-Json

            updatestatus("Removing old version of websites...")
            
            write-host "Removing old version of webisites..."
            
            
            
            foreach ($website in $inputs.websites) {
		
                $iisAppName = $website.name
                write-host $iisappname
                $iisAppPoolName = $website.app_pool
                write-host $iisapppoolname

        
                if (get-website | Select-Object $iisappname) {
		
                    Remove-Item IIS:\Sites\$iisappname  -Recurse -ErrorAction SilentlyContinue -force
                    Remove-Item iis:\AppPools\$iisapppoolname  -Recurse -ErrorAction SilentlyContinue -Force
		
                    updatestatus("$iisAppName and $iisapppoolname removed.")
                }
            }
            #pause
            updatestatus("Importing Certificate...")
            write-host "Importing certificate..."

            #$certPath = "C:\Users\pkeelu\Documents\Work Documents\GUIDemo\SSL-SelfSignedCert\orsustest.pfx"  
            #$certPass = "pass123"  
            
            write-host $certPath

            $pfx = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2  
            $pfx.Import($certPath, $certPass, "Exportable,PersistKeySet")   
            $store = New-Object System.Security.Cryptography.X509Certificates.X509Store("MY", "LocalMachine")  
            $store.Open("ReadWrite")  
            $store.Add($pfx)   
            $store.Close()   
            $certThumbprint = $pfx.Thumbprint  
            write-host cert thumbprint: $certThumbprint





            updatestatus("Creating new websites...")
	
            foreach ($website in $inputs.websites) {
		

                $iisAppName = $website.name
        
                $directoryPath = $website.directory
                #$directoryPath = "$websitedirectory"
                write-host $directoryPath
                $iisAppPoolName = $website.app_pool
                $iisAppPoolDotNetVersion = "v4.0"

                $fileuploaddir = $website.fileuploaddir
		
                #navigate to the app pools root
                Set-Location IIS:\AppPools\
		
                #create the app pool
                $appPool = New-Item $iisAppPoolName -force
                $appPool | Set-ItemProperty -Name "managedRuntimeVersion" -Value $iisAppPoolDotNetVersion
		
                #navigate to the sites root
                Set-Location IIS:\Sites\
		
                #create the site
                $iisApp = New-Item $iisAppName -bindings @{protocol = "http"; bindingInformation = ":80:" + $iisAppName } -physicalPath $directoryPath -force
                $iisApp | Set-ItemProperty -Name "applicationPool" -Value $iisAppPoolName -force
        
		
                if ($fileuploaddir -ne "nofileuploads") {
			
                    if (!(test-path $fileuploads)) { New-Item -Path $fileuploads -ItemType Directory }
			
                    New-WebApplication -Name "Fileuploads" -Site $iisappname -PhysicalPath $fileuploads -ApplicationPool $iisAppPoolName -force
		
                }
		

                New-WebBinding -Name $iisAppName -IP "*" -Port 443 -Protocol https -hostheader $iisAppName -sslflags 1

                $binding = Get-WebBinding -Name $iisAppName -Protocol "https"
                $binding.AddSslCertificate($certThumbprint, "my")
            

                
                updatestatus("$iisappname and $iisAppPoolName created.")
                write-host $iisappname and $iisAppPoolName created.
        
            }

            $wpf.webInstallStatus = "Finished"

            updatestatus("Websites installed.")
            write-host "websites installed."


            # Adding entries in hosts


            Add-Content -Path $env:windir\System32\drivers\etc\hosts -Value "

            `n$TrustedIPs`t$globaluiurl_name
$TrustedIPs`t$globalapiurl_name
$TrustedIPs`t$iamuiurl_name
$TrustedIPs`t$iamapiurl_name
            "  -Force
            # Add-Content -Path $env:windir\System32\drivers\etc\hosts -Value "`n$TrustedIPs`t$globalapiurl_name" -Force
            # Add-Content -Path $env:windir\System32\drivers\etc\hosts -Value "`n$TrustedIPs`t$iamuiurl_name" -Force
            # Add-Content -Path $env:windir\System32\drivers\etc\hosts -Value "`n$TrustedIPs`t$iamapiurl_name" -Force




            # $global:websites_install_status = "Completed";
            $wpf.websites_install_status = "Completed"

		
            # $wpf.InputPageApply.Dispatcher.Invoke([action] {
            #         $wpf.InputPageApply.Content = "Finish"
            #         $wpf.InputPageApply.visibility = "visible"
            #     })


            # [System.Windows.MessageBox]::Show(" websites finished" , "IAG Installer" , 0, 64)
            
            # stop-transcript


        })
    $WebsitesAsyncObject = $PowerShell.BeginInvoke()

    If ($wpf.WebsitesAsyncObject.isCompleted) {
        [void]$wpf.Powershell.EndInvoke($wpf.WebsitesAsyncObject)
        $wpf.Powershell.runspace.close()
        $wpf.Powershell.runspace.dispose()

        # $wpf.websiteInstallStatus = "Completed"

    }
}

function install-Services {
    
    
    $wpf.IAMServicesSource = $wpf.IAMservicesPath; 
    $wpf.IAMServicesDestination = join-path $wpf.servicespath.text "\IAM\WinServices"

    $wpf.GlobalServicesSource = $wpf.GlobalservicesPath; 
    $wpf.GlobalServicesDestination = join-path $wpf.servicespath.text "\Global\WinServices"
    
    $wpf.ServicesTrustedIPs = $wpf.ServicesIPComboBox.Text 
    $wpf.ServicesLogFolder = $wpf.ServicesLogPath.text

    $wpf.Servicesdatasource = $wpf.ServicesIPComboBox.text


    $wpf.globalapiurl = "http://" + $wpf.GlobalAPIURL_Services.text + "/api/"
    $wpf.IAMAPIURL = "http://" + $wpf.IAMAPIURL_Services.text + "/api/"
    $wpf.GlobalUIURL = "http://" + $wpf.GlobalUIURL_Services.text + "/"
    $wpf.IAMUIURL = "http://" + $wpf.IAMUIURL_Services.text + "/"

    

    $runspace = [runspacefactory]::CreateRunspace()
    $powerShell = [powershell]::Create()
    $powerShell.runspace = $runspace
    $runspace.ThreadOptions = 'ReuseThread'
    $runspace.ApartmentState = 'STA'
    $runspace.Open()
    $runspace.SessionStateProxy.SetVariable("wpf", $wpf)

    [void]$PowerShell.AddScript( {
        

            $LogFilePath = $wpf.LogFilePath
            # $logfile = "$LogFilePath" + (Get-date -Format dd_MM_yyyy) + ".log"
            # Start-Transcript -Path $LogFile -Append
            function updatestatus($message) {
            
                $wpf.installstatus.Dispatcher.Invoke([action] {
                        $wpf.InstallStatus.Text = $message
                    })
            }
        
            Function WriteLog($message) {

                Write-Host (Get-Date).ToString() + $message
                $logfile = "$LogFilePath" + (Get-date -Format dd_MM_yyyy) + ".log"
                Add-Content $logfile ((Get-Date).ToString() + " " + $message)
        
            } 

            $IAMServicesSource = $wpf.IAMServicesSource
            $IAMServicesDestination = $wpf.IAMServicesDestination

            $GlobalServicesSource = $wpf.GlobalServicesSource
            $GlobalServicesDestination = $wpf.GlobalServicesDestination
            $ServicesLogFolder = $wpf.ServicesLogFolder
            
            $globalapiurl = $wpf.globalapiurl 
            $IAMAPIURL = $wpf.IAMAPIURL 
            $GlobalUIURL = $wpf.GlobalUIURL
            $IAMUIURL = $wpf.IAMUIURL 
            $ServicesTrustedIPs = $wpf.ServicesTrustedIPs

            $ServicesServerIP = $wpf.Servicesdatasource
            $iam_catalog = $wpf.iam_catalog 
            $global_catalog = $wpf.global_catalog
            $username = $wpf.username
            $password = $wpf.password

    
            # Validation is already done for copying. Now copying files...
            updatestatus("Validation is already done for copying. Now copying files...")

            Copy-Item $IAMServicesSource $IAMServicesDestination -Recurse
            Copy-Item $GlobalServicesSource $GlobalServicesDestination -Recurse
         
            # Get services AppConfig configuration files.
            
            $iamconfigs = Get-ChildItem -Path $IAMServicesDestination -Filter appsettings.config -Recurse -ErrorAction SilentlyContinue -Force  | select-object fullname -expandproperty fullname #-first 1
            $globalconfigs = Get-ChildItem -Path $GlobalServicesDestination -Filter appsettings.config -Recurse -ErrorAction SilentlyContinue -Force  | select-object fullname -expandproperty fullname #-first 1
            $configs = $iamconfigs + $globalconfigs 



            foreach ($config in $configs) {
		
                $configfile = $config
                $config = [xml](get-content $config )
		
                ($config.appsettings.add | Where-Object { $_.key -eq "GlobalAPIURL" }).value = $GlobalAPIURL 
                ($config.appsettings.add | Where-Object { $_.key -eq "IAMAPIURL" }).value = $IAMAPIURL 
                ($config.appsettings.add | Where-Object { $_.key -eq "GlobalUIURL" }).value = $GlobalUIURL 
                ($config.appsettings.add | Where-Object { $_.key -eq "IAMUIURL" }).value = $IAMUIURL 
                ($config.appsettings.add | Where-Object { $_.key -eq "TrustedIPs" }).value = $ServicesTrustedIPs 
                # ($config.appsettings.add | Where-Object { $_.key -eq "FileUploadDir" }).value = $FileUploadDir 
                ($config.appsettings.add | Where-Object { $_.key -eq "LogFolder" }).value = $ServicesLogFolder 

                $config.Save($configfile);
                updatestatus(" $configfile updated.")
                write-host "$configfile updated."
            }

            # Get services Connections configuration files.


            $iamconfigs = Get-ChildItem -Path $IAMServicesDestination -Filter connections.config -Recurse -ErrorAction SilentlyContinue -Force  | select-object fullname -expandproperty fullname #-first 1
            $globalconfigs = Get-ChildItem -Path $GlobalServicesDestination -Filter connections.config -Recurse -ErrorAction SilentlyContinue -Force  | select-object fullname -expandproperty fullname #-first 1
            $configs = $iamconfigs + $globalconfigs
	


            $iamconnString = "Data Source=$ServicesServerIP; Initial Catalog=$iam_catalog; User Id=$username; Password=$password; MultipleActiveResultSets=True"
            $globalconnString = "Data Source=$ServicesServerIP; Initial Catalog=$global_catalog; User Id=$username; Password=$password; MultipleActiveResultSets=True"
	

            foreach ($config in $configs) {
		
                $configfile = $config
                $config = [xml](get-content $config )
		
                ($config.connectionstrings.add | Where-Object { $_.name -eq "IAMContext" }).connectionString = $iamconnString 
                ($config.connectionstrings.add | Where-Object { $_.name -eq "GlobalContext" }).connectionString = $globalconnString 
                $config.Save($configfile);
                updatestatus(" $configfile updated.")
                write-host "$configfile updated."
            }


            # Create services.
	
            $IAMServicesDestinationExes = Get-ChildItem -Path $IAMServicesDestination -Filter *.exe -Recurse -ErrorAction SilentlyContinue -Force | select-object fullname -expandproperty fullname
            $GlobalServicesDestinationExes = Get-ChildItem -Path $GlobalServicesDestination -Filter *.exe -Recurse -ErrorAction SilentlyContinue -Force | select-object fullname -expandproperty fullname
	
            $exes = $IAMServicesDestinationExes + $GlobalServicesDestinationExes
    
    
            # foreach ($exe in $exes) {
    
            #     $binaryPath = $exe
            #     $dirpath = split-path $binaryPath
            #     $dir = split-path $dirpath -leaf
            #     $serviceName = "ISSQ ORSUS-IAG $dir"
    	
            #     if (Get-Service $serviceName -ErrorAction SilentlyContinue) {
            #         $serviceToRemove = Get-WmiObject -Class Win32_Service -Filter "name='$dir'"
            #         $serviceToRemove.delete()
            #         "$serviceName service removed."
            #     }
    
            # }
	
            updatestatus("Installing Services...")
    
            foreach ($exe in $exes) {
	
                $binaryPath = $exe
                $dirpath = split-path $binaryPath
                $dir = split-path $dirpath -leaf
                $serviceName = "ISSQ ORSUS-IAG $dir"
		
	
                New-Service -name $dir -binaryPathName $binaryPath -displayName $serviceName -startupType Automatic -description "$dir Service for ORSUS-IAG"
                write-host "$serviceName service created."
                updatestatus("$serviceName service created.")
                # [System.Windows.MessageBox]::Show('focus', 'inside services creation.')
                # pause
		
            }

            $wpf.services_install_status = "Completed";


            # $wpf.InputPageApply.Dispatcher.Invoke([action] {
            #         $wpf.InputPageApply.Content = "Finish"
            #         $wpf.InputPageApply.visibility = "visible"
            #     })



        
            # stop-transcript



        })
    $ServicesAsyncObject = $PowerShell.BeginInvoke()

    If ($wpf.ServicesAsyncObject.isCompleted) {
        [void]$wpf.Powershell.EndInvoke($wpf.ServicesAsyncObject)
        $wpf.Powershell.runspace.close()
        $wpf.Powershell.runspace.dispose()
    }

}


   
function checkInstallStatus {


    $wpf.dbcheckboxstatus = $wpf.dbcheckbox.IsChecked
    $wpf.websitescheckboxstatus = $wpf.websitescheckbox.IsChecked
    $wpf.servicescheckboxstatus = $wpf.servicescheckbox.IsChecked

    # Runspace Creation - configuration.
    $runspace = [runspacefactory]::CreateRunspace()
    $powerShell = [powershell]::Create()
    $powerShell.runspace = $runspace
    $runspace.ThreadOptions = 'ReuseThread'
    $runspace.ApartmentState = 'STA'
    $runspace.Open()
    $runspace.SessionStateProxy.SetVariable("wpf", $wpf)


    # Commands to run inside runspace.
    [void]$PowerShell.AddScript( {


            $dbcheckboxstatus = $wpf.dbcheckboxstatus
            $websitescheckboxstatus = $wpf.websitescheckboxstatus
            $servicescheckboxstatus = $wpf.servicescheckboxstatus


            while ($true) {

                # wait-debugger   
                
                $servicesStatus = $wpf.services_install_status
                $databaseStatus = $wpf.database_install_status
                $websitesStatus = $wpf.websites_install_status

                if ($servicesStatus -eq "Empty" -and $databaseStatus -eq "Empty" -and $websitesStatus -eq "Empty") {
                    continue

                }

                if ( $websitescheckboxstatus -and $servicescheckboxstatus -and $dbcheckboxstatus) {

                    if ($servicesStatus -eq "Completed" -and $websitesStatus -eq "Completed" -and $databaseStatus-eq "Completed") {

                        $wpf.InputPageApply.Dispatcher.Invoke([action] {
                                $wpf.InstallStatus.Text = "Press Finish to exit."
                                $wpf.InputPageApply.Content = "Finish"
                                $wpf.InputPageApply.visibility = "visible"
                            })
                        break
                        
                    } 

                }

                elseif ( $servicescheckboxstatus -and $websitescheckboxstatus ) {

                    if ($servicesStatus -eq "Completed" -and $websitesStatus -eq "Completed") {

                        $wpf.InputPageApply.Dispatcher.Invoke([action] {
                                $wpf.InstallStatus.Text = "Press Finish to exit."
                                $wpf.InputPageApply.Content = "Finish"
                                $wpf.InputPageApply.visibility = "visible"
                            })
                        break

                    } 

                }   

                elseif ( $dbcheckboxstatus -and $websitescheckboxstatus ) {

                    if ($databaseStatus -eq "Completed" -and $websitesStatus -eq "Completed") {

                        $wpf.InputPageApply.Dispatcher.Invoke([action] {
                                $wpf.InstallStatus.Text = "Press Finish to exit."
                                $wpf.InputPageApply.Content = "Finish"
                                $wpf.InputPageApply.visibility = "visible"
                            })
                        break

                    } 

                }   

                elseif ( $servicescheckboxstatus ) {

                    if ($servicesStatus -eq "Completed") {

                        $wpf.InputPageApply.Dispatcher.Invoke([action] {
                                $wpf.InstallStatus.Text = "Press Finish to exit."
                                $wpf.InputPageApply.Content = "Finish"
                                $wpf.InputPageApply.visibility = "visible"
                            })
                        break

                    } 

                }

                elseif ( $websitescheckboxstatus ) {

                    if ($websitesStatus -eq "Completed") {
                        $wpf.InputPageApply.Dispatcher.Invoke([action] {
                                $wpf.InstallStatus.Text = "Press Finish to exit."
                                $wpf.InputPageApply.Content = "Finish"
                                $wpf.InputPageApply.visibility = "visible"
                            })
                        break

                    } 

                }


                # [System.Windows.MessageBox]::Show("databases completed $dbcheckboxstatus", 'database status')

                elseif ( $dbcheckboxstatus ) {


                        if ($databaseStatus -eq "Completed") {

                            $wpf.InputPageApply.Dispatcher.Invoke([action] {
                                    $wpf.InstallStatus.Text = "Press Finish to exit."
                                    $wpf.InputPageApply.Content = "Finish"
                                    $wpf.InputPageApply.visibility = "visible"
                                })
                            break

                        }

                }

               

                start-sleep -s 1
                $wpf.InputPageApply.Dispatcher.Invoke([action] {
                    $wpf.InstallStatus.Text = "Please wait while the operation is running..."
                    # $wpf.InputPageApply.Content = "Finish"
                    # $wpf.InputPageApply.visibility = "visible"
                })
            }

        })

    #Launch Runspace script.
    $StatusAsyncObject = $PowerShell.BeginInvoke()

    #Dispose runspace when execution is finished - hence freeing resources.
    If ($wpf.StatusAsyncObject.isCompleted) {
        [void]$wpf.Powershell.EndInvoke($wpf.StatusAsyncObject)
        $wpf.Powershell.runspace.close()
        $wpf.Powershell.runspace.dispose()

    }
		
}



function checkInstallStatus1 {

    $runspace = [runspacefactory]::CreateRunspace()
    $powerShell = [powershell]::Create()
    $powerShell.runspace = $runspace
    $runspace.ThreadOptions = 'ReuseThread'
    $runspace.ApartmentState = 'STA'
    $runspace.Open()
    $runspace.SessionStateProxy.SetVariable("wpf", $wpf)

    [void]$PowerShell.AddScript( {
        
            function updatestatus($message) {
				
                $wpf.installstatus.Dispatcher.Invoke([action] {
                        $wpf.InstallStatus.Text = $message
                    })
            }
        
            Function WriteLog($message) {

                Write-Host (Get-Date).ToString() + $message
                $logfile = "$LogFilePath" + (Get-date -Format dd_MM_yyyy) + ".log"
                Add-Content $logfile ((Get-Date).ToString() + " [checkInstallStatus:] " + $message)
        
            } 

            [System.Windows.MessageBox]::Show(" checkInstallStatus started" , "IAG Installer" , 0, 64)
            # updatestatus("Creating new websites...")
            while ($true) {
                if (($wpf.websiteInstallStatus) -and ($wpf.databaseInstallStatus) -eq "completed") { 

                    updatestatus("Press Finish to exit.")
                    # $wpf.InstallStatus.Text = "Press Finish to exit."
                    $wpf.InputPageApply.Content = "Finish"
                    $wpf.InputPageApply.visibility = "visible"
                    break
                    
                }
                Start-Sleep -s 2
                [System.Windows.MessageBox]::Show(" checkInstallStatus sleeping" , "IAG Installer" , 0, 64)

            }

        })
    $checkInstallStatusAsyncObject = $PowerShell.BeginInvoke()

    If ($wpf.checkInstallStatusAsyncObject.isCompleted) {
        [void]$wpf.Powershell.EndInvoke($wpf.checkInstallStatusAsyncObject)
        $wpf.Powershell.runspace.close()
        $wpf.Powershell.runspace.dispose()
    }
}

$wpf.InputPageApply.add_Click( {

        #Exit if user clicks Finish button.
        if ($wpf.InputPageApply.Content -eq "Finish") {

            Stop-Install("exit")
        }
        else {
            $wpf.SummaryTab.visibility = "visible"
            $wpf.SummaryGrid.visibility = "visible"
            $wpf.SummaryTab.IsSelected = "True"
    
    
            $wpf.OptionsTab.add_mouseup( {

                    $wpf.InputPageApply.Content = "Summary"

                })
            $wpf.WebsitesTab.add_mouseup( {

                    $wpf.InputPageApply.Content = "Summary"

                })
            $wpf.DatabaseTab.add_mouseup( {

                    $wpf.InputPageApply.Content = "Summary"

                })
            $wpf.SummaryTab.add_mouseup( {

                    if ($wpf.InputPageApply.Content -ne "Finish") {

                        $wpf.InputPageApply.Content = "Apply"
                    } 
            

                })
            $wpf.statustab.add_mouseup( {

                    $wpf.InputPageApply.Content = "Apply"

                })
    
        }
        #start validating given inputs
        if ($wpf.InputPageApply.Content -eq "Apply") {
        
            #validating inputs before applying changes.

            if ($wpf.dbcheckbox.IsChecked) {
                $validation = validate-inputs 1 0 0
                # continue
            }
            elseif ($wpf.WebsitesCheckbox.IsChecked) {
                $validation = validate-inputs 1 1 0
                #$validation = "Pass"
            }
            elseif ($wpf.ServicesCheckbox.IsChecked) {
                $validation = validate-inputs 1 0 1
            }

            if ($validation -eq "Fail") {

                # continue

            }

            # if validation passed, then apply changes.
            else {

                $Apply_confirm_result = [System.Windows.MessageBox]::Show('Do you want to apply your inputs?                            ', 'IAG Installer.' , 4, 64)
                #[System.ComponentModel.CancelEventArgs]$e = $args[1]    
                if ($Apply_confirm_result -eq 'Yes') { 

                    $wpf.SummaryTab.IsSelected = "True"
                    $wpf.optionstab.visibility = "collapsed"
                    $wpf.websitestab.visibility = "collapsed"
                    $wpf.servicestab.visibility = "collapsed"
                    $wpf.databasetab.visibility = "collapsed"
                    $wpf.statustab.visibility = "collapsed"
                    $wpf.InputPageApply.visibility = "hidden"

                    checkInstallStatus

                    # if ($wpf.dbcheckbox.IsChecked -and !$wpf.servicescheckbox.IsChecked -and !$wpf.websitescheckbox.IsChecked) {
                    if ($wpf.dbcheckbox.IsChecked) {
                    
                        $wpf.InputPageApply.visibility = "hidden"

                        install-Database


                    }
                    

                    if ( $wpf.websitescheckbox.IsChecked ) {


                        $wpf.InputPageApply.visibility = "hidden"

                        install-websites
                        
                    

                    }

                    if ( $wpf.servicescheckbox.IsChecked ) {
                        install-Services
                    }



                    # If (($wpf.DatabaseAsyncObject.isCompleted) -and ($wpf.WebsitesAsyncObject.isCompleted)) { 

                    #     $wpf.InstallStatus.Text = "Press Finish to exit."
                    #     $wpf.InputPageApply.Content = "Finish"
                    #     $wpf.InputPageApply.visibility = "visible"

                    # }

                }
                else {
        
                    #$e.Cancel = $true
                }
            }
        }
        if ($wpf.InputPageApply.Content -eq "Summary" -and ($wpf.InputPageApply.Content -ne "Finish" )) {
        
            UpdateSummary
            $wpf.InputPageApply.Content = "Apply"
            $wpf.SummaryTab.visibility = "visible"
            $wpf.SummaryGrid.visibility = "visible"
            $wpf.SummaryTab.IsSelected = "True"
    
        }
    
    
    
    })
	


$wpf.installerwindow.Add_Closing( {
		
        if ($stop_install -eq "True") {
    
            if ($message -eq "exit") {
                #[System.Windows.MessageBox]::Show(" $message" , "IAG Installer" , 0, 64)
                #exit
            }
            else {
                [System.Windows.MessageBox]::Show(" Aborting Installation due to failure." , "IAG Installer" , 0, 64)
            }
        }
        elseif ($stop_install -eq "False") {
        
            $Close_result = [System.Windows.MessageBox]::Show("Are you sure you want to cancel IAG installation?" , "IAG Installer" , 4, 64)

            [System.ComponentModel.CancelEventArgs]$e = $args[1]    
            if ($Close_result -eq 'Yes') { 
            
            }
            else {
    
                $e.Cancel = $true
            }
        }
    
    })

$wpf.InputPageCancel.add_Click( {
	
        $wpf.installerWindow.Close() 
        
    })





	


     
# checkInstallStatus

# $wpf.InstallStatus.Text = "Press Finish to exit."
#     $wpf.InputPageApply.Content = "Finish"
#     $wpf.InputPageApply.visibility = "visible"




$wpf.installerWindow.ShowDialog() | Out-Null




