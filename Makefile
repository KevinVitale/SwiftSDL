SDL_REPO_URL="https://github.com/libsdl-org/SDL.git"
SDL_REF=release-3.2.0
SDL_DIR=Dependencies/SDL3
SDL_BUILD_DIR=${SDL_DIR}/build/Release

.PHONY: clone-sdl
clone-sdl:
	-rm -rdf ${SDL_DIR}
	-mkdir -p ${SDL_DIR}
	git clone ${SDL_REPO_URL} ${SDL_DIR} --recursive --depth=1 --branch ${SDL_REF}

.PHONY: build-sdl-macOS
build-sdl-macOS:
	-mkdir -p ${SDL_BUILD_DIR}
	cmake -B${SDL_BUILD_DIR}/macOS -S${SDL_DIR} -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_SYSTEM_NAME=Darwin -DCMAKE_OSX_ARCHITECTURES="x86_64;arm64" -DCMAKE_OSX_DEPLOYMENT_TARGET=10.11 -DSDL_STATIC=ON -DSDL_FRAMEWORK=ON 
	cmake --build ${SDL_BUILD_DIR}/macOS

.PHONY: build-sdl-iphoneos
build-sdl-iphoneos:
	-mkdir -p ${SDL_BUILD_DIR}
	cmake -B${SDL_BUILD_DIR}/iphoneos -S${SDL_DIR} -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_SYSTEM_NAME=iOS -DCMAKE_OSX_SYSROOT=iphoneos -DCMAKE_OSX_ARCHITECTURES=arm64 -DCMAKE_OSX_DEPLOYMENT_TARGET=9.0 -DSDL_STATIC=ON -DSDL_FRAMEWORK=ON
	cmake --build ${SDL_BUILD_DIR}/iphoneos

.PHONY: build-sdl-iphonesimulator
build-sdl-iphonesimulator:
	-mkdir -p ${SDL_BUILD_DIR}
	cmake -B${SDL_BUILD_DIR}/iphonesimulator -S${SDL_DIR} -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_SYSTEM_NAME=iOS -DCMAKE_OSX_SYSROOT=iphonesimulator -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" -DCMAKE_OSX_DEPLOYMENT_TARGET=9.0 -DSDL_STATIC=ON -DSDL_FRAMEWORK=ON
	cmake --build ${SDL_BUILD_DIR}/iphonesimulator

.PHONY: build-sdl-appletvos
build-sdl-appletvos:
	-mkdir -p ${SDL_BUILD_DIR}
	cmake -B${SDL_BUILD_DIR}/appletvos -S${SDL_DIR} -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_SYSTEM_NAME=tvOS -DCMAKE_OSX_SYSROOT=appletvos -DCMAKE_OSX_ARCHITECTURES=arm64 -DCMAKE_OSX_DEPLOYMENT_TARGET=9.0 -DSDL_STATIC=ON -DSDL_FRAMEWORK=ON
	cmake --build ${SDL_BUILD_DIR}/appletvos

.PHONY: build-sdl-appletvsimulator
build-sdl-appletvsimulator:
	-mkdir -p ${SDL_BUILD_DIR}
	cmake -B${SDL_BUILD_DIR}/appletvsimulator -S${SDL_DIR} -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_SYSTEM_NAME=tvOS -DCMAKE_OSX_SYSROOT=appletvsimulator -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" -DCMAKE_OSX_DEPLOYMENT_TARGET=9.0 -DSDL_STATIC=ON -DSDL_FRAMEWORK=ON
	cmake --build ${SDL_BUILD_DIR}/appletvsimulator

.PHONY: build-sdl-frameworks
build-sdl-frameworks: clone-sdl build-sdl-macOS build-sdl-iphoneos build-sdl-iphonesimulator build-sdl-appletvos build-sdl-appletvsimulator

.PHONY: build-sdl-xcframework
build-sdl-xcframework: build-sdl-frameworks
	-rm -rdf "${SDL_BUILD_DIR}/SDL3.xcframework"

	xcodebuild -create-xcframework \
		-framework "${SDL_BUILD_DIR}/macOS/SDL3.framework" \
		-framework "${SDL_BUILD_DIR}/iphoneos/SDL3.framework" \
		-framework "${SDL_BUILD_DIR}/iphonesimulator/SDL3.framework" \
		-framework "${SDL_BUILD_DIR}/appletvos/SDL3.framework" \
		-framework "${SDL_BUILD_DIR}/appletvsimulator/SDL3.framework" \
		-output ${SDL_BUILD_DIR}/SDL3.xcframework

		# -library "${SDL_BUILD_DIR}/iphoneos-arm64/libSDL3.a" -headers ${SDL_DIR}/include/SDL3 \
		-library "${SDL_BUILD_DIR}/iphonesimulator-arm64-x86_64/libSDL3.a" -headers ${SDL_DIR}/include/SDL3 \
		-library "${SDL_BUILD_DIR}/appletvos-arm64/libSDL3.a" -headers ${SDL_DIR}/include/SDL3 \
		-library "${SDL_BUILD_DIR}/appletvsimulator-arm64-x86_64/libSDL3.a" -headers ${SDL_DIR}/include/SDL3 \
		-output ${SDL_BUILD_DIR}/SDL3.xcframework

		zip -rq ${SDL_BUILD_DIR}/SDL3.xcframework.zip ${SDL_BUILD_DIR}/SDL3.xcframework

# REFERENCES:
# Adopted from: https://github.com/ctreffs/swift-sdl/blob/main/Makefile
# CMAKE commands: https://github.com/libsdl-org/SDL/blob/main/docs/README-cmake.md#frameworks
# Apple docs: https://developer.apple.com/documentation/xcode/creating-a-multi-platform-binary-framework-bundle#Avoid-issues-when-using-alternate-build-systems

