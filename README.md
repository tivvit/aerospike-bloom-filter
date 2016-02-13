# Aerospike Bloom filter UDF module

Storage based on probabilistic structure [Bloom filter](https://en.wikipedia.org/wiki/Bloom_filter)

Suitable for storing huge amount of data and quering if element is present or not

## CAUTION 

This module is based on:
https://github.com/mozilla-services/lua_bloom_filter
but it uses specific serialization methods (https://github.com/mozilla-services/lua_bloom_filter/pull/4)

This module uses Aerospike's `bytes.get_string()` which causes memory leaks (https://github.com/aerospike/aerospike-mod-lua/pull/3)

### Installation

- Compile lua_bloom_filter (described in the project)
- Upload so module to Aerospike `echo "REGISTER MODULE '/path_to_repo/lua_bloom_filter/release/bloom_filter.so'" | aql`
- Upload UDF to Aerospike `echo "REGISTER MODULE '/path_to_repo/bloom.lua'" | aql`

### Usage

Use Aerospike apply

Module: bloom

Method: add

Example in python:
```python
as_client.apply(key, "bloom", "add", ["bin", value])) #returns 0 if not found, 1 if found
```

Default size is **10000** elements with precision **0.01**, which are defined on first lines of the code.
I did not want to pass them as parameter with every request, if you have better idea how to solve that fell free to open issue or PR.

### Development

Feel free to contribute.

### Copyright and License

&copy; 2016 [Vít Listík](http://tivvit.cz)

Released under [MIT licence](https://github.com/tivvit/aerospike-bloom-filter/blob/master/LICENSE)
