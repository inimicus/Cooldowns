#!/bin/bash

# Get directory name, strip spaces
addon=${PWD##*/}

# Output location for zip
outDir="${addon}/release/"

# Get version number
version=`cat EarthgoreCooldown.txt | grep "## Version" | sed 's/.*: //'`

# Setup zip file name
zipName="${addon}-${version/ /_}.zip"

# Files to exclude
exclude=""
declare -a systemExclude=(
    "*.git*"
    "*.DS_Store"
)
declare -a fileExclude=(
    "README.md"
    "makePackage.sh"
    "release/*"
    "release/**/*"
)

# Prepend excludes with directory path
for item in "${systemExclude[@]}" "${fileExclude[@]}"
do
    exclude="${exclude} ${addon}/${item}"
done

# Create zip package
echo "Creating: ${zipName}"
cd ..
zip -DqrX ${outDir}${zipName} ${addon} -x ${exclude}
echo "Done!"

