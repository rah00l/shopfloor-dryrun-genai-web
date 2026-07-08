source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# ============================================================================
# CORE RAILS & SERVER
# ============================================================================
gem "rails", "~> 7.2.3", ">= 7.2.3.1"
gem "puma", ">= 5.0"
gem "bootsnap", require: false

# ============================================================================
# DATABASE
# ============================================================================
# None — this app has no relational data, it only calls the AI engine over HTTP.

# ============================================================================
# FRONTEND & ASSETS
# ============================================================================
gem "sprockets-rails"
gem "tailwindcss-rails", "~> 2.0"
gem "jbuilder"

# ============================================================================
# API & HTTP COMMUNICATION
# ============================================================================
# HTTP client for calling the ShopFloor GenAI Engine (FastAPI)
# Used in EngineClient to make requests to /analyze and /generate-sop
gem "httparty", "~> 0.24.2"

# ============================================================================
# CONFIGURATION & UTILITIES
# ============================================================================
# Environment variable management from .env files
gem "dotenv-rails", "~> 3.2"

# Timezone support for Windows and JRuby
gem "tzinfo-data", platforms: %i[ windows jruby ]
