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
* Simple RDF Triplestore -- stores links as resource relations in a SPARQL 1.1 compliant triple store

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

### The Simple RDF Link Store

The simple RDF store is not completely compliant to the RFC. It is intended to support the use case 
where the link relationships provided in `LINK` (and `UNLINK`) requests are describe relationships 
between resources.

The `rel` attribute of the link will be the URI of the predicate to be created.

E.g. sending this link header to `http://example.org/resource/1`:

	Link: <http://example.com/resource/1>; rel="http://www.w3.org/2002/07/owl#sameAs";

Will add this triple to the store:

	<http://example.org/resource/1> <http://www.w3.org/2002/07/owl#sameAs> <http://example.com/resource/1>.

Link attributes other than `rel` will be ignored.

The store implementation uses several design patterns:

* [Graph Per Resource](http://patterns.dataincubator.org/book/graph-per-resource.html) -- the links for each 
resource are stored in a separate Named Graph
* [Rebased URI](http://patterns.dataincubator.org/book/rebased-uri.html) -- Named graph URIs are automatically 
derived from the context URI and a base URI provided in the store constructor

The following will create middleware backed by an SPARQL 1.1 compliant endpoint. Both parameters 
are required. The first is the base URI for the named graphs, the second the URL of the SPARQL 
endpoint:

	opts = {
		:graph_base => "...",
		:endpoint => "..."
	}
	use LinkMiddleware::Filter, :store => LinkMiddleware::SimpleRDFStore(opts)
	
By default, [Fusek](http://jena.apache.org/documentation/serving_data/) uses separate query and update 
endpoints. These can be explicitly configured:

	opts = {
		:graph_base => "...",
		:query_endpoint => "...",
		:update_endpoint => "..."
	}
	use LinkMiddleware::Filter, :store => LinkMiddleware::SimpleRDFStore(opts)

#### Potential Improvements	
	
* A more compliant RDF store could be created. To capture all link attributes the store would need to 
use a [qualified relation](http://patterns.dataincubator.org/book/qualified-relation.html) between the 
linked resources, rather than a simple binary predicate.

* Use an alternate storage option, e.g. [Graph Per Source](http://patterns.dataincubator.org/book/graph-per-source.html), storing links by their origin rather than by 
resource. This would make provenance more explicit but would require some form of authentication. 

* Support filtering of links, to only allow storage of certain predicates or link patterns

#### Benefits

This approach provides the means for Linked Data publishers to exchange links with one another in a 
controlled way: 

* No special protocol or exchange mechanism is required: HTTP requests are made directly to the resources to which 
links are being provided
* Links can be automatically captured and stored separately to core data, e.g. as a separate link site. 
This allows link information to be exposed in a controlled way  
	
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
