#!/usr/bin/env python
import os
from distutils.core import setup
from distutils.extension import Extension

HATTRIE_DIR = 'hat-trie/src'
HATTRIE_FILE_NAMES = ['ahtable.c', 'hat-trie.c', 'misc.c', 'murmurhash3.c']
HATTRIE_FILES = [os.path.join(HATTRIE_DIR, name) for name in HATTRIE_FILE_NAMES]

setup(
    name="hat-trie",
    version="0.2",
    description="HAT-Trie for Python",
    long_description = open('README.rst').read() + "\n\n" + open('CHANGES.rst').read(),
    author='Mikhail Korobov',
    author_email='kmike84@gmail.com',
    url='https://github.com/kmike/hat-trie/',

    ext_modules = [
        Extension(
            "hat_trie",
            ['src/hat_trie.c', 'src/chat_trie.c'] + HATTRIE_FILES,
            include_dirs=['hat-trie/src'],
        )
    ],

    classifiers=[
        'Development Status :: 3 - Alpha',
        'Intended Audience :: Developers',
        'Intended Audience :: Science/Research',
        'License :: OSI Approved :: MIT License',
        'Programming Language :: Cython',
        'Programming Language :: Python',
        'Programming Language :: Python :: 2',
        'Programming Language :: Python :: 2.6',
        'Programming Language :: Python :: 2.7',
        'Programming Language :: Python :: 3',
        'Programming Language :: Python :: 3.2',
        'Programming Language :: Python :: 3.3',
        'Programming Language :: Python :: 3.4',
        'Programming Language :: Python :: Implementation :: CPython',
        'Topic :: Software Development :: Libraries :: Python Modules',
        'Topic :: Scientific/Engineering :: Information Analysis',
        'Topic :: Text Processing :: Linguistic',
    ],
)
