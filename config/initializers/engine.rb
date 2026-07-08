# AI Analyst Engine Configuration
# Configure how Rails communicates with the Sinatra engine

ENGINE_CONFIG = {
  url: ENV['ENGINE_URL'] || 'http://engine:8080',
  timeout: ENV['ENGINE_TIMEOUT'].to_i || 30,
  max_retries: ENV['ENGINE_MAX_RETRIES'].to_i || 1
}.freeze

# Log configuration on startup
Rails.logger.info("=" * 60)
Rails.logger.info("AI Analyst Engine Configuration")
Rails.logger.info("=" * 60)
Rails.logger.info("Engine URL: #{ENGINE_CONFIG[:url]}")
Rails.logger.info("Timeout: #{ENGINE_CONFIG[:timeout]}s")
Rails.logger.info("=" * 60)

# Production warning
if Rails.env.production? && ENGINE_CONFIG[:url].include?('localhost')
  Rails.logger.warn("⚠️  WARNING: Engine URL points to localhost in production!")
  Rails.logger.warn("⚠️  This will cause chat to fail!")
  Rails.logger.warn("⚠️  Set ENGINE_URL environment variable correctly")
end