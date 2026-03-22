#!/usr/bin/env bash

# --- Dependency Check ---
if ! command -v identify &> /dev/null; then
    kdialog --error "Program 'imagemagick' is not installed. Please install it for the script to work."
    exit 1
fi

# --- Get User Input ---
while [ -z "$themeName" ]; do
    if ! themeName=$(kdialog --title "KDE Wallpaper Generator" --inputbox "Enter theme name:" "DynamicTheme"); then
        exit
    fi
done

while [ -z "$themeAuthor" ]; do
    if ! themeAuthor=$(kdialog --title "KDE Wallpaper Generator" --inputbox "Enter author name:" "$USER"); then
        exit
    fi
done

themeID="${themeName// /}"
wallpaperPath="$HOME/.local/share/wallpapers/$themeID"

# --- File Selection ---
if ! l_path=$(kdialog --title "Select LIGHT wallpaper" --getopenfilename "$HOME" 'Images (*.jpg *.png *.gif *.webp)'); then
    exit
fi

if ! d_path=$(kdialog --title "Select DARK wallpaper" --getopenfilename "$HOME" 'Images (*.jpg *.png *.gif *.webp)'); then
    exit
fi

# Get extensions and dimensions
l_ext="${l_path##*.}"
l_dim=$(identify -format "%wx%h" "${l_path}[0]")

d_ext="${d_path##*.}"
d_dim=$(identify -format "%wx%h" "${d_path}[0]")

# --- File Generation ---
mkdir -p "$wallpaperPath/contents/images"
mkdir -p "$wallpaperPath/contents/images_dark"

# Create metadata.json
cat << EOF > "$wallpaperPath/metadata.json"
{
    "KPlugin": {
        "Authors": [ { "Name": "$themeAuthor" } ],
        "Id": "$themeID",
        "Name": "$themeName"
    }
}
EOF

# Copying files
cp "$l_path" "$wallpaperPath/contents/images/${l_dim}.${l_ext}"
cp "$d_path" "$wallpaperPath/contents/images_dark/${d_dim}.${d_ext}"

# --- Final Message ---
kdialog --title "Success!" --msgbox "The wallpaper has been created at:\n$wallpaperPath\n\nYou can now select it in your Desktop Settings."
