SVN_SCRIPTS=	/usr/local/libexec/subversion
DESTDIR=	/usr/local/sbin

SUDO=		sudo

all:
	for f in *.pl; do perl -c $$f; done

install:
	$(SUDO) install -d $(SVN_SCRIPTS)
	$(SUDO) install -m 555 svn-checkzone.pl $(SVN_SCRIPTS)/svn-checkzone
	$(SUDO) install -m 555 svn-installzone.pl $(SVN_SCRIPTS)/svn-installzone
	$(SUDO) install -d $(DESTDIR)
	$(SUDO) install -m 544 dns-janitor.sh $(DESTDIR)/dns-janitor
	$(SUDO) install -m 544 dns-installzone.pl $(DESTDIR)/dns-installzone
	$(SUDO) install -m 544 dns-buildconf.pl $(DESTDIR)/dns-buildconf
	$(SUDO) install -m 544 dns-buildsec.pl $(DESTDIR)/dns-buildsec
