cimport chat_trie

cdef class BaseTrie:

    cdef chat_trie.hattrie_t* _trie

    def __cinit__(self):
        self._trie = chat_trie.hattrie_create()

    def __dealloc__(self):
        if self._trie:
            chat_trie.hattrie_free(self._trie)

    def __getitem__(self, bytes key):
        return self._getitem(key)

    cdef int _getitem(self, bytes key) except -1:
        cdef char* c_key = key
        cdef chat_trie.value_t* value_ptr = chat_trie.hattrie_tryget(self._trie, c_key, len(c_key))
        if value_ptr == NULL:
            raise KeyError(key)
        return value_ptr[0]

    def __setitem__(self, bytes key, int value):
        self._setitem(key, value)

    cdef void _setitem(self, bytes key, chat_trie.value_t value):
        chat_trie.hattrie_get(self._trie, key, len(key))[0] = value

    def __contains__(self, bytes key):
        return self._contains(key)

    cdef bint _contains(self, bytes key):
        cdef chat_trie.value_t* value_ptr = chat_trie.hattrie_tryget(self._trie, key, len(key))
        return value_ptr != NULL


cdef class Trie(BaseTrie):
    cdef unicode encoding

    def __init__(self, encoding='latin1'):
        self.encoding = encoding

    def __getitem__(self, unicode key):
        return self._getitem(key.encode(self.encoding))

    def __contains__(self, unicode key):
        return self._contains(key.encode(self.encoding))

    def __setitem__(self, unicode key, int value):
        self._setitem(key.encode(self.encoding), value)
