tag ?= tag

semver = $(subst ., ,$(tag))
major = $(word 1,$(semver))
minor = $(word 2,$(semver))
patch = $(word 3,$(semver))
version = $(major).$(minor).$(patch)

packages = pds pds-source pds-compiled pds-demo

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

	cp -r src/assets/* build/assets
	mkdir -p build/assets/css/
	node_modules/.bin/sass \
		--style=compressed \
		build/assets/sass/main.scss \
		build/assets/css/main.css
	node_modules/.bin/sass \
		--style=compressed \
		build/assets/sass/reset.scss \
		build/assets/css/reset.css

#	mkdir -p build/demo/css/
#	node_modules/.bin/sass \
#		--style=compressed \
#		src/demo/sass/main.scss \
#		build/demo/css/main.css

compile-html:
	@echo
	php src/demo/compile.php src/demo build/demo
	cp -r build/assets build/demo

clean: 

	rm -rf ./build/packages/*/

	rm -rf ./build/assets/*
	echo "The assets will be compiled here." >> build/assets/README.md

	rm -rf ./build/demo/*
	echo "The demo will be compiled here." >> build/demo/README.md

packages:
	rm -rf ./build/packages/*/
	$(foreach package,$(packages),make package-$(package);)

package-pds: PACKAGE_DIR = build/packages/pds
package-pds:
	@echo
	@echo Building pds ..
	mkdir -p $(PACKAGE_DIR)/assets
	cp -r build/assets/* $(PACKAGE_DIR)/assets
	rm -f $(PACKAGE_DIR)/assets/README.md
	@echo Creating package.json ..
	@cp build/packages/package.json.tpl $(PACKAGE_DIR)/package.json
	@sed -i $(SEDFIX) 's/##PACKAGE-NAME##/pds/' $(PACKAGE_DIR)/package.json

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

package-pds-compiled: PACKAGE_DIR = build/packages/pds-compiled
package-pds-compiled:
	@echo
	@echo Building pds-compiled ..
	@if [ ! -d "build/assets/css" ] ; then echo "Error: compile css first" ; false ; fi
	mkdir -p $(PACKAGE_DIR)/assets
	cp -r build/assets/css \
		build/assets/javascript \
		build/assets/images \
		build/assets/fonts \
		$(PACKAGE_DIR)/assets 
	@echo Creating package.json ..
	@cp build/packages/package.json.tpl $(PACKAGE_DIR)/package.json
	@sed -i $(SEDFIX) 's/##PACKAGE-NAME##/pds-compiled/' $(PACKAGE_DIR)/package.json

package-pds-demo: PACKAGE_DIR = build/packages/pds-demo
package-pds-demo:
	@echo
	@echo Building pds-demo ..
	@if [ ! -f "build/demo/index.html" ] ; then echo "Error: compile html first" ; false ; fi
	mkdir -p $(PACKAGE_DIR)
	cp -r build/demo $(PACKAGE_DIR)
	rm -f $(PACKAGE_DIR)/demo/README.md $(PACKAGE_DIR)/demo/assets/README.md
	@echo Creating package.json ..
	@cp build/packages/package.json.tpl $(PACKAGE_DIR)/package.json
	@sed -i $(SEDFIX) 's/##PACKAGE-NAME##/pds-demo/' $(PACKAGE_DIR)/package.json

release:
	@if test -z "$(version)"; then echo "make release requires a semantic version"; false ; fi
	$(foreach package,$(packages),make release-$(package);)

release-pds:
	@echo
	@echo Releasing pds ..
	@if [ ! -d "build/packages/pds" ] ; then echo "build/packages/pds not ready" ; false ; fi
	cd build/packages/pds && npm version $(version)
	npm publish ./build/packages/pds --access public
	tar -czf ./build/packages/pds.tgz ./build/packages/pds
	gh release upload $(version) ./build/packages/pds.tgz

release-pds-source:
	@echo
	@echo Releasing pds-source ..
	@if [ ! -d "build/packages/pds-source" ] ; then echo "build/packages/pds-source not ready" ; false ; fi
	cd build/packages/pds-source && npm version $(version)
	npm publish ./build/packages/pds-source --access public
	tar -czf ./build/packages/pds-source.tgz ./build/packages/pds-source
	gh release upload $(version) ./build/packages/pds-source.tgz

release-pds-compiled:
	@echo
	@echo Releasing pds-compiled ..
	@if [ ! -d "build/packages/pds-compiled" ] ; then echo "build/packages/pds-compiled not ready" ; false ; fi
	cd build/packages/pds-compiled && npm version $(version)
	npm publish ./build/packages/pds-compiled --access public
	tar -czf ./build/packages/pds-compiled.tgz ./build/packages/pds-compiled
	gh release upload $(version) ./build/packages/pds-compiled.tgz

release-pds-demo:
	@echo
	@echo Releasing pds-demo ..
	@if [ ! -d "build/packages/pds-demo" ] ; then echo "build/packages/pds-demo not ready" ; false ; fi
	cd build/packages/pds-demo && npm version $(version)
	npm publish ./build/packages/pds-demo --access public
	tar -czf ./build/packages/pds-demo.tgz ./build/packages/pds-demo
	gh release upload $(version) ./build/packages/pds-demo.tgz

serve:
	@echo
	@echo Starting python webserver ..
	cd build/demo && python3 -m http.server