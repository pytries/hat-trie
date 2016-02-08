0.3 (2016-02-08)
----------------

* hat-trie C library is updated to the latest version (thanks Michael Phan-Ba);
* FloatTrie (thanks Michael Phan-Ba);
* Python 2.6 and Python 3.2 support is dropped. hat-trie 0.3 likely still works
  in 2.6 and 3.2, but this is no longer checked by unit tests, and
  future compatibility is not guaranteed;
* setup.py is switched to setuptools.


0.2 (2014-08-22)
----------------

* Installation is simplified: Cython is no longer required;
* ``get`` method for tries (thanks Brandon Forehand);
* ``iterkeys`` method is fixed (thanks Brandon Forehand);
* ``hat_trie.Trie`` can store any Python object as a value (thanks Brandon Forehand);
* segfault is fixed for large int values (thanks Brandon Forehand);
* hat-trie C library is updated to the latest version to fix some issues
  with 64bit builds and RHEL (thanks Brandon Forehand and Michael Heilman);

0.1 (2014-03-27)
----------------

Initial release.
