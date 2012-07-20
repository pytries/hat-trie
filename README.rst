hat-trie
========

HAT-Trie structure for Python (2.x and 3.x).
Uses `hat-trie`_

.. _hat-trie: https://github.com/dcjones/hat-trie

.. warning::

    The underlying library doesn't provide sorted access so it
    is hard to implement common trie operations such as
    prefix search. The C library needs more thought in order
    to make this package useful.


Installation
============

::

    pip install hat-trie

Usage
=====

Create a new trie::

    >>> from hat_trie import Trie
    >>> trie = Trie()

``trie`` variable is a dict-like object that support unicode
keys and integer values and stores them efficiently.

Currently implemented methods are:

* __getitem__()
* __setitem__()
* __contains__()
* __len__()
* setdefault()
* keys()
* iterkeys()

Other methods are not implemented.

Performance
===========

Performance is measured for ``hat_trie.Trie`` against Python's dict with
100k unique unicode words (English and Russian) as keys and '1' numbers
as values.

Benchmark results for Python 3.3b1 (macbook air i5 1.7GHz,
"1.000M ops/sec" == "1 000 000 operations per second")::

    dict __getitem__ (hits):    6.411M ops/sec
    trie __getitem__ (hits):    3.249M ops/sec
    dict __contains__ (hits):   6.917M ops/sec
    trie __contains__ (hits):   3.334M ops/sec
    dict __contains__ (misses): 5.604M ops/sec
    trie __contains__ (misses): 2.859M ops/sec
    dict __len__:               604229.965 ops/sec
    trie __len__:               482318.662 ops/sec
    dict __setitem__ (updates): 6.079M ops/sec
    trie __setitem__ (updates): 3.052M ops/sec
    dict __setitem__ (inserts): 6.641M ops/sec
    trie __setitem__ (inserts): 2.207M ops/sec
    dict setdefault (updates):  3.520M ops/sec
    trie setdefault (updates):  2.493M ops/sec
    dict setdefault (inserts):  3.562M ops/sec
    trie setdefault (inserts):  1.757M ops/sec
    dict keys():                152.804 ops/sec
    trie keys():                14.681 ops/sec

You may wonder how it compares with `datrie`_ results.

HAT-Trie is about 1.5x faster that `datrie`_ on all supported operations;
it also supports fast inserts unlike datrie. But hat-trie doesn't support
sorted iteration, advanced trie operations and saving/loading in current
implementation. So fast __getitem__ is not an advantage (you can always
get even faster __getitem__ from a regular dict).

.. _datrie: https://github.com/kmike/datrie

Contributing
============

Development happens at github and bitbucket:

* https://github.com/kmike/datrie
* https://bitbucket.org/kmike/datrie

The main issue tracker is at github.

Feel free to submit ideas, bugs, pull requests (git or hg) or
regular patches.

.. warning::

    Please take into account that development is currently
    frozen and bugs may get zero attention.


Running tests and benchmarks
----------------------------

Make sure `tox`_ is installed and run

::

    $ tox

from the source checkout. Tests should pass under python 2.6, 2.7, 3.2 and 3.3.

.. note::

    At the moment of writing the latest pip release (1.1) does not
    support Python 3.3; in order to run tox tests under Python 3.3
    find the "virtualenv_support" directory in site-packages
    (of the env you run tox from) and place an sdist zip/tarball of the newer
    pip (from github) there.

::

    $ tox -c bench.ini

runs benchmarks.

.. _cython: http://cython.org
.. _tox: http://tox.testrun.org

Authors & Contributors
----------------------

* Mikhail Korobov <kmike84@gmail.com>

This module is based on `hat-trie`_ C library.

License
=======

Licensed under MIT License.
