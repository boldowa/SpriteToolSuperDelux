g++.exe -static -static-libgcc -static-libstdc++ -o "pixi.exe" -Wall --std=c++11 -Wno-format src/*.cpp src/asar/asardll.c src/json/base64.cpp
@pause