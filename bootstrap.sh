#!/bin/bash
s3cmd="/usr/local/bin/s3cmd --config=/root/.s3cfg"
s3name="dash-bootstrap"
s3bucket="s3://$s3name/"
s3https="https://$s3name.ams3.digitaloceanspaces.com/"
file="bootstrap.dat"
file_zip="$file.zip"
file_sha256="sha256.txt"
header=`cat header.md`
footer=`cat footer.md`

# pass network name as a param
do_the_job() {
  network=$1
  date=`date -u`
  date_fmt=`date -u +%Y-%m-%d`
  s3networkPath="$s3bucket$network/"
  s3currentPath="$s3networkPath$date_fmt/"
  s3currentUrl="$s3https$network/$date_fmt/"
  linksFile="links-$network.md"
  prevLinks=`head $linksFile`
  echo "$network job - Starting..."
  # process blockchain
  ./linearize-hashes.py linearize-$network.cfg > hashlist.txt
  ./linearize-data.py linearize-$network.cfg
  # compress
  zip $file_zip $file
  # calculate checksums
  sha256sum $file > $file_sha256
  sha256sum $file_zip >> $file_sha256
  # store
  $s3cmd put $file_zip $file_sha256 $s3currentPath --acl-public
  # update docs
  url_zip=$s3currentUrl$file_zip
  url_sha256=$s3currentUrl$file_sha256
  size_zip=`ls -lh $file_zip | awk -F" " '{ print $5 }'`
  newLinks="Block [$blocks]($url_explorer): $date [zip]($url_zip) ($size_zip) [SHA256]($url_sha256)\n\n$prevLinks"
  echo -e "$newLinks" > $linksFile
  rm $file $file_zip $file_sha256 hashlist.txt
  echo -e "#### For $network:\n\n$newLinks\n\n" >> README.md
  # clean up old files
  keepDays=7
  scanDays=30
  oldFolders=$($s3cmd ls $s3networkPath | grep -oP 's3:.*')
  while [ $keepDays -lt $scanDays ]; do
    loopDate=$(date -u -d "now -"$keepDays" days" +%Y-%m-%d)
    found=$(echo -e $oldFolders | grep -oP $loopDate)
    if [ "$found" != "" ]; then
      echo "found old folder $found, deleting $s3networkPath$loopDate/ ..."
      $s3cmd del -r $s3networkPath$loopDate/
    fi
    let keepDays=keepDays+1
  done
  echo "$network job - Done!"
}

# fill the header
echo -e "$header\n" > README.md

# mainnet
#cat ~/.dash/blocks/blk0000* > $file
blocks=`dash-cli getblockcount`
blockhash=`dash-cli getblockhash $blocks`
url_explorer="https://insight.dash.org/insight/block/$blockhash"
do_the_job mainnet

# testnet
#cat ~/.dash/testnet3/blocks/blk0000* > $file
blocks=`dash_testnet-cli -datadir=/root/.dashcore_test getblockcount`
blockhash=`dash_testnet-cli -datadir=/root/.dashcore_test getblockhash $blocks`
url_explorer="https://testnet-insight.dashevo.org/insight/block/$blockhash"
do_the_job testnet

# finalize with the footer
echo -e "$footer" >> README.md

# push to github
git add *.md
git commit -m "$date - autoupdate"
git push
