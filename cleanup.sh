#~/bin/sh

rm -rf output
mkdir output
mkdir output/odb
mkdir output/db
mkdir output/logs

rm -f oasys.cmd*
rm -f oasys.dbg*
rm -rf oasys.etc*
rm -f oasys.log*

echo "\n-------------------------------------"
echo "\nCleanup Complete"
echo "\n-------------------------------------\n"
