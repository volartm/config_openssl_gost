apk add --virtual build-dependencies alpine-sdk wget git cmake unzip gcc  cmake perl

PREFIX="/usr/local/ssl"
WORK_DIR=${PWD}

OPENSSL_VERSION="OpenSSL_1_1_1d"
wget "https://github.com/openssl/openssl/archive/${OPENSSL_VERSION}.zip" -O "${OPENSSL_VERSION}.zip" --no-check-certificate \
&& unzip "${OPENSSL_VERSION}.zip" -d ./ \
&& cd "openssl-${OPENSSL_VERSION}" \
&& ./config shared -d --prefix="${PREFIX}" --openssldir="${PREFIX}" && make -j$(nproc) all && make install
#rm /usr/bin/openssl /usr/bin/c_rehash /usr/lib/ssl/openssl.cnf
#ln -s "${PREFIX}"/openssl.cnf /usr/lib/ssl/openssl.cnf \
#&& ln -s "${PREFIX}"/bin/openssl /usr/bin/openssl && ln -s "${PREFIX}"/bin/c_rehash /usr/bin/c_rehash && ldconfig

echo "${PREFIX}"/lib >> /etc/ld.so.conf && ldconfig
cd ../ && rm -rf "openssl-${OPENSSL_VERSION}" && rm "${OPENSSL_VERSION}.zip"


cd ${WORK_DIR}

ENGINES="${PREFIX}/lib/engines-3"

GOST_ENGINE_VERSION="58a46b289d6b8df06072fc9c0304f4b2d3f4b051"
GOST_ENGINE_SHA256="6b47e24ee1ce619557c039fc0c1201500963f8f8dea83cad6d05d05b3dcc2255"
#&& echo "$GOST_ENGINE_SHA256" gost-engine.zip | sha256sum -c - \
wget "https://github.com/gost-engine/engine/archive/${GOST_ENGINE_VERSION}.zip" -O gost-engine.zip \
  && unzip gost-engine.zip -d ./ \
  && cd "engine-${GOST_ENGINE_VERSION}" \
  && sed -i 's|printf("GOST engine already loaded\\n");|goto end;|' gost_eng.c \
  && mkdir build \
  && cd build \
  && cmake -DCMAKE_BUILD_TYPE=Release \
   -DOPENSSL_ROOT_DIR="${PREFIX}" -DOPENSSL_LIBRARIES="${PREFIX}/lib" -DOPENSSL_ENGINES_DIR="${ENGINES}" .. \
  && cmake --build . --config Release \
  && cmake --build . --target install --config Release \
  && cd bin \
  && cp gostsum gost12sum /usr/local/bin \
  && cd .. \
  && rm -rf gost-engine.zip "engine-${GOST_ENGINE_VERSION}"

sed -i '6i openssl_conf=openssl_def' "${PREFIX}/openssl.cnf" \
  && echo "" >>"${PREFIX}/openssl.cnf" \
  && echo "# OpenSSL default section" >>"${PREFIX}/openssl.cnf" \
  && echo "[openssl_def]" >>"${PREFIX}/openssl.cnf" \
  && echo "engines = engine_section" >>"${PREFIX}/openssl.cnf" \
  && echo "" >>"${PREFIX}/openssl.cnf" \
  && echo "# Engine scetion" >>"${PREFIX}/openssl.cnf" \
  && echo "[engine_section]" >>"${PREFIX}/openssl.cnf" \
  && echo "gost = gost_section" >>"${PREFIX}/openssl.cnf" \
  && echo "" >> "${PREFIX}/openssl.cnf" \
  && echo "# Engine gost section" >>"${PREFIX}/openssl.cnf" \
  && echo "[gost_section]" >>"${PREFIX}/openssl.cnf" \
  && echo "engine_id = gost" >>"${PREFIX}/openssl.cnf" \
  && echo "dynamic_path = ${ENGINES}/gost.so" >>"${PREFIX}/openssl.cnf" \
  && echo "default_algorithms = ALL" >>"${PREFIX}/openssl.cnf" \
  && echo "CRYPT_PARAMS = id-Gost28147-89-CryptoPro-A-ParamSet" >>"${PREFIX}/openssl.cnf"

