# binary coercible POC

Forked from https://github.com/adjust/ajbool

This POC introduces three types:
- original unchanged `ajbool`
- new type `ajbool_bc` binary coercible when casting `bool` -> `ajbool_bc`

The goal is to check if using such a type while changing a column's type can
allow to skip table rewrite (as supported by documentation), and also skip
index rebuild (documentation is less clear on that end, especially on the
meaning for "the new index would be logically equivalent to the existing one"
part).

Documentation references:

- from https://www.postgresql.org/docs/current/sql-altertable.html#SQL-ALTERTABLE-NOTES

> Adding a column with a volatile DEFAULT or changing the type of an existing
> column will require the entire table and its indexes to be rewritten. As an
> exception, when changing the type of an existing column, if the USING clause
> does not change the column contents and the old type is either binary
> coercible to the new type or an unconstrained domain over the new type, a
> table rewrite is not needed. However, indexes must always be rebuilt unless
> the system can verify that the new index would be logically equivalent to the
> existing one. For example, if the collation for a column has been changed, an
> index rebuild is always required because the new sort order might be
> different. However, in the absence of a collation change, a column can be
> changed from text to varchar (or vice versa) without rebuilding the indexes
> because these data types sort identically. Table and/or index rebuilds may
> take a significant amount of time for a large table; and will temporarily
> require as much as double the disk space.

- from https://www.postgresql.org/docs/current/sql-createcast.html

> Two types can be binary coercible, which means that the conversion can be
> performed “for free” without invoking any function. This requires that
> corresponding values use the same internal representation. For instance, the
> types text and varchar are binary coercible both ways. Binary coercibility is
> not necessarily a symmetric relationship. For example, the cast from xml to
> text can be performed for free in the present implementation, but the reverse
> direction requires a function that performs at least a syntax check. (Two
> types that are binary coercible both ways are also referred to as binary
> compatible.)


# Build and run tests

Locally:
```
make && make install && make installcheck
```

Using PGXN tools docker image:
```
docker run -it --rm -w /repo --volume "$PWD:/repo" pgxn/pgxn-tools \
    sh -c 'pg-start 16 && pg-build-test'
```



