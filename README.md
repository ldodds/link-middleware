# Rack Middleware for LINK/UNLINK

Provides a simple implementation of [HTTP Link and Unlink Methods draft-snell-link-method-08](http://tools.ietf.org/html/draft-snell-link-method-08) 
as configurable [Rack](http://rack.github.io/) middle-ware.
 
The code provides an easy way to instrument any existing Rack based application with support for the 
`LINK` and `UNLINK` HTTP Methods.

## Installation

Add the gem into your Gemfile:

    gem 'link-middleware', :git => "git://github.com/ldodds/link-middleware.git"

Or:

	sudo gem install link-middleware

## Basic Usage

There are two separate middleware components: 

* `LinkMiddleware::Filter` -- provides the basic LINK/UNLINK support
* `LinkMiddleware::Annotator` --- provides support for annotating requests with stored links

Here is a simple example see: `examples/simple.rb`

	require 'sinatra'
	require 'link-middleware'
	
	set :store, LinkMiddleware::MemoryStore.new
	
	use LinkMiddleware::Filter, :store => settings.store
	use LinkMiddleware::Annotator, :store => settings.store
	
	get '/' do
	  'Hello World'
	end

The `Filter` middleware will intercept and process `LINK` and `UNLINK` requests.

The `Annotator` middleware will automatically annotate responses to `/` with any stored links.

The middleware is configured to use a shared in-memory store. To make this persistent across 
HTTP connections the store instance is cached as a Sinatra setting

## Link Store Implementations

The gem is bundled with several different ways to store links for resources:

* In-Memory -- suitable for testing only, all data held in memory in a Hash
* [Redis](http://redis.io) -- stores all links in Redis Sets (see below)
* RDF Triplestore (TODO) -- stores links in a SPARQL 1.1 compliant triple store

### Configuring the Implementation

Middleware components will default to using an in-memory store. To configure your preferred 
implementation you need to provide some options to the middleware. One approach is to 
ask the middleware component to create a class for you:

	use LinkMiddleware::Filter, :store_impl => LinkMiddleware::MemoryStore

Any additional options provided to the `use` keyword will be passed as a Hash to the store 
constructor. This is really only useful if you're using a single component, but not if 
you're using both as they will end up using separate instances. 

In this case you should provide a pre-initialized store as follows:

	use LinkMiddleware::Filter, :store => LinkMiddleware::MemoryStore.new

You can then configure the instance however you like.

### The Redis Link Store

E.g:

	use LinkMiddleware::Filter, :store => LinkMiddleware::RedisStore.new

The `RedisStore` constructor will automatically construct a client that will 
connect to a local Redis instance on the default port. To configure details such as 
host name, port, password, etc provide a Hash to the constructor of the store. 

E.g:

	store = LinkMiddleware::RedisStore.new :host => "...", :port => ..., :password => "..."

Read the [redis.rb](https://github.com/redis/redis-rb) documentation for configuration 
options

### Implementing a new Link Store

Link Store implementations should have the following methods:

	add(context_uri, header)
	remove(context_uri, header)
	read(context_uri)
	
The header parameter passed to `add` and `remove` will be an instance of `LinkHeader` from the 
[link-header gem](https://github.com/asplake/link_header). This will have an array of links. Similarly 
the response from `read` should be a `LinkHeader` instance.

The constructor should also accept a Hash of options for configuration.

## Licence

Placed into the public domain under the unlicence. See `LICENCE.md`	