cd ${WORK_DIR}

CURL_VERSION=7.64.1
CURL_SHA256="432d3f466644b9416bc5b649d344116a753aeaa520c8beaf024a90cba9d3d35d"
# && echo "$CURL_SHA256" "curl-${CURL_VERSION}.tar.gz" | sha256sum -c - \
apk del curl \
 &&
 rm -rf /usr/local/include/curl \
  && wget "https://curl.haxx.se/download/curl-${CURL_VERSION}.tar.gz" -O "curl-${CURL_VERSION}.tar.gz" \
  && tar -zxvf "curl-${CURL_VERSION}.tar.gz" \
  && cd "curl-${CURL_VERSION}" \
  && CPPFLAGS="-I/usr/local/ssl/include" LDFLAGS="-L${PREFIX}/lib -Wl,-rpath,${PREFIX}/lib" LD_LIBRARY_PATH="${PREFIX}l/lib" \
   ./configure --prefix=/usr/local/curl --with-ssl="${PREFIX}" --with-libssl-prefix="${PREFIX}" \
  && make \
  && make install \
  && ln -sf /usr/local/curl/bin/curl /usr/bin/curl \
  && cd ../ && rm -rf "curl-${CURL_VERSION}.tar.gz" "curl-${CURL_VERSION}"

#cd ${WORK_DIR}

#STUNNEL_VERSION="5.56"
#STUNNEL_SHA256="7384bfb356b9a89ddfee70b5ca494d187605bb516b4fff597e167f97e2236b22"
#wget "https://www.stunnel.org/downloads/stunnel-${STUNNEL_VERSION}.tar.gz" -O "stunnel-${STUNNEL_VERSION}.tar.gz" \
#  && echo "$STUNNEL_SHA256" "stunnel-${STUNNEL_VERSION}.tar.gz" | sha256sum \
#  && tar -zxvf "stunnel-${STUNNEL_VERSION}.tar.gz" \
#  && cd "stunnel-${STUNNEL_VERSION}" \
#  && CPPFLAGS="-I${PREFIX}/include" LDFLAGS="-L${PREFIX}/lib -Wl,-rpath,${PREFIX}/lib" LD_LIBRARY_PATH="${PREFIX}/lib" \
#   ./configure --prefix=/usr/local/stunnel --with-ssl="${PREFIX}" \
#  && make \
#  && make install \
#  && ln -s /usr/local/stunnel/bin/stunnel /usr/bin/stunnel \
#  && rm -rf "/usr/local/src/stunnel-${STUNNEL_VERSION}.tar.gz" "/usr/local/src/stunnel-${STUNNEL_VERSION}"

#cd ${WORK_DIR}
#
#tar xfv cryptopro-4.0-amd64_deb.tgz \
#	&& sh linux-amd64_deb/install.sh \
#	&& wget https://update.cryptopro.ru/support/nginx-gost/bin/180423/cprocsp-cpopenssl-110-gost-64_5.0.11216-5_amd64.deb \
#	   -O /mnt/cprocsp-cpopenssl-110-gost-64_5.0.11216-5_amd64.deb \
#	&& dpkg -i /mnt/cprocsp-cpopenssl-110-gost-64_5.0.11216-5_amd64.deb
#
#
#CONFIG="${PREFIX}/openssl.cnf"
#cat <<EOF >> "${PREFIX}"/openssl.cnf
#
#[gostengy_section]
#engine_id = gostengy
#dynamic_path = /opt/cprocsp/cp-openssl-1.1.0/lib/amd64/engines/libgostengy.so
#default_algorithms = CIPHERS, DIGESTS, PKEY, PKEY_CRYPTO, PKEY_ASN1
#
#EOF
#
#LINE_SECTION=$(grep -n '\[engine_section\]' $CONFIG | cut -f 1 -d ':')
#
#sed -i "${LINE_SECTION}a gostengy = gostengy_section" $CONFIG
#
#


