#!/bin/bash

while true; do
    # Prompt for the ROM directory
    echo "Please enter the system ROM directory you want to check (e.g., nes, snes):"
    read -r system

    # Define the ROM directory path using the current user
    rom_directory="/home/$USER/RetroPie/roms/$system"

    # Check if the directory exists
    if [ ! -d "$rom_directory" ]; then
        echo "Error: ROM directory '$rom_directory' does not exist or cannot be accessed."
        echo "Please input a new directory."
        continue  # Restart the loop to ask for the directory again
    fi

    # Count of removed ROMs
    removed_count=0
    roms_to_remove=()  # Array to hold ROMs to be removed

    # Loop through each ROM file in the specified directory
    cd "$rom_directory" || exit
    for rom in *; do
        # Get the base name of the ROM (without extension)
        rom_name="${rom%.*}"

        # Check for PNG and JPG metadata files
        png_metadata_file="/opt/retropie/configs/all/emulationstation/downloaded_images/$system/$rom_name.png"
        jpg_metadata_file="/opt/retropie/configs/all/emulationstation/downloaded_images/$system/$rom_name.jpg"

        if [[ ! -f "$png_metadata_file" && ! -f "$jpg_metadata_file" ]]; then
            roms_to_remove+=("$rom")  # Add ROM to the removal list
            ((removed_count++))  # Increment the removed count
        fi
    done

    # If there are ROMs to remove, prompt for confirmation
    if (( removed_count > 0 )); then
        echo "The following ROMs will be removed:"
        printf "%s\n" "${roms_to_remove[@]}"  # Print each ROM name

        # Ask for confirmation
        echo "Are you sure you want to remove these ROMs? (y/n)"
        read -r confirmation
        if [[ "$confirmation" =~ ^[Yy]$ ]]; then
            for rom in "${roms_to_remove[@]}"; do
                rm "$rom"  # Remove the ROM file
            done
            echo "ROM Deletion Successful! $removed_count ROM(s) were removed."
        else
            echo "No ROMs were removed."
        fi
    else
        echo "No ROMs found without metadata."
    fi

    # Prompt to restart the script
    echo "Would you like to run the script again? (y/n)"
    read -r answer
    if [[ ! "$answer" =~ ^[Yy]$ ]]; then
        break  # Exit the loop if the user does not want to restart
    fi
done
