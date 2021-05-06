if ($(try { choco -v } catch { $null }) -eq $null) {
    echo "Installing choco"
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
} else {
    echo "Found choco"
}
 
# Find R
$has_r = `
    $($env:R_HOME -ne $null) -or ` 
    $(-not $(choco list -lo -e R)[1].StartsWith("0")) -or ` 
    $((ls 'C:\Program Files\R\' -ErrorAction SilentlyContinue  | Measure).Count -ne 0)


if (-not $has_r) {
    echo "Installing R using `choco` "
    choco install R -y
} else {
    echo "Found R"
}

if ($env:R_HOME -eq $null) {
    echo "Tryin to set up R_HOME variable"
    $r_ver = ls 'C:\Program Files\R\' -ErrorAction SilentlyContinue | select -Expand Name | % {$_.Split("-")[1]} | sort -Descending | select -first 1

    if ($r_ver -eq $null) {
        echo "Failed to set up R_HOME! Do it manually"
    } else {
        $r_home = "C:\Program Files\R\R-$r_ver"
        Invoke-Expression "setx R_HOME `"$r_home`""
        $env:R_HOME = $r_home

        echo "Set up R_HOME to $r_home"
    }
} else {
    echo "Found R_HOME with value $env:R_HOME"
}

$has_rtools = ` 
    $($env:RTOOLS40_HOME -ne $null) -or ` 
    $(-not $(choco list -lo -e rtools)[1].StartsWith("0")) -or ` 
    $((ls 'C:\rtools40' -ErrorAction SilentlyContinue  | Measure).Count -ne 0)


if (-not $has_rtools) {
    echo "Installing Rtools using `choco` "
    choco install rtools -y
} else {
    echo "Found RTools"
}

if ($env:RTOOLS40_HOME -eq $null) {
    echo "Tryin to set up RTOOLS40_HOME variable"
    
    $rtools_home = "C:\rtools40"
    Invoke-Expression "setx RTOOLS40_HOME `"$rtools_home`""
    $env:RTOOLS40_HOME = $rtools_home

    echo "Set up RTOOLS40_HOME to $rtools_home"
} else {
    echo "Found RTOOLS40_HOME with value $env:RTOOLS40_HOME"
}

choco install visualstudio2019buildtools -y
choco install visualstudio2019-workload-vctools -y -f --package-parameters "--no-includeRecommended --add Microsoft.VisualStudio.Component.VC.CoreBuildTools --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 --add Microsoft.VisualStudio.Component.Windows10SDK.18362"

$has_rust = try {rustup --version} catch { $null }

if ($has_rust -eq $null) {
    if ((ls "~\Downloads\rustup-init.exe" -ErrorAction SilentlyContinue | Measure).Count -ne 0) {
        echo "Found a 'rustup-init.exe' in the '~\Downloads', running it"
    } else {
        echo "Downloading rustup-init"
        Invoke-WebRequest https://win.rustup.rs/x86_64 -OutFile "~\Downloads\rustup-init.exe"
    }
    echo "Setting up rust toolchain and targets"
    ~\Downloads\rustup-init.exe -y --no-update-default-toolchain --default-toolchain stable-x86_64-pc-windows-msvc --target x86_64-pc-windows-gnu i686-pc-windows-gnu

    # Adding cargo to path in the current session
    $env:PATH += ";$env:USERPROFILE\.cargo\bin"
} else {
    echo "Found rustup"
    echo "Setting up/updating rust toolchain and targets"
    rustup toolchain install stable-x86_64-pc-windows-msvc
    rustup target add x86_64-pc-windows-gnu --toolchain stable-x86_64-pc-windows-msvc
    rustup target add i686-pc-windows-gnu --toolchain stable-x86_64-pc-windows-msvc
}


function add_path {
    param (
        $path
    )
    $split_path = $env:PATH.Split(";")
    if (($split_path | ? {$_ -like $path} | measure).Count -eq 0) {
        echo "Adding $path to PATH for this session only"
        $env:PATH += ";$path"
    }
}

add_path("$env:R_HOME\bin")
add_path("$env:R_HOME\bin\x64")
add_path("$env:R_HOME\bin\i386")


add_path("$env:RTOOLS40_HOME\usr\bin")
add_path("$env:RTOOLS40_HOME\mingw64\bin")
add_path("$env:RTOOLS40_HOME\mingw32\bin")

echo "You are all set up!"