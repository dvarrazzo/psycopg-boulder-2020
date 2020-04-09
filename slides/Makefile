all: html

html: psycopg.html

psycopg.html: psycopg.rst
	landslide psycopg.cfg

publish: ../docs/psycopg.html

../docs/psycopg.html: psycopg.html
	mkdir -p ../docs
	cp -r css img js theme psycopg.html ../docs
