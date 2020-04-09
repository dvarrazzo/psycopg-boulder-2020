all: html

html: docs/index.html

docs/index.html: docs/psycopg.rst
	cd docs && landslide psycopg.cfg
