DIRECTORY_ROOTS := $(wildcard /var/www/*.*)
NULLSTR :=
SPACE := $(NULLSTR) $(NULLSTR)
COMMA := ,
DOMAINLIST := $(subst $(SPACE),$(COMMA),$(notdir $(DIRECTORY_ROOTS)))
CERTNAME := $(shell basename $$(readlink /var/www/default))
certbot: /var/www/$(CERTNAME)/index.html
	sudo $@ certonly --apache --certname $(CERTNAME) -d $(DOMAINLIST)
