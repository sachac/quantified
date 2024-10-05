FROM ruby:3.1.0

RUN apt-get -y update -qq
RUN groupadd -g 1000 quantified && useradd -m -u 1000 -g quantified quantified
#USER quantified 
WORKDIR /app
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN bundle install --without development test
COPY . /app
EXPOSE 13001
#CMD mkdir tmp && chown quantified:quantified tmp 
CMD bash -c "rm -f tmp/pids/server.pid; bundle exec rails server -b 0.0.0.0 -p 13001"
