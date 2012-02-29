#!/bin/bash

firefox_app="/Applications/Firefox.app"
conkeror_app="Conkeror.app"
conkeror_source=$1

cp_or_ln='cp -rp'
#cp_or_ln='ln -s'

here=`pwd`
gcc xulrunner.c -o xulrunner
gcc $conkeror_source/conkeror-spawn-helper.c -o conkeror-spawn-helper

rm -rf $conkeror_app
mkdir $conkeror_app
mkdir $conkeror_app/Contents
cd $conkeror_app/Contents

conkeror_version=`grep '^Version=' $conkeror_source/application.ini | sed -e 's/Version=//'`
sed -e 's/\$CONKEROR_SHORT_VERSION\$/1.0pre/' -e 's_</dict>_<key>CFBundleURLTypes</key><array><dict><key>CFBundleURLName</key><string>Web site URL</string><key>CFBundleURLSchemes</key><array><string>http</string><string>https</string></array></dict></array></dict>_' $conkeror_source/Info.plist > ./Info.plist

mkdir MacOS
cd MacOS
mv $here/xulrunner .

$cp_or_ln $firefox_app/Contents/MacOS/* .

mkdir conkeror
mv $here/conkeror-spawn-helper conkeror/
cp -p $conkeror_source/application.ini conkeror/
cp -rp $conkeror_source/branding conkeror/
cp -rp $conkeror_source/chrome conkeror/
cp -p $conkeror_source/chrome.manifest conkeror/
cp -rp $conkeror_source/components conkeror/
cp -rp $conkeror_source/content conkeror/
cp -p $conkeror_source/content-policy.manifest conkeror/
cp -rp $conkeror_source/contrib conkeror/
cp -rp $conkeror_source/defaults conkeror/
cp -rp $conkeror_source/help conkeror/
cp -rp $conkeror_source/locale conkeror/
cp -rp $conkeror_source/modules conkeror/
cp -rp $conkeror_source/search-engines conkeror/
cp -rp $conkeror_source/style conkeror/
cp -rp $conkeror_source/tests conkeror/

cd ..
mkdir Resources
cd Resources
$cp_or_ln $firefox_app/Contents/Resources/*.icns .
for lproj in $firefox_app/Contents/Resources/*.lproj
do
   dirname=`basename $lproj`
   mkdir $dirname
   echo 'CFBundleName = "Conkeror";' > $dirname/InfoPlist.strings
done
