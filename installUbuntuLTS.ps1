Param (
[Parameter(Mandatory=$True)][ValidateNotNull()][string]$wslName,
[Parameter(Mandatory=$True)][ValidateNotNull()][string]$wslInstallationPath,
[Parameter(Mandatory=$True)][ValidateNotNull()][string]$username,
[Parameter(Mandatory=$True)][ValidateNotNull()][string]$githubUsername
)

$install_path = $env:userprofile + "/git/wsltooling"
$distro_path = "./staging/" + $wslName
$distro_file_name = "ubuntu-jammy-wsl-amd64-wsl.rootfs.tar.gz"
$wsl_init_script = "./scripts/install/prepare_distro.sh"

Set-Location $install_path

# create staging directory if it does not exists
if (-Not (Test-Path -Path $distro_path)) {
    $dir = mkdir -p $distro_path
}

if (-Not (Test-Path -Path $wslInstallationPath)) {
    $dir = mkdir -p $wslInstallationPath
}

if (-Not (Test-Path -Path ("{0}\{1}" -f $distro_path, $distro_file_name))) {
    # TODO: create timestamp based check
    curl.exe -L -o ("{0}\{1}" -f $distro_path, $distro_file_name) https://cloud-images.ubuntu.com/wsl/jammy/current/$distro_file_name
}

wsl --import $wslName $wslInstallationPath ("{0}\{1}" -f $distro_path, $distro_file_name)

# Update the system
wsl -d $wslName -u root bash -ic "apt update; apt upgrade -y"

# create your user and add it to sudoers
wsl -d $wslName -u root bash -ic ("./scripts/config/system/createUser.sh {0} ubuntu" -f $username)

# ensure WSL Distro is restarted when first used with user account
wsl -t $wslName

wsl -d $wslName -u $username bash -ic $wsl_init_script $githubUsername
