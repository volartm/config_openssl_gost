PREFIX="/usr/local/ssl"

# installing 
echo 'gem "openssl",  git: "https://gitlab+deploy-token-10:jz8m25znE4k6qpSvyPKE@git.ceki.ru/ceki/openssl_patched.git"' >> Gemfile

rvm use ruby-2.4.1

bundle config build.openssl --with-openssl-dir="${PREFIX}"
bundle install


