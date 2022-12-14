# This file was autogenerated by the 'packer hcl2_upgrade' command. We
# recommend double checking that everything is correct before going forward. We
# also recommend treating this file as disposable. The HCL2 blocks in this
# file can be moved to other files. For example, the variable blocks could be
# moved to their own 'variables.pkr.hcl' file, etc. Those files need to be
# suffixed with '.pkr.hcl' to be visible to Packer. To use multiple files at
# once they also need to be in the same folder. 'packer inspect folder/'
# will describe to you what is in that folder.

# Avoid mixing go templating calls ( for example ```{{ upper(`string`) }}``` )
# and HCL2 calls (for example '${ var.string_value_example }' ). They won't be
# executed together and the outcome will be unknown.

# All generated input variables will be of 'string' type as this is how Packer JSON
# views them; you can change their type later on. Read the variables type
# constraints documentation
# https://www.packer.io/docs/templates/hcl_templates/variables#type-constraints for more info.

packer {
  required_plugins {
    bolt = {
      version = ">= 0.0.1"
      source  = "github.com/martezr/bolt"
    }
  }
}

variable "iso_md5" {
  type    = string
  default = ""
}

variable "iso_path" {
  type    = string
  default = ""
}

variable "switch_name" {
  type    = string
  default = "Default Switch"
}

# source blocks are generated from your builders; a source can be referenced in
# build blocks. A build block runs provisioner and post-processors on a
# source. Read the documentation for source blocks here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/source
source "hyperv-iso" "autogenerated_1" {
  communicator      = "winrm"
  disk_size         = 61440
  floppy_files      = ["Autounattend.xml", "update-windows.ps1", "configure-winrm.ps1"]
  generation        = "1"
  headless          = true
  iso_checksum      = "${var.iso_md5}"
  iso_checksum_type = "md5"
  iso_url           = "${var.iso_path}"
  shutdown_command  = "shutdown /s /t 5 /f /d p:4:1 /c \"Packer Shutdown\""
  skip_compaction   = false
  switch_name       = "${var.switch_name}"
  winrm_password    = "vagrant"
  winrm_timeout     = "6h"
  winrm_username    = "vagrant"
}

source "parallels-iso" "autogenerated_2" {
  communicator               = "winrm"
  disk_size                  = 61440
  floppy_files               = ["Autounattend.xml", "update-windows.ps1", "configure-winrm.ps1"]
  guest_os_type              = "win-10"
  iso_checksum               = "${var.iso_md5}"
  iso_checksum_type          = "md5"
  iso_url                    = "${var.iso_path}"
  parallels_tools_flavor     = "win"
  parallels_tools_guest_path = "c:/Windows/Temp/windows.iso"
  parallels_tools_mode       = "upload"
  prlctl                     = [["set", "{{ .Name }}", "--startup-view", "window"], ["set", "{{ .Name }}", "--memsize", "2048"], ["set", "{{ .Name }}", "--cpus", "2"], ["set", "{{ .Name }}", "--smart-mount", "off"], ["set", "{{ .Name }}", "--efi-boot", "off"], ["set", "{{ .Name }}", "--shared-profile", "off"], ["set", "{{ .Name }}", "--shared-cloud", "off"], ["set", "{{ .Name }}", "--sh-app-guest-to-host", "off"], ["set", "{{ .Name }}", "--sh-app-host-to-guest", "off"]]
  shutdown_command           = "shutdown /s /t 5 /f /d p:4:1 /c \"Packer Shutdown\""
  skip_compaction            = false
  winrm_password             = "vagrant"
  winrm_timeout              = "6h"
  winrm_username             = "vagrant"
}

source "virtualbox-iso" "autogenerated_3" {
  communicator         = "winrm"
  disk_size            = 61440
  floppy_files         = ["Autounattend.xml", "update-windows.ps1", "configure-winrm.ps1"]
  guest_additions_mode = "upload"
  guest_additions_path = "c:/Windows/Temp/windows.iso"
  guest_os_type        = "Windows10_64"
  hard_drive_interface = "sata"
  headless             = true
  iso_checksum         = "${var.iso_md5}"
  iso_interface        = "sata"
  iso_url              = "${var.iso_path}"
  shutdown_command     = "shutdown /s /t 0 /f /d p:4:1 /c \"Packer Shutdown\""
  vboxmanage           = [["modifyvm", "{{ .Name }}", "--memory", "2048"], ["modifyvm", "{{ .Name }}", "--cpus", "2"], ["modifyvm", "{{ .Name }}", "--vram", "32"]]
  winrm_insecure       = true
  winrm_password       = "vagrant"
  winrm_timeout        = "6h"
  winrm_username       = "vagrant"
}

source "vmware-iso" "autogenerated_4" {
  communicator        = "winrm"
  disk_size           = 61440
  floppy_files        = ["Autounattend.xml", "update-windows.ps1", "configure-winrm.ps1"]
  guest_os_type       = "windows9-64"
  headless            = true
  iso_checksum        = "${var.iso_md5}"
  iso_checksum_type   = "md5"
  iso_url             = "${var.iso_path}"
  skip_compaction     = false
  tools_upload_flavor = "windows"
  tools_upload_path   = "c:/Windows/Temp/windows.iso"
  vmx_data = {
    "gui.fitguestusingnativedisplayresolution" = "FALSE"
    memsize                                    = "2048"
    numvcpus                                   = "2"
    "scsi0.virtualDev"                         = "lsisas1068"
    "virtualHW.version"                        = "10"
  }
  winrm_password = "vagrant"
  winrm_timeout  = "6h"
  winrm_username = "vagrant"
}

# a build block invokes sources and runs provisioning steps on them. The
# documentation for build blocks can be found here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/build
build {
  sources = ["source.hyperv-iso.autogenerated_1", "source.parallels-iso.autogenerated_2", "source.virtualbox-iso.autogenerated_3", "source.vmware-iso.autogenerated_4"]

  provisioner "powershell" {
    scripts = ["install-guest-tools.ps1", "enable-rdp.ps1", "disable-hibernate.ps1", "disable-autologin.ps1", "enable-uac.ps1", "no-expiration.ps1"]
  }

  provisioner "windows-restart" {
    restart_check_command = "powershell -command \"& {if ((get-content C:\\ProgramData\\lastboot.txt) -eq (Get-WmiObject win32_operatingsystem).LastBootUpTime) {Write-Output 'Sleeping for 600 seconds to wait for reboot'; start-sleep 600} else {Write-Output 'Reboot complete'}}\""
    restart_command       = "powershell \"& {(Get-WmiObject win32_operatingsystem).LastBootUpTime > C:\\ProgramData\\lastboot.txt; Restart-Computer -force}\""
  }

  provisioner "bolt" {
      bolt_plan = "profiles::swpkg_install"
      backend   = "winrm"
      password  = "vagrant"
      user      = "vagrant"
  }

  post-processor "vagrant" {
    keep_input_artifact  = false
    output               = "{{ .Provider }}_windows-10.box"
    vagrantfile_template = "vagrantfile.template"
  }
}
