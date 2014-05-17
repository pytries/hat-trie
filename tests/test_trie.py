# -*- coding: utf-8 -*-
from __future__ import absolute_import, unicode_literals
import string
import random

import pytest
import hat_trie

def test_getitem_set():
    trie = hat_trie.Trie()
    trie['foo'] = 5
    trie['bar'] = 10
    assert trie['foo'] == 5
    assert trie['bar'] == 10

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

    assert trie.get('foo') == -1
    assert trie.get('bar') == -1
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
