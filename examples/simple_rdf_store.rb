$:.unshift File.join( File.dirname(__FILE__), "..", "lib")
require 'sinatra'
require 'link-middleware'

opts = {
  :graph_base=>"http://127.0.0.1/graphs",
  :query_endpoint=>"http://127.0.0.1:3030/test/query",
  :update_endpoint=>"http://127.0.0.1:3030/test/update"
}

set :store, LinkMiddleware::SimpleRDFStore.new(opts)

use LinkMiddleware::Filter, :store => settings.store
use LinkMiddleware::Annotator, :store => settings.store

get '/' do
  'Hello World'
end