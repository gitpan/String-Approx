tar		=	gtar

package		=	String-Approx

version		=	1.5

pkgvrs		=	$(package)-$(version)

tararc		=	$(pkgvrs).tar

tartoc		=	MANIFEST

hello:
	@echo hello world

tar:	$(tararc)

tar.gz:	$(tararc).gz

$(tararc):	$(tartoc)
	-@mkdir -p $(pkgvrs)
	@cp -fp `cat $(tartoc)` $(pkgvrs)
	$(tar) -cpf $(tararc) $(pkgvrs)

$(tararc).gz:	$(tararc)
	gzip -9f $(tararc)

clean:
	rm -f *~ \#* core
