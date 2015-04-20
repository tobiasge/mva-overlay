# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/i2pd/i2pd-9999.ebuild,v 1.2 2015/02/02 17:06:04 mgorny Exp $

EAPI=5
inherit eutils systemd user git-r3 cmake-multilib

DESCRIPTION="A C++ daemon for accessing the I2P anonymous network"
HOMEPAGE="https://github.com/PurpleI2P/i2pd"
SRC_URI=""
EGIT_REPO_URI="https://github.com/PurpleI2P/i2pd"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="cpu_flags_x86_aes pax_kernel library static upnp"

RDEPEND="!static? ( >=dev-libs/boost-1.46[threads] )
	!static? ( dev-libs/crypto++ )
	library? ( >=dev-libs/boost-1.46[threads,${MULTILIB_USEDEP}] )
	library? ( dev-libs/crypto++[${MULTILIB_USEDEP}] )"
DEPEND="${RDEPEND}
	static? ( >=dev-libs/boost-1.46[static-libs,threads] )
	static? ( dev-libs/crypto++[static-libs] )
	>=dev-util/cmake-2.8.5
	pax_kernel? ( >=sys-devel/gcc-4.6[hardened] )
	upnp? ( >=net-libs/miniupnpc-1.5 )
	|| ( >=sys-devel/gcc-4.6 >=sys-devel/clang-3.3 )"

I2PD_USER="${I2PD_USER:-i2pd}"
I2PD_GROUP="${I2PD_GROUP:-i2pd}"

CMAKE_USE_DIR="${S}/build"

multilib_src_configure() {
	mycmakeargs=(
		$(cmake-utils_use_with cpu_flags_x86_aes AESNI)
		$(cmake-utils_use_with pax_kernel HARDENING)
		$(cmake-utils_use_with library LIBRARY)
		$(cmake-utils_use_with static STATIC)
		$(multilib_is_native_abi && echo -DWITH_BINARY=ON \
					|| echo -DWITH_BINARY=OFF)
	)
	use upnp && (
		append-cppflags -DUSE_UPNP
	)
	(multilib_is_native_abi || use library) && cmake-utils_src_configure
}

multilib_src_compile() {
	(multilib_is_native_abi || use library) && cmake-utils_src_compile
}

multilib_src_install() {
	(multilib_is_native_abi || use library) && cmake-utils_src_install
}

multilib_src_install_all() {
	dodoc README.md
	doman "${FILESDIR}/${PN}.1"
	keepdir /var/lib/i2pd/
	fowners "${I2PD_USER}:${I2PD_GROUP}" /var/lib/i2pd/
	fperms 700 /var/lib/i2pd/
	insinto /etc/
	doins "${FILESDIR}/${PN}.conf"
	fowners "${I2PD_USER}:${I2PD_GROUP}" "/etc/${PN}.conf"
	fperms 600 "/etc/${PN}.conf"
	dodir /usr/share/i2pd
	cp -R "${S}/contrib/certificates" "${D}/var/lib/i2pd" || die "Install failed!"
	newconfd "${FILESDIR}/${PN}.confd" "${PN}"
	newinitd "${FILESDIR}/${PN}.initd" "${PN}"
	systemd_dounit "${FILESDIR}/${PN}.service"
	doenvd "${FILESDIR}/99${PN}"
	insinto /etc/logrotate.d
	newins "${FILESDIR}/${PN}.logrotate" "${PN}"
}

pkg_setup() {
	enewgroup "${I2PD_GROUP}"
	enewuser "${I2PD_USER}" -1 -1 "/var/lib/run/${PN}" "${I2PD_GROUP}"
}