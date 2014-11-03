#!/bin/bash
file="bootstrap.dat"
cat ~/.darkcoin/blocks/blk0000* >> $file
date=`date --utc`
url=`curl --upload-file $file https://transfer.sh/bootstrap.dat`
readmeHead="bootstrap.dat files for DarkCoin\n==="
prevLinks=`tail -n +3 README.md | head`
echo -e "$readmeHead\n$date [$url]($url)\n\n$prevLinks" > README.md
rm $file
git commit -am "$date - autoupdate"
git push
