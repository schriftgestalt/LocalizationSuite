IBTOOL = ibtool

XIBS = $(wildcard *.xib)
OUTS = $(XIBS:.xib=.out)

%.out:	%.xib
	$(IBTOOL) --objects --classes --hierarchy $< >$@

all:	$(OUTS)
	touch ..

clean:
	rm *.out
