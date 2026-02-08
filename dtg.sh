#!/usr/bin/env bash

# --- Dependency Check ---
if ! command -v identify &> /dev/null; then
    kdialog --error "Program 'imagemagick' is not installed. Please install it so the script can read image dimensions."
    exit 1
fi

# --- Get User Input ---
while [ -z "$themeName" ]
do
    themeName=$(kdialog --title "Universal KDE Wallpaper Generator" --inputbox "Enter theme name:" "DynamicTheme")
    [ $? -ne 0 ] && exit
done

while [ -z "$themeAuthor" ]
do
    themeAuthor=$(kdialog --title "Universal KDE Wallpaper Generator" --inputbox "Enter author name:" "$USER")
    [ $? -ne 0 ] && exit
done

themeID="${themeName// /}"
wallpaperPath="$HOME/.local/share/wallpapers/$themeID"

# --- File Selection (Universal Filter) ---
l_path=$(kdialog --title "Select LIGHT wallpaper (JPG, PNG, GIF, WebP)" --getopenfilename "$HOME" 'Images (*.jpg *.jpeg *.png *.gif *.webp)')
[ -z "$l_path" ] && exit

d_path=$(kdialog --title "Select DARK wallpaper (JPG, PNG, GIF, WebP)" --getopenfilename "$HOME" 'Images (*.jpg *.jpeg *.png *.gif *.webp)')
[ -z "$d_path" ] && exit

# Get extensions and dimensions
# [0] in identify ensures correct reading of the first frame for GIFs
l_ext="${l_path##*.}"
l_dim=$(identify -format "%wx%h" "${l_path}[0]")

d_ext="${d_path##*.}"
d_dim=$(identify -format "%wx%h" "${d_path}[0]")

# --- Generate Structure and Files ---
dbusRef=$(kdialog --title "Processing" --progressbar "Preparing folders..." 3)
qdbus $dbusRef Set "" value 1

mkdir -p "$wallpaperPath/contents/images"
mkdir -p "$wallpaperPath/contents/images_dark"

# Create metadata.json file
cat << EOF > "$wallpaperPath/metadata.json"
{
    "KPlugin": {
        "Authors": [ { "Name": "$themeAuthor" } ],
        "Id": "$themeID",
        "Name": "$themeName"
    }
}
EOF

# Copy light file
qdbus $dbusRef setLabelText "Copying light file: $l_ext"
qdbus $dbusRef Set "" value 2
cp "$l_path" "$wallpaperPath/contents/images/${l_dim}.${l_ext}"

# Copy dark file
qdbus $dbusRef setLabelText "Copying dark file: $d_ext"
qdbus $dbusRef Set "" value 3
cp "$d_path" "$wallpaperPath/contents/images_dark/${d_dim}.${d_ext}"

qdbus $dbusRef close

# --- Final Message ---
kdialog --title "Success!" --msgbox "Your dynamic wallpaper has been created!\n\nLocation: $wallpaperPath\n\nYou can now select it in the KDE Desktop Settings."
