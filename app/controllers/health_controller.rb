class HealthController < ActionController::Base
  skip_before_action :verify_authenticity_token
  
  def check
    render json: { status: 'ok', time: Time.now }
  end
end