CSC ?= csc

.PHONY: all core full clean

all: mucha-core mucha mucha-full

core: mucha-core
full: mucha-full

mucha-core: mucha-core.scm src/core.scm
	$(CSC) mucha-core.scm -o mucha-core

mucha: mucha.scm src/core.scm src/extra.scm
	$(CSC) mucha.scm -o mucha

mucha-full: mucha-full.scm src/core.scm src/extra.scm src/raw.scm
	$(CSC) mucha-full.scm -o mucha-full

clean:
	rm -f *.o *.c mucha-core mucha mucha-full
