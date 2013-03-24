cdef extern from "../hat-trie/src/hat-trie.h":

    ctypedef int value_t
    ctypedef int size_t

    ctypedef struct hattrie_t:
        pass

    hattrie_t* hattrie_create ()                 # Create an empty hat-trie.
    void       hattrie_free   (hattrie_t*)       # Free all memory used by a trie.
    hattrie_t* hattrie_dup    (hattrie_t*)       # Duplicate an existing trie.
    void       hattrie_clear  (hattrie_t*)       # Remove all entries.


    # Find the given key in the trie, inserting it if it does not exist, and
    # returning a pointer to it's key.
    # This pointer is not guaranteed to be valid after additional calls to
    # hattrie_get, hattrie_del, hattrie_clear, or other functions that
    # modifies the trie.
    value_t* hattrie_get (hattrie_t*, char* key, size_t len)

    # Find a given key in the table, returning a NULL pointer if it does not exist.
    value_t* hattrie_tryget (hattrie_t*, char* key, size_t len)

    ctypedef struct hattrie_iter_t:
        pass

    hattrie_iter_t* hattrie_iter_begin     (hattrie_t*, bint sorted)
    void            hattrie_iter_next      (hattrie_iter_t*)
    bint            hattrie_iter_finished  (hattrie_iter_t*)
    void            hattrie_iter_free      (hattrie_iter_t*)
    char*           hattrie_iter_key       (hattrie_iter_t*, size_t* len)
    value_t*        hattrie_iter_val       (hattrie_iter_t*)

cdef struct hattrie_t_:
    void* root
    size_t m      # number of stored keys
