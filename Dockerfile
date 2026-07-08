FROM ruby:3.2-slim

WORKDIR /app

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
      build-essential \
      nodejs \
      curl \
      ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY Gemfile ./
COPY Gemfile.lock* ./

RUN bundle install --jobs 4 --retry 3

COPY . .

ENV RAILS_ENV=production
ENV RAILS_SERVE_STATIC_FILES=true
ENV RAILS_LOG_TO_STDOUT=true
# Placeholder key so asset precompile can run at build time.
# Railway/production should still set a real SECRET_KEY_BASE at runtime
# for anything session/cookie related.
ENV SECRET_KEY_BASE=dryrun_placeholder_key_for_asset_precompile_only

RUN bundle exec rails tailwindcss:build
RUN bundle exec rails assets:precompile

EXPOSE 3000

# No database — no db:prepare, no migrations. Just boot the server.
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3000"]
