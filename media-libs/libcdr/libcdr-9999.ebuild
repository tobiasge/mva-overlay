# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGIT_REPO_URI="git://anongit.freedesktop.org/git/libreoffice/libcdr/"
inherit eutils ltprune
[[ ${PV} == 9999 ]] && inherit autotools git-r3

DESCRIPTION="Library parsing the Corel cdr documents"
HOMEPAGE="https://www.freedesktop.org/wiki/Software/libcdr"
[[ ${PV} == 9999 ]] || SRC_URI="http://dev-www.libreoffice.org/src/${P}.tar.xz"

LICENSE="MPL-2.0"
SLOT="0"
[[ ${PV} == 9999 ]] || KEYWORDS="~amd64 ~arm ~ppc ~hppa ~ppc64 ~x86"
IUSE="doc static-libs"

RDEPEND="
	dev-libs/icu:=
	media-libs/lcms:2
	sys-libs/zlib
	dev-libs/librevenge
"
DEPEND="${RDEPEND}
	dev-libs/boost
	sys-devel/libtool
	virtual/pkgconfig
	doc? ( app-doc/doxygen )
"

src_prepare() {
	default
	[[ -d m4 ]] || mkdir "m4"
	[[ ${PV} == 9999 ]] && eautoreconf
}

src_configure() {
	econf \
		--docdir="${EPREFIX}/usr/share/doc/${PF}" \
		$(use_enable static-libs static) \
		--disable-werror \
		$(use_with doc docs)
}

src_install() {
	default
	prune_libtool_files --all
}
