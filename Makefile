.PHONY: build clean run 

LINKER_FLAGS = -Xlinker -L/usr/local/lib -Xlinker -lsdl2

build:
	swift build $(LINKER_FLAGS)
	cp Sources/DemoSDL2/*.png .build/x86_64-apple-macosx/debug

clean:
	swift package clean
	rm -fr .build

run:
	swift run $(LINKER_FLAGS)

