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
	ssh root@vhosts $@ certonly \
	 --apache \
	 --certname $(CERTNAME) \
	 -d $(DOMAINLIST)
$(CONF)/%: %
	rsync -avuz $* root@easy-vhosts:$(CONF)/
$(ENABLE)/%: $(CONF)/%
	ssh root@easy-vhosts cd $(@D) && sudo ln -s ../$(notdir $(CONF))/$* .
	ssh root@easy-vhosts sudo systemctl restart apache2
.PRECIOUS: $(CONF)/%
