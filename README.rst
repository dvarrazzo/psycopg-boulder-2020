Psycopg slideshow at Boulder Linux Users Group, April 2020
==========================================================

You can see these slides at https://www.varrazzo.com/psycopg-boulder-2020/.

An `HTML5 slideshow`__ made with Landslide__.

.. __: https://code.google.com/p/html5slides/
.. __: https://github.com/adamzap/landslide

Usage
-----

In order to render the slideshow, just ``pip install landslide`` and::

    make

The slideshow has an interactive part with more complex requirements: you can
build the entire environment with::

    virtualenv env
    source env/bin/activate
    pip install -r requirements.txt

Run the ``pushdemo.py`` script with a connection string as first argument
(hint: quote it), e.g. ::

    python3 pushdemo.py "user=postgres dbname=test"

Display the html slideshow.  At the demo page, connect to the same database
using psql and execute something like::

    NOTIFY data, 'blue';
    NOTIFY data, 'red';
