#
# Makefile for ruby-sphere
# $Id: Makefile,v 1.25 2007/03/01 05:25:55 tomono Exp $
#

RUBY=ruby
RDOC=rdoc
SETUP=setup.rb
VERSION := $(shell ruby -Ilib -rsphere/version -e 'puts Sphere::VERSION')
PKGNAME := $(shell ruby -Ilib -rsphere/version -e 'puts Sphere::PKGNAME')
ardir=.

HOST=`whoami`,ruby-sphere@web.sourceforge.net
# this requires the commiter to have the same uid as on sourceforge.net
HOMEDIR=/home/groups/r/ru/ruby-sphere
HTMLDIR=$(HOMEDIR)/htdocs
WWWPATH=$(HOST):$(HTMLDIR)

# run test scripts
.PHONY: check
check: test

.PHONY: test
test:
	$(RUBY) -Ilib test/run-test.rb

# wrappers for setup.rb
.PHONY: install .config
install:
	$(RUBY) $(SETUP) $@

.config: config
.PHONY: config
config:
	$(RUBY) $(SETUP) $@

.PHONY: setup
setup:
	$(RUBY) $(SETUP) $@

# crerate API document in doc/
doc: doc/.timestamp doc/README.html doc/ruby-sphere.css doc/ruby-sphere-logo-32.png doc/GPL.txt
doc/.timestamp: $(wildcard lib/*.rb lib/sphere/*.rb)
	pushd lib; \
	$(RDOC) --title "$(PKGNAME) API document" \
		--main Sphere::StellarBody \
		--template kilmer \
		--op ../doc/ sphere; \
	popd
	touch doc/.timestamp

# things to do when releasing
.PHONY: release
release: .svn reltest dist
	!( svn status 2>/dev/null | grep ^M )

# test a release version: pass the test cases and create the HTML documents
.PHONY: reltest
reltest: .svn
	rm -rf tmp; mkdir tmp
	svn info | grep URL: | cut -f2 -d' ' | sed s:/trunk/:/tags/: | (cd tmp; xargs -i svn export {}-${VERSION} ${PKGNAME})
	make -C tmp/$(PKGNAME) test
	make -C tmp/$(PKGNAME) doc
	rm -rf tmp
	@echo '*** Make sure there is no files not added to the SVN repository.'

# create a tarball
.PHONY: dist
dist: .svn
	rm -rf tmp; mkdir tmp
	svn info | grep URL: | cut -f2 -d' ' | sed s:/trunk/:/tags/: | (cd tmp; xargs -i svn export {}-${VERSION} ${PKGNAME})
	( cd tmp; tar cf - $(PKGNAME) ) | gzip -c -9 > $(ardir)/$(PKGNAME).tar.gz
	rm -rf tmp

# convert the README file into HTML
doc/README.html: README.en lib/sphere/version.rb
	rd2 -r rd/rd2html-lib.rb \
		--with-css='ruby-sphere.css' \
		--html-title='$(PKGNAME) README' \
		README.en > doc/README.html

# files needed on the project www site
doc/ruby-sphere.css: web/ruby-sphere.css
	cp $< $@

doc/ruby-sphere-logo-32.png: web/ruby-sphere-logo-32.png
	cp $< $@

doc/GPL.txt: GPL
	cp $< $@

web/ChangeLog.txt: ChangeLog
	cp $< $@

# make the project web site in shape
.PHONY: web
web: doc doc/README.html web/ChangeLog.txt
	pushd web; \
	if ( ! test -d doc ); then ln -s ../doc .; fi; \
	popd

# upload the web contents to ruby-shpere.sourceforge.net
.PHONY: upload
upload: web
	echo uploading ...
	rsync -e ssh -z -v --delete -L -C -r web/ $(WWWPATH)

# commit the changes
.PHONY: commit
commit: .svn
	log=`ruby -e 'print File.open("ChangeLog").read.split(/^$$/,2)[0]'`;\
	ver=`echo "$$log" | ruby -ne 'print $$_.match(/(?!\()\d+\.\d+\.\d+(?=\))/).to_s'`;\
	if [ -n "$$ver" ] && [ "$$ver" != "$(VERSION)" ]; then \
		echo '*** Version in ChangeLog does not match the library version';\
		exit 1;\
	fi && \
	svn commit -m "$$log" && \
	echo "$$log" &&\
	if [ -n "$$ver" ]; then \
		cur_repo=`svn info | grep URL: | cut -f2 -d\ `;\
		tag_repo=`echo $$cur_repo | sed s:/trunk/:/tags/:`-${VERSION}; \
		echo "Tagging to $$tag_repo"; \
		svn remove -m "$$log" $$tag_repo 2>/dev/null ; \
		svn cp -m "$$log" $$cur_repo $$tag_repo && \
		echo Svn tag made at $$tag_repo; \
	fi

