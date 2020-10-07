PREFIX="/usr/local/ssl"

# installing 
echo 'gem "openssl",  git: "git@github.com:volartm/openssl_patched.git"' >> Gemfile

rvm use ruby-2.4.1

bundle config build.openssl --with-openssl-dir="${PREFIX}"
bundle install


