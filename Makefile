# Environment variables

SCRIPTS=wodd wp wp-restore
TEMPLATES=default

BINDIR=/usr/bin
LIBDIR=/usr/lib/wodd
LIB_TEMPLATE_DIR=$(LIBDIR)/template
SRC_TEMPLATE_DIR=./template
SRCDIR_TEMPLATES=$(addprefix $(SRC_TEMPLATE_DIR)/,$(TEMPLATES))
SRCDIR_SCRIPTS=$(addprefix bin/,$(SCRIPTS))
BINDIR_SCRIPTS=$(addprefix $(BINDIR)/,$(SCRIPTS))

default :
	@echo "Run make install to install wodd."

install : bin templates

bin : $(SRCDIR_SCRIPTS)
	install $(SRCDIR_SCRIPTS) $(BINDIR)

templates : $(SRCDIR_TEMPLATES)
	for each in $(TEMPLATES); do (cd $(SRC_TEMPLATE_DIR) && find $$each -type f -exec install -Dm 644 "{}" "$(LIB_TEMPLATE_DIR)/{}" \;); done

.PHONY : uninstall
uninstall :
	rm -f $(BINDIR_SCRIPTS)
	rm -rf $(LIBDIR)
