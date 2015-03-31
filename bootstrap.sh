#!/bin/bash
blocks=`dashd getinfo | grep blocks | cut -d " " -f 7 | cut -d "," -f 1`
blocksTestnet=`dashd_testnet -conf=/root/.dash/dash-testnet.conf getinfo | grep blocks | cut -d " " -f 7 | cut -d "," -f 1`
date=`date -u`
date_fmt=`date -u +%Y%m%d`
file="bootstrap.dat"
file_md5="md5.txt"
file_7z="$file.$date_fmt.7z"
file_zip="$file.$date_fmt.zip"
file_sha256="sha256.txt"
header=`cat header.md`
prevLinks=`head links.md`
prevLinksTestnet=`head linksTestnet.md`
footer=`cat footer.md`
#mainnet
cat ~/.dash/blocks/blk0000* > $file
touch $file_md5 $file_sha256
7z a $file_7z $file
zip $file_zip $file
md5sum $file $file_7z $file_zip > $file_md5
sha256sum $file $file_7z $file_zip > $file_sha256
size_7z=`ls -lh $file_7z | awk -F" " '{ print $5 }'`
size_zip=`ls -lh $file_zip | awk -F" " '{ print $5 }'`
url_7z=`curl --upload-file $file_7z https://transfer.sh/$file_7z`
url_zip=`curl --upload-file $file_zip https://transfer.sh/$file_zip`
url_md5=`curl --upload-file $file_md5 https://transfer.sh/$file_md5`
url_sha256=`curl --upload-file $file_sha256 https://transfer.sh/$file_sha256`
newLinks="Block $blocks: $date [7z]($url_7z) ($size_7z) [zip]($url_zip) ($size_zip) [MD5]($url_md5) [SHA256]($url_sha256)\n\n$prevLinks"
echo -e "$newLinks" > links.md
rm $file $file_7z $file_zip $file_md5 $file_sha256
#testnet
cat ~/.dash/testnet3/blocks/blk0000* > $file
touch $file_md5 $file_sha256
7z a $file_7z $file
zip $file_zip $file
md5sum $file $file_7z $file_zip > $file_md5
sha256sum $file $file_7z $file_zip > $file_sha256
size_7z=`ls -lh $file_7z | awk -F" " '{ print $5 }'`
size_zip=`ls -lh $file_zip | awk -F" " '{ print $5 }'`
url_7z=`curl --upload-file $file_7z https://transfer.sh/$file_7z`
url_zip=`curl --upload-file $file_zip https://transfer.sh/$file_zip`
url_md5=`curl --upload-file $file_md5 https://transfer.sh/$file_md5`
url_sha256=`curl --upload-file $file_sha256 https://transfer.sh/$file_sha256`
newLinksTestnet="Block $blocksTestnet: $date [7z]($url_7z) ($size_7z) [zip]($url_zip) ($size_zip) [MD5]($url_md5) [SHA256]($url_sha256)\n\n$prevLinksTestnet"
echo -e "$newLinksTestnet" > linksTestnet.md
rm $file $file_7z $file_zip $file_md5 $file_sha256
#construct README.md
echo -e "$header\n\n####For mainnet:\n\n$newLinks\n\n####For testnet:\n\n$newLinksTestnet\n\n$footer" > README.md
#push
git commit -am "$date - autoupdate"
git push
