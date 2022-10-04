FROM ruby:3.1.2

ENV RACK_ENV development

WORKDIR /app

COPY Gemfile* /app/
RUN bundle install
COPY docker-entrypoint.sh /app/
COPY *.rb /app/

CMD ["ruby", "chaos.rb", "-p", "4567", "-o", "0.0.0.0"]
