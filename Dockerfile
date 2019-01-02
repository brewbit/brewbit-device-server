FROM ruby:2.6

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/app
COPY Gemfile Gemfile.lock ./

RUN gem install bacon \
    && gem install formatador -v 0.2.4 \
    && gem install log4r -v 1.1.10 \
	&& bundle install

VOLUME /usr/src/app
COPY . .

EXPOSE 10080 31337
CMD ["./server.rb"]
