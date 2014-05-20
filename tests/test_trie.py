# -*- coding: utf-8 -*-
from __future__ import absolute_import, unicode_literals
import string
import random

import pytest
import hat_trie

def test_getitem_set():
    trie = hat_trie.Trie()
    trie['foo'] = 5
    trie['bar'] = 'asdf'
    trie['baz'] = (10, 'quuz')
    assert trie['foo'] == 5
    assert trie['bar'] == 'asdf'
    assert trie['baz'] == (10, 'quuz')

    with pytest.raises(KeyError):
        trie['f']

    with pytest.raises(KeyError):
        trie['foob']

    with pytest.raises(KeyError):
        trie['x']

    non_ascii_key = 'вася'
    trie[non_ascii_key] = 20
    assert trie[non_ascii_key] == 20

def test_get():
    trie = hat_trie.Trie()

    assert trie.get('foo') is None 
    assert trie.get('bar') is None
    assert trie.get('foo', 5) == 5

    trie['foo'] = 5
    trie['bar'] = 10

    assert trie.get('foo') == 5
    assert trie.get('bar') == 10

def test_contains():
    trie = hat_trie.Trie()
    assert 'foo' not in trie
    trie['foo'] = 5
    assert 'foo' in trie
    assert 'f' not in trie

def test_iterkeys():
    trie = hat_trie.Trie()

    non_ascii_key = 'вася'
    trie[non_ascii_key] = 20

    assert next(trie.iterkeys()) == non_ascii_key

def test_get_set_fuzzy():
    russian = 'абвгдеёжзиклмнопрстуфхцчъыьэюя'
    alphabet = russian.upper() + string.ascii_lowercase
    words = list(set([
        "".join([random.choice(alphabet) for x in range(random.randint(2,10))])
        for y in range(20000)
    ]))

    trie = hat_trie.Trie()

    enumerated_words = list(enumerate(words))

    for index, word in enumerated_words:
        trie[word] = index

    random.shuffle(enumerated_words)
    for index, word in enumerated_words:
        assert word in trie, word
        assert trie[word] == index, (word, index)

    assert sorted(trie.keys()) == sorted(words)

def test_leak():
    import sys

    values = list(string.ascii_lowercase)
    # Using "list(map())" to avoid the list comprehension variable
    # which increases the reference count.
    counts = list(map(sys.getrefcount, values))

    trie = hat_trie.Trie()

    for v in values:
        trie['foo'] = v
    # Python's for loop variables leak scope into the function body
    del v

    count = sys.getrefcount(trie['foo'])
    for i in range(10):
        current_count = sys.getrefcount(trie['foo'])
        assert current_count == count

    count0 = sys.getrefcount(values[0])
    count_last = sys.getrefcount(values[-1])
    assert count0 == counts[0]
    assert count_last == counts[-1] + 1

    del trie

    after = list(map(sys.getrefcount, values))
    assert after == counts
