DIRECTORY_ROOTS := $(wildcard /var/www/*.*)
NULLSTR :=
SPACE := $(NULLSTR) $(NULLSTR)
COMMA := ,
DOMAINLIST := $(notdir $(DIRECTORY_ROOTS))
DOMAINLIST += $(addprefix www.,$(DOMAINLIST))
DOMAINLIST := $(subst $(SPACE),$(COMMA),$(DOMAINLIST))
CERTNAME := certbot_cert
certbot:
	sudo $@ certonly --apache --certname $(CERTNAME) -d $(DOMAINLIST)
