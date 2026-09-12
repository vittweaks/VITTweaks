Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

[System.Windows.Forms.Application]::EnableVisualStyles()

# Theme
$bg = [Drawing.Color]::FromArgb(12,12,18)
$panel = [Drawing.Color]::FromArgb(22,15,35)
$purple = [Drawing.Color]::FromArgb(140,50,255)
$text = [Drawing.Color]::White

$form = New-Object Windows.Forms.Form
$form.Text = "VITTweaks"
$form.Size = New-Object Drawing.Size(1150,700)
$form.StartPosition = "CenterScreen"
$form.BackColor = $bg
$form.ForeColor = $text
$form.FormBorderStyle = "FixedSingle"
$form.MaximizeBox = $false

# Sidebar
$sidebar = New-Object Windows.Forms.Panel
$sidebar.BackColor = $panel
$sidebar.Dock = "Left"
$sidebar.Width = 220
$form.Controls.Add($sidebar)

# Logo
$logo = New-Object Windows.Forms.Label
$logo.Text = "VITTweaks"
$logo.Font = New-Object Drawing.Font("Segoe UI",22,[Drawing.FontStyle]::Bold)
$logo.ForeColor = $purple
$logo.Location = New-Object Drawing.Point(20,20)
$logo.AutoSize = $true
$sidebar.Controls.Add($logo)

# Buttons
$buttons = @("Dashboard","Windows","Registry","Network","CPU","GPU","RAM","Cleanup","Restore")

$y = 90
foreach($b in $buttons){

    $btn = New-Object Windows.Forms.Button
    $btn.Text = $b
    $btn.Size = New-Object Drawing.Size(180,42)
    $btn.Location = New-Object Drawing.Point(20,$y)

    $btn.FlatStyle = "Flat"
    $btn.FlatAppearance.BorderSize = 1
    $btn.FlatAppearance.BorderColor = $purple
    $btn.BackColor = $bg
    $btn.ForeColor = $text

    $btn.Add_MouseEnter({
        $this.BackColor = $purple
    })

    $btn.Add_MouseLeave({
        $this.BackColor = $bg
    })

    $sidebar.Controls.Add($btn)
    $y += 50
}

# Main Panel
$main = New-Object Windows.Forms.Panel
$main.Dock = "Fill"
$main.BackColor = $bg
$form.Controls.Add($main)

# Title
$title = New-Object Windows.Forms.Label
$title.Text = "SYSTEM DASHBOARD"
$title.Font = New-Object Drawing.Font("Segoe UI",24,[Drawing.FontStyle]::Bold)
$title.ForeColor = $purple
$title.Location = New-Object Drawing.Point(40,30)
$title.AutoSize = $true
$main.Controls.Add($title)

# Stats Labels
$cpu = New-Object Windows.Forms.Label
$cpu.Font = New-Object Drawing.Font("Segoe UI",16)
$cpu.Location = New-Object Drawing.Point(40,110)
$cpu.AutoSize = $true
$main.Controls.Add($cpu)

$ram = New-Object Windows.Forms.Label
$ram.Font = New-Object Drawing.Font("Segoe UI",16)
$ram.Location = New-Object Drawing.Point(40,150)
$ram.AutoSize = $true
$main.Controls.Add($ram)

$os = New-Object Windows.Forms.Label
$os.Font = New-Object Drawing.Font("Segoe UI",16)
$os.Location = New-Object Drawing.Point(40,190)
$os.AutoSize = $true
$main.Controls.Add($os)

# Big Action Button
$boost = New-Object Windows.Forms.Button
$boost.Text = "⚡ PERFORMANCE MODE"
$boost.Font = New-Object Drawing.Font("Segoe UI",15,[Drawing.FontStyle]::Bold)
$boost.Size = New-Object Drawing.Size(320,70)
$boost.Location = New-Object Drawing.Point(40,270)
$boost.FlatStyle = "Flat"
$boost.FlatAppearance.BorderSize = 0
$boost.BackColor = $purple
$boost.ForeColor = $text

$boost.Add_Click({
    powercfg /setactive SCHEME_MIN
    [Windows.Forms.MessageBox]::Show("Performance Mode Applied","VITTweaks")
})

$main.Controls.Add($boost)

# Live Stats
$timer = New-Object Windows.Forms.Timer
$timer.Interval = 1000

$timer.Add_Tick({

    $cpuLoad = (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue

    $osInfo = Get-CimInstance Win32_OperatingSystem

    $used = [math]::Round(($osInfo.TotalVisibleMemorySize-$osInfo.FreePhysicalMemory)/1024)
    $total = [math]::Round($osInfo.TotalVisibleMemorySize/1024)

    $cpu.Text = "CPU Usage: " + $cpuLoad.ToString("0") + "%"
    $ram.Text = "RAM: $used MB / $total MB"
    $os.Text = "Windows: " + $osInfo.Caption

})

$timer.Start()

[System.Windows.Forms.Application]::Run($form)
