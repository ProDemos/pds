tag ?= tag

semver = $(subst ., ,$(tag))
major = $(word 1,$(semver))
minor = $(word 2,$(semver))
patch = $(word 3,$(semver))
version = $(major).$(minor).$(patch)

packages = pds-compiled pds-source pds-docs

# uncomment this on mac
# SEDFIX=''

test:
	@echo $(tag) - $(semver) - $(version)
	$(foreach package,$(packages),echo $(package);)

install:
	@echo
	composer install
	@echo
	npm install

compile: compile-css compile-html

compile-css:
	@echo
	node_modules/node-sass/bin/node-sass \
		--output-style compressed \
		src/assets/sass/main.scss \
		src/assets/css/main.css

compile-html:
	@echo
	php src/php/compile-html.php

clean: 
	rm -r ./build/*/

	rm -rf src/assets/css/*
	echo "The CSS will be generated here." >> src/assets/css/README.md

	rm -rf src/docs/html/*
	echo "The HTML will be generated here." >> src/docs/html/README.md

packages:
	rm -rf ./build/*/
	$(foreach package,$(packages),make package-$(package);)

package-pds-compiled:
	@echo
	@echo Building pds-compiled ..
	@if [ ! -f "src/assets/css/main.css" ] ; then echo "Compile css first" ; false ; fi
	mkdir -p build/pds-compiled/assets
	cp -r src/assets/css \
		src/assets/javascript \
		src/assets/images \
		build/pds-compiled/assets 
	rm -f build/pds-compiled/assets/css/README.md
	cp build/package.json.tpl build/pds-compiled/package.json
	sed -i $(SEDFIX) 's/##PACKAGE-NAME##/multipackage-compiled/' build/pds-compiled/package.json

package-pds-source:
	@echo
	@echo Building pds-source ..
	mkdir -p build/pds-source/assets
	cp -r src/assets/javascript \
		src/assets/images \
		src/assets/sass \
		build/pds-source/assets
	cp build/package.json.tpl build/pds-source/package.json
	sed -i $(SEDFIX) 's/##PACKAGE-NAME##/multipackage-source/' build/pds-source/package.json

package-pds-docs:
	@echo
	@echo Building pds-docs ..
	@if [ ! -f "src/docs/html/test.html" ] ; then echo "Compile html first" ; false ; fi
	mkdir -p build/pds-docs
	cp -r src/docs/html build/pds-docs
	rm -f build/pds-docs/html/README.md
	cp build/package.json.tpl build/pds-docs/package.json
	sed -i $(SEDFIX) 's/##PACKAGE-NAME##/multipackage-docs/' build/pds-docs/package.json

release:

	@if test -z "$(version)"; then echo "make release requires a semantic version"; false ; fi
	$(foreach package,$(packages),make release-$(package);)

release-pds-compiled:

	@echo
	@echo Releasing pds-compiled ..
	@if [ ! -d "build/pds-compiled" ] ; then echo "build/pds-compiled not ready" ; false ; fi
	cd build/pds-compiled && npm version $(version)
	npm publish ./build/pds-compiled
	tar -cvzf ./build/pds-compiled.tgz ./build/pds-compiled
	hub release edit -a ./build/pds-compiled.tgz -m "" $(version)

release-pds-source:

	@echo
	@echo Releasing pds-source ..
	@if [ ! -d "build/pds-source" ] ; then echo "build/pds-source not ready" ; false ; fi
	cd build/pds-source && npm version $(version)
	npm publish ./build/pds-source
	tar -cvzf ./build/pds-source.tgz ./build/pds-source
	hub release edit -a ./build/pds-source.tgz -m "" $(version)

release-pds-docs:

	@echo
	@echo Releasing pds-docs ..
	@if [ ! -d "build/pds-docs" ] ; then echo "build/pds-docs not ready" ; false ; fi
	cd build/pds-docs && npm version $(version)
	npm publish ./build/pds-docs
	tar -cvzf ./build/pds-docs.tgz ./build/pds-docs
	hub release edit -a ./build/pds-docs.tgz -m "" $(version)
