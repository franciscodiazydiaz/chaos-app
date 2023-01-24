FROM ruby:3.2.0

ENV rack 3
ENV RACK_ENV development

WORKDIR /app

## Ensure gems are installed on a persistent volume and available as bins
VOLUME /bundle
RUN bundle config set --global path '/bundle'
ENV PATH="/bundle/ruby/3.2.0/bin:${PATH}"

COPY Gemfile* /app/
RUN bundle install
COPY *.rb /app/

ENTRYPOINT ["bundle", "exec", "ruby"]
CMD ["chaos.rb", "-p", "4567", "-o", "0.0.0.0"]
