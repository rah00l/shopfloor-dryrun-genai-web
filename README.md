# ShopFloor GenAI Web

**Manufacturing Knowledge Assistant Interface** — Rails 7 frontend for intelligent shop floor operations.

[![Rails 7.2](https://img.shields.io/badge/rails-7.2.3-red)](https://rubyonrails.org/) [![Ruby 3.2](https://img.shields.io/badge/ruby-3.2-cc342d)](https://www.ruby-lang.org/) [![Tailwind CSS](https://img.shields.io/badge/tailwind-css-blue)](https://tailwindcss.com/) [![Live Demo](https://img.shields.io/badge/demo-Railway-brightgreen)](https://shopfloor-dryrun-genai-web-production.up.railway.app)

## Overview

**ShopFloor GenAI Web** is a production-grade Rails 7 interface for accessing manufacturing knowledge via natural language. It provides a responsive, accessible chat experience — desktop and mobile — connected to the [ShopFloor GenAI Engine](https://github.com/rah00l/shopfloor-dryrun-genai-engine) backend (Python/FastAPI).

**Key properties:**
- **No relational database** — this app is stateless; it only orchestrates calls to the GenAI Engine over HTTP
- **Responsive design** — Tailwind CSS, mobile-first, works seamlessly on any device
- **Real-time feedback** — thumbs up/down on answers, logged for model improvement
- **Transparent reasoning** — every answer shows source, retrieval mode (RAG vs. CAG), confidence tier
- **Seamless deployment** — Rails + Puma on Railway, engine running separately

Built and deployed in **24 hours** as part of GOH-UC-020 (GenAI-Powered Intelligent Manufacturing Knowledge Assistant for Shop Floor Operations) hackathon, selected from a pool of 100+ use cases based on 65–75% architectural reuse from ReconPilot AI.

---

## 🎬 Demo

![ShopFloor GenAI Web Demo](docs/demo.gif)

*Full walkthrough in 49 seconds (2.5x speed): ask a question → view sources with confidence badges → generate a new SOP from an engineering change. Try the [live app →](https://shopfloor-dryrun-genai-web-production.up.railway.app)*

---

## Features

### 💬 Chat Interface (Q&A Tab)
- **Natural-language questions** about shop floor procedures, specs, alerts, maintenance
- **Live chat widget** with streaming response display
- **Source cards** expand on demand to show exact document, section, match confidence
- **Mode badges** (RAG/CAG) show whether answer came from fresh retrieval or cache
- **Confidence tiers** (High/Medium/Low) — derived from real retrieval distance
- **Feedback loop** — thumbs up/down on any answer, logged for review
- **Mobile-responsive** — works equally well on phone, tablet, desktop

### ✍️ Generate SOP Tab
- **Paste an engineering change** (ECN, thickness spec update, procedure tweak, etc.)
- **Get a draft SOP** — the system merges your change into the existing baseline procedure
- **Preserve unaffected steps** — only changes relevant sections
- **No hallucinations** — flags directly when no baseline exists, never invents one
- **Reference documents** shown — you see which documents informed the draft

### 📁 Documents Tab
- **Downloadable sample corpus** — 8 real manufacturing documents
- **Transparent about source material** — users see exactly what the assistant reads from
- **Types included**: SOPs, work instructions, maintenance manuals, quality alerts, ECNs, RCA reports
- **Inspection-ready** — download any doc to verify the assistant's grounding

### 🎨 Responsive & Accessible
- **Tailwind CSS** for modern, consistent styling
- **Mobile-first design** — chat widget adapts fluidly to any viewport
- **Keyboard navigation** — fully accessible inputs and buttons
- **Dark mode ready** — CSS variables support light/dark themes
- **Zero database** — no cookies, sessions, or user state to manage

---

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                   Rails 7 Application                       │
│                    (Puma, port 3000)                        │
│                                                             │
│  ┌──────────────────────────────────────────────────────────┤
│  │  Routing (config/routes.rb)                              │
│  │  - GET  / → chat#index (main page)                       │
│  │  - POST /chat/ask → chat#ask (Q&A endpoint)              │
│  │  - POST /chat/generate-sop → chat#generate_sop           │
│  │  - GET  /health → health#check                           │
│  └──────────────────────────────────────────────────────────┤
│                          │
│                          ▼
│  ┌───────────────────────────────────────────────────────── ┤
│  │  Controllers (app/controllers/)                          │
│  │                                                          │
│  │  ┌────────────────┐  ┌──────────────────────────────┐    │
│  │  │  ChatController│  │ ApplicationController        │    │
│  │  │                │  │ - Error handling             │    │
│  │  │ - index        │  │ - CORS config                │    │
│  │  │ - ask          │  │ - Request logging            │    │
│  │  │ - generate_sop │  │                              │    │
│  │  │ - feedback     │  │                              │    │
│  │  │                │  │                              │    │
│  │  └────────────────┘  └──────────────────────────────┘    │
│  └──────────────────────────────────────────────────────────┤
│                          │
│                          ▼
│  ┌──────────────────────────────────────────────────────────┤
│  │  HTTP Client (app/lib/engine_client.rb)                  │
│  │  - Talks to ShopFloor GenAI Engine                       │
│  │  - POST /analyze (Q&A)                                   │
│  │  - POST /generate-sop (SOP generation)                   │
│  │  - Timeout handling, retry logic                         │
│  └──────────────────────────────────────────────────────────┤
│                          │
│                          ▼
│  ┌──────────────────────────────────────────────────────────┤
│  │  Views & Partials (app/views/)                           │
│  │                                                          │
│  │  ├── chat/index.html.erb         Main page               │
│  │  ├── chat/sop_page.html.erb      SOP generator           │
│  │  ├── shared/_chat_widget.html    Chat interface          │
│  │  ├── shared/_navbar.html         Header/nav              │
│  │  └── shared/_questions_widget    Sample questions        │
│  │                                                          │
│  │  Styling:                                                │
│  │  ├── app/assets/stylesheets/globals.css                  │
│  │  ├── app/assets/stylesheets/application.css              │
│  │  └── app/assets/stylesheets/application.tailwind.css     │
│  └──────────────────────────────────────────────────────────┤
│
└─────────────────────────────────────────────────────────────┘
         │
         │ HTTP/REST
         │ (ENGINE_URL env var)
         │
         ▼
    ┌─────────────────────────────────────┐
    │  ShopFloor GenAI Engine             │
    │  (FastAPI, Python, separate deploy) │
    │                                     │
    │  POST /analyze → RAG Q&A            │
    │  POST /generate-sop → SOP gen       │
    │  GET /health → liveness check       │
    │                                     │
    └─────────────────────────────────────┘
```

---

## Tech Stack

| Component | Technology | Purpose |
|-----------|-----------|---------|
| **Framework** | Rails 7.2.3 | Web app framework, routing, views |
| **Server** | Puma 5.0+ | Rack-based app server |
| **Ruby** | 3.2 | Language runtime |
| **Frontend** | Tailwind CSS 2.0 | Responsive styling, no database |
| **HTTP Client** | HTTParty 0.24 | REST calls to GenAI Engine |
| **Config** | dotenv-rails | Environment variable management |
| **Container** | Docker + Railway | Production deployment |
| **Build** | Tailwindcss-rails | CSS compilation |

**Note:** No database (no ActiveRecord, no migrations). This app is entirely stateless.

---

## Quick Start

### Prerequisites
- Ruby 3.2+
- Bundler
- Node.js (for asset compilation)
- ShopFloor GenAI Engine running (local or remote)

### Local Development

1. **Clone & navigate:**
   ```bash
   git clone https://github.com/rah00l/shopfloor-dryrun-genai-web.git
   cd shopfloor-dryrun-genai-web
   ```

2. **Set up environment:**
   ```bash
   cp .env.example .env
   # Edit .env and set ENGINE_URL:
   # ENGINE_URL=http://localhost:8000          # if engine runs locally
   # ENGINE_URL=http://engine:8000            # if using docker-compose
   # ENGINE_TIMEOUT=30                         # seconds
   ```

3. **Install dependencies:**
   ```bash
   bundle install
   ```

4. **Build Tailwind CSS:**
   ```bash
   bundle exec rails tailwindcss:build
   ```

5. **Run the server:**
   ```bash
   bundle exec rails server -b 0.0.0.0 -p 3000
   ```

6. **Open browser:**
   - Main app: `http://localhost:3000`
   - Chat widget: Ready to type
   - Generate SOP: Switch to the tab above chat

### Docker Compose (Engine + Web)

From the parent directory (with both `shopfloor-dryrun-genai-engine` and `shopfloor-dryrun-genai-web`):

```bash
docker-compose up
# Engine: http://localhost:8000
# Web: http://localhost:3000
```

Check logs:
```bash
docker-compose logs -f web
docker-compose logs -f engine
```

---

## API Reference (Web → Engine)

The web app calls the engine via `EngineClient` (app/lib/engine_client.rb). These endpoints are transparent to end users:

### Ask a Question
```ruby
EngineClient.ask_question(question: "What torque spec for door hinge bracket?")
# Returns:
{
  "session_id": "...",
  "explanation": "According to WI-4.2, ...",
  "sources": [{...}],
  "from_cache": false,
  "timestamp": "..."
}
```

### Generate an SOP
```ruby
EngineClient.generate_sop(change_text: "Bracket thickness increased from 2mm to 2.5mm")
# Returns:
{
  "draft_sop": "## SOP-3.1 Bracket Installation, Rev C\n\n1. ...",
  "reference_docs": [...],
  "grounded": true,
  "timestamp": "..."
}
```

---

## Controllers & Views

### ChatController
- **`index`** — Renders main page with chat widget, SOP tab, documents tab
- **`ask`** — Receives question, calls engine, returns JSON response for AJAX
- **`generate_sop`** — Receives change text, calls engine, returns draft SOP
- **`feedback`** — Logs thumbs up/down (future: could send to analytics backend)

### Views
- **`chat/index.html.erb`** — Three-tab layout (Chat, Generate SOP, Documents)
- **`shared/_chat_widget.html.erb`** — Chat interface (questions, responses, sources)
- **`shared/_navbar.html.erb`** — Header with app title and documentation link
- **`shared/_questions_widget.html.erb`** — Pre-loaded sample questions for guidance

### Styling
- **Tailwind CSS** — utility-first responsive design
- **Globals** — shared variables, breakpoints, colors
- **Application CSS** — compiled from Tailwind config

---

## Deployment

### Railway (Production)

1. **Connect Railway project:**
   ```bash
   railway link
   ```

2. **Set environment variables in Railway dashboard:**
   ```
   ENGINE_URL=https://shopfloor-dryrun-genai-engine-production.up.railway.app
   RAILS_ENV=production
   PORT=3000
   RAILS_SERVE_STATIC_FILES=true
   RAILS_LOG_TO_STDOUT=true
   SECRET_KEY_BASE=<randomly generated secret>
   ```

3. **Deploy:**
   ```bash
   railway up
   ```

4. **View logs:**
   ```bash
   railway logs
   ```

**Live Endpoint:**
```
https://shopfloor-dryrun-genai-web-production.up.railway.app
```

---

## Configuration

### Environment Variables

```bash
# Engine communication
ENGINE_URL=http://localhost:8000           # Full URL to ShopFloor GenAI Engine
ENGINE_TIMEOUT=30                          # Seconds to wait for engine response
ENGINE_MAX_RETRIES=1                       # Retry transient failures

# Rails
RAILS_ENV=production                       # development, test, or production
RAILS_LOG_TO_STDOUT=true                   # Log to stdout (Docker)
RAILS_SERVE_STATIC_FILES=true              # Serve assets directly
SECRET_KEY_BASE=<random-key>               # Required for production cookies/session

# Deployment
PORT=3000                                   # HTTP port (Railway overrides)
```

### Engine Client Timeout

In `config/initializers/engine.rb`:
```ruby
ENGINE_CONFIG = {
  url: ENV['ENGINE_URL'] || 'http://localhost:8000',
  timeout: (ENV['ENGINE_TIMEOUT'].presence || 30).to_i,
  max_retries: ENV['ENGINE_MAX_RETRIES'].to_i || 1
}.freeze
```

If the engine is slow to respond, increase `ENGINE_TIMEOUT`. If it's timing out on Railway production, ensure:
1. Engine is deployed and healthy (`GET /engine/health`)
2. `ENGINE_URL` points to correct, live endpoint
3. Network connectivity between services

---

## Known Issues & Solutions

### Issue: Chat requests time out
**Check:**
1. Is the engine running? `curl http://engine:8000/health`
2. Is `ENGINE_URL` set correctly in `.env` or Railway?
3. Increase `ENGINE_TIMEOUT` if engine is slow

### Issue: Tailwind CSS not building in Docker
**Solution:**
```bash
bundle exec rails tailwindcss:build
# Then run docker-compose build
```

### Issue: Asset precompile fails in Docker
**Solution:**
Ensure `SECRET_KEY_BASE` is set during Docker build:
```dockerfile
ENV SECRET_KEY_BASE=dryrun_placeholder_for_build
RUN bundle exec rails assets:precompile
```

Then override with real key at runtime in Railway.

---

## Project Structure

```
shopfloor-dryrun-genai-web/
├── app/
│   ├── controllers/
│   │   ├── application_controller.rb
│   │   ├── chat_controller.rb           # Main Q&A and SOP endpoints
│   │   └── health_controller.rb         # Liveness check
│   │
│   ├── lib/
│   │   └── engine_client.rb             # HTTP client to GenAI Engine
│   │
│   ├── helpers/
│   │   ├── application_helper.rb
│   │   └── chat_formatter_helper.rb     # Format responses for display
│   │
│   ├── views/
│   │   ├── chat/
│   │   │   ├── index.html.erb          # Main three-tab layout
│   │   │   └── sop_page.html.erb       # SOP generator tab
│   │   │
│   │   ├── layouts/
│   │   │   └── application.html.erb    # Base layout
│   │   │
│   │   └── shared/
│   │       ├── _navbar.html.erb        # Header/navigation
│   │       ├── _chat_widget.html.erb   # Chat interface
│   │       └── _questions_widget.html  # Sample questions
│   │
│   └── assets/
│       ├── stylesheets/
│       │   ├── application.css
│       │   ├── application.tailwind.css
│       │   └── globals.css
│       └── images/
│
├── config/
│   ├── routes.rb                       # Route definitions
│   ├── puma.rb                         # Puma server config
│   ├── application.rb                  # Rails config
│   ├── tailwind.config.js              # Tailwind CSS config
│   │
│   ├── environments/
│   │   ├── development.rb
│   │   ├── production.rb
│   │   └── test.rb
│   │
│   └── initializers/
│       ├── engine.rb                   # Engine configuration & validation
│       ├── content_security_policy.rb
│       ├── assets.rb
│       └── ...
│
├── public/
│   └── documents/                      # Downloadable sample corpus
│       └── index.html.erb              # Document listing
│
├── Dockerfile                          # Production container image
├── docker-compose.yml                  # Local dev with engine + web
├── Gemfile                            # Ruby dependencies
├── .env.example                        # Environment template
└── config.ru                          # Rack entrypoint
```

---

## Production Scaling

This web app is stateless, so scaling is straightforward:

### Horizontal Scaling
1. **Run multiple instances** behind a load balancer (Railway does this automatically)
2. **No session storage** — each request is independent
3. **No shared state** — only calls to the engine backend

### Engine as Bottleneck
- If chat latency becomes an issue, **scale the engine** (add worker pool, replicas)
- Implement **queue-based async jobs** if SOP generation is slow
- Add **Redis caching** for repeated questions (beyond CAG)

### Monitoring
- **Track engine response times** — log `ENGINE_TIMEOUT` hits
- **Monitor chat success rate** — catch engine downtime early
- **Log feedback data** — thumbs down indicates content gaps; feed back into corpus updates

---

## Contributing

1. **Add new UI features** — extend views, add controllers as needed
2. **Improve responsiveness** — modify Tailwind config in `config/tailwind.config.js`
3. **Enhance formatter** — improve `ChatFormatterHelper` for richer response display
4. **Add analytics** — extend `feedback` action to log to analytics backend

---

## Testing

Currently, this is a reference build from a 24-hour hackathon. For production:

1. **Add RSpec tests:**
   ```bash
   bundle add rspec-rails --group test
   rails generate rspec:install
   ```

2. **Test controllers:**
   ```ruby
   describe ChatController do
     describe "POST #ask" do
       it "calls engine and returns response" do
         # Mock EngineClient, verify response
       end
     end
   end
   ```

3. **Test views & integration:**
   ```bash
   bundle add capybara --group test
   # Write feature specs
   ```

---

## Contact & Questions

- **Build**: GOH-UC-020 (GenAI-Powered Intelligent Manufacturing Knowledge Assistant)
- **Hackathon**: 24-hour build, July 2026
- **Author**: [Rahul Patil](https://github.com/rah00l)
- **Live Demo**: [shopfloor-dryrun-genai-web-production.up.railway.app](https://shopfloor-dryrun-genai-web-production.up.railway.app)
- **Paired Engine**: [shopfloor-dryrun-genai-engine](https://github.com/rah00l/shopfloor-dryrun-genai-engine)

---

## License

MIT — See LICENSE file for details.
