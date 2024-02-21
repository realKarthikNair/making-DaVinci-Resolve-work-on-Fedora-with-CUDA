# making-DaVinci-Resolve-work-on-Fedora-with-CUDA

This should have been way easier in an ideal world :/

## TESTED ON FEDORA 39

**Please read this whole thing once before running any commands.**

### Who this is for

- Those who want to use DaVinci Resolve on Fedora with CUDA support

### Who this is not for

- Those who aren't using Fedora and/or don't have an Nvidia GPU with CUDA support

### Step 1: Let's start from NVIDIA drivers

Remove any existing Nvidia or CUDA packages from your system

```bash
sudo dnf remove *nvidia* *cuda*
```

Before typing y to confirm the removal, make sure that any other packages that are going to be removed are not important to you.

Incase so, try this instead 

```bash
sudo dnf remove nvidia-driver xorg-x11-drv-nvidia-cuda xorg-x11-drv-nvidia-cuda-libs
```


### Step 2: Install the Nvidia drivers and CUDA

1. We'll be using Nvidia Drivers from negativo17's repository. You can add the repository by running the following command:

```bash
sudo dnf config-manager --add-repo=https://negativo17.org/repos/fedora-nvidia.repo
```

2. Install the Nvidia drivers

```bash
sudo dnf install nvidia-driver nvidia-driver-cuda cuda-devel 
```

3. Reboot your system

```bash
reboot
```


### Step 3: Install DaVinci Resolve

1. Download the DaVinci Resolve installer from the official website: https://www.blackmagicdesign.com/products/davinciresolve

You'll get a .zip file after giving away all your personal information. (pro tip: fill random stuff)

2. Extract the .zip file to get a .run file

3. cd to the directory where the .run file is located and run the following command:

```bash
chmod +xr DaVinci_Resolve_18.6.5_Linux.run
./DaVinci_Resolve_18.6.5_Linux.run
```

4. Follow the installation instructions and install DaVinci Resolve

### Step 4: fix library issues

```bash
cd /opt/resolve/libs
sudo mkdir disabled-libraries
sudo mv libglib* disabled-libraries
sudo mv libgio* disabled-libraries
sudo mv libgmodule* disabled-libraries
```

### Section 5: Run DaVinci Resolve 

1. Run DaVinci Resolve

```bash
/opt/resolve/bin/resolve
```

**The welcome screen WON't show up, instead you'll see a black window which will crash later. 
When it asks to wait or close, just close it.**


2. Run DaVinci Resolve again

This time it should work. But CUDA won't work in most cases.

How to check if CUDA is working?

- Open any project
- Go to Preferences > Memory and GPU
- Change GPU selection to Nvidia
- If you see CUDA under GPU Processing Mode after clicking on the dropdown, you're good to go, else continue with below steps

### Section 6: Fix CUDA

1. Remove any rocm opencl packages

```bash
sudo dnf remove rocm-opencl rocm*
```

2. reload nvidia_uvm module

```bash
sudo modprobe -r nvidia_uvm
sudo modprobe nvidia_uvm
```

3. Run DaVinci Resolve again

```bash
/opt/resolve/bin/resolve
```

If you see GPU error, repeat from step 2 of Section 6. **It really is a hit or miss.**

What I personally do is this: 

1. reload nvidia_uvm module
2. run Blackmagic RAW Speed Test (its installed with DaVinci Resolve)
3. If it shows CUDA, without closing it, run DaVinci Resolve. Then close RAW Speed Test.
4. else, repeat from 1 (reload nvidia_uvm module)

