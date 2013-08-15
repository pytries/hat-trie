# cython: profile=True

from chat_trie cimport *

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
        return (<hattrie_t_*> self._trie).m

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


    cdef int _getitem(self, char* key) except -1:
        cdef value_t* value_ptr = hattrie_tryget(self._trie, key, len(key))
        if value_ptr == NULL:
            raise KeyError(key)
        return value_ptr[0]

    cdef void _setitem(self, char* key, value_t value):
        hattrie_get(self._trie, key, len(key))[0] = value

    cdef int _setdefault(self, char* key, value_t value):
        cdef value_t* value_ptr = hattrie_tryget(self._trie, key, len(key))
        if value_ptr == NULL:
            self._setitem(key, value)
            return value
        return value_ptr[0]

    cdef bint _contains(self, char* key):
        cdef value_t* value_ptr = hattrie_tryget(self._trie, key, len(key))
        return value_ptr != NULL


cdef class Trie(BaseTrie):
    """
    HAT-Trie with unicode support.

    XXX: Internal encoding is hardcoded as UTF8. This is the fastest
    encoding that can handle all unicode symbols and doesn't have
    zero bytes.

    This may seem sub-optimal because it is multibyte encoding;
    single-byte language-specific encoding (such as cp1251)
    seems to be faster. But this is not the case because:

    1) the bottleneck of this wrapper is string encoding, not trie traversal;
    2) python's unicode encoding utilities are optimized for utf8;
    3) users will have to select language-specific encoding for the trie;
    4) non-hardcoded encoding causes extra overhead and prevents cython
       optimizations.

    That's why hardcoded utf8 is up to 9 times faster than configurable cp1251.

    XXX: char-walking utilities may become tricky with multibyte
    internal encoding.
    """

    def __getitem__(self, unicode key):
        cdef bytes bkey = key.encode('utf8')
        return self._getitem(bkey)

    def __contains__(self, unicode key):
        cdef bytes bkey = key.encode('utf8')
        return self._contains(bkey)

    def __setitem__(self, unicode key, int value):
        cdef bytes bkey = key.encode('utf8')
        self._setitem(bkey, value)

    def setdefault(self, unicode key, int value):
        cdef bytes bkey = key.encode('utf8')
        return self._setdefault(bkey, value)

    def keys(self):
        return [key.decode('utf8') for key in self.iterkeys()]
