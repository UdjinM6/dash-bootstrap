#!/bin/bash
file="bootstrap.dat"
cat ~/.darkcoin/blocks/blk0000* >> $file
date=`date --utc`
url=`curl --upload-file $file https://transfer.sh/bootstrap.dat`
header=`cat header.md`
prevLinks=`head links.md`
footer=`cat footer.md`
newLinks="$date [$url]($url)\n\n$prevLinks"
echo -e "$newLinks" > links.md
echo -e "$header\n\n$newLinks\n\n$footer" > README.md
rm $file
git commit -am "$date - autoupdate"
git push
