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

* In-Memory
* Redis (TODO)
* RDF Triplestore (TODO)	

To configure a Link Store. The following will instantiate a new instance, passing any 
additional options to the constructor of the store class:

	use LinkMiddleware::Filter, :store_impl => LinkMiddleware::MemoryStore

Or, initialize the middleware with an existing object:

	use LinkMiddleware::Filter, :store => LinkMiddleware::MemoryStore.new
	
Link Store implementations should have the following methods:

	add(context_uri, header)
	remove(context_uri, header)
	read(context_uri)
	
The header parameter passed to `add` and `remove` will be an instance of `LinkHeader` from the 
[link-header gem](https://github.com/asplake/link_header). This will have an array of links. Similarly 
the response from `read` should be a `LinkHeader` instance.

			
	
## Licence

Placed into the public domain under the unlicence. See `LICENCE.md`	