FROM selenium/standalone-chrome
USER root
RUN apt-get update && apt-get install -y -qq ruby ruby-dev bundler cmake libgmp3-dev gengetopt libpcap-dev flex byacc libjson-c-dev pkg-config libunistring-dev wget unzip curl libxml2 zlib1g-dev
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN apt-get update && apt-get install -qq -y nodejs yarn --fix-missing --no-install-recommends

WORKDIR /var/www/app
COPY Gemfile Gemfile.lock ./
RUN bundle install
COPY . .
RUN yarn install --modules-folder /deps/node_modules

EXPOSE 3000
CMD [ "rails", "s", "-b", "0.0.0.0" ]