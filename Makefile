# Local LLM Makefile

# デフォルトモデル
MODEL ?= gemma2:7b

# =============================================================================
# Ollama
# =============================================================================

.PHONY: ollama-up ollama-down ollama-logs ollama-pull ollama-run ollama-list ollama-api

ollama-up:
	docker compose -f ollama/docker-compose.yml up -d

ollama-down:
	docker compose -f ollama/docker-compose.yml down

ollama-logs:
	docker compose -f ollama/docker-compose.yml logs -f

ollama-pull:
	docker exec -it ollama ollama pull $(MODEL)

ollama-run:
	docker exec -it ollama ollama run $(MODEL)

ollama-list:
	docker exec -it ollama ollama list

ollama-api:
	@echo "API endpoint: http://localhost:11434"
	@echo "Example:"
	@echo '  curl http://localhost:11434/api/generate -d '\''{"model": "$(MODEL)", "prompt": "Hello"}'\'''
