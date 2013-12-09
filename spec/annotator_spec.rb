require 'spec_helper'

describe LinkMiddleware::Annotator do

  include Rack::Test::Methods

  let(:inner_app) do
    lambda { |env| [200, {'Content-Type' => 'text/plain'}, ['App'] ] }
  end

  let(:store) do
    LinkMiddleware::MemoryStore.new()
  end

  let(:app) {
    LinkMiddleware::Annotator.new( inner_app, { :store => store }) 
  }

  it "should add nothing if there are no links" do
    get "/"
    expect( last_response ).to be_ok
    expect( last_response.headers["HTTP_LINK"] ).to be(nil)
  end

  it "should echo back all links in a LINK request" do
    store.add("http://example.org/", 
      LinkHeader.new([ LinkHeader::Link.new( "http://example.com/foo", [["rel", "self"]] ) ] ))        
    get "/"
    expect( last_response ).to be_ok    
    expect( last_response.headers["Link"] ).to_not be(nil)
  end

end