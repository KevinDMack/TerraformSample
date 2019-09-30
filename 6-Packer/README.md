# Azure PAcker Image Building

#####*PLEASE DO NOT PUT ANYTHING IN HERE THAT DOES NOT BELONG ON EVERY VM!*

This image takes the latest image and:

* Applies all latest patches.

Building Centos
========================

 ```packer build -var-file <DEPCODE>.json centos.json```
 
Building Ubuntu
========================

 ```packer build -var-file <DEPCODE>.json ubuntu.json```
 
 Building Windows
========================

 ```packer build -var-file <DEPCODE>.json windows.json```
 

## Notes:

1. Requires creating and passing in a deployment-specific config file, as images can’t be shared between accounts.

## Appendix:

Provisioning Packer Application Registration

1. Confirm Terraform has created a Packer Resource Group.
2. Build out a new <DEPCODE>.json