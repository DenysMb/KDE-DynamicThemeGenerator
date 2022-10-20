#!/bin/sh
echo "---------- Dynamic Theme Generator ----------"

## Select images and store it to variables
kdialog --title "Dynamic Theme Generator - Light Theme" --msgbox "A file picker will open and you'll need to select the LIGHT image"
lightImagePath=$(kdialog --getopenfilename $HOME 'image/*')
lightImageExtension=$(echo "${lightImagePath##*.}")

kdialog --title "Dynamic Theme Generator - Dark Theme" --msgbox "A file picker will open and you'll need to select the DARK image"
darkImagePath=$(kdialog --getopenfilename $HOME 'image/*')
darkImageExtension=$(echo "${darkImagePath##*.}")

## Show input to user to write the theme name
while [ ! "$themeName" ]
do
    themeName=$(kdialog --title "Dynamic Theme Generator - Theme name" --inputbox "What name would you like to use?" "DynamicTheme")
    if [ ! "$themeName" ]; then
        kdialog --error "Name should not be empty!"
    fi
done

## Get screen resolution
screenResolution=$(xdpyinfo | grep dimensions | sed -r 's/^[^0-9]*([0-9]+x[0-9]+).*$/\1/')

## Show progressbar - First step
dbusRef=`kdialog --title "Dynamic Theme Generator - Generating Files" --progressbar "Generating the metadata file" 3`
qdbus-qt5 $dbusRef Set "" value 1

## Remove old wallpaper if wallpaper with same name exists
wallpaperPath="$HOME/.local/share/wallpapers/$themeName"
if [ -d "$wallpaperPath" ]; then
    rm -r $wallpaperPath
fi

## Create Metadata file
mkdir -p "$wallpaperPath"
touch "$wallpaperPath/metadata.desktop"

## Write in Metadata file
echo "[Desktop Entry]" >> "$wallpaperPath/metadata.desktop"
echo "Name=$themeName" >> "$wallpaperPath/metadata.desktop"

## Show progressbar - Second step
qdbus-qt5 $dbusRef setLabelText "Creating folders and copying the LIGHT image"
qdbus-qt5 $dbusRef Set "" value 2

## Copy LIGHT image
lightImageFolder="$wallpaperPath/contents/images"
mkdir -p "$lightImageFolder"
cp "$lightImagePath" "$lightImageFolder/$screenResolution.$lightImageExtension"

## Show progressbar - Third step
qdbus-qt5 $dbusRef setLabelText "Creating folders and copying the DARK image"
qdbus-qt5 $dbusRef Set "" value 3

## Copy DARK image
darkImageFolder="$wallpaperPath/contents/images_dark"
mkdir -p "$darkImageFolder"
cp "$darkImagePath" "$darkImageFolder/$screenResolution.$darkImageExtension"

## Close progressbar
qdbus-qt5 $dbusRef close

### Final message
kdialog --title "Dynamic Theme Generator - Final" --msgbox "The wallpaper was successfully generated."