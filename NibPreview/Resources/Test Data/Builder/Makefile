IBTOOL = ibtool

XIBS = $(wildcard */*.xib)
OUTS = $(XIBS:.xib=.out)
NIBS = $(XIBS:.xib=.nib)

%.out:	%.xib
	$(IBTOOL) --objects --classes --hierarchy $< >$@
%.nib:	%.xib
	$(IBTOOL) --compile $@ $<

all:	$(OUTS) $(NIBS)
	touch ..

clean:
	rm */*.out
	rm */*.nib
