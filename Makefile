# To build in production mode, do  "make LIBRARY_TYPE=static BUILD_MODE=prod".
# To build in development mode, do "make LIBRARY_TYPE=static BUILD_MODE=dev".

BUILD_MODE ?= dev
LIBRARY_TYPE ?= static
LALTOOLS_SET ?= all
PROCESSORS ?= 0
GPRBUILD_EXTRA ?= ""

ALL_LIBRARY_TYPES = static static-pic relocatable
ALL_BUILD_MODES = dev prod AddressSanitizer

LIB_PROJECTS = \
	src/lal_tools.gpr

BIN_PROJECTS = \
	src/build.gpr

TESTSUITE_PROJECTS ?= \
	testsuite/ada_drivers/gen_marshalling_lib/tgen_marshalling.gpr \
	testsuite/ada_drivers/indent/indent.gpr \
	testsuite/ada_drivers/outgoing_calls/outgoing_calls.gpr \
	testsuite/ada_drivers/partial_gnatpp/partial_gnatpp.gpr

ALL_PROJECTS = \
	$(BIN_PROJECTS) $(LIB_PROJECTS) $(TESTSUITE_PROJECTS)

.PHONY: all
all:
	which gprbuild
	which gcc
	for proj in $(ALL_PROJECTS) ; do \
		gprbuild -v -k \
			-XLIBRARY_TYPE=$(LIBRARY_TYPE) \
			-XXMLADA_BUILD=$(LIBRARY_TYPE) \
			-XLALTOOLS_BUILD_MODE=$(BUILD_MODE) \
			-XLALTOOLS_SET=$(LALTOOLS_SET) \
			$(GPRBUILD_EXTRA) \
			-P $$proj -p -j$(PROCESSORS) ; \
	done

.PHONY: lib
lib:
	which gprbuild
	which gcc
	for proj in $(LIB_PROJECTS) ; do \
		for kind in $(ALL_LIBRARY_TYPES) ; do \
			rm -f obj/lib/$$kind/*.lexch; \
			gprbuild -v -k \
				-XLIBRARY_TYPE=$$kind \
				-XLALTOOLS_BUILD_MODE=$(BUILD_MODE) \
				$(GPRBUILD_EXTRA) \
				-P $$proj -p -j$(PROCESSORS) ; \
		done ; \
	done

.PHONY: bin
bin:
	which gprbuild
	which gcc
	for proj in $(BIN_PROJECTS) ; do \
		gprbuild -v -k \
			-XLIBRARY_TYPE=$(LIBRARY_TYPE) \
			-XXMLADA_BUILD=$(LIBRARY_TYPE) \
			-XLALTOOLS_BUILD_MODE=$(BUILD_MODE) \
			-XLALTOOLS_SET=$(LALTOOLS_SET) \
			$(GPRBUILD_EXTRA) \
			-P $$proj -p -j$(PROCESSORS) ; \
	done

.PHONY: testsuite_drivers
testsuite_drivers:
	which gprbuild
	which gcc
	for proj in $(TESTSUITE_PROJECTS) ; do \
		gprbuild -v -k \
			-XLIBRARY_TYPE=$(LIBRARY_TYPE) \
			-XXMLADA_BUILD=$(LIBRARY_TYPE) \
			-XLALTOOLS_BUILD_MODE=$(BUILD_MODE) \
			-XLALTOOLS_SET=$(LALTOOLS_SET) \
			$(GPRBUILD_EXTRA) \
			-P $$proj -p -j$(PROCESSORS) ; \
	done

.PHONY: test
test: all
	bin/utils-var_length_ints-test
	testsuite/testsuite.py

.PHONY: clean
clean:
	for proj in $(ALL_PROJECTS) ; do \
		for build_mode in $(ALL_BUILD_MODES) ; do \
			for library_type in $(ALL_LIBRARY_TYPES) ; do \
				gprclean \
					-XLIBRARY_TYPE=$$library_type \
					-XLALTOOLS_BUILD_MODE=$$build_mode \
					-q -P $$proj; \
			done ; \
		done ; \
	done

.PHONY: install-lib
install-lib:
	for proj in $(LIB_PROJECTS) ; do \
		for kind in $(ALL_LIBRARY_TYPES) ; do \
			gprinstall \
				-XLIBRARY_TYPE=$$kind \
				-XLALTOOLS_BUILD_MODE=$(BUILD_MODE) \
				--prefix="$(DESTDIR)" \
				--sources-subdir=include/$$(basename $$proj | cut -d. -f1) \
				--build-name=$$kind \
				--build-var=LIBRARY_TYPE --build-var=LAL_TOOLS_BUILD \
				-P $$proj -p -f ; \
		done ; \
	done

.PHONY: install-bin-strip
install-bin-strip:
	mkdir -p "$(DESTDIR)"
	cp -r bin "$(DESTDIR)/"
	# Don't strip debug builds
	test "$(BUILD_MODE)" = dev || strip "$(DESTDIR)/bin/"*

.PHONY: install-tgen
install-tgen:
	mkdir -p "$(DESTDIR)/share/tgen"
	cp -r src/tgen/tgen_rts "$(DESTDIR)/share/tgen/"
	cp -r src/tgen/templates "$(DESTDIR)/share/tgen/"

