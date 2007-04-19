BUSYBOX_MAKE_DIR:=$(TOOLS_DIR)/make
BUSYBOX_TOOLS_DIR:=$(SOURCE_DIR)/busybox-host

BUSYBOX_TOOLS_CONFIG_FILE:=$(BUSYBOX_MAKE_DIR)/Config.busybox
BUSYBOX_VERSION:=1.4.1
BUSYBOX_SOURCE:=busybox-$(BUSYBOX_VERSION).tar.bz2
BUSYBOX_SITE:=http://www.busybox.net/downloads
BUSYBOX_HOST_DIR:=busybox
BUSYBOX_HOST_BINARY:=busybox

# Activate on demand to avoid collision with identical target for regular
# busybox package
ifneq ($(strip $(DS_HAVE_DOT_CONFIG)),y)
$(DL_DIR)/$(BUSYBOX_SOURCE): $(DL_DIR)
	wget -P $(DL_DIR) $(BUSYBOX_SITE)/$(BUSYBOX_SOURCE)
endif

$(BUSYBOX_TOOLS_DIR)/.unpacked: $(DL_DIR)/$(BUSYBOX_SOURCE)
	mkdir -p $(BUSYBOX_TOOLS_DIR)
	tar -C $(BUSYBOX_TOOLS_DIR) $(VERBOSE) -xjf $(DL_DIR)/$(BUSYBOX_SOURCE)
	for i in $(BUSYBOX_MAKE_DIR)/patches/*.patch; do \
		patch -d $(BUSYBOX_TOOLS_DIR)/busybox-$(BUSYBOX_VERSION) -p0 < $$i; \
	done
	touch $@

$(BUSYBOX_TOOLS_DIR)/.configured: $(BUSYBOX_TOOLS_DIR)/.unpacked $(BUSYBOX_TOOLS_CONFIG_FILE)
	cp $(BUSYBOX_TOOLS_CONFIG_FILE) $(BUSYBOX_TOOLS_DIR)/busybox-$(BUSYBOX_VERSION)/.config
	$(MAKE) -C $(BUSYBOX_TOOLS_DIR)/busybox-$(BUSYBOX_VERSION) oldconfig
	touch $@

$(BUSYBOX_TOOLS_DIR)/busybox-$(BUSYBOX_VERSION)/busybox: $(BUSYBOX_TOOLS_DIR)/.configured
	$(MAKE) -C $(BUSYBOX_TOOLS_DIR)/busybox-$(BUSYBOX_VERSION) 

$(TOOLS_DIR)/busybox: $(BUSYBOX_TOOLS_DIR)/busybox-$(BUSYBOX_VERSION)/busybox
	cp $(BUSYBOX_TOOLS_DIR)/busybox-$(BUSYBOX_VERSION)/$(BUSYBOX_HOST_BINARY) $(TOOLS_DIR)/$(BUSYBOX_HOST_BINARY)
	@ln -s busybox $(TOOLS_DIR)/makedevs

busybox-tools: $(TOOLS_DIR)/busybox

busybox-tools-clean:
	-$(MAKE) -C $(BUSYBOX_TOOLS_DIR)/busybox-$(BUSYBOX_VERSION) clean
	rm -f $(TOOLS_DIR)/busybox
	rm -f $(TOOLS_DIR)/makedevs

busybox-tools-dirclean:
	rm -rf $(BUSYBOX_TOOLS_DIR)
	rm -f $(TOOLS_DIR)/busybox
	rm -f $(TOOLS_DIR)/makedevs
