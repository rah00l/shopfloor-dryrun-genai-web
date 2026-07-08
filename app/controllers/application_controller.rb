class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # HTTP Basic Authentication
  # Skip for health check endpoint and API endpoints
  # before_action :authenticate_user!, unless: :skip_auth?

  private

  def authenticate_user!
    return if skip_auth?
    
    authenticate_or_request_with_http_basic do |username, password|
      # Verify credentials from environment variables
      username == ENV.fetch('HTTP_AUTH_USER', 'test.user') &&
      password == ENV.fetch('HTTP_AUTH_PASSWORD', 'Password123')
    end
  end

  def skip_auth?
    # Skip authentication for health checks and specific endpoints
    request.path == '/health' ||
    request.path.start_with?('/rails/') ||
    request.path == '/assets'
  end
end
