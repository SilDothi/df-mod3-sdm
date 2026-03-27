# df-mod3-sdm
SDM &amp; Engage (includes Outcome)

## Purpose
This exercise demonstrates how to protect sensitive text data in PowerShell by converting plaintext content into a SecureString-based protected file, storing it in a separate folder, and documenting access control permissions before and after restricting access.

## Why this is useful

In a forensic or incident-response case, investigators may recover sensitive values such as passwords, tokens, case notes, or confidential identifiers. Leaving that information in plain text increases the risk of unauthorized access. By protecting the content and restricting folder permissions, the investigator reduces exposure and better documents access control.

## Task 3 notes on PowerShell commands for Secure Data Management(SDM)

### 1. Create the Evidence Folder
--New-Item -Path ".\3-Evidence" -ItemType Directory -Force
### 2. Create a sensitive text file
--cd C:\Projects\df-mod3-sdm\3-Evidence
--ni PasswordEvidence
--Add-Content PasswordEvidence "This is a file that contains a suspects account password recovered during analysis: P@ssw0rd!"
### 3. Create the encrypted folder
--cd C:\Projects\df-mod3-sdm
--New-Item -Path ".\3-Evidence-Encrypted" -ItemType Directory -Force
### 4. Convert the plaintext content to a SecureString
--$plainText = Get-Content ".\3-Evidence\PasswordEvidence" -Raw
--$secureText = ConvertTo-SecureString $plaintext -AsPlainText -Force
### 5. Save the protected value to a file
--$secureText = ConvertFrom-SecureString | Set-Content ".\3-Evidence-Encrypted\PasswordEvidence-Encrypted.txt"
### 6. Export the ACL of the original folder
--Get-Acl ".\3-Evidence" | Format-List | Out-File ".\3-Evidence-ACL.txt"

### Notes
--This method protects string data, not an entire folder.
--ConvertFrom-SecureSTring stores a protected representation of the SecureString
--Get-Acl documents permissions

## Task 4 notes on Powershell commands for Managing Permissions

### 1. Restrict access to the encrypted folder
--icacls ".\3-Evidence-Encrypted" /inheritance:r
--icacls ".\3-Evidence-Encrypted" /remove "Users" "Authenticated Users" "Everyone"
--icacls ".\3-Evidence-Encrypted" /grant:r "${env:USERNAME}:(OI)(CI)RX" "Administrators:(OI)(CI)RX" "SYSTEM:(OI)(CI)RX"
### 2. Export the ACL of the encrypted folder
--Get-Acl ".\3-Evidence-Encrypted" | Format-List | Out-File ".\3-Evidence-Encrypted-ACL.txt"

## Task 5 Create a Powershell Script

### Explanation of 'fc-hashing.ps1'

The `fc-hashing.ps1` script was created to automate the process of making a forensic-style copy of evidence files, generating SHA-256 hash values for both the original files and copied files, and comparing those hash values to verify that the copied files are identical to the originals.

### Purpose of the script

This script demonstrates an important forensic concept: when evidence files are copied, the copied versions should be exact duplicates of the originals. One way to confirm that is by hashing both sets of files and comparing the results.

The script performs four main tasks:

1. Creates a folder for storing hash reports
2. Generates SHA-256 hashes for the original evidence files
3. Creates a copy of the evidence files
4. Generates SHA-256 hashes for the copied files and compares both sets of results


