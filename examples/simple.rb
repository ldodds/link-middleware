$:.unshift File.join( File.dirname(__FILE__), "..", "lib")
require 'sinatra'
require 'link-middleware'

set :store, LinkMiddleware::MemoryStore.new

use LinkMiddleware::Filter, :store => settings.store
use LinkMiddleware::Annotator, :store => settings.store

get '/' do
  'Hello World'
end