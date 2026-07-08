# Wrapper for calling the ShopFloor GenAI Engine (FastAPI)
# Handles HTTP communication, error handling, response parsing

class EngineClient
  ENGINE_URL = ENV['ENGINE_URL'] || 'http://engine:8080'
  TIMEOUT = ENV['ENGINE_TIMEOUT'].to_i || 30

  def self.analyze(question:, session_id: nil)
    raise ArgumentError, "Question cannot be empty" if question.blank?

    payload = {
      question: question,
      session_id: session_id || generate_session_id
    }

    response = HTTParty.post(
      "#{ENGINE_URL}/analyze",
      body: payload.to_json,
      headers: { 'Content-Type' => 'application/json' },
      timeout: TIMEOUT
    )

    parse_response(response)
  rescue Timeout::Error
    handle_timeout_error
  rescue StandardError => e
    handle_generic_error(e)
  end

  def self.generate_sop(change_text:)
    raise ArgumentError, "Change text cannot be empty" if change_text.blank?

    payload = { change_text: change_text }

    response = HTTParty.post(
      "#{ENGINE_URL}/generate-sop",
      body: payload.to_json,
      headers: { 'Content-Type' => 'application/json' },
      timeout: TIMEOUT
    )

    parse_sop_response(response)
  rescue Timeout::Error
    handle_timeout_error
  rescue StandardError => e
    handle_generic_error(e)
  end

  private

  def self.generate_session_id
    "session_#{Time.now.to_i}_#{SecureRandom.hex(4)}"
  end

  def self.parse_response(response)
    if response.success?
      data = JSON.parse(response.body, symbolize_names: true)
      {
        explanation: data[:explanation],
        sources: data[:sources] || [],
        concept: data[:concept],
        from_cache: data[:from_cache] || false,
        status: "success"
      }
    else
      {
        explanation: "The engine encountered an error.",
        sources: [],
        status: "error"
      }
    end
  end

  def self.parse_sop_response(response)
    if response.success?
      data = JSON.parse(response.body, symbolize_names: true)
      {
        draft_sop: data[:draft_sop],
        reference_docs: data[:reference_docs] || [],
        grounded: data[:grounded] || false,
        status: "success"
      }
    else
      {
        draft_sop: "The engine encountered an error.",
        reference_docs: [],
        grounded: false,
        status: "error"
      }
    end
  end

  def self.handle_timeout_error
    {
      explanation: "The engine is taking too long to respond.",
      sources: [],
      status: "timeout"
    }
  end

  def self.handle_generic_error(error)
    Rails.logger.error("EngineClient Error: #{error.message}")
    {
      explanation: "Sorry, I couldn't process your question.",
      sources: [],
      status: "error"
    }
  end
end
