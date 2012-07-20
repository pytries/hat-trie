# -*- coding: utf-8 -*-
from __future__ import absolute_import, unicode_literals
import string
import random

import pytest
import hat_trie

def test_get_set():
    trie = hat_trie.Trie('cp1251')
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

def test_contains():
    trie = hat_trie.Trie('1251')
    assert 'foo' not in trie
    trie['foo'] = 5
    assert 'foo' in trie
    assert 'f' not in trie


@pytest.mark.parametrize(("encoding",), [['cp1251'], ['utf8']])
def test_get_set_fuzzy(encoding):
    russian = 'абвгдеёжзиклмнопрстуфхцчъыьэюя'
    alphabet = russian.upper() + string.ascii_lowercase
    words = list(set([
        "".join([random.choice(alphabet) for x in range(random.randint(2,10))])
        for y in range(1000)
    ]))

    trie = hat_trie.Trie(encoding)

    enumerated_words = list(enumerate(words))

    for index, word in enumerated_words:
        trie[word] = index

    random.shuffle(enumerated_words)
    for index, word in enumerated_words:
        assert word in trie, word
        assert trie[word] == index, (word, index)

