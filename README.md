# ShopFloor GenAI Web (dry run)

Web frontend for GOH-UC-020 — GenAI-Powered Manufacturing Knowledge Assistant.
Talks to the shopfloor-genai-engine (Python/FastAPI) over REST.

## Status
Dry run — foundation build ahead of the July 9-10 hackathon.

## Structure
- app/views/shared/ — chat widget, SOP generation page, header/nav
- app/controllers/ — chat and SOP request handling
- app/lib/ — engine_client.rb (HTTP client to the engine)

## Stack
Ruby on Rails 7.1. No relational database (no Postgres) — this app has no
business entities to persist, only talks to the engine.

## Engine
https://shopfloor-dryrun-genai-engine-production.up.railway.app
