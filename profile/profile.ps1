Set-Alias npp "C:\Program Files (x86)\Notepad++\notepad++.exe"
set-alias ppcd "cd \puppet\puppet"
set-alias winbuild "cd \@inf\scripts\ps\winbuild"
#set-alias ppa "C:\Ruby187\bin\puppet.bat apply --verbose"
set-alias vim " C:\Program Files (x86)\Git\share\vim\vim73\vim.exe"
remove-item alias:ls
set-alias ls Get-ChildItemColor
set-alias which get-command | format-list Path;

 # Helper Functions
function ff ([string] $glob) { get-childitem -recurse -include $glob }
function reboot { shutdown /r /t 5 }
function halt { shutdown /h /t 5 }
function rmd ([string] $glob) { remove-item -recurse -force $glob }
function whoami { (get-content env:\userdomain) + "\" + (get-content env:\username); }
function strip-extension ([string] $filename) { [system.io.path]::getfilenamewithoutextension($filename) } 
function ed-profile { npp $profile }
function lint($files) {puppet-lint --with-filename $files}
function amend {git commit --amend -s}
 
 function Resize-Screen
{
  param (
    [int] $width
  )
  $h = get-host
  $win = $h.ui.rawui.windowsize
  $buf = $h.ui.rawui.buffersize
  $win.width = $width # change to preferred width
  $buf.width = $width
  $h.ui.rawui.set_buffersize($buf)
  $h.ui.rawui.set_windowsize($win)
}
########################################################

########################################################
# 'go' command and targets
$GLOBAL:go_locations = @{}
if( $GLOBAL:go_locations -eq $null ) {
	$GLOBAL:go_locations = @{}
}

function go ([string] $location) {
	if( $go_locations.ContainsKey($location) ) {
		set-location $go_locations[$location];
	} else {
		write-output "The following locations are defined:";
		write-output $go_locations;
	}
}
$go_locations.Add("home", (get-item ([environment]::GetFolderPath("MyDocuments"))).Parent.FullName)
$go_locations.Add("desktop", [environment]::GetFolderPath("Desktop"))
$go_locations.Add("dl", (Join-Path ($env:HOME) "Downloads"))
$go_locations.Add("docs", [environment]::GetFolderPath("MyDocuments"))
$go_locations.Add("scripts", (Join-Path ([environment]::GetFolderPath("MyDocuments")) "WindowsPowerShell") )
########################################################


########################################################

########################################################
# Custom 'cd' command to maintain directory history
if( test-path alias:\cd ) { remove-item alias:\cd }
$GLOBAL:PWD = get-location;
$GLOBAL:CDHIST = [System.Collections.Arraylist]::Repeat($PWD, 1);
function cd {
	$cwd = get-location;
	$l = $GLOBAL:CDHIST.count;

	if ($args.length -eq 0) { 
		set-location $HOME;
		$GLOBAL:PWD = get-location;
		$GLOBAL:CDHIST.Remove($GLOBAL:PWD);
		if ($GLOBAL:CDHIST[0] -ne $GLOBAL:PWD) {
			$GLOBAL:CDHIST.Insert(0,$GLOBAL:PWD);
		}
		$GLOBAL:PWD;
	}
	elseif ($args[0] -like "-[0-9]*") {
		$num = $args[0].Replace("-","");
		$GLOBAL:PWD = $GLOBAL:CDHIST[$num];
		set-location $GLOBAL:PWD;
		$GLOBAL:CDHIST.RemoveAt($num);
		$GLOBAL:CDHIST.Insert(0,$GLOBAL:PWD);
		$GLOBAL:PWD;
	}
	elseif ($args[0] -eq "-l") {
		for ($i = $l-1; $i -ge 0 ; $i--) { 
			"{0,6}  {1}" -f $i, $GLOBAL:CDHIST[$i];
		}
	}
	elseif ($args[0] -eq "-") { 
		if ($GLOBAL:CDHIST.count -gt 1) {
			$t = $CDHIST[0];
			$CDHIST[0] = $CDHIST[1];
			$CDHIST[1] = $t;
			set-location $GLOBAL:CDHIST[0];
			$GLOBAL:PWD = get-location;
		}
		$GLOBAL:PWD;
	}
	else { 
		set-location "$args";
		$GLOBAL:PWD = pwd; 
		for ($i = ($l - 1); $i -ge 0; $i--) { 
			if ($GLOBAL:PWD -eq $CDHIST[$i]) {
				$GLOBAL:CDHIST.RemoveAt($i);
			}
		}

		$GLOBAL:CDHIST.Insert(0,$GLOBAL:PWD);
		$GLOBAL:PWD;
	}

	$GLOBAL:PWD = get-location;
}


function Get-ChildItemColor {
    $fore = $Host.UI.RawUI.ForegroundColor
 
    Invoke-Expression ("Get-ChildItem $args") |
    %{
      if ($_.GetType().Name -eq 'DirectoryInfo') {
        $Host.UI.RawUI.ForegroundColor = 'White'
        echo $_
        $Host.UI.RawUI.ForegroundColor = $fore
      } elseif ($_.Name -match '\.(zip|tar|gz|rar)$') {
        $Host.UI.RawUI.ForegroundColor = 'DarkGray'
        echo $_
        $Host.UI.RawUI.ForegroundColor = $fore
      } elseif ($_.Name -match '\.(exe|bat|cmd|py|pl|ps1|psm1|vbs|rb|reg)$') {
        $Host.UI.RawUI.ForegroundColor = 'DarkCyan'
        echo $_
        $Host.UI.RawUI.ForegroundColor = $fore
      } elseif ($_.Name -match '\.(txt|cfg|conf|ini|csv|sql|xml|config)$') {
        $Host.UI.RawUI.ForegroundColor = 'Cyan'
        echo $_
        $Host.UI.RawUI.ForegroundColor = $fore
      } elseif ($_.Name -match '\.(cs|asax|aspx.cs)$') {
        $Host.UI.RawUI.ForegroundColor = 'Yellow'
        echo $_
        $Host.UI.RawUI.ForegroundColor = $fore
       } elseif ($_.Name -match '\.(aspx|spark|master)$') {
        $Host.UI.RawUI.ForegroundColor = 'DarkYellow'
        echo $_
        $Host.UI.RawUI.ForegroundColor = $fore
       } elseif ($_.Name -match '\.(sln|csproj)$') {
        $Host.UI.RawUI.ForegroundColor = 'Magenta'
        echo $_
        $Host.UI.RawUI.ForegroundColor = $fore
	   } elseif ($_.Name -match '\.(docx|doc|xls|xlsx|pdf|mobi|epub|mpp|)$') {
        $Host.UI.RawUI.ForegroundColor = 'Gray'
        echo $_
        $Host.UI.RawUI.ForegroundColor = $fore
       }
        else {
        $Host.UI.RawUI.ForegroundColor = $fore
        echo $_
      }
    }
}

function Reload-Profile {
    @(
        $Profile.AllUsersAllHosts,
        $Profile.AllUsersCurrentHost,
        $Profile.CurrentUserAllHosts,
        $Profile.CurrentUserCurrentHost
    ) | % {
        if(Test-Path $_){
            Write-Verbose "Running $_"
            . $_
        }
    }    
}

# . reload-profile to dot source it


function clip {
[void][Reflection.Assembly]::LoadWithPartialName("PresentationCore");
$text=pwd;[System.Windows.Clipboard]::SetText($text);
}

$Shell = $Host.UI.RawUI
$size = $Shell.WindowSize
#$size.width=150
$size.height=50
$Shell.WindowSize = $size
$size = $Shell.BufferSize
#$size.width=150
$size.height=9999
$Shell.BufferSize = $size
$shell.BackgroundColor = "DarkBlue"
$shell.ForegroundColor = "White"
clear

Set-Alias npp "C:\Program Files (x86)\Notepad++\notepad++.exe"
set-alias ppcd "cd \puppet\puppet"
set-alias ppa "puppet apply"

function title($title) {
$host.ui.RawUI.WindowTitle = $title
}

function gitpo {
git push origin
$seconds=60-[DateTime]::Now.Second
write-host "Time to wait:$seconds"
}



Function Get-NumberedContent { 
    param ([string] $filename=$profile) 
    If (Test-Path $filename) { 
       $counter = 0 
        get-content $filename | foreach { 
            $counter++ 
            #default font color 
            $fcolor="White" 
            #determine if file is a script 
            if ((Get-Item $filename).extension -match "bat|vbs|cmd|wsf|ps1") { 
                #determine if line is a comment. If so we want to write it in Green 
                if ($_.Trim().StartsWith("#") -or ` 
                    $_.Trim().StartsWith("'") -or ` 
                    $_.Trim().StartsWith("::") -or ` 
                    $_.Trim().ToLower().StartsWith("rem")) { 
                   $fcolor="Green" 
                } 
            } 
            #write a 4 digit line number the | bar an.d then the line of text from the file 
            #trimming off any trailing spaces 
            Write-Host ("{0:d4} | {1}" -f $counter,$_.TrimEnd()) -foregroundcolor $fcolor 
             } 
    } 
    else { 
        Write-Warning "Failed to find $filename" 
        } 
} #end function

remove-item alias:type
set-alias type Get-NumberedContent


$titlereq =  Read-Host "Enter title"

title($titlereq)

