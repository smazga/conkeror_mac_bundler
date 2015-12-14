#!/bin/bash

xulrunner_version=35.0.1
xulrunner_tarball=xulrunner-${xulrunner_version}.bz2

app_name=Conkeror.app
conkeror_repo=git://repo.or.cz/conkeror.git
git_stage=conkeror.git

files="application.ini chrome.manifest content-policy.manifest"
subdirs="branding chrome components content contrib defaults help locale modules search-engines style tests"

clean() {
	rm -rf Conkeror.app csh.c XUL.framework
}

distclean() {
	clean
	rm -rf $xulrunner_tarball conkeror.git
	exit 0
}

download() {
	if [ ! -f $xulrunner_tarball ]; then
		echo "[ Downloading xulrunner $xulrunner_version ]"
		curl https://ftp.mozilla.org:/pub/xulrunner/releases/${xulrunner_version}/runtimes/xulrunner-${xulrunner_version}.en-US.mac.tar.bz2 -o $xulrunner_tarball
	fi

	if [ ! -d XUL.framework ]; then
		echo "[ Unpacking xulrunner ]"
		tar xf $xulrunner_tarball
	fi

	if [ -d $git_stage ]; then
		echo "[ Cloning conkeror ]"
		cd $git_stage
		git pull
		cd ..
	else
		git clone $conkeror_repo $git_stage
	fi
}

create_app() {
	mkdir -p ${app_name}/Contents/MacOS/conkeror
	mkdir -p ${app_name}/Contents/Resources
	cp -a XUL.framework/Versions/Current/* ${app_name}/Contents/MacOS

	for f in $files; do cp ${git_stage}/$f ${app_name}/Contents/MacOS/conkeror; done
	for d in $subdirs; do cp -r ${git_stage}/$d ${app_name}/Contents/MacOS/conkeror; done

	cp Info.plist ${app_name}/Contents
	cc xulrunner.c -o xulrunner -o ${app_name}/Contents/MacOS/xulrunner_launcher

	echo "#include <arpa/inet.h>" > csh.c
	cat ${git_stage}/conkeror-spawn-helper.c >> csh.c
	cc csh.c -o ${app_name}/Contents/MacOS/conkeror/conkeror-spawn-helper

	cp images/conkeror.icns ${app_name}/Contents/Resources

	(
	cat <<-EOF
		libmozglue.dylib
		libnss3.dylib
		libmozalloc.dylib
		XUL
	EOF
	) > ${app_name}/Contents/Resources/dependentlibs.list

	if [ -d ~/Applications/${app_name} ]; then
		if [ -d ~/Applications/${app_name}-previous ]; then
			rm -rf ~/Applications/${app_name}-previous
		fi
		mv ~/Applications/${app_name} ~/Applications/${app_name}-previous
	fi

	mv ${app_name} ~/Applications

	echo
	echo " *** Installed as: $HOME/Applications/${app_name}"
	echo
	echo "  ./install.sh clean or ./install.sh distclean to clean up"
}

case "$1" in
	distclean)
		distclean
		;;

	clean)
		clean
		;;

	*)
		download
		create_app
		;;
esac