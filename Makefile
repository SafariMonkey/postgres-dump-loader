POSTGRES_VERSION ?= 12.2-alpine
POSTGRES_HOST ?= localhost
POSTGRES_PORT ?= 5432
POSTGRES_USER ?= db_dump
POSTGRES_DATABASE ?= db_dump

.PHONY: password-set
password-set:
	@[ "${POSTGRES_PASSWORD}" ] || ( echo ">> POSTGRES_PASSWORD is not set"; exit 1 )

.PHONY: run-db
run-db: password-set
	POSTGRES_VERSION="$(POSTGRES_VERSION)" \
	POSTGRES_USER="$(POSTGRES_USER)" \
	POSTGRES_HOST="$(POSTGRES_HOST)" \
	POSTGRES_PORT="$(POSTGRES_PORT)" \
	POSTGRES_DB="$(POSTGRES_DATABASE)" \
	POSTGRES_PASSWORD="$(POSTGRES_PASSWORD)" \
	docker-compose up -d

PHONY: print-uri
print-uri: password-set
	@echo "postgres://$(POSTGRES_USER):$(POSTGRES_PASSWORD)@$(POSTGRES_HOST):$(POSTGRES_PORT)/$(POSTGRES_DATABASE)"

.PHONY: rm-db
rm-db:
	docker stop postgres-dump-loader_postgres_1
	docker rm postgres-dump-loader_postgres_1

.PHONY: rm-data
rm-data:
	sudo rm -rf data/

define postgres_exec
	docker exec -it \
		-e PGUSER="$(POSTGRES_USER)" \
		-e PGPASSWORD="$(POSTGRES_PASSWORD)" \
		postgres_postgres_1 $(1)
endef

define postgres_run
	docker run -it --rm --net=host $(2) \
			-e PGHOST="$(POSTGRES_HOST)" \
			-e PGPORT="$(POSTGRES_PORT)" \
			-e PGDATABASE="$(POSTGRES_DATABASE)" \
			-e PGUSER="$(POSTGRES_USER)" \
			-e PGPASSWORD="$(POSTGRES_PASSWORD)" \
			postgres:$(POSTGRES_VERSION) $(1)
endef

.PHONY: psql
psql:
	$(call postgres_run,psql -v ON_ERROR_STOP=1)

comma := ,

.PHONY: load-dump
load-dump: password-set
	@[ "${DUMP_FILE}" ] || ( echo ">> DUMP_FILE is not set"; exit 1 )
	$(call postgres_exec,dropdb --if-exists $(POSTGRES_DATABASE))
	$(call postgres_exec,createdb $(POSTGRES_DATABASE))
	$(call postgres_run,pg_restore -O -d $(POSTGRES_DATABASE) /dump.pgdump,--mount type=bind$(comma)source="$(DUMP_FILE)"$(comma)target=/dump.pgdump)
