# -*- coding: utf-8 -*-
from __future__ import absolute_import, unicode_literals
import string
import random

import pytest
import hat_trie

def test_getitem_set():
    trie = hat_trie.BaseTrie()
    trie[b'foo'] = 5
    trie[b'bar'] = 10
    assert trie[b'foo'] == 5
    assert trie[b'bar'] == 10

    with pytest.raises(KeyError):
        trie[b'f']

    with pytest.raises(KeyError):
        trie[b'foob']

    with pytest.raises(KeyError):
        trie[b'x']

    non_ascii_key = 'вася'.encode('cp1251')
    trie[non_ascii_key] = 20
    assert trie[non_ascii_key] == 20

def test_get():
    trie = hat_trie.BaseTrie()

    assert trie.get(b'foo') == -1
    assert trie.get(b'bar') == -1
    assert trie.get(b'foo', 5) == 5

    trie[b'foo'] = 5
    trie[b'bar'] = 10

    assert trie.get(b'foo') == 5
    assert trie.get(b'bar') == 10

def test_contains():
    trie = hat_trie.BaseTrie()
    assert b'foo' not in trie
    trie[b'foo'] = 5
    assert b'foo' in trie
    assert b'f' not in trie

def test_len():
    trie = hat_trie.BaseTrie()
    assert len(trie) == 0
    trie[b'foo'] = 1
    assert len(trie) == 1
    trie[b'bar'] = 1
    assert len(trie) == 2
    trie[b'f'] = 1
    assert len(trie) == 3

def test_setdefault():
    trie = hat_trie.BaseTrie()

    with pytest.raises(KeyError):
        trie[b'foo']

    trie.setdefault(b'foo', 1)
    assert trie[b'foo'] == 1
    trie.setdefault(b'foo', 5)
    assert trie[b'foo'] == 1



@pytest.mark.parametrize(("encoding",), [['cp1251'], ['utf8']])
def test_get_set_fuzzy(encoding):
    russian = 'абвгдеёжзиклмнопрстуфхцчъыьэюя'
    alphabet = string.ascii_lowercase + russian.upper()
    words = list(set([
        "".join([random.choice(alphabet) for x in range(random.randint(2,10))])
        for y in range(20000)
    ]))

    words = [w.encode(encoding) for w in words]

    trie = hat_trie.BaseTrie()

    enumerated_words = list(enumerate(words))

    for index, word in enumerated_words:
        trie[word] = index

    random.shuffle(enumerated_words)
    for index, word in enumerated_words:
        assert word in trie, word
        assert trie[word] == index, (word, index)

    assert sorted(trie.keys()) == sorted(words)
