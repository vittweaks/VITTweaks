Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore

[xml]$xaml=@"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Title="VITTweaks"
        Height="650"
        Width="1050"
        WindowStartupLocation="CenterScreen"
        Background="#09090F"
        Foreground="White">

    <Grid>

        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="220"/>
            <ColumnDefinition Width="*"/>
        </Grid.ColumnDefinitions>

        <Border Background="#120020">
            <StackPanel Margin="15">

                <TextBlock Text="VITTweaks"
                           FontSize="28"
                           FontWeight="Bold"
                           Foreground="#B347FF"
                           Margin="0,10"/>

                <Button Name="DashboardBtn" Margin="0,8" Height="42">Dashboard</Button>
                <Button Name="WindowsBtn" Margin="0,8" Height="42">Windows Tweaks</Button>
                <Button Name="RegistryBtn" Margin="0,8" Height="42">Registry</Button>
                <Button Name="NetworkBtn" Margin="0,8" Height="42">Network</Button>
                <Button Name="CleanupBtn" Margin="0,8" Height="42">Cleanup</Button>
                <Button Name="RestoreBtn" Margin="0,8" Height="42">Restore Point</Button>

            </StackPanel>
        </Border>

        <Grid Grid.Column="1">

            <StackPanel Margin="30">

                <TextBlock Text="SYSTEM DASHBOARD"
                           FontSize="30"
                           Foreground="#C66BFF"
                           FontWeight="Bold"/>

                <TextBlock Name="CPU" FontSize="20" Margin="0,25"/>
                <TextBlock Name="RAM" FontSize="20"/>
                <TextBlock Name="OS" FontSize="20"/>

                <Button Name="BoostBtn"
                        Content="APPLY PERFORMANCE MODE"
                        Height="55"
                        Margin="0,40"
                        Background="#8A2BE2"
                        Foreground="White"/>

            </StackPanel>

        </Grid>

    </Grid>

</Window>
"@

$reader = New-Object System.Xml.XmlNodeReader $xaml
$window = [Windows.Markup.XamlReader]::Load($reader)

$cpu = $window.FindName("CPU")
$ram = $window.FindName("RAM")
$os = $window.FindName("OS")
$boost = $window.FindName("BoostBtn")

$timer = New-Object Windows.Threading.DispatcherTimer
$timer.Interval = "0:0:1"

$timer.Add_Tick({

    $cpu.Text = "CPU Usage: " + (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue.ToString("0") + "%"

    $osInfo = Get-CimInstance Win32_OperatingSystem

    $used = [math]::Round(($osInfo.TotalVisibleMemorySize - $osInfo.FreePhysicalMemory)/1024)
    $total = [math]::Round($osInfo.TotalVisibleMemorySize/1024)

    $ram.Text = "RAM: $used MB / $total MB"
    $os.Text = "Windows: " + $osInfo.Caption

})

$timer.Start()

$boost.Add_Click({

    powercfg /setactive SCHEME_MIN

    [System.Windows.MessageBox]::Show("Performance Mode Applied.","VITTweaks")

})

$window.ShowDialog()
