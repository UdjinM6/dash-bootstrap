#!/bin/bash
file="bootstrap.dat"
cat ~/.darkcoin/blocks/blk0000* >> $file
date=`date --utc`
url=`curl --upload-file $file https://transfer.sh/bootstrap.dat`
readmeHead="bootstrap.dat files for DarkCoin\n==="
donations="Donations are welcome:\n\nDRK: XsV4GHVKGTjQFvwB7c6mYsGV3Mxf7iser6"
prevLinks=`tail -n +3 README.md | head -n -3 | head`
echo -e "$readmeHead\n$date [$url]($url)\n\n$prevLinks\n\n$donations" > README.md
rm $file
git commit -am "$date - autoupdate"
git push
