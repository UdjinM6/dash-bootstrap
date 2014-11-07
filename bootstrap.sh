#!/bin/bash
file="bootstrap.dat"
file_md5="md5.txt"
file_sha256="sha256.txt"
cat ~/.darkcoin/blocks/blk0000* >> $file
touch $file_md5 $file_sha256
md5sum $file > $file_md5
sha256sum $file > $file_sha256
size=`ls -lh $file | awk -F" " '{ print $5 }'`
date=`date --utc`
url=`curl --upload-file $file https://transfer.sh/bootstrap.dat`
url_md5=`curl --upload-file $file_md5 https://transfer.sh/$file_md5`
url_sha256=`curl --upload-file $file_sha256 https://transfer.sh/$file_sha256`
header=`cat header.md`
prevLinks=`head links.md`
footer=`cat footer.md`
newLinks="$date [$url]($url) ($size) [MD5]($url_md5) [SHA256]($url_sha256)\n\n$prevLinks"
echo -e "$newLinks" > links.md
echo -e "$header\n\n$newLinks\n\n$footer" > README.md
rm $file $file_md5 $file_sha256
git commit -am "$date - autoupdate"
git push
