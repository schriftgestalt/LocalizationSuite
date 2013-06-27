IBTOOL = ibtool

all:	
	$(IBTOOL) --localize-incremental --previous-file en.lproj/previous.xib --incremental-file de.lproj/incremental.xib --import-strings-file de.lproj/incremental.strings --write de.lproj/output.xib en.lproj/reference.xib

clean:
	rm de.lproj/output.xib
