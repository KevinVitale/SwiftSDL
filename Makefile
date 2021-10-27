.PHONY: build clean run 

LINKER_FLAGS = -Xlinker -L/opt/homebrew/lib -Xlinker -lsdl2 -Xlinker -lsdl2_image
ARCH = $(shell uname -m)

build:
	swift build $(LINKER_FLAGS)
	cp Sources/DemoSDL2/Resources/*.png .build/$(ARCH)-apple-macosx/debug

clean:
	swift package clean
	rm -fr .build

run:
	swift run DemoSDL2 $(LINKER_FLAGS)
