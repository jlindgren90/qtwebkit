# Maintainer: John Lindgren <john@jlindgren.net>
# Maintainer: Fabio 'Lolix' Loli <fabio.loli@disroot.org>
# Contributor: Zen Wen <zen.8841@gmail.com>
# Contributor: Felix Yan <felixonmars@archlinux.org>
# Contributor: Antonio Rojas <arojas@archlinux.org>
# Contributor: Andrea Scarpino <andrea@archlinux.org>

pkgname=qt5-webkit-jlindgren
provides=(qt5-webkit)
conflicts=(qt5-webkit)
pkgver=5.212.0alpha4
pkgrel=1
arch=(x86_64)
url="https://github.com/jlindgren90/qtwebkit/"
license=(LGPL2.1)
pkgdesc="Classes for a WebKit2 based implementation and a new QML API"
depends=(qt5-location qt5-sensors qt5-webchannel libwebp libxcomposite gst-plugins-base hyphen woff2
         glibc gcc-libs glib2 zlib libx11 sqlite gst-plugins-base-libs libjpeg-turbo icu libpng gstreamer libxml2
         qt5-base qt5-declarative libxslt)
depends+=(libicuuc.so libicui18n.so)
makedepends=(cmake ruby gperf python qt5-doc qt5-tools)
optdepends=('gst-plugins-good: Webm codec support')
options=(!lto)

build() {
  cmake -B build -S .. -Wno-dev \
    -DCMAKE_BUILD_TYPE=None \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_CXX_FLAGS="${CXXFLAGS} -DNDEBUG" \
    -DPORT=Qt \
    -DUSE_LD_GOLD=OFF \
    -DENABLE_TOOLS=OFF
  # --parallel 4 limits RAM usage
  cmake --build build --parallel 4
}

package() {
  DESTDIR="${pkgdir}" cmake --install build
}
