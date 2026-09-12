DIRECTORY_ROOTS := $(foreach root,\
 $(wildcard /var/www/*.*),\
 $(shell readlink -f $(root)))
CONF := /etc/apache2/conf-available
ENABLE := $(CONF:-available=-enabled)
NULLSTR :=
SPACE := $(NULLSTR) $(NULLSTR)
COMMA := ,
DOMAINLIST := $(notdir $(DIRECTORY_ROOTS))
DOMAINLIST += $(filter-out $(EXCEPTIONS),$(addprefix www.,$(DOMAINLIST)))
DOMAINLIST := $(subst $(SPACE),$(COMMA),$(DOMAINLIST))
CERTNAME := certbot_cert
ifneq ($(SHOWENV),)
export
endif
all: $(ENABLE)/easy_vhosts.conf certbot $(ENABLE)/easy_ssl_vhosts.conf
certbot:
	# make sure mod_vhost_alias and ssl are enabled
	# (should not error if they already are)
	sudo a2enmod vhost_alias ssl
	sudo systemctl restart apache2
	# remove ssl conf
	sudo rm -f $(ENABLE)/easy_ssl_vhosts.conf
	sudo $@ certonly --apache --cert-name $(CERTNAME) -d $(DOMAINLIST)
$(CONF)/%: %
	cat $< | sudo tee $@ > /dev/null
$(ENABLE)/%: $(CONF)/%
	cd $(@D) && sudo ln -sf ../$(notdir $(CONF))/$* .
	sudo systemctl restart apache2
mailman3:
	sudo cp mailman3.conf /etc/apache2/conf-enabled/
	a2enmod proxy proxy_uwsgi
	systemctl restart apache2
env:
ifneq ($(SHOWENV),)
	$@
else
	$(MAKE) SHOWENV=1 $@
endif
.PRECIOUS: $(CONF)/%
