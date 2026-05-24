# Compiler settings
CXX = g++
CXXFLAGS = -Wall -Wextra -std=c++17
LDFLAGS = -lsqlite3

# Files and output
TARGET = app
SRCS = main.cpp DatabaseHandler.cpp
OBJS = $(SRCS:.cpp=.o)
DB_DIR = DatabaseFolder

# Default target
all: $(DB_DIR) $(TARGET)

# Ensure the database subfolder exists before running
$(DB_DIR):
	mkdir -p $(DB_DIR)

# Link the executable
$(TARGET): $(OBJS)
	$(CXX) $(CXXFLAGS) -o $(TARGET) $(OBJS) $(LDFLAGS)

# Compile object files
%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

# Clean compiled files
clean:
	rm -f $(OBJS) $(TARGET)

# Compile and run immediately
run: all
	./$(TARGET)