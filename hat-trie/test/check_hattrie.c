
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#include "str_map.h"
#include "../src/hat-trie.h"

/* Simple random string generation. */
void randstr(char* x, size_t len)
{
    x[len] = '\0';
    while (len > 0) {
        x[--len] = '\x20' + (rand() % ('\x7e' - '\x20' + 1));
    }
}

const size_t n = 100000;  // how many unique strings
const size_t m_low  = 50;  // minimum length of each string
const size_t m_high = 500; // maximum length of each string
const size_t k = 200000;  // number of insertions
const size_t d = 50000;

char** xs;
char** ds;

hattrie_t* T;
str_map* M;
int have_error = 0;

void setup()
{
    fprintf(stderr, "generating %zu keys ... ", n);
    xs = malloc(n * sizeof(char*));
    ds = malloc(d * sizeof(char*));
    size_t i;
    size_t m;
    for (i = 0; i < n; ++i) {
        m = m_low + rand() % (m_high - m_low);
        xs[i] = malloc(m + 1);
        randstr(xs[i], m);
    }
    for (i = 0; i < d; ++i) {
        m = rand()%n;
        ds[i] = xs[m];
    }

    T = hattrie_create();
    M = str_map_create();
    fprintf(stderr, "done.\n");
}


void teardown()
{
    hattrie_free(T);
    str_map_destroy(M);

    size_t i;
    for (i = 0; i < n; ++i) {
        free(xs[i]);
    }
    free(xs);
    free(ds);
}


void test_hattrie_insert()
{
    fprintf(stderr, "inserting %zu keys ... \n", k);

    size_t i, j;
    value_t* u;
    value_t  v;

    for (j = 0; j < k; ++j) {
        i = rand() % n;


        v = 1 + str_map_get(M, xs[i], strlen(xs[i]));
        str_map_set(M, xs[i], strlen(xs[i]), v);


        u = hattrie_get(T, xs[i], strlen(xs[i]));
        *u += 1;


        if (*u != v) {
            fprintf(stderr, "[error] tally mismatch (reported: %lu, correct: %lu)\n",
                            *u, v);
            have_error = 1;
        }
    }

    fprintf(stderr, "deleting %zu keys ... \n", d);
    for (j = 0; j < d; ++j) {
        str_map_del(M, ds[j], strlen(ds[j]));
        hattrie_del(T, ds[j], strlen(ds[j]));
        u = hattrie_tryget(T, ds[j], strlen(ds[j]));
        if (u) {
            fprintf(stderr, "[error] item %zu still found in trie after delete\n",
                    j);
            have_error = 1;
        }
    }

    fprintf(stderr, "done.\n");
}



void test_hattrie_iteration()
{
    fprintf(stderr, "iterating through %zu keys ... \n", k);

    hattrie_iter_t* i = hattrie_iter_begin(T, false);

    size_t count = 0;
    value_t* u;
    value_t  v;

    size_t len;
    const char* key;

    while (!hattrie_iter_finished(i)) {
        ++count;

        key = hattrie_iter_key(i, &len);
        u   = hattrie_iter_val(i);

        v = str_map_get(M, key, len);

        if (*u != v) {
            if (v == 0) {
                fprintf(stderr, "[error] incorrect iteration (%lu, %lu)\n", *u, v);
                have_error = 1;
            }
            else {
                fprintf(stderr, "[error] incorrect iteration tally (%lu, %lu)\n", *u, v);
                have_error = 1;
            }
        }

        // this way we will see an error if the same key is iterated through
        // twice
        str_map_set(M, key, len, 0);

        hattrie_iter_next(i);
    }

    if (count != M->m) {
        fprintf(stderr, "[error] iterated through %zu element, expected %zu\n",
                count, M->m);
        have_error = 1;
    }

    hattrie_iter_free(i);

    fprintf(stderr, "done.\n");
}


int cmpkey(const char* a, size_t ka, const char* b, size_t kb)
{
    int c = memcmp(a, b, ka < kb ? ka : kb);
    return c == 0 ? (int) ka - (int) kb : c;
}


void test_hattrie_sorted_iteration()
{
    fprintf(stderr, "iterating in order through %zu keys ... \n", k);

    hattrie_iter_t* i = hattrie_iter_begin(T, true);

    size_t count = 0;
    value_t* u;
    value_t  v;

    char* key_copy = malloc(m_high + 1);
    char* prev_key = malloc(m_high + 1);
    memset(prev_key, 0, m_high + 1);
    size_t prev_len = 0;

    const char *key = NULL;
    size_t len = 0;

    while (!hattrie_iter_finished(i)) {
        memcpy(prev_key, key_copy, len);
        prev_key[len] = '\0';
        prev_len = len;
        ++count;

        key = hattrie_iter_key(i, &len);

        /* memory for key may be changed on iter, copy it */
        strncpy(key_copy, key, len);

        if (prev_key != NULL && cmpkey(prev_key, prev_len, key, len) > 0) {
            fprintf(stderr, "[error] iteration is not correctly ordered.\n");
            have_error = 1;
        }

        u = hattrie_iter_val(i);
        v = str_map_get(M, key, len);

        if (*u != v) {
            if (v == 0) {
                fprintf(stderr, "[error] incorrect iteration (%lu, %lu)\n", *u, v);
                have_error = 1;
            }
            else {
                fprintf(stderr, "[error] incorrect iteration tally (%lu, %lu)\n", *u, v);
                have_error = 1;
            }
        }

        // this way we will see an error if the same key is iterated through
        // twice
        str_map_set(M, key, len, 0);

        hattrie_iter_next(i);
    }

    if (count != M->m) {
        fprintf(stderr, "[error] iterated through %zu element, expected %zu\n",
                count, M->m);
        have_error = 1;        
    }

    hattrie_iter_free(i);
    free(prev_key);
    free(key_copy);

    fprintf(stderr, "done.\n");
}


void test_trie_non_ascii()
{
    fprintf(stderr, "checking non-ascii... \n");

    value_t* u;
    hattrie_t* T = hattrie_create();
    char* txt = "\x81\x70";

    u = hattrie_get(T, txt, strlen(txt));
    *u = 10;

    u = hattrie_tryget(T, txt, strlen(txt));
    if (*u != 10){
        fprintf(stderr, "can't store non-ascii strings\n");
    }
    hattrie_free(T);

    fprintf(stderr, "done.\n");
}


typedef struct {
    int size;
    size_t lens[10];
    value_t vals[10];
} trie_walk_data_t;


static int trie_walk_cb(const char* key __attribute__((unused)), size_t len, value_t* val, void* data) {
    trie_walk_data_t* d = data;
    d->lens[d->size] = len;
    d->vals[d->size] = *val;
    d->size++;
    return hattrie_walk_continue;
}


void test_trie_walk()
{
    fprintf(stderr, "checking tryget_longest_match... \n");

    hattrie_t* T = hattrie_create();
    char* txt1 = "hello world1";
    char* txt2 = "hello world2";
    char* txt3 = "hello";
    value_t* val;

    val = hattrie_get(T, txt1, strlen(txt1));
    *val = 1;
    val = hattrie_get(T, txt2, strlen(txt2));
    *val = 2;
    val = hattrie_get(T, txt3, strlen(txt3));
    *val = 3;

#define EXPECT(check) \
    if (!(check)) {\
        fprintf(stderr, "[error] %s:%d: expect failure\n", __FILE__, __LINE__);\
        have_error = 1;\
    }

    trie_walk_data_t data = {
        .size = 0
    };
    char* txt = "hello world20";
    hattrie_walk(T, txt, strlen(txt), &data, trie_walk_cb);
    EXPECT(data.size == 2);
    EXPECT(data.lens[0] = strlen(txt3));
    EXPECT(data.vals[0] == 3);
    EXPECT(data.lens[1] = strlen(txt2));
    EXPECT(data.vals[1] == 2);
#undef EXPECT

    hattrie_free(T);
}



int main()
{
    test_trie_non_ascii();
    test_trie_walk();

    setup();
    test_hattrie_insert();
    test_hattrie_iteration();
    teardown();

    setup();
    test_hattrie_insert();
    test_hattrie_sorted_iteration();
    teardown();

    if (have_error) {
        return -1;
    }
    return 0;
}
