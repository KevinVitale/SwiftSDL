.PHONY: build clean run 

LINKER_FLAGS = -Xlinker -L/usr/local/lib -Xlinker -lsdl2

build:
	swift build $(LINKER_FLAGS)

clean:
	swift package clean
	rm -fr .build

run:
	swift run $(LINKER_FLAGS)

