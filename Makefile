CC=          gcc
SRC=         airport-bssid/main.m
FRAMEWORKS:= -framework Foundation -framework CoreWLAN
LIB:=        -lobjc
CFLAGS=      -Wall -Werror -v
BUILD_DIR:=  Build
TARGET=      $(BUILD_DIR)/airport-bssid

$(TARGET): $(SRC) | $(BUILD_DIR)
	$(CC) -o $(OBJECTS) $@ $(CFLAGS) $(LIB) $(FRAMEWORKS) -o $(TARGET) $(SRC)

$(BUILD_DIR):
	mkdir -p $@

.m.o:
	$(CC) -c -Wall $< -o $@

all: $(TARGET)
