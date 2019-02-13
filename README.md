EscherLua - HTTP request signing lib [![Build Status](https://travis-ci.org/emartech/escher-lua.svg?branch=master)](https://travis-ci.org/emartech/escher-lua)
====================================

Lua implementation of the [AWS4](http://docs.aws.amazon.com/general/latest/gr/sigv4_signing.html) compatible [Escher](https://github.com/emartech/escher) HTTP request signing and authentication library. The library is compatible with the [Nginx's HttpLuaModule](http://wiki.nginx.org/HttpLuaModule) and [Openresty](http://openresty.org/).

We are using it for our OpenResty based API gateway server for authenticating the requests, and route the request to our microservices with a different signature.

Prerequisite
------------

In order to run the tests, Lua, LuaRocks and some libraries must be installed.

Setup
-----

Some tips to setup the local development environment on a Mac:

```bash
brew install lua
brew install cmake
brew install openssl
luarocks-5.2 install luafilesystem 1.6.3-2
luarocks-5.2 install busted
luarocks-5.2 install luasocket
luarocks-5.2 install rapidjson 0.4.5-1
luarocks-5.2 install luacrypto 0.3.2-2 OPENSSL_INCDIR=/usr/local/Cellar/openssl/1.0.2j/include
luarocks-5.2 install date 2.1.1-1
```



Run the tests
-------------

To run all the tests, use the `LUA="luajit" LUA_PATH="lib/?.lua;;" busted` command.

About Escher
------------

More details are available at our [Escher documentation site](http://escherauth.io/).
