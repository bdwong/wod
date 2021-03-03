# Environment variables

SCRIPTS=wod
LIB_SCRIPTS=functions wod-create wod-down wod-help wod-ls wod-restore wod-rm wod-up wod-wp wp
TEMPLATES=default no-mcrypt

BINDIR=/usr/bin
LIBDIR=/usr/lib/wod
LIB_SCRIPTS_DIR=$(LIBDIR)/bin
LIB_TEMPLATE_DIR=$(LIBDIR)/template
SRC_TEMPLATE_DIR=./template
SRCDIR_TEMPLATES=$(addprefix $(SRC_TEMPLATE_DIR)/,$(TEMPLATES))
SRCDIR_SCRIPTS=$(addprefix bin/,$(SCRIPTS))
SRCDIR_LIBS=$(addprefix lib/,$(LIB_SCRIPTS))
BINDIR_SCRIPTS=$(addprefix $(BINDIR)/,$(SCRIPTS))
LIBDIR_SCRIPTS=$(addprefix $(LIB_SCRIPTS_DIR)/,$(LIB_SCRIPTS))

default :
	@echo "Run make install to install wod."

install : bin templates lib

bin : $(BINDIR_SCRIPTS)

$(BINDIR_SCRIPTS) : $(SRCDIR_SCRIPTS)
	install $(SRCDIR_SCRIPTS) $(BINDIR)

lib: $(SRCDIR_LIBS)
	mkdir -p $(LIB_SCRIPTS_DIR) && install $(SRCDIR_LIBS) $(LIB_SCRIPTS_DIR)

templates : $(SRCDIR_TEMPLATES)
	for each in $(TEMPLATES); do (cd $(SRC_TEMPLATE_DIR) && find $$each -type f -exec install -Dm 644 "{}" "$(LIB_TEMPLATE_DIR)/{}" \;); done

.PHONY : uninstall
uninstall :
	rm -f $(BINDIR_SCRIPTS)
	rm -rf $(LIBDIR)
