FIREFOX ?= /Applications/Firefox.app
CONKEROR = Conkeror.app
REPO = git://repo.or.cz/conkeror.git
STAGE = conkeror.git
GIT = /usr/bin/git
FILES = application.ini chrome.manifest content-policy.manifest
SUBDIRS = branding chrome components content contrib defaults help locale modules search-engines style tests
LPROJ := $(wildcard $(FIREFOX)/Contents/Resources/*.lproj)

.PHONY: all
all: clean $(CONKEROR)

$(STAGE):
	cd $@ 2>/dev/null && $(GIT) pull || $(GIT) clone $(REPO) $@

%/MacOS:
	mkdir -p $@
	cp -rp $(FIREFOX)/Contents/MacOS/* $@

%/Resources:
	mkdir -p $@
	cp -rp $(FIREFOX)/Contents/Resources/*.icns $@
	cp images/conkeror.icns $@

	$(foreach dir,$(LPROJ), mkdir $@/$(notdir $(dir)) ; echo "CFBundleName = \"Conkeror\";" > $@/$(notdir $(dir))/InfoPlist.strings; )

%/Info.plist:
	mkdir -p $(@D)
	cp Info.plist $@

%/conkeror: %
	mkdir -p $@/conkeror
	@echo copying files...
	@$(foreach file,$(FILES),cp -p $(STAGE)/$(file) $@; )

	@echo copying directories...
	@$(foreach dir,$(SUBDIRS),cp -rp $(STAGE)/$(dir) $@; )

%/xulrunner: % $(STAGE)
	$(CC) $(@F).c -o $@

%/conkeror-spawn-helper: % $(STAGE)
	$(CC) $(STAGE)/$(@F).c -o $@

$(CONKEROR): \
 $(CONKEROR)/Contents/MacOS \
 $(CONKEROR)/Contents/MacOS/xulrunner \
 $(CONKEROR)/Contents/MacOS/conkeror-spawn-helper \
 $(CONKEROR)/Contents/MacOS/conkeror \
 $(CONKEROR)/Contents/Resources \
 $(CONKEROR)/Contents/Info.plist
	@echo "built $(CONKEROR)"

.PHONY: install
install: $(CONKEROR)
	@mv /Applications/$(CONKEROR) $(CONKEROR).backup
	mv $(CONKEROR) /Applications
	@rm -rf $(CONKEROR).backup

.PHONY: clean distclean
clean:
	rm -rf ./$(CONKEROR)

distclean: clean
	rm -rf ./$(STAGE)