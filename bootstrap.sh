#!/bin/bash
blocks=`dash-cli getblockcount`
blocksTestnet=`dash_testnet-cli -datadir=/root/.dashcore_test getblockcount`
date=`date -u`
date_fmt=`date -u +%Y%m%d`
file="bootstrap.dat"
file_7z="$file.$date_fmt.7z"
file_zip="$file.$date_fmt.zip"
file_sha256="sha256.txt"
header=`cat header.md`
prevLinks=`head links.md`
prevLinksTestnet=`head linksTestnet.md`
footer=`cat footer.md`
#mainnet
#cat ~/.dash/blocks/blk0000* > $file
./linearize-hashes.py linearize.cfg > hashlist.txt
./linearize-data.py linearize.cfg 
#
touch $file_sha256
sha256sum $file > $file_sha256
#7z
7z a $file_7z $file
sha256sum $file_7z >> $file_sha256
size_7z=`ls -lh $file_7z | awk -F" " '{ print $5 }'`
url_7z=`curl --upload-file $file_7z https://transfer.sh/$file_7z`
rm $file_7z
#zip
zip $file_zip $file
sha256sum $file_zip >> $file_sha256
size_zip=`ls -lh $file_zip | awk -F" " '{ print $5 }'`
url_zip=`curl --upload-file $file_zip https://transfer.sh/$file_zip`
rm $file_zip
#
url_sha256=`curl --upload-file $file_sha256 https://transfer.sh/$file_sha256`
newLinks="Block $blocks: $date [7z]($url_7z) ($size_7z) [zip]($url_zip) ($size_zip) [SHA256]($url_sha256)\n\n$prevLinks"
echo -e "$newLinks" > links.md
rm $file $file_sha256 hashlist.txt
#testnet
#cat ~/.dash/testnet3/blocks/blk0000* > $file
./linearize-hashes.py linearize-testnet.cfg > hashlist.txt
./linearize-data.py linearize-testnet.cfg 
#
touch $file_sha256
sha256sum $file > $file_sha256
#7z
7z a $file_7z $file
sha256sum $file_7z >> $file_sha256
size_7z=`ls -lh $file_7z | awk -F" " '{ print $5 }'`
url_7z=`curl --upload-file $file_7z https://transfer.sh/$file_7z`
rm $file_7z
#zip
zip $file_zip $file
sha256sum $file_zip >> $file_sha256
size_zip=`ls -lh $file_zip | awk -F" " '{ print $5 }'`
url_zip=`curl --upload-file $file_zip https://transfer.sh/$file_zip`
rm $file_zip
#
url_sha256=`curl --upload-file $file_sha256 https://transfer.sh/$file_sha256`
newLinksTestnet="Block $blocksTestnet: $date [7z]($url_7z) ($size_7z) [zip]($url_zip) ($size_zip) [SHA256]($url_sha256)\n\n$prevLinksTestnet"
echo -e "$newLinksTestnet" > linksTestnet.md
rm $file $file_sha256 hashlist.txt
#construct README.md
echo -e "$header\n\n####For mainnet:\n\n$newLinks\n\n####For testnet:\n\n$newLinksTestnet\n\n$footer" > README.md
#push
git add *.md
git commit -m "$date - autoupdate"
git push
