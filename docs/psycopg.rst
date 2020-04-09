=========================================
*Psycopg*: bridging PostgreSQL and Python
=========================================

.. image:: img/psycopg.png
    :height: 30em


.. class:: text-right

    Boulder Linux Users Group, ``'2020-04-09'::date``

    Daniele Varrazzo

    `slides source <https://github.com/dvarrazzo/psycopg-boulder-2020/>`__
..
    Note to piro: you want
    :autocmd BufWritePost psycopg.rst :silent !make html

----


What are we talking about?
==========================

* There is this language, Python 🐍

  * it's got all its types (strongly typed, dynamically typed)

* and this database, PostgreSQL 🐘

  * yeah, not a great name. Let's call it Postgres
  * it's got a lot of different types too

* You want to do something with the two 🐍↔️🐘

  * they are both very extendible
  * someone should map the two together

----


Mapping the two together
========================

Psycopg!
--------

* Yeah, maybe questionable name too. 🤔
* But now we sort of like it. 🤭

``psycopg2``
------------

.. role:: html(raw)
    :format: html

* Current mature adapter: in production for about 15 years 👴
* https://www.psycopg.org/



``psycopg3``
------------

* Development recently started. Exciting! 👶
* https://www.varrazzo.com/blog/2020/03/06/thinking-psycopg3/


----


Basic usage
===========

The roles of the main actors

.. code-block:: python

    import psycopg2                             # the driver
    conn = psycopg2.connect("dbname=piro")      # the connection/session
    cur = conn.cursor()                         # the cursor - holds a result

    cur.execute("select 10 as a, 'foo' as b")   # sends command
    cur.fetchone()                              # retrieve results
    conn.commit()                               # controls the session


Different ways to consume data

.. code-block:: python

    cur.fetchone()      # returns one tuples
    cur.fetchmany(n)    # returns a list of n tuples
    cur.fetchall()      # returns a list with all the tuples
    for t in cur:
        pass            # iterable of tuples


----

Data type mapping
=================

Default data types mapping

.. table::
    :class: data-types

    +--------------------+-------------------------+
    | Python             | PostgreSQL              |
    +====================+=========================+
    | ``None``           | ``NULL``                |
    +--------------------+-------------------------+
    | ``bool``           | ``bool``                |
    +--------------------+-------------------------+
    | ``int``,           | ``smallint``,           |
    | ``long``           | ``integer``,            |
    |                    | ``bigint``              |
    +--------------------+-------------------------+
    | ``float``          | ``real``,               |
    |                    | ``double``              |
    +--------------------+-------------------------+
    | ``Decimal``        | ``numeric``             |
    +--------------------+-------------------------+
    | ``str``,           | ``varchar``,            |
    | ``unicode``        | ``text``                |
    +--------------------+-------------------------+
    | ``date``           | ``date``                |
    +--------------------+-------------------------+
    | ``time``           | ``time``                |
    +--------------------+-------------------------+
    | ``datetime``       | ``timestamp``,          |
    |                    | ``timestamptz``         |
    +--------------------+-------------------------+
    | ``timedelta``      | ``interval``            |
    +--------------------+-------------------------+
    | and many more...                             |
    +--------------------+-------------------------+


----

Typecasting
===========

.. image:: img/pg-to-py.png

Typecasters have:

- one or more OID
- a name
- a conversion function


----

Typecasting
===========

.. image:: img/pg-to-py.png

Customizing a typecaster

.. code-block:: pycon

    >>> cur.execute("select 123.45")
    >>> cur.fetchone()
    (Decimal('123.45'),)

    >>> from psycopg2 import extensions as ext

    >>> def num2float(s, cur):
    ...     if s is None:
    ...         return float(s)

    >>> t = ext.new_type((1700,), "NUM2FLOAT", num2float)
    >>> ext.register_type(t, cur)

    >>> cur.execute("select 123.45")
    >>> cur.fetchone()
    (123.45,)

----


Adaptation
==========

.. image:: img/py-to-pg.png


.. code-block:: pycon

    >>> cur.execute("select '%s' || '%s'" % ('a', 'b'))
    >>> cur.fetchone()
    ('ab',)

    >>> cur.execute("select '%s' || '%s'" % ("O'Reilly", ' Books'))
    Traceback (most recent call last):
      File "<ipython-input-29-720a7746fc83>", line 1, in <module>
        cur.execute("select '%s' || '%s'" % ("O'Reilly", ' Books'))
    ProgrammingError: syntax error at or near "' || '"
    LINE 1: select 'O'Reilly' || ' Books'
                            ^

    >>> cur.execute("select %s || %s", ("O'Reilly", ' Books'))
    >>> cur.fetchone()
    ("O'Reilly Books",)

----


Adaptation risk
===============

.. code-block:: pycon

    >>> cur.execute("insert into students (name) values ('%s')" % name)

.. image:: img/exploits_of_a_mom.png

Funny, but wrong conclusion:

.. code-block:: pycon

    >>> cur.execute("insert into students (name) values (%s)" , [name])

Look ma: no *sanitizing database input* here!


----

New architecture in psycopg3
============================

* Adapters -> Dumpers
* Typecasters -> Loaders
* Transform lifetime tied to the query

  * more performance

.. code-block:: pycon

    >>> Dumper.register(MyType, DumperSubclass)
    >>> Dumper.register(MyType, dump_function)

    >>> Loader.register(my_oid, LoaderSubclass)
    >>> Loader.register(my_oid, load_function)


----

``pushdemo.py`` architecture
============================

.. image:: img/pushdemo-diagram.png



----

Async notification demo
=======================

Using gevent__, gevent-websocket__, psycogreen__

.. __: http://www.gevent.org/
.. __: http://www.gelens.org/code/gevent-websocket/
.. __: https://bitbucket.org/dvarrazzo/psycogreen/

.. class:: apology

    **Note:** this demo requires the ``pushdemo.py`` script running.

.. raw:: html

    <script src="js/jquery.min.js"></script>
    <style type="text/css">
          .bar {width: 40px; height: 40px;}
    </style>
    <script>
        window.onload = function() {
            ws = new WebSocket("ws://localhost:7000/data");
            ws.onopen = function() {
                $('p.apology').hide();
                // drop the offline slide
                $('#target').parents('.slide-wrapper').next().remove();
            }
            ws.onmessage = function(msg) {
                bar = $('#' + msg.data);
                if (bar.length) {
                    bar.width(bar.width() + 40);
                } else {
                    $('#target').text("DB says: " + msg.data);
                }
            }
        }
    </script>
    <p id="red" class="bar" style="background-color: red;">&nbsp;</p>
    <p id="green" class="bar" style="background-color: green;">&nbsp;</p>
    <p id="blue" class="bar" style="background-color: blue;">&nbsp;</p>
    <p id="target"></p>

.. class:: text-right

    Demo code at https://github.com/dvarrazzo/psycopg-boulder-2020

----


Async notification demo (offline)
=================================

.. image:: img/pushdemo.png
