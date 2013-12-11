require 'spec_helper'
require 'webmock/rspec'

describe LinkMiddleware::SimpleRDFStore do
  
  before(:each) do    
    @store = LinkMiddleware::SimpleRDFStore.new( 
        :endpoint=>"http://localhost:6661",
        :graph_base=>"http://localhost:6661/graphs")
        
  end
  
  it "should generate correct graph uris" do
    expect( @store.graph_uri( "http://example.org") ).to eql("http://localhost:6661/graphs;http://example.org")
    
    @store = LinkMiddleware::SimpleRDFStore.new( 
            :endpoint=>"http://localhost:6661",
            :graph_base=>"http://localhost:6661")
                
    expect( @store.graph_uri( "http://example.org") ).to eql("http://localhost:6661/;http://example.org")            
  end
  
  it "should correctly generate predicates for registered relations" do
    link = LinkHeader::Link.new( "http://example.com/foo", [["rel", "about"]] )
    expect( @store.predicate( link ) ).to eql(
        RDF::URI.new("http://www.iana.org/assignments/link-relations/link-relations.xhtml#about") )      
  end
  
  it "should correctly generate predicates for unregistered relations" do
    link = LinkHeader::Link.new( "http://example.com/foo", [["rel", "http://example.com/predicate"]] )
    expect( @store.predicate( link ) ).to eql(
        RDF::URI.new("http://example.com/predicate") )      
  end

  describe "when using simple links" do
    before(:each) do    
      @store = LinkMiddleware::SimpleRDFStore.new( 
          :endpoint=>"http://localhost:6661",
          :graph_base=>"http://localhost:6661/graphs",
          :reify_links=>false)
    end
        
    it "should generate the correct graph" do
      link = LinkHeader::Link.new( "http://example.com/foo", [["rel", "http://example.com/predicate"]] )
      header = LinkHeader.new( [ link ] )
      
      graph = @store.header_to_graph("http://example.com/bar", header)
      
      statement = RDF::Statement.new( RDF::URI.new("http://example.com/bar" ), 
          RDF::URI.new("http://example.com/predicate"), RDF::URI.new("http://example.com/foo") )
      expect( graph.include?(statement) ).to eql(true)
      expect( graph.size ).to eql(1)
    end
        
    it "should store links" do
      stub_request(:post, "http://localhost:6661/").
               with(
                 :body => {"update"=>"INSERT DATA { GRAPH <http://localhost:6661/graphs;http://example.com/bar> {\n<http://example.com/bar> <http://example.com/predicate> <http://example.com/foo> .\n}}\n"}
                 ).to_return(:status => 200, :body => "", :headers => {})
                       
      link = LinkHeader::Link.new( "http://example.com/foo", [["rel", "http://example.com/predicate"]] )
      header = LinkHeader.new( [ link ] )
      result = @store.add("http://example.com/bar", header)
            
      expect( result ).to eql(true)
      a_request(:post, "localhost:6661").should have_been_made
    end
    
    it "should retrieve stored links" do     
      json = {
      "head" => {
        "vars" => [ "p" , "o" ]
      } ,
      "results" => {
        "bindings"=> [
          {
            "p" => { "type"=>"uri" , "value"=>"http://b.org" } ,
            "o" => { "type"=>"uri" , "value"=>"http://c.org" }
          }
        ]
      }
    }
      stub_request(:post, "http://localhost:6661/").
        with(:body => {"query"=>"SELECT ?p ?o WHERE { GRAPH <http://localhost:6661/graphs;http://example.com/bar> { <http://example.com/bar> ?p ?o. } }"}).
      to_return(:status => 200, :body => json.to_json, :headers=>{"Content-Type"=>"application/sparql-results+json"})
             
      header = @store.read("http://example.com/bar")
      a_request(:post, "localhost:6661").should have_been_made
      expect( header.links.length ).to eql(1)
    end
    
    
    it "should remove links" do
      stub_request(:post, "http://localhost:6661/").
               with(:body => {"query"=>"ASK WHERE { GRAPH <http://localhost:6661/graphs;http://example.com/bar> { <http://example.com/bar> <http://example.com/predicate> <http://example.com/foo> ."}).
               to_return(:status => 200, :body => { "boolean" => true }.to_json, 
      :headers=>{"Content-Type"=>"application/sparql-results+json"})
      
      stub_request(:post, "http://localhost:6661/").
               with(
                 :body => {"update"=>"DELETE DATA { GRAPH <http://localhost:6661/graphs;http://example.com/bar> {\n<http://example.com/bar> <http://example.com/predicate> <http://example.com/foo> .\n}}\n"}
                 ).to_return(:status => 200, :body => "", :headers => {})
                       
      link = LinkHeader::Link.new( "http://example.com/foo", [["rel", "http://example.com/predicate"]] )
      header = LinkHeader.new( [ link ] )
      result = @store.remove("http://example.com/bar", header)
            
      expect( result ).to eql(true)
      a_request(:post, "localhost:6661").should have_been_made.twice      
    end
    
    it "should not remove any links if they're not all present" do
      stub_request(:post, "http://localhost:6661/").
               with(:body => {"query"=>"ASK WHERE { GRAPH <http://localhost:6661/graphs;http://example.com/bar> { <http://example.com/bar> <http://example.com/predicate> <http://example.com/foo> ."}).
               to_return(:status => 200, :body => { "boolean" => false }.to_json, 
      :headers=>{"Content-Type"=>"application/sparql-results+json"})
                             
      link = LinkHeader::Link.new( "http://example.com/foo", [["rel", "http://example.com/predicate"]] )
      header = LinkHeader.new( [ link ] )
      result = @store.remove("http://example.com/bar", header)
            
      expect( result ).to eql(false)
      a_request(:post, "localhost:6661").should have_been_made.once      
      
    end
  end
    
end