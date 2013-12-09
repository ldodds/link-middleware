require 'spec_helper'

describe LinkMiddleware::Filter do

  include Rack::Test::Methods

  let(:inner_app) do
    lambda { |env| [200, {'Content-Type' => 'text/plain'}, ['App'] ] }
  end

  let(:store) do
    LinkMiddleware::MemoryStore.new()
  end

  let(:app) {
    LinkMiddleware::Filter.new( inner_app, { :store => store }) 
  }

  it "should do nothing for a GET" do
    get "/"
    expect( last_response ).to be_ok
    expect( last_response.body ).to eql("App")
  end

  it "should return OK for a LINK request" do
    link "/"
    expect( last_response ).to be_ok
    expect( last_response.body ).to eql("OK")
  end

  it "should return OK for an UNLINK request" do
    unlink "/"
    expect( last_response ).to be_ok
    expect( last_response.body ).to eql("OK")
  end

  it "should echo back all links in a LINK request" do
    link "/", nil, { "HTTP_LINK" => 
    '<http://example.com/TheBook/chapter2>; rel="previous"; title="previous chapter"' }
    expect( last_response ).to be_ok
    expect( last_response.headers["HTTP_LINK"] ).to_not be("")
  end

  it "should echo back all links in an UNLINK request" do
    unlink "/", nil, { "HTTP_LINK" => 
    '<http://example.com/TheBook/chapter2>; rel="previous"; title="previous chapter"' }
    expect( last_response ).to be_ok
    expect( last_response.headers["HTTP_LINK"] ).to_not be("")      
  end

  it "should store all links in a LINK request" do
    link "/", nil, { "HTTP_LINK" => 
    '<http://example.com/TheBook/chapter2>; rel="previous"; title="previous chapter"' }
    links = store.read("http://example.org/")
    expect( links.links.length ).to eql(1) 
  end

  it "should remove all links in an UNLINK request" do
    link "/", nil, { "HTTP_LINK" => 
    '<http://example.com/TheBook/chapter2>; rel="previous"; title="previous chapter"' }
    unlink "/", nil, { "HTTP_LINK" => 
    '<http://example.com/TheBook/chapter2>; rel="previous"; title="previous chapter"' }
    links = store.read("http://example.org/")
    expect( links.links.length ).to eql(0)     
  end  

end