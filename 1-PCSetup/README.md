Below are the steps to configuring your environment for working with terraform on a windows 10 machine.  

### Step 1:  Install Windows SubSystem on your Windows 10 Machine
To start with, you will need to be able to leverage bash as part of the Linux Subsystem.  You can enable this on a Windows 10 machine, by following the steps outlined in this guide:

<a href="https://docs.microsoft.com/en-us/windows/wsl/install-win10">https://docs.microsoft.com/en-us/windows/wsl/install-win10</a>

Once you’ve completed this step, you will be able to move forward with VS Code and the other components required.

### Step 2:  Install VS Code and Terraform Plugins
For this guide we recommend VS Code as your editor, VS code works on a variety of operating systems, and is a very light-weight code editor.

You can download VS Code from this link:

<a href="https://code.visualstudio.com/download">https://code.visualstudio.com/download</a>

Once you’ve downloaded and installed VS code, we need to install the [VS Code Extension for Terraform](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-azureterraform).

Then click “Install” and “Reload” when completed.  This will allow you to have intelli-sense and support for the different terraform file types.

### Step 3:  Opening Terminal
You can then perform the remaining steps from the VS Code application.  Go to the “View” menu and select “integrated terminal”.  You will see the terminal appear at the bottom:

By default, the terminal is set to “powershell”, type in “Bash” to switch to Bash Scripting.   You can default your shell following this guidance - <a href="https://code.visualstudio.com/docs/editor/integrated-terminal#_configuration">https://code.visualstudio.com/docs/editor/integrated-terminal#_configuration</a>

### Step 4:            Install Unzip on Subsystem
Run the following command to install “unzip” on your linux subsystem, this will be required to unzip both terraform and packer.
<p style="text-align: center;"><em>sudo apt-get install unzip</em></p>

### Step 5:            Install TerraForm
You will need to execute the following commands to download and install Terraform, we need to start by getting the latest version of terraform.

Go to this link:

<a href="https://www.terraform.io/downloads.html">https://www.terraform.io/downloads.html</a>

And copy the link for the appropriate version of the binaries for TerraForm.

Go back to VS Code, and enter the following command:
`wget {url for terraform}`
Then Run the following commands in sequence:
`unzip {terraform.zip file name}`
`sudo mv terraform /usr/local/bin/terraform`
`rm {terraform.zip file name}`
Confirm the installation by typing the following command:
`terraform --version`

### Step 6:            Install Packer
To start with, we need to get the most recent version of packer.  Go to the following Url, and copy the url of the appropriate version.

<a href="https://www.packer.io/downloads.html">https://www.packer.io/downloads.html</a>

Note:  There is a bug with the most recent version of Packer that causes issues with Azure AD Tokens, so you will need to install a previous version at this time.  We recommend 1.3.2 found here:
<a href="https://releases.hashicorp.com/packer/1.3.2/">https://releases.hashicorp.com/packer/1.3.2/</a>

Please select the appropriate zip file for your linux subsystem.

Go back to VS Code and execute the following commands:
`wget {packer url}`
`unzip {packer.zip file name}`
`sudo mv packer /usr/local/bin/packer`
`rm {packer.zip file name}`

### Step 7:            Install Azure CLI 2.0
Go back to VS Code again, and download / install azure CLI.  To do so, execute the steps and commands found here:

<a href="https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-apt?view=azure-cli-latest">https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-apt?view=azure-cli-latest</a>

### Step 8:            Authenticating against Azure
Once this is done you are in a place where you can run terraform projects, but before you do, you need to authenticate against Azure.  This can be done by running the following commands in the bash terminal (see link below):

<a href="https://docs.microsoft.com/en-us/azure/azure-government/documentation-government-get-started-connect-with-cli">https://docs.microsoft.com/en-us/azure/azure-government/documentation-government-get-started-connect-with-cli</a>

Once that is completed, you will be authenticated against Azure and will be able to update the documentation for the various environments.

**NOTE:  Your authentication token will expire, should you get a message about an expired token, enter the command, to refresh:**
`az account get-access-token`
Token lifetimes can be described here - <a href="https://docs.microsoft.com/en-us/azure/active-directory/develop/active-directory-token-and-claims#access-tokens">https://docs.microsoft.com/en-us/azure/active-directory/develop/active-directory-token-and-claims#access-tokens</a>

### Step 8:            Run Terraform Plan
The first time you try and execute the terraform plan, we must complete the following steps.  Firstly, we need to make sure the tf-deploy.sh file is configured correctly for line returns for Linux.  Open this file in VS Code and in the lower left hand corner, you will see a “CRLF”, click on this and select “LF”, and then click “Ctrl-S” to save the file.

Then from your integrated terminal enter the following command:
`terraform plan`
Now note the “sus1” is the environment name, which can be found in the folder structure of the template, this allows you to separate configuration from your infrastructure code.

Once you execute the plan, you will be provided a list  of everything that will be added, or destroyed by TerraForm, be careful to review this list for more detail before executing to make sure you aren’t affecting a change negatively.

### Step 9:            Run TerraForm Apply
When you are ready to execute the plan, enter the following command:
`terraform apply`
Now this will apply the changes to the subscription, you will be prompted with an “Are you sure?” message, be sure to enter “yes” (case sensitive) to continue.

**NOTE:  Now if you haven’t run packer before to create the image, you will have to do so using the steps in the README.md file in the “packer” folder, prior to running the “apply”.**

### Step 10:          Targeting modules
As you continue to work with a terraform template, you will want to “target” specific modules.  Terraform leverages a graph to map dependencies, but this allows you the option of focusing to pushing updates only for specific modules that you leverage.

First you would run a plan:
`terraform plan`
You will then be provided with output, this is telling you what TerraForm is going to do to the environment before it executes:

Now, if I scroll up, I can review everything Terraform is going to create, and you can see in green a heading for each item.  If you would like to target a specific element, add re-run the plan.
`terraform plan -target azurerm_key_vault.kub-kv`

The power of targeting is that I can review the plan, and identify a subset of resources that I actually want to “target” or execute on.  I can do this by copying the references  which are displayed in green.  Say I want to create only a specific vm, it would be similar to what is shown below:

`+ module.lkma.azurerm_virtual_machine.vm`

This is done leveraging the “-t” parameter and specifying the changes you want to make.  Similar to what is shown below:
./tf-deploy.ash -c azure -e sus1 -a plan -t module.lzoo.azurerm_virtual_machine.vm[0]

If I re-run the plan, with that command, Terraform implements a graph, which maps dependencies, so if I ask it to create a single vm, it will create all lower level resources that VM dependences on, and those will automatically be included.

This type of annotation will allow you to target a subset of resources rather than pushing updates to the entire environment and becomes crucial when you are working with live production environments.

### Step 11:          Generating an image with Packer
So, the next step before you run TerraForm is to ensure that you have a valid image created by Packer to be leveraged for the Virtual Machines you are going to create.  The benefits of Packer are that it really provides the ability to create a custom image for all the VMs you deploy as part of your implementation.  This is done from the VS Code terminal, with the following command:

`packer build -var-file sus1.json ubuntu.json`

Prior to running the command, make sure you are in the appropriate folder of the json files that provide the packer configuration.  I will be talking more about the template I use in the next post.