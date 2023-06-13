tag ?= tag

semver = $(subst ., ,$(tag))
major = $(word 1,$(semver))
minor = $(word 2,$(semver))
patch = $(word 3,$(semver))
version = $(major).$(minor).$(patch)

packages = pds-compiled pds-source pds-demo

SEDFIX = 
ifneq ($(OS),Windows_NT)
	UNAME := $(shell uname -s)
	ifeq ($(UNAME),Darwin)
		SEDFIX = ''
	endif
endif

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
	php src/demo/compile.php src/demo/twig src/demo/html
	cp -r src/assets src/demo/html

clean: 

	rm -rf ./build/packages/*/

	rm -rf src/assets/css/*
	echo "The CSS will be generated here." >> src/assets/css/README.md

	rm -rf src/demo/html/*
	echo "The HTML will be generated here." >> src/demo/html/README.md

packages:
	rm -rf ./build/packages/*/
	$(foreach package,$(packages),make package-$(package);)

package-pds-compiled: PACKAGE_DIR = build/packages/pds-compiled
package-pds-compiled:
	@echo
	@echo Building pds-compiled ..
	@if [ ! -f "src/assets/css/main.css" ] ; then echo "Compile css first" ; false ; fi
	mkdir -p $(PACKAGE_DIR)/assets
	cp -r src/assets/css \
		src/assets/javascript \
		src/assets/images \
		src/assets/fonts \
		$(PACKAGE_DIR)/assets 
	rm -f $(PACKAGE_DIR)/assets/css/README.md
	@echo Creating package.json ..
	@cp build/packages/package.json.tpl $(PACKAGE_DIR)/package.json
	@sed -i $(SEDFIX) 's/##PACKAGE-NAME##/pds-compiled/' $(PACKAGE_DIR)/package.json

package-pds-source: PACKAGE_DIR = build/packages/pds-source
package-pds-source:
	@echo
	@echo Building pds-source ..
	mkdir -p $(PACKAGE_DIR)/assets
	cp -r src/assets/javascript \
		src/assets/images \
		src/assets/fonts \
		src/assets/sass \
		$(PACKAGE_DIR)/assets
	@echo Creating package.json ..
	@cp build/packages/package.json.tpl $(PACKAGE_DIR)/package.json
	@sed -i $(SEDFIX) 's/##PACKAGE-NAME##/pds-source/' $(PACKAGE_DIR)/package.json

package-pds-demo: PACKAGE_DIR = build/packages/pds-demo
package-pds-demo:
	@echo
	@echo Building pds-demo ..
	@if [ ! -f "src/demo/html/index.html" ] ; then echo "Compile html first" ; false ; fi
	mkdir -p $(PACKAGE_DIR)
	cp -r src/demo/html $(PACKAGE_DIR)
	rm -f $(PACKAGE_DIR)/html/README.md
	@echo Creating package.json ..
	@cp build/packages/package.json.tpl $(PACKAGE_DIR)/package.json
	@sed -i $(SEDFIX) 's/##PACKAGE-NAME##/pds-demo/' $(PACKAGE_DIR)/package.json

release:
	@if test -z "$(version)"; then echo "make release requires a semantic version"; false ; fi
	$(foreach package,$(packages),make release-$(package);)

release-pds-compiled:
	@echo
	@echo Releasing pds-compiled ..
	@if [ ! -d "build/packages/pds-compiled" ] ; then echo "build/packages/pds-compiled not ready" ; false ; fi
	cd build/packages/pds-compiled && npm version $(version)
	npm publish ./build/packages/pds-compiled
	tar -cvzf ./build/packages/pds-compiled.tgz ./build/packages/pds-compiled
	hub release edit -a ./build/packages/pds-compiled.tgz -m "" $(version)

release-pds-source:

	@echo
	@echo Releasing pds-source ..
	@if [ ! -d "build/packages/pds-source" ] ; then echo "build/packages/pds-source not ready" ; false ; fi
	cd build/packages/pds-source && npm version $(version)
	npm publish ./build/packages/pds-source
	tar -cvzf ./build/packages/pds-source.tgz ./build/packages/pds-source
	hub release edit -a ./build/packages/pds-source.tgz -m "" $(version)

release-pds-demo:

	@echo
	@echo Releasing pds-demo ..
	@if [ ! -d "build/packages/pds-demo" ] ; then echo "build/packages/pds-demo not ready" ; false ; fi
	cd build/packages/pds-demo && npm version $(version)
	npm publish ./build/packages/pds-demo
	tar -cvzf ./build/packages/pds-demo.tgz ./build/packages/pds-demo
	hub release edit -a ./build/packages/pds-demo.tgz -m "" $(version)
