#This file performs multiple actions.  Which will have comments above to explain in detail what is being performed.

#This Powershell command will obtain the Hashes from all files within a folder, then output those into the evidence-hashes folder
#as a CSV that is named Evidence-Original-Hashes
New-Item -ItemType Directory -Force -Path C:\Projects\df-mod3-sdm\3-Evidence\Evidence-Hashes
Get-ChildItem ".\df-mod3-sdm\3-Evidence" -File| 
Get-FileHash -Algorithm SHA256 | 
Select-Object Algorithm, Hash, Path | 
Export-Csv ".\df-mod3-sdm\3-Evidence\Evidence-Hashes\Evidence-Original-Hashes.csv" -NoTypeInformation

#Next using Powershell we will make a new folder named evidence-COPY and copy the files into this new folder
New-Item -ItemType Directory -Force -Path C:\Projects\df-mod3-sdm\3-Evidence-COPY
Copy-Item ".\df-mod3-sdm\3-Evidence\*" -Destination ".\df-mod3-sdm\3-Evidence-COPY" -Recurse -Force

#This Powershell command will obtain the hashes from all the files within our newly made folder, then output those into the evidence-hashes folder
#as a CSV that is named Evidence-Copy-Hashes
Get-ChildItem ".\3-Evidence-COPY" | 
Get-FileHash -Algorithm SHA256 | 
Select-Object Algorithm, Hash, Path | 
Export-Csv "C:\Projects\df-mod3-sdm\3-Evidence-COPY\Evidence-Hashes\Evidence-COPY-Hashes.csv" -NoTypeInformation

#This last powershell command will compare the hashes stored in the 2 differnt files but the same pathways to see if they are identical for contents only.
#It chooses to only compare the content based upon hash and filename because we kept the filenames the same in the copy folder, but the pathway to the hashed
#files differs.  It then presents in the terminal a PASS or FIL result if they are identical or not.
$original = Import-Csv "C:\Projects\df-mod3-sdm\3-Evidence-COPY\Evidence-Hashes\Evidence-Original-Hashes.csv" |
    Select-Object @{Name='Name';Expression={[System.IO.Path]::GetFileName($_.Path)}}, Hash |
    Sort-Object Name

$copy = Import-Csv "C:\Projects\df-mod3-sdm\3-Evidence-COPY\Evidence-Hashes\Evidence-COPY-Hashes.csv" |
    Select-Object @{Name='Name';Expression={[System.IO.Path]::GetFileName($_.Path)}}, Hash |
    Sort-Object Name

$differences = Compare-Object $original $copy -Property Name, Hash

if ($differences.Count -eq 0) {
    Write-Host "PASS: Hashes match. The copied files are identical to the originals."
}
else {
    Write-Host "FAIL: Hashes do NOT match. Differences were found."
    $differences | Format-Table -AutoSize
}

