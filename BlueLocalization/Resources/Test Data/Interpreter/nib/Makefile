IBTOOL = ibtool

XIBS = $(wildcard *.xib)
STRINGS = $(XIBS:.xib=.strings)

%.strings:	%.xib
	$(IBTOOL) --generate-strings-file $@ $<

all:	$(STRINGS)
	touch ..

clean:
	rm *.strings
