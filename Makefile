.PHONY: mac mac-install solar2d clean

mac:
	@mkdir -p build && cd build && cmake .. && make -j4

solar2d:
	@mkdir -p build-solar2d && cd build-solar2d && cmake .. -DSOLAR2D_PLUGIN=ON && make -j4

mac-install: solar2d
	@mkdir -p "$(HOME)/Library/Application Support/Corona/Simulator/Plugins"
	@cp build-solar2d/plugin_yoga.dylib "$(HOME)/Library/Application Support/Corona/Simulator/Plugins/"
	@echo "Installed plugin_yoga.dylib to Corona Simulator plugins"

clean:
	@rm -rf build build-solar2d
