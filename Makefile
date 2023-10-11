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
DRYRUN ?= --dry-run
all: deploy $(ENABLE)/easy_vhosts.conf certbot $(ENABLE)/easy_ssl_vhosts.conf
deploy:
	rsync -avuz $(DRYRUN) \
	 easy_vhosts.conf \
	 easy_ssl_vhosts.conf \
	 root@easy-vhosts:$(CONF)/ || \
	echo Must alias your server IP address to easy-vhosts in /etc/hosts >&2
certbot:
	sudo $@ certonly --apache --certname $(CERTNAME) -d $(DOMAINLIST)
$(CONF)/%: %
	cat $< | sudo tee $@ > /dev/null
$(ENABLE)/%: $(CONF)/%
	cd $(@D) && sudo ln -s ../$(notdir $(CONF))/$* .
	sudo systemctl restart apache2
.PRECIOUS: $(CONF)/%
