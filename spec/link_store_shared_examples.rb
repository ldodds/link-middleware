shared_examples_for "a valid Link Store" do
  
  it "should store links" do
    header = LinkHeader.new([ LinkHeader::Link.new( "http://example.com/foo", [["rel", "self"]] ) ] )      
    result = @store.add("http://example.com/my-uri", header)  
    expect( result).to be(true)      
  end
  
  it "should retrieve stored links" do
    header = LinkHeader.new([ LinkHeader::Link.new( "http://example.com/foo", [["rel", "self"]] ) ] )
    result = @store.add("http://example.com/my-uri", header)
    retrieved = @store.read("http://example.com/my-uri")
    expect( retrieved.links.first.href ).to eql("http://example.com/foo")          
  end
  
  it "should return empty array for unknown context uri" do
    retrieved = @store.read("http://example.com/my-uri")
    expect( retrieved.links.empty? ).to be(true)
  end
  
  it "should remove links" do
    header = LinkHeader.new([ LinkHeader::Link.new( "http://example.com/foo", [["rel", "self"]] ) ] )
    result = @store.add("http://example.com/my-uri", header)
    
    @store.remove( "http://example.com/my-uri", 
      LinkHeader.new([ LinkHeader::Link.new( "http://example.com/foo", [["rel", "self"]] ) ] ) )

    retrieved = @store.read("http://example.com/my-uri")
    expect( retrieved.links.empty? ).to be(true)
                
  end

  it "should not remove any links if they're not all present" do
    header = LinkHeader.new([ LinkHeader::Link.new( "http://example.com/foo", [["rel", "self"]] ) ] )
    result = @store.add("http://example.com/my-uri", header)
    
    @store.remove( "http://example.com/my-uri", 
      LinkHeader.new([ LinkHeader::Link.new( "http://example.com/foo", [["rel", "self"]] ), 
                       LinkHeader::Link.new( "http://example.com/bar", [["rel", "self"]] )] ) )

    retrieved = @store.read("http://example.com/my-uri")
    expect( retrieved.links.empty? ).to be(false)
                
  end
    
end