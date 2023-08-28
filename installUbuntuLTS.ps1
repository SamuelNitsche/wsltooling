Param (
[Parameter(Mandatory=$True)][ValidateNotNull()][string]$wslName,
[Parameter(Mandatory=$True)][ValidateNotNull()][string]$wslInstallationPath,
[Parameter(Mandatory=$True)][ValidateNotNull()][string]$username,
[Parameter(Mandatory=$True)][ValidateNotNull()][string]$installAllSoftware
)

$distro_file_name = "ubuntu-jammy-wsl-amd64-wsl.rootfs.tar.gz"
$wsl_init_script = "https://raw.githubusercontent.com/cherrmann89/ansible/dev/wsl-start.sh?token=GHSAT0AAAAAACF76PVJ6OXKAJJ3BXS3CFA6ZHIZL7A"

# create staging directory if it does not exists
if (-Not (Test-Path -Path .\staging\$wslName)) {
    $dir = mkdir -p .\staging\$wslName
}

if (-Not (Test-Path -Path $wslInstallationPath)) {
    $dir = mkdir -p $wslInstallationPath
}

if (-Not (Test-Path -Path .\staging\$wslName\$distro_file_name)) {
    # TODO: create timestamp based check
    curl.exe -L -o .\staging\$wslName\$distro_file_name https://cloud-images.ubuntu.com/wsl/jammy/current/$distro_file_name
}

wsl --import $wslName $wslInstallationPath .\staging\$wslName\$distro_file_name

# Update the system
wsl -d $wslName -u root bash -ic "apt update; apt upgrade -y"

# create your user and add it to sudoers
wsl -d $wslName -u root bash -ic "./scripts/config/system/createUser.sh $username ubuntu"

# ensure WSL Distro is restarted when first used with user account
wsl -t $wslName

if ($installAllSoftware -ieq $true) {
    wsl -d $wslName -u root bash -ic "./scripts/config/system/sudoNoPasswd.sh $username"
    wsl -d $wslName -u root bash -ic ./scripts/install/installBasePackages.sh
    wsl -d $wslName -u $username bash -ic ./scripts/install/installAllSoftware.sh
    wsl -d $wslName -u root bash -ic "./scripts/config/system/sudoWithPasswd.sh $username"
}
