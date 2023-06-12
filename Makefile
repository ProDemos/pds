tag ?= tag

semver = $(subst ., ,$(tag))
major = $(word 1,$(semver))
minor = $(word 2,$(semver))
patch = $(word 3,$(semver))
version = $(major).$(minor).$(patch)

packages = pds-compiled pds-source pds-demo

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
	node_modules/node-sass/bin/node-sass \
		--output-style compressed \
		src/assets/sass/reset.scss \
		src/assets/css/reset.css
	node_modules/node-sass/bin/node-sass \
		--output-style compressed \
		src/demo/twig/sass/styleguide.scss \
		src/demo/html/css/styleguide.css
	node_modules/node-sass/bin/node-sass \
		--output-style compressed \
		src/demo/twig/sass/prodemos.scss \
		src/demo/html/css/prodemos.css

compile-html:
	@echo
	php src/demo/compile.php

clean: 
	rm -rf ./build/*/

	rm -rf src/assets/css/*
	echo "The CSS will be generated here." >> src/assets/css/README.md

	rm -rf src/demo/html/*
	echo "The HTML will be generated here." >> src/demo/html/README.md

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
		src/assets/fonts \
		build/pds-compiled/assets 
	rm -f build/pds-compiled/assets/css/README.md
	cp build/package.json.tpl build/pds-compiled/package.json
	sed -i $(SEDFIX) 's/##PACKAGE-NAME##/pds-compiled/' build/pds-compiled/package.json

package-pds-source:
	@echo
	@echo Building pds-source ..
	mkdir -p build/pds-source/assets
	cp -r src/assets/javascript \
		src/assets/images \
		src/assets/fonts \
		src/assets/sass \
		build/pds-source/assets
	cp build/package.json.tpl build/pds-source/package.json
	sed -i $(SEDFIX) 's/##PACKAGE-NAME##/pds-source/' build/pds-source/package.json

package-pds-demo:
	@echo
	@echo Building pds-demo ..
	@if [ ! -f "src/demo/html/index.html" ] ; then echo "Compile html first" ; false ; fi
	mkdir -p build/pds-demo
	cp -r src/demo/html build/pds-demo
	rm -f build/pds-demo/html/README.md
	cp build/package.json.tpl build/pds-demo/package.json
	sed -i $(SEDFIX) 's/##PACKAGE-NAME##/pds-demo/' build/pds-demo/package.json

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

release-pds-demo:

	@echo
	@echo Releasing pds-demo ..
	@if [ ! -d "build/pds-demo" ] ; then echo "build/pds-demo not ready" ; false ; fi
	cd build/pds-demo && npm version $(version)
	npm publish ./build/pds-demo
	tar -cvzf ./build/pds-demo.tgz ./build/pds-demo
	hub release edit -a ./build/pds-demo.tgz -m "" $(version)
