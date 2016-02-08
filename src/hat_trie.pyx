# cython: profile=True

from libc.math cimport NAN
from chat_trie cimport *

cimport cpython

cdef class BaseTrie:
    """
    Base HAT-Trie wrapper.
    """

    cdef hattrie_t* _trie

    def __cinit__(self):
        self._trie = hattrie_create()

    def __dealloc__(self):
        if self._trie:
            hattrie_free(self._trie)


    def __getitem__(self, bytes key):
        return self._getitem(key)

    def __setitem__(self, bytes key, int value):
        self._setitem(key, value)

    def __contains__(self, bytes key):
        return self._contains(key)

    def __len__(self):
        return hattrie_size(self._trie)

    def get(self, bytes key, value=-1):
        try:
            return self._getitem(key)
        except KeyError:
            return value

    def setdefault(self, bytes key, int value):
        return self._setdefault(key, value)

    def keys(self):
        return list(self.iterkeys())

    def iterkeys(self):
        cdef:
            hattrie_iter_t* it = hattrie_iter_begin(self._trie, 0)
            char* c_key
            size_t val
            size_t length
            bytes py_str

        try:
            while not hattrie_iter_finished(it):
                c_key = hattrie_iter_key(it, &length)
                py_str = c_key[:length]
                yield py_str
                hattrie_iter_next(it)

        finally:
            hattrie_iter_free(it)


    cdef value_t _getitem(self, char* key) except -1:
        cdef value_t* value_ptr = hattrie_tryget(self._trie, key, len(key))
        if value_ptr == NULL:
            raise KeyError(key)
        return value_ptr[0]

    cdef void _setitem(self, char* key, value_t value):
        hattrie_get(self._trie, key, len(key))[0] = value

    cdef value_t _setdefault(self, char* key, value_t value):
        cdef value_t* value_ptr = hattrie_tryget(self._trie, key, len(key))
        if value_ptr == NULL:
            self._setitem(key, value)
            return value
        return value_ptr[0]

    cdef bint _contains(self, char* key):
        cdef value_t* value_ptr = hattrie_tryget(self._trie, key, len(key))
        return value_ptr != NULL


cdef class IntTrie(BaseTrie):
    """
    HAT-Trie with unicode support that stores int as value.
    """

    # XXX: Internal encoding is hardcoded as UTF8. This is the fastest
    # encoding that can handle all unicode symbols and doesn't have
    # zero bytes.

    # This may seem sub-optimal because it is multibyte encoding;
    # single-byte language-specific encoding (such as cp1251)
    # seems to be faster. But this is not the case because:

    # 1) the bottleneck of this wrapper is string encoding, not trie traversal;
    # 2) python's unicode encoding utilities are optimized for utf8;
    # 3) users will have to select language-specific encoding for the trie;
    # 4) non-hardcoded encoding causes extra overhead and prevents cython
    #    optimizations.

    # That's why hardcoded utf8 is up to 9 times faster than configurable cp1251.

    # XXX: char-walking utilities may become tricky with multibyte
    # internal encoding.

    def __getitem__(self, unicode key):
        cdef bytes bkey = key.encode('utf8')
        return self._getitem(bkey)

    def __contains__(self, unicode key):
        cdef bytes bkey = key.encode('utf8')
        return self._contains(bkey)

    def __setitem__(self, unicode key, int value):
        cdef bytes bkey = key.encode('utf8')
        self._setitem(bkey, value)

    def get(self, unicode key, value=-1):
        cdef bytes bkey = key.encode('utf8')
        try:
            return self._getitem(bkey)
        except KeyError:
            return value

    def setdefault(self, unicode key, int value):
        cdef bytes bkey = key.encode('utf8')
        return self._setdefault(bkey, value)

    def iterkeys(self):
        for key in BaseTrie.iterkeys(self):
            yield key.decode('utf8')


cdef class FloatTrie(BaseTrie):
    """
    HAT-Trie with unicode support that stores float as value.
    """

    # XXX: uintptr_t is interpreted as a float32. This should work on all
    # systems with 32-bit or larger pointers, e.g. the majority of modern
    # computers. This will likely not work on embedded 8- and 16-bit
    # systems.

    def __getitem__(self, unicode key):
        cdef bytes bkey = key.encode('utf8')
        return self._fromvalue(self._getitem(bkey))

    def __contains__(self, unicode key):
        cdef bytes bkey = key.encode('utf8')
        return self._contains(bkey)

    def __setitem__(self, unicode key, float value):
        cdef bytes bkey = key.encode('utf8')
        self._setitem(bkey, self._tovalue(value))

    def get(self, unicode key, value=float('nan')):
        cdef bytes bkey = key.encode('utf8')
        try:
            return self._fromvalue(self._getitem(bkey))
        except KeyError:
            return value

    def setdefault(self, unicode key, float value):
        cdef bytes bkey = key.encode('utf8')
        return self._fromvalue(self._setdefault(bkey, self._tovalue(value)))

    def iterkeys(self):
        for key in BaseTrie.iterkeys(self):
            yield key.decode('utf8')

    cdef float _fromvalue(self, value_t value):
        cdef float* float_ptr = <float *> &value
        return float_ptr[0]

    cdef value_t _tovalue(self, float value):
        cdef value_t* value_ptr = <value_t *> &value
        return value_ptr[0]


cdef class Trie(BaseTrie):
    """
    HAT-Trie with unicode support and arbitrary values.
    """

    # XXX: Internal encoding is hardcoded as UTF8. See note in IntTrie
    # for more details.

    def __dealloc__(self):
        cdef hattrie_iter_t* it = hattrie_iter_begin(self._trie, 0)
        cdef cpython.PyObject *o

        try:
            while not hattrie_iter_finished(it):
                o = <cpython.PyObject *> hattrie_iter_val(it)[0]
                cpython.Py_XDECREF(o)
                hattrie_iter_next(it)

        finally:
            hattrie_iter_free(it)


    def __getitem__(self, unicode key):
        cdef bytes bkey = key.encode('utf8')
        return self._fromvalue(self._getitem(bkey))

    def __contains__(self, unicode key):
        cdef bytes bkey = key.encode('utf8')
        return self._contains(bkey)

    def __setitem__(self, unicode key, value):
        cdef bytes bkey = key.encode('utf8')
        self._setitem(bkey, self._tovalue(value))

    def get(self, unicode key, value=None):
        cdef bytes bkey = key.encode('utf8')
        try:
            return self._fromvalue(self._getitem(bkey))
        except KeyError:
            return value

    def setdefault(self, unicode key, value):
        cdef bytes bkey = key.encode('utf8')
        return self._setdefault(bkey, self._tovalue(value))

    def iterkeys(self):
        for key in BaseTrie.iterkeys(self):
            yield key.decode('utf8')

    cdef void _setitem(self, char* key, value_t value):
        cdef cpython.PyObject *o
        cdef value_t* value_ptr = hattrie_tryget(self._trie, key, len(key))
        if value_ptr != NULL:
            o = <cpython.PyObject *> value_ptr[0]
            cpython.Py_XDECREF(o)
        hattrie_get(self._trie, key, len(key))[0] = value

    cdef object _fromvalue(self, value_t value):
        cdef cpython.PyObject *o
        o = <cpython.PyObject *> value
        return <object> o

    cdef value_t _tovalue(self, object obj):
        cdef cpython.PyObject *o
        o = <cpython.PyObject *> obj
        cpython.Py_XINCREF(o)
        return <value_t> o
