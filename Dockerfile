FROM ruby:2.1.10

RUN apt-get -y update
RUN groupadd -g 1000 quantified && useradd -m -u 1000 -g quantified quantified
#USER quantified 
WORKDIR /app
ENV PATH="${BUNDLE_BIN}:${PATH}"
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN bundle install
COPY . /app
#CMD mkdir tmp && chown quantified:quantified tmp 
CMD bash -c "rm -f tmp/pids/server.pid; bundle exec rails server -b 0.0.0.0 -p 13001"
