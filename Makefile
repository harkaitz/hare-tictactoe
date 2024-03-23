.POSIX:
.SUFFIXES:
PROJECT=hare-tictactoe
VERSION=1.0.0
HAREDOC = haredoc
HARE = hare
PROGS = ttt 
PREFIX=/usr/local
SRCDIR = $(PREFIX)/src
HARESRCDIR = $(SRCDIR)/hare
THIRDPARTYDIR = $(HARESRCDIR)/third-party
SOURCES=$(shell find cmd games -name '*.ha')

all: $(PROGS)
install:
	install -D -t $(DESTDIR)$(PREFIX)/bin $(PROGS)
clean:
	rm -f $(PROGS)
## -- BLOCK:hare --
ttt: $(SOURCES)
	$(HARE) build -o $@ ./cmd/ttt
## -- BLOCK:hare --
