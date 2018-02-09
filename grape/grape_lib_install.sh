#!/bin/bash
# ------------------------------------------------------------------------------
#
echo "[GRAPE] automatically install dependencies "


mkdir grape_tmp
export GRAPE_LIBS_PATH=`pwd grape_tmp`/grape_tmp
export GRAPE_INSTALL_PATH=${GRAPE_LIBS_PATH}/local

# create grape.conf ------------------------------------------------------------
{
	echo -e '/usr/local/lib \n /usr/lib/grape \n /usr/local/folly ' > /etc/ld.so.conf.d/grape.conf
	ldconfig
}

# install deps boost -----------------------------------------------------------
{
  echo "[GRAPE] begin to install dependency boost."
	cd ${GRAPE_LIBS_PATH}
	export BOOST_VERSION=1.63.0
	export BOOST_FOLDER="boost_${BOOST_VERSION//./_}"
	wget -q http://sourceforge.net/projects/boost/files/boost/${BOOST_VERSION}/${BOOST_FOLDER}.tar.bz2 --output-document=boost.tar.bz2
  mkdir ${BOOST_FOLDER}
  tar jxf boost.tar.bz2 --strip-components=1 -C ${BOOST_FOLDER}
  (cd ${BOOST_FOLDER}; ./bootstrap.sh)
  (cd ${BOOST_FOLDER}; echo "using mpi ;" >> project-config.jam)
  (cd ${BOOST_FOLDER}; ./b2 --prefix=/usr/local install)
  cd ${GRAPE_LIBS_PATH}
  sudo rm -r ${BOOST_FOLDER}
  sudo rm boost.tar.bz2
  echo "[GRAPE] installed dependency boost."
}

# install deps gtest -----------------------------------------------------------
{
	echo "[GRAPE] begin to install dependency gtest."
	cd ${GRAPE_LIBS_PATH}
	export GTEST_VERSION=1.7.0
	wget -q https://github.com/google/googletest/archive/release-${GTEST_VERSION}.tar.gz --output-document=gtest.tar.gz
	tar xf gtest.tar.gz
	cd googletest-release-${GTEST_VERSION}
	cmake -DBUILD_SHARED_LIBS=ON .
	make
	cp -a include/gtest /usr/local/include
	cp -a libgtest.* /usr/local/lib
	cp -a libgtest_main.* /usr/local/lib
  cd ${GRAPE_LIBS_PATH}
  rm gtest.tar.gz
	rm -r googletest-release-${GTEST_VERSION}
  echo "[GRAPE] installed dependency gtest."
}

# install dep double-conversion  -----------------------------------------------
{
	echo "[GRAPE] begin to install dependency double-conversion."
	cd ${GRAPE_LIBS_PATH}
	git clone --depth=1 https://github.com/yecol/double-conversion.git
	cd double-conversion
	cmake .
	make && sudo make install
	cd ${GRAPE_LIBS_PATH}
	sudo rm -r double-conversion
	echo "[GRAPE] installed dependency double-conversion."
}

# install deps tcmalloc --------------------------------------------------------
{
  echo "[GRAPE] begin to install dependency gperftools."
	cd ${GRAPE_LIBS_PATH}
	git clone --depth=1 https://github.com/yecol/gperftools.git
	cd gperftools
	./autogen.sh
	./configure
	make && sudo make install
	cd ${GRAPE_LIBS_PATH}
	sudo rm -r gperftools
  echo "[GRAPE] installed dependency gperftools."
}

# install deps folly -----------------------------------------------------------
{
  echo "[GRAPE] begin to install dependency folly."
	cd ${GRAPE_LIBS_PATH}
	git clone https://github.com/facebook/folly.git --depth=1
  cd folly/folly
  autoreconf -ivf && ./configure --prefix=/usr/local
  make -j8 && make install
  cd ${GRAPE_LIBS_PATH}
  sudo rm -r folly
  echo "[GRAPE] installed dependency folly."
}

# install deps aws -------------------------------------------------------------
{
  echo "[GRAPE] begin to install dependency aws."
	cd ${GRAPE_LIBS_PATH}
	git clone https://github.com/aws/aws-sdk-cpp.git --depth=1
  cd aws-sdk-cpp
  mkdir build && cd build
  cmake -DBUILD_ONLY=s3 -DCMAKE_INSTALL_PREFIX=/usr/local ..
  make -j8 && sudo make install
  cd ${GRAPE_LIBS_PATH}
  sudo rm -r aws-sdk-cpp
  echo "[GRAPE] installed dependency aws."
}

rm -r ${GRAPE_LIBS_PATH}
echo "[GRAPE] automatically install finished "
echo
echo -e "\033[33m To sure remove openmpi, please run the command: \033[0m"
echo -e "\033[33m sudo apt-get purge libopenmpi-dev openmpi-common \033[0m"
