class ChatController < ApplicationController
  include ChatFormatterHelper

  skip_before_action :verify_authenticity_token, only: [:analyze, :generate_sop]

  def index
    # Renders app/views/chat/index.html.erb
    # Layout automatically renders navbar and chat_widget
  end

  def analyze
    question = params[:question]
    session_id = params[:session_id]

    if question.blank?
      return render json: { error: "Question is required" }, status: :bad_request
    end

    session_id ||= generate_session_id

    result = EngineClient.analyze(question: question, session_id: session_id)

    render json: {
      status: result[:status],
      explanation: result[:explanation],
      sources: result[:sources],
      concept: result[:concept],
      from_cache: result[:from_cache],
      session_id: session_id
    }
  rescue StandardError => e
    Rails.logger.error("ChatController#analyze Error: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    render json: {
      status: "error",
      explanation: "An error occurred processing your question.",
      sources: []
    }, status: :internal_server_error
  end

  def generate_sop
    change_text = params[:change_text]

    if change_text.blank?
      return render json: { error: "Change text is required" }, status: :bad_request
    end

    result = EngineClient.generate_sop(change_text: change_text)

    render json: {
      status: result[:status],
      draft_sop: result[:draft_sop],
      reference_docs: result[:reference_docs],
      grounded: result[:grounded]
    }
  rescue StandardError => e
    Rails.logger.error("ChatController#generate_sop Error: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    render json: {
      status: "error",
      draft_sop: "An error occurred generating the SOP.",
      reference_docs: [],
      grounded: false
    }, status: :internal_server_error
  end

  private

  def generate_session_id
    "session_#{Time.now.to_i}_#{SecureRandom.hex(4)}"
  end
end
