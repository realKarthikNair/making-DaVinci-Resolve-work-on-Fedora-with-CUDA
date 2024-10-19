# making-DaVinci-Resolve-work-on-Fedora-with-CUDA

This should have been way easier in an ideal world :/

## TESTED ON FEDORA 39

**Please read this whole thing once before running any commands.**

### Who this is for

- Those who want to use DaVinci Resolve on Fedora with CUDA support

### Who this is not for

- Those who aren't using Fedora and/or don't have an Nvidia GPU with CUDA support

### Section 1: Let's start from NVIDIA drivers

Remove any existing Nvidia or CUDA packages from your system

```bash
sudo dnf remove *nvidia* *cuda*
```

Before typing y to confirm the removal, make sure that any other packages that are going to be removed are not important to you.

Incase so, try this instead 

```bash
sudo dnf remove nvidia-driver xorg-x11-drv-nvidia-cuda xorg-x11-drv-nvidia-cuda-libs nvidia-driver-cuda cuda-devel
```


### Section 2: Install the Nvidia drivers and CUDA

1. We'll be using Nvidia Drivers from negativo17's repository. You can add the repository by running the following command:

```bash
sudo dnf config-manager --add-repo=https://negativo17.org/repos/fedora-nvidia.repo
```

2. Install the Nvidia drivers and CUDA

```bash
sudo dnf install nvidia-driver nvidia-driver-cuda cuda-devel 
```

3. Reboot your system

```bash
reboot
```


### Section 3: Install DaVinci Resolve

1. Download the DaVinci Resolve installer from the official website: https://www.blackmagicdesign.com/products/davinciresolve

You'll get a .zip file after giving away all your personal information. (pro tip: fill random stuff)

2. Extract the .zip file to get a .run file

3. cd to the directory where the .run file is located and run the following command:

    a. For Fedora 39

    ```bash
    chmod +xr DaVinci_Resolve_18.6.5_Linux.run
    ./DaVinci_Resolve_18.6.5_Linux.run
    ```

    b. For Fedora 40 (`zlib-ng-compat` has replaced `zlib` in Fedora 40 and Resolve installer demands `zlib`)

   ```bash
   chmod +xr DaVinci_Resolve_18.6.5_Linux.run
   sudo SKIP_PACKAGE_CHECK=1 ./DaVinci_Resolve_18.6.6_Linux.run SKIP_PACKAGE_CHECK=1
   ```

5. Follow the installation instructions and install DaVinci Resolve

### Section 4: fix library issues

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

~**The welcome screen WON't show up, instead you'll see a black window which will crash later. 
When it asks to wait or close, just close it.**~ (fixed in Resolve 19)


2. Run DaVinci Resolve again from application, but use the "Launch using Discrete Graphics Card" option 

![image](https://github.com/realKarthikNair/making-DaVinci-Resolve-work-on-Fedora-with-CUDA/assets/78267371/5537b047-4738-466b-a2a7-b047b7e5e560)


This time it should work. ~But CUDA won't work in most cases.~ 
> \> CUDA issues aren't seen since Resolve 19, atleast on my system. 

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

![image](https://github.com/realKarthikNair/making-DaVinci-Resolve-work-on-Fedora-with-CUDA/assets/78267371/5537b047-4738-466b-a2a7-b047b7e5e560)


If you see GPU error, repeat from step 2 of Section 6. **It really is a hit or miss.**
> \> GPU/CUDA issues aren't seen since Resolve 19, atleast on my system. 

What I personally do is this: 

1. reload nvidia_uvm module
2. run Blackmagic RAW Speed Test (its installed with DaVinci Resolve)
3. If it shows CUDA, without closing it, run DaVinci Resolve using Discrete Graphics Card. Then close RAW Speed Test.
4. else, repeat from 1 (reload nvidia_uvm module)

### Section 7: Fix video files

DaVinci Resolve on Windows can edit video files with proprietary codecs like H.264, H.265, etc. But on Linux, it can't due to licensing issues. (Yes on Linux you can play these files using VLC or after installing the required codecs, but their licensing doesn't allow them to be used in a commercial software like DaVinci Resolve. In case of Windows, Windows license includes these codecs, so it's not a problem.)

So we need to convert every video file to a format that DaVinci Resolve can read.

You can do this using ffmpeg. 

The below example is a script that I use to convert all .MOV files using HEVC (H.265) codec with AAC audio to DNxHD codec with PCM audio so that DaVinci Resolve can use them.

```bash
#!/bin/bash

# Iterate over each MOV file in the directory
for file in *.MOV; do
    # Check if the file is a regular file
    if [ -f "$file" ]; then
        # Extract filename without extension
        filename="${file%.*}"
        # Run ffmpeg command to convert MOV to DNxHD
        ffmpeg -i "$file" -c:v dnxhd -profile:v dnxhr_hq -pix_fmt yuv422p -c:a pcm_s16le "${filename}_dnxhd.mov"
    fi
done
```
You can use ChatGPT to write similar scripts for your use case.
