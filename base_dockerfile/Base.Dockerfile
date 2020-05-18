FROM madnight/docker-alpine-wkhtmltopdf as wkhtmltopdf_image

FROM ruby:2.4.6-alpine
ENV APP_PATH /var/www/fgiski
ENV PHANTOM_JS_VERSION "2.1.1"
ENV LANG="en_US.UTF-8"
ENV LANGUAGE="en_US.UTF-8"

RUN apk update \
&& apk upgrade \
&& apk add --update --no-cache \
build-base curl-dev git postgresql-dev \
yaml-dev zlib-dev nodejs npm yarn \
mysql-client mariadb-dev \
curl openssl-dev chrpath libxft-dev \
freetype-dev fontconfig-dev wget \
imagemagick-dev ttf-liberation \
msttcorefonts-installer \
gcc g++ make busybox ctags \
tzdata wkhtmltopdf sqlite-dev python2

RUN update-ms-fonts && fc-cache -f

RUN cp /usr/share/zoneinfo/Europe/Moscow /etc/localtime && \
  echo "Europe/Moscow" >  /etc/timezone

ENV TZ Europe/Moscow
ENV LANG ru_RU.UTF-8
ENV LANGUAGE ru_RU.UTF-8
ENV LC_ALL ru_RU.UTF-8

RUN cd /tmp && curl -Ls https://github.com/dustinblackman/phantomized/releases/download/${PHANTOM_JS_VERSION}/dockerized-phantomjs.tar.gz | tar xz &&\
    cp -R lib lib64 / &&\
    cp -R usr/lib/x86_64-linux-gnu /usr/lib &&\
    cp -R usr/share /usr/share &&\
    cp -R etc/fonts /etc &&\
    curl -k -Ls https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-${PHANTOM_JS_VERSION}-linux-x86_64.tar.bz2 | tar -jxf - &&\
    cp phantomjs-${PHANTOM_JS_VERSION}-linux-x86_64/bin/phantomjs /usr/local/bin/phantomjs

COPY --from=wkhtmltopdf_image /bin/wkhtmltopdf /usr/bin

COPY install_gost_deps.sh /tmp/install_gost_deps.sh

RUN sh /tmp/install_gost_deps.sh

ENV SSL_CERT_DIR='/etc/ssl/certs'
ENV SSL_CERT_FILE='/etc/ssl/certs/ca-certificates.crt'
ENV LD_LIBRARY_PATH "$LIBRARY_PATH:/usr/local/ssl/lib"


RUN mkdir -p $APP_PATH
WORKDIR $APP_PATH

COPY Gemfile $APP_PATH/Gemfile
COPY Gemfile.lock $APP_PATH/Gemfile.lock
COPY package.json $APP_PATH/package.json
COPY package-lock.json $APP_PATH/package-lock.json

RUN yarn global add node-sass
RUN yarn
RUN bundle config build.openssl --with-openssl-dir="/usr/local/ssl" && bundle install && gem install mailcatcher

