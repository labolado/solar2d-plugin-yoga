.PHONY: mac mac-install solar2d android clean

ANDROID_HOME ?= $(HOME)/Library/Android/sdk
ANDROID_NDK ?= $(shell ls -d $(ANDROID_HOME)/ndk/*/ 2>/dev/null | sort -V | tail -1)
CORONA_NATIVE ?= $(HOME)/Library/Application Support/Corona/NativePE
CORONA_LUA_SO ?= /tmp/corona-libs/jni/arm64-v8a/liblua.so

mac:
	@mkdir -p build && cd build && cmake .. && make -j4

solar2d:
	@mkdir -p build-solar2d && cd build-solar2d && cmake .. -DSOLAR2D_PLUGIN=ON && make -j4

android:
	@# Extract liblua.so from Corona.aar if not already done
	@if [ ! -f "$(CORONA_LUA_SO)" ]; then \
		mkdir -p /tmp/corona-libs && \
		cd /tmp/corona-libs && \
		unzip -o "$(CORONA_NATIVE)/Corona/android/lib/gradle/Corona.aar" "jni/arm64-v8a/liblua.so"; \
	fi
	@mkdir -p build-android-arm64 && cd build-android-arm64 && cmake .. \
		-DCMAKE_TOOLCHAIN_FILE=$(ANDROID_NDK)/build/cmake/android.toolchain.cmake \
		-DANDROID_ABI=arm64-v8a \
		-DANDROID_PLATFORM=android-21 \
		-DANDROID_ALLOW_UNDEFINED_SYMBOLS=TRUE \
		-DSOLAR2D_PLUGIN=ON \
		-DLUA_INCLUDE_DIR="$(CORONA_NATIVE)/Corona/shared/include/lua" \
		-DLUA_LIBRARIES="$(CORONA_LUA_SO)" \
		&& make -j4
	@echo "Built build-android-arm64/libplugin.yoga.so"

mac-install: solar2d
	@mkdir -p "$(HOME)/Library/Application Support/Corona/Simulator/Plugins"
	@cp build-solar2d/plugin_yoga.dylib "$(HOME)/Library/Application Support/Corona/Simulator/Plugins/"
	@echo "Installed plugin_yoga.dylib to Corona Simulator plugins"

clean:
	@rm -rf build build-solar2d build-android-arm64
