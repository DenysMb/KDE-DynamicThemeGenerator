#!/usr/bin/env bash

## Show input to user to write the theme name
while [ ! "$themeName" ]
do
    themeName=$(kdialog --title "Dynamic Theme Generator - Theme name" --inputbox "What name would you like to use?" "DynamicTheme")
    if [ ! "$themeName" ]; then
        kdialog --error "Name should not be empty!"
    fi
done

## Show input to user to write the theme author
while [ ! "$themeAuthor" ]
do
    themeAuthor=$(kdialog --title "Dynamic Theme Generator - Theme author" --inputbox "What name would you like to use?" "DynamicTheme")
    if [ ! "$themeName" ]; then
        kdialog --error "Name should not be empty!"
    fi
done

themeID="${themeName// /}"
wallpaperPath="$HOME/.local/share/wallpapers/$themeID"

## Select images and store it to variables
l_path=$(kdialog --title "Dynamic Theme Generator - Light Image" --getopenfilename "$HOME" '*')
l_ext="${l_path##*.}"

d_path=$(kdialog --title "Dynamic Theme Generator - Dark Image" --getopenfilename "$HOME" '*')
d_ext="${d_path##*.}"

## Get image sizes
l_width=$(identify -format "%w" "$l_path")> /dev/null
l_height=$(identify -format "%h" "$l_path")> /dev/null

d_width=$(identify -format "%w" "$d_path")> /dev/null
d_height=$(identify -format "%h" "$d_path")> /dev/null

## Show progressbar - First step
dbusRef=$(kdialog --title "Dynamic Theme Generator - Generating Files" --progressbar "Generating the metadata file" 3)
qdbus $dbusRef Set "" value 1

## Create Metadata file
mkdir -p "$wallpaperPath"

## Write in Metadata file
cat << EOF > "$wallpaperPath/metadata.json"
{
    "KPlugin": {
        "Authors": [
            {
                "Name": "$themeAuthor"
            }
        ],
        "Id": "$themeID",
        "Name": "$themeName"
    }
}
EOF

## Show progressbar - light image
qdbus $dbusRef setLabelText "Creating folders and copying the light image"
qdbus $dbusRef Set "" value 2

l_folder="$wallpaperPath/contents/images"
mkdir -p "$l_folder"
cp "$l_path" "$l_folder/${l_width}x${l_height}.$l_ext"

## Show progressbar - dark image
qdbus $dbusRef setLabelText "Creating folders and copying the dark image"
qdbus $dbusRef Set "" value 3

d_folder="$wallpaperPath/contents/images_dark"
mkdir -p "$d_folder"
cp "$d_path" "$d_folder/${d_width}x${d_height}.$d_ext"

## Close progressbar
qdbus $dbusRef close

### Final message
kdialog --title "Dynamic Theme Generator - Final" --msgbox "The wallpaper was successfully generated."
