SHAREDLIB = libriffmantle

UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
	SHAREDLIBPATH = /usr/lib
endif
ifeq ($(UNAME_S),Darwin)
	SHAREDLIBPATH = /usr/local/lib
endif

all:
ifeq ($(UNAME_S),Linux)
	@sudo cp $(SHAREDLIB).so $(SHAREDLIBPATH)
endif
ifeq ($(UNAME_S),Darwin)
	@cp $(SHAREDLIB).so $(SHAREDLIBPATH)
endif
	@git init
	@git add .
	@git commit -m "Package setup"
	@git tag 1.0.0

clean:
	@-rm -f $(SHAREDLIB).so $(SHAREDLIB).h
	@-rm -fr .git

mrproper:
ifeq ($(UNAME_S),Linux)
	@-sudo rm -f $(SHAREDLIBPATH)/$(SHAREDLIB).so
endif
ifeq ($(UNAME_S),Darwin)
	@-rm -f $(SHAREDLIBPATH)/$(SHAREDLIB).so
endif
