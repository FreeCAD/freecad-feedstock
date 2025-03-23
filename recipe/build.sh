mkdir -p build
cd build

if [[ ${FEATURE_DEBUG} = 1 ]]; then
      BUILD_TYPE="Debug"
      DEV_TESTS="ON"
      echo "#! building debug package !#"
else
      BUILD_TYPE="Release"
      DEV_TESTS="OFF"
fi

declare -a CMAKE_PLATFORM_FLAGS

if [[ ${HOST} =~ .*linux.* ]]; then
  echo "adding hacks for linux"
  CMAKE_PLATFORM_FLAGS+=(-DCMAKE_TOOLCHAIN_FILE="${RECIPE_DIR}/cross-linux.cmake")
fi


if [[ ${HOST} =~ .*darwin.* ]]; then
  # add hacks for osx here!
  echo "adding hacks for osx"
  
  # install space-mouse
  /usr/bin/curl -o /tmp/3dFW.dmg -L 'https://download.3dconnexion.com/drivers/mac/10-7-0_B564CC6A-6E81-42b0-82EC-418EA823B81A/3DxWareMac_v10-7-0_r3411.dmg'
  hdiutil attach -readonly /tmp/3dFW.dmg
  sudo installer -package /Volumes/3Dconnexion\ Software/Install\ 3Dconnexion\ software.pkg -target /
  diskutil eject /Volumes/3Dconnexion\ Software
  CMAKE_PLATFORM_FLAGS+=(-DFREECAD_3DCONNEXION_SUPPORT=Both)
  CMAKE_PLATFORM_FLAGS+=(-D3DCONNEXIONCLIENT_FRAMEWORK:FILEPATH="/Library/Frameworks/3DconnexionClient.framework")

  CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

cmake -G "Ninja" \
      -D BUILD_WITH_CONDA:BOOL=ON \
      -D CMAKE_BUILD_TYPE=${BUILD_TYPE} \
      -D CMAKE_INSTALL_PREFIX:FILEPATH="$PREFIX" \
      -D CMAKE_PREFIX_PATH:FILEPATH="$PREFIX" \
      -D CMAKE_LIBRARY_PATH:FILEPATH="$PREFIX/lib" \
      -D CMAKE_INSTALL_LIBDIR:FILEPATH="$PREFIX/lib" \
      -D CMAKE_INCLUDE_PATH:FILEPATH="$PREFIX/include" \
      -D FREECAD_USE_OCC_VARIANT="Official Version" \
      -D OCC_INCLUDE_DIR:FILEPATH="$PREFIX/include" \
      -D SMESH_INCLUDE_DIR:FILEPATH="$PREFIX/include/smesh" \
      -D FREECAD_USE_EXTERNAL_SMESH=ON \
      -D FREECAD_USE_EXTERNAL_FMT:BOOL=OFF \
      -D BUILD_FLAT_MESH:BOOL=ON \
      -D BUILD_WITH_CONDA:BOOL=ON \
      -D Python_EXECUTABLE:FILEPATH="$PYTHON" \
      -D Python3_EXECUTABLE:FILEPATH="$PYTHON" \
      -D BUILD_FEM_NETGEN:BOOL=ON \
      -D OCCT_CMAKE_FALLBACK:BOOL=OFF \
      -D FREECAD_USE_QT_DIALOG:BOOL=ON \
      -D BUILD_DYNAMIC_LINK_PYTHON:BOOL=OFF \
      -D FREECAD_USE_PCL:BOOL=ON \
      -D FREECAD_USE_PCH:BOOL=OFF \
      -D INSTALL_TO_SITEPACKAGES:BOOL=ON \
      -D ENABLE_DEVELOPER_TESTS:BOOL="${DEV_TESTS}" \
      -D QT_HOST_PATH="${PREFIX}" \
      ${CMAKE_PLATFORM_FLAGS[@]} \
      ..

ninja install
mv ${PREFIX}/bin/FreeCAD ${PREFIX}/bin/freecad
mv ${PREFIX}/bin/FreeCADCmd ${PREFIX}/bin/freecadcmd
