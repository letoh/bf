all: bf

bf: bf.o

go:
	$(MAKE) -f Makefile.go

clean:
	rm -f bf bf.o
	$(MAKE) -f Makefile.go clean

