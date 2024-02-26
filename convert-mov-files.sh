for file in *.MOV; do
    # Check if the file is a regular file
    if [ -f "$file" ]; then
        # Extract filename without extension
        filename="${file%.*}"
        # Run ffmpeg command to convert MOV to DNxHD
        ffmpeg -i "$file" -c:v dnxhd -profile:v dnxhr_hq -pix_fmt yuv422p -c:a pcm_s16le "${filename}_dnxhd.mov"
    fi
done