module ChatFormatterHelper
  
  # Main formatter method - handles ALL response types
  def format_chat_response(response_data)
    # Parse response if it's a string
    data = parse_response(response_data)
    
    Rails.logger.debug("Formatter input data: #{data.inspect[0..200]}...")
    Rails.logger.debug("Data class: #{data.class}")
    Rails.logger.debug("Has status: #{data[:status].present?}")
    
    # Check overall status first
    return format_error_response(data) if data[:status] == "ERROR"
    
    # Get result
    result = data[:result]
    
    Rails.logger.debug("Result class: #{result.class}")
    Rails.logger.debug("Result value: #{result.inspect[0..100] if result}")
    
    # Format based on result type
    case result
    when Hash
      # Complex response with multiple fields
      if result[:status] == "NOT_DEFINED"
        Rails.logger.debug("Routing to: format_not_defined_response")
        format_not_defined_response(result)
      elsif result[:concept_type]
        Rails.logger.debug("Routing to: format_status_response (has concept_type)")
        format_status_response(result)
      elsif result[:error_mapping]
        Rails.logger.debug("Routing to: format_error_mapping_response")
        format_error_mapping_response(result)
      else
        Rails.logger.debug("Routing to: format_generic_hash_response")
        format_generic_hash_response(result)
      end
    when String
      # Simple string response (yes, no, or sentence)
      Rails.logger.debug("Routing to: format_simple_response (String)")
      format_simple_response(result)
    when TrueClass, FalseClass
      # Boolean response (true/false)
      Rails.logger.debug("Routing to: format_boolean_response")
      format_boolean_response(result)
    when NilClass
      # Null response
      Rails.logger.debug("Result is nil - using fallback")
      format_error_response({ error: "No response content" })
    else
      # Unknown type - fallback
      Rails.logger.debug("Routing to: format_fallback_response (#{result.class})")
      format_fallback_response(result)
    end
  end

  private

  # ========================================
  # PARSING
  # ========================================

  def parse_response(response_data)
    return response_data if response_data.is_a?(Hash)
    
    # Try to parse string as Ruby hash
    begin
      eval(response_data)
    rescue
      { status: "ERROR", error: "Could not parse response" }
    end
  end

  # ========================================
  # TYPE 1: Complex Status Response
  # ========================================

  def format_status_response(result)
    html = ""
    
    # Determine icon based on concept type
    icon = get_icon(result[:concept_type], result[:blocking])
    
    # Title with icon
    html += '<div class="flex items-center gap-2 mb-4">'
    html += "<span class=\"text-lg\">#{icon}</span>"
    html += '<h3 class="font-bold text-gray-900">Status Information</h3>'
    html += '</div>'
    
    # Blocking badge if applicable
    if result[:blocking]
      html += '<div class="mb-4">'
      html += '<span class="inline-block bg-red-100 text-red-800 px-2 py-1 rounded text-xs font-semibold">⚠️ Blocks Reconciliation</span>'
      html += '</div>'
    end
    
    # Ownership
    if result[:ownership]
      html += '<div class="border-t border-gray-200 pt-2 mb-4">'
      html += '<p class="text-xs text-gray-500 font-semibold uppercase mb-1">Owned By</p>'
      html += "<p class=\"text-gray-900 font-semibold\">#{escape_html(result[:ownership])}</p>"
      html += '</div>'
    end
    
    # Meaning (primary content)
    if result[:meaning]
      html += '<div class="border-t border-gray-200 pt-2 mb-4">'
      html += '<p class="text-xs text-gray-500 font-semibold uppercase mb-2">What It Means</p>'
      html += "<p class=\"text-sm text-gray-800 leading-relaxed\">#{escape_html(result[:meaning])}</p>"
      html += '</div>'
    end
    
    # Impact
    if result[:impact]
      html += '<div class="border-t border-gray-200 pt-2 mb-4">'
      html += '<p class="text-xs text-gray-500 font-semibold uppercase mb-2">Impact</p>'
      html += "<p class=\"text-sm text-gray-800 leading-relaxed\">#{escape_html(result[:impact])}</p>"
      html += '</div>'
    end
    
    # Next steps
    if result[:typical_next_step]
      html += '<div class="border-t border-gray-200 pt-2 mb-4">'
      html += '<p class="text-xs text-gray-500 font-semibold uppercase mb-2">Next Steps</p>'
      html += "<p class=\"text-sm text-gray-800 leading-relaxed\">#{escape_html(result[:typical_next_step])}</p>"
      html += '</div>'
    end
    
    # Notes
    if result[:notes]
      html += '<div class="bg-blue-50 border-l-4 border-blue-600 p-2 rounded mb-4">'
      html += '<p class="text-xs text-gray-500 font-semibold uppercase mb-1">📝 Note</p>'
      html += "<p class=\"text-gray-700 text-xs\">#{escape_html(result[:notes])}</p>"
      html += '</div>'
    end
    
    html
  end

  # ========================================
  # TYPE 2: Simple String Response
  # ========================================

  def format_simple_response(text)
    return "" if text.blank?
    
    text = text.to_s.strip
    text_lower = text.downcase
    
    # Determine color based on content
    if text_lower.start_with?("yes") || text_lower.include?("complete") || text_lower.include?("true")
      bg_class = "bg-green-50"
      border_class = "border-green-600"
      icon = "✅"
    elsif text_lower.start_with?("no") || text_lower.include?("cannot") || text_lower.include?("false")
      bg_class = "bg-red-50"
      border_class = "border-red-600"
      icon = "❌"
    else
      bg_class = "bg-blue-50"
      border_class = "border-blue-600"
      icon = "ℹ️"
    end
    
    html = "<div class=\"#{bg_class} border-l-4 #{border_class} p-4 rounded\">"
    html += "<p class=\"text-sm text-gray-800 leading-relaxed\">#{icon} #{escape_html(text)}</p>"
    html += '</div>'
    
    html
  end

  # ========================================
  # TYPE 3: Boolean Response (NEW)
  # ========================================

  def format_boolean_response(value)
    if value == true
      html = '<div class="bg-green-50 border-l-4 border-green-600 p-4 rounded">'
      html += '<p class="text-sm text-gray-800 leading-relaxed">✅ <span class="font-semibold">Yes</span> - This is true</p>'
      html += '</div>'
    else
      html = '<div class="bg-red-50 border-l-4 border-red-600 p-4 rounded">'
      html += '<p class="text-sm text-gray-800 leading-relaxed">❌ <span class="font-semibold">No</span> - This is false</p>'
      html += '</div>'
    end
    
    html
  end

  # ========================================
  # TYPE 4: Not Defined Response
  # ========================================

  def format_not_defined_response(result)
    message = result[:message] || "This question could not be answered from the knowledge base."
    
    html = '<div class="bg-amber-50 border-l-4 border-amber-600 p-4 rounded">'
    html += '<p class="text-sm font-semibold text-amber-900 mb-2">🔍 Question Not in Knowledge Base</p>'
    html += "<p class=\"text-sm text-gray-700\">#{escape_html(message)}</p>"
    html += '</div>'
    
    html
  end

  # ========================================
  # TYPE 5: Error Response
  # ========================================

  def format_error_response(data)
    error_msg = data[:error] || "An error occurred while processing your question."
    
    html = '<div class="bg-red-50 border-l-4 border-red-600 p-4 rounded">'
    html += '<p class="text-sm font-semibold text-red-900 mb-2">❌ Error</p>'
    html += "<p class=\"text-sm text-gray-700\">#{escape_html(error_msg)}</p>"
    html += '</div>'
    
    html
  end

  # ========================================
  # TYPE 6: Generic Hash Response
  # ========================================

  def format_generic_hash_response(result)
    return "" if result.blank?
    
    # Try to extract key information
    html = ""
    
    # If it has specific known keys, format them
    if result.is_a?(Hash)
      # Check for answer/status field
      if result[:answer]
        html += '<div class="bg-blue-50 border-l-4 border-blue-600 p-4 rounded mb-4">'
        html += "<p class=\"text-sm font-semibold text-blue-900\">#{escape_html(result[:answer])}</p>"
        html += '</div>'
      end
      
      # Check for description
      if result[:description]
        html += '<div class="border-t border-gray-200 pt-4">'
        html += "<p class=\"text-sm text-gray-800 leading-relaxed\">#{escape_html(result[:description])}</p>"
        html += '</div>'
      end
      
      # Check for related items
      if result[:related_statuses]&.is_a?(Array) && result[:related_statuses].any?
        html += '<div class="border-t border-gray-200 pt-4 mt-4">'
        html += '<p class="text-xs text-gray-500 font-semibold uppercase mb-2">Related Statuses</p>'
        html += '<div class="flex flex-wrap gap-2">'
        result[:related_statuses].each do |status|
          html += "<span class=\"inline-block bg-gray-200 text-gray-800 px-2 py-1 rounded text-xs\">#{escape_html(status.to_s)}</span>"
        end
        html += '</div>'
        html += '</div>'
      end
    end
    
    # If we got something, return it
    return html if html.present?
    
    # Otherwise fallback
    format_fallback_response(result)
  end

  # ========================================
  # FALLBACK
  # ========================================

  def format_fallback_response(result)
    return "" if result.blank?
    
    text = result.to_s.strip
    return "" if text.blank?
    
    html = '<div class="text-sm text-gray-600 bg-gray-50 border border-gray-200 p-4 rounded">'
    html += "<p>#{escape_html(text)}</p>"
    html += '</div>'
    
    html
  end

  # ========================================
  # HELPERS
  # ========================================

  def get_icon(concept_type, blocking = false)
    case concept_type
    when "status_transitional"
      "🔄"
    when "status_blocking"
      blocking ? "⚠️" : "📌"
    when "status_terminal"
      "✅"
    when "error_mapping"
      "❌"
    else
      "ℹ️"
    end
  end

  def escape_html(text)
    return text if text.nil?
    
    text
      .gsub("&", "&amp;")
      .gsub("<", "&lt;")
      .gsub(">", "&gt;")
      .gsub("\"", "&quot;")
      .gsub("'", "&#39;")
  end

end