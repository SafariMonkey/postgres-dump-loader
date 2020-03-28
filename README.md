# Postgres Dump Loader

This is a makefile that will start a Postgres docker container and lets you pass various arguments as variables:

```
POSTGRES_VERSION (docker image version, default 12.2-alpine)
POSTGRES_DATABASE (default db_dump)
POSTGRES_USER (default db_dump)
POSTGRES_PASSWORD (required)
```

You can generate a password easily:

```
export POSTGRES_PASSWORD=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32})
```

And if you want to connect to a different database instance:

```
POSTGRES_HOST
POSTGRES_PORT
```

And to load a dump:
```
DUMP_FILE
```
