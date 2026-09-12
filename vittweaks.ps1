Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

[System.Windows.Forms.Application]::EnableVisualStyles()

$bg = [Drawing.Color]::FromArgb(10,10,18)
$panel = [Drawing.Color]::FromArgb(20,15,35)
$purple = [Drawing.Color]::FromArgb(155,60,255)
$white = [Drawing.Color]::White

$form = New-Object System.Windows.Forms.Form
$form.Text = "VITTweaks"
$form.Size = New-Object System.Drawing.Size(1150,700)
$form.StartPosition = "CenterScreen"
$form.BackColor = $bg
$form.ForeColor = $white

# Sidebar
$sidebar = New-Object System.Windows.Forms.Panel
$sidebar.Dock = "Left"
$sidebar.Width = 220
$sidebar.BackColor = $panel
$form.Controls.Add($sidebar)

$logo = New-Object System.Windows.Forms.Label
$logo.Text = "VITTweaks"
$logo.Font = New-Object System.Drawing.Font("Segoe UI",20,[System.Drawing.FontStyle]::Bold)
$logo.ForeColor = $purple
$logo.Location = New-Object System.Drawing.Point(20,20)
$logo.AutoSize = $true
$sidebar.Controls.Add($logo)

# Main area
$main = New-Object System.Windows.Forms.Panel
$main.Dock = "Fill"
$main.BackColor = $bg
$form.Controls.Add($main)

# Pages
$pages = @{}

function New-Page($name){
    $p = New-Object System.Windows.Forms.Panel
    $p.Dock = "Fill"
    $p.BackColor = $bg
    $p.Visible = $false
    $main.Controls.Add($p)
    $pages[$name] = $p
}

"Dashboard","Windows","Network","Cleanup","Restore" | ForEach-Object { New-Page $_ }

function Show-Page($name){
    foreach($p in $pages.Values){ $p.Visible = $false }
    $pages[$name].Visible = $true
}

# Dashboard
$title = New-Object System.Windows.Forms.Label
$title.Text = "SYSTEM DASHBOARD"
$title.Font = New-Object System.Drawing.Font("Segoe UI",24,[System.Drawing.FontStyle]::Bold)
$title.ForeColor = $purple
$title.Location = New-Object System.Drawing.Point(40,30)
$title.AutoSize = $true
$pages["Dashboard"].Controls.Add($title)

$cpu = New-Object System.Windows.Forms.Label
$cpu.Font = New-Object System.Drawing.Font("Segoe UI",16)
$cpu.Location = New-Object System.Drawing.Point(40,100)
$cpu.AutoSize = $true
$pages["Dashboard"].Controls.Add($cpu)

$ram = New-Object System.Windows.Forms.Label
$ram.Font = New-Object System.Drawing.Font("Segoe UI",16)
$ram.Location = New-Object System.Drawing.Point(40,140)
$ram.AutoSize = $true
$pages["Dashboard"].Controls.Add($ram)

$boost = New-Object System.Windows.Forms.Button
$boost.Text = "⚡ Enable Performance Mode"
$boost.Size = New-Object System.Drawing.Size(320,60)
$boost.Location = New-Object System.Drawing.Point(40,220)
$boost.BackColor = $purple
$boost.ForeColor = $white
$boost.FlatStyle = "Flat"
$boost.Add_Click({
    powercfg /setactive SCHEME_MIN
    [System.Windows.Forms.MessageBox]::Show("Performance Mode Enabled","VITTweaks")
})
$pages["Dashboard"].Controls.Add($boost)

# Windows page
$w = New-Object System.Windows.Forms.Label
$w.Text = "Windows Tweaks (Coming Soon)"
$w.Font = New-Object System.Drawing.Font("Segoe UI",20,[System.Drawing.FontStyle]::Bold)
$w.ForeColor = $purple
$w.Location = New-Object System.Drawing.Point(40,40)
$w.AutoSize = $true
$pages["Windows"].Controls.Add($w)

# Network page
$n = New-Object System.Windows.Forms.Button
$n.Text = "Flush DNS"
$n.Size = New-Object System.Drawing.Size(200,45)
$n.Location = New-Object System.Drawing.Point(40,80)
$n.BackColor = $purple
$n.ForeColor = $white
$n.FlatStyle = "Flat"
$n.Add_Click({
    ipconfig /flushdns | Out-Null
    [System.Windows.Forms.MessageBox]::Show("DNS Flushed","VITTweaks")
})
$pages["Network"].Controls.Add($n)

# Cleanup page
$c = New-Object System.Windows.Forms.Button
$c.Text = "Open Temp Folder"
$c.Size = New-Object System.Drawing.Size(220,45)
$c.Location = New-Object System.Drawing.Point(40,80)
$c.BackColor = $purple
$c.ForeColor = $white
$c.FlatStyle = "Flat"
$c.Add_Click({
    Start-Process $env:TEMP
})
$pages["Cleanup"].Controls.Add($c)

# Restore page
$r = New-Object System.Windows.Forms.Button
$r.Text = "Create Restore Point"
$r.Size = New-Object System.Drawing.Size(240,45)
$r.Location = New-Object System.Drawing.Point(40,80)
$r.BackColor = $purple
$r.ForeColor = $white
$r.FlatStyle = "Flat"
$r.Add_Click({
    Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue
    Checkpoint-Computer -Description "VITTweaks Restore" -RestorePointType "MODIFY_SETTINGS"
    [System.Windows.Forms.MessageBox]::Show("Restore Point Created","VITTweaks")
})
$pages["Restore"].Controls.Add($r)

# Sidebar buttons
$items = @("Dashboard","Windows","Network","Cleanup","Restore")
$y = 90

foreach($item in $items){
    $b = New-Object System.Windows.Forms.Button
    $b.Text = $item
    $b.Size = New-Object System.Drawing.Size(180,40)
    $b.Location = New-Object System.Drawing.Point(20,$y)
    $b.BackColor = $bg
    $b.ForeColor = $white
    $b.FlatStyle = "Flat"
    $b.FlatAppearance.BorderColor = $purple
    $page = $item
    $b.Add_Click({ Show-Page $page })
    $sidebar.Controls.Add($b)
    $y += 50
}

# Live stats
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 1000
$timer.Add_Tick({
    $cpu.Text = "CPU: " + ((Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue.ToString("0")) + "%"
    $os = Get-CimInstance Win32_OperatingSystem
    $used = [math]::Round(($os.TotalVisibleMemorySize-$os.FreePhysicalMemory)/1024)
    $total = [math]::Round($os.TotalVisibleMemorySize/1024)
    $ram.Text = "RAM: $used MB / $total MB"
})
$timer.Start()

Show-Page "Dashboard"

[System.Windows.Forms.Application]::Run($form)
