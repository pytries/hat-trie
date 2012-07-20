# cython: profile=True

cimport chat_trie

cdef class BaseTrie:
    """
    Base HAT-Trie wrapper.
    """

    cdef chat_trie.hattrie_t* _trie

    def __cinit__(self):
        self._trie = chat_trie.hattrie_create()

    def __dealloc__(self):
        if self._trie:
            chat_trie.hattrie_free(self._trie)



    def __getitem__(self, bytes key):
        return self._getitem(key)

    def __setitem__(self, bytes key, int value):
        self._setitem(key, value)

    def __contains__(self, bytes key):
        return self._contains(key)

    def __len__(self):
        return (<chat_trie._hattrie_t*> self._trie).m

    def setdefault(self, bytes key, int value):
        return self._setdefault(key, value)


    cdef int _getitem(self, char* key) except -1:
        cdef chat_trie.value_t* value_ptr = chat_trie.hattrie_tryget(self._trie, key, len(key))
        if value_ptr == NULL:
            raise KeyError(key)
        return value_ptr[0]

    cdef void _setitem(self, char* key, chat_trie.value_t value):
        chat_trie.hattrie_get(self._trie, key, len(key))[0] = value

    cdef int _setdefault(self, char* key, chat_trie.value_t value):
        cdef chat_trie.value_t* value_ptr = chat_trie.hattrie_tryget(self._trie, key, len(key))
        if value_ptr == NULL:
            self._setitem(key, value)
            return value
        return value_ptr[0]

    cdef bint _contains(self, char* key):
        cdef chat_trie.value_t* value_ptr = chat_trie.hattrie_tryget(self._trie, key, len(key))
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
        self._setdefault(bkey, value)
