param([String]$psyq_path4)

$psyq_path = "E:\Data\mgs\psyq\psyq_4.6\bin"

$ErrorActionPreference = "Stop"

Push-Location $PSScriptRoot

$oldPathEnv = $Env:path 

Function psyq_setup($psyq_path)
{
    # Setup PSYQ ini
    $psyq_path_without_bin = $psyq_path
    if ($psyq_path_without_bin.EndsWith("\bin\", "CurrentCultureIgnoreCase"))
    {
        $psyq_path_without_bin = $psyq_path_without_bin.Substring(0, $psyq_path_without_bin.Length - 5)
    }
    elseif ($psyq_path_without_bin.EndsWith("\bin", "CurrentCultureIgnoreCase"))
    {
        $psyq_path_without_bin = $psyq_path_without_bin.Substring(0, $psyq_path_without_bin.Length - 4)
    }


    $Env:PSX_PATH = $psyq_path
    $Env:LIBRARY_PATH = "$psyq_path_without_bin\lib"
    $Env:C_PLUS_INCLUDE_PATH = "$psyq_path_without_bin\include"
    $Env:C_INCLUDE_PATH = "$psyq_path_without_bin\include"
    $Env:PSYQ_PATH = $psyq_path

    $Env:COMPILER_PATH = $psyq_path
    $Env:ASSEMBLER_PATH = $psyq_path
    $Env:LINKER_PATH = $psyq_path

    $Env:path = $oldPathEnv + ";" + $psyq_path

    Write-Host $Env:PSX_PATH
    Write-Host $Env:LIBRARY_PATH
    Write-Host $Env:C_PLUS_INCLUDE_PATH
    Write-Host $Env:C_INCLUDE_PATH
    Write-Host $Env:PSYQ_PATH

    Write-Host $Env:COMPILER_PATH
    Write-Host $Env:ASSEMBLER_PATH
    Write-Host $Env:LINKER_PATH

    (Get-Content $psyq_path\psyq.ini.template) | 
    Foreach-Object {$_ -replace '\$PSYQ_PATH',$psyq_path_without_bin}  | 
    Out-File $psyq_path\psyq.ini
}

Write-Host "Enable psyq 4.4" -ForegroundColor "DarkMagenta" -BackgroundColor "Black"
psyq_setup($psyq_path)

del main -ea silentlycontinue
del main.exe -ea silentlycontinue
del main.cpe -ea silentlycontinue
ccpsx -g0 -O3 -Xo$80010000 seqplayer.cpp -omain -I $Env:C_INCLUDE_PATH -l $Env:LIBRARY_PATH\libds.lib -l $Env:LIBRARY_PATH\libc.lib -l $Env:LIBRARY_PATH\libsn.lib -l $Env:LIBRARY_PATH\libgs.lib -l $Env:LIBRARY_PATH\libsnd.lib -l $Env:LIBRARY_PATH\libspu.lib -l $Env:LIBRARY_PATH\libcd.lib -l $Env:LIBRARY_PATH\libapi.lib -l $Env:LIBRARY_PATH\libgpu.lib -l $Env:LIBRARY_PATH\libgte.lib -l $Env:LIBRARY_PATH\libetc.lib
cpe2exe main
del iso\main.exe -ea silentlycontinue
del iso.cue -ea silentlycontinue
del iso.bin -ea silentlycontinue
copy main.exe iso\main.exe
psxbuild -c iso.cat
Start-Process "C:\Users\paul\Downloads\pcsxr\pcsxr.exe" -WorkingDirectory "C:\Users\paul\Downloads\pcsxr" -ArgumentList "-nogui", "-cdfile E:\Data\alive\reversing\sound_rev\psx_seq_player\iso.cue"
