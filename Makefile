DIRECTORY_ROOTS := $(wildcard /var/www/*.*)
CONF := /etc/apache2/conf-available
ENABLE := $(CONF:-available=-enabled)
NULLSTR :=
SPACE := $(NULLSTR) $(NULLSTR)
COMMA := ,
DOMAINLIST := $(notdir $(DIRECTORY_ROOTS))
DOMAINLIST += $(addprefix www.,$(DOMAINLIST))
DOMAINLIST := $(subst $(SPACE),$(COMMA),$(DOMAINLIST))
CERTNAME := certbot_cert
all: $(ENABLE)/easy_vhosts.conf certbot $(ENABLE)/easy_ssl_vhosts.conf
certbot:
	# first remove ssl conf
	sudo rm -f $(ENABLE)/easy_ssl_vhosts.conf
	sudo $@ certonly --apache --cert-name $(CERTNAME) -d $(DOMAINLIST)
$(CONF)/%: %
	cat $< | sudo tee $@ > /dev/null
$(ENABLE)/%: $(CONF)/%
	cd $(@D) && sudo ln -s ../$(notdir $(CONF))/$* .
	sudo systemctl restart apache2
.PRECIOUS: $(CONF)/%
