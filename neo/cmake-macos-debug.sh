cd ..
rm -rf build
mkdir build
cd build
cmake -G "Xcode" -DCMAKE_BUILD_TYPE=Debug -DSDL2=ON ../neo
