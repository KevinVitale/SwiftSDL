.PHONY: build  run

LINKER_FLAGS = -Xlinker -L/usr/local/lib -Xlinker -lsdl2

build:
	swift build $(LINKER_FLAGS)

run:
	swift run $(LINKER_FLAGS)

