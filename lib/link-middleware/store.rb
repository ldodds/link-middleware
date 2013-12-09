module LinkMiddleware
      
  require 'set'
  
  #Use for testing only!
  class MemoryStore    
        
    def initialize(options={})
      @store = {}
    end
    
    def add(context_uri, header)
      stored_header = @store[context_uri] || LinkHeader.new
      header.links.each do |link|
        stored_header << link
      end
      @store[context_uri] = stored_header
      return true             
    end

    def remove(context_uri, header)
      stored_header = @store[context_uri] || LinkHeader.new
      return true if stored_header.links.empty?
      
      #if there are links to remove, which aren't in the stored set, then return false
      return false if !(header.links - stored_header.links).empty?
      
      #otherwise remove them
      final = stored_header.links - header.links
      @store[context_uri] = LinkHeader.new( final )
      return true             
    end
        
    def read(context_uri)
      @store[context_uri] || LinkHeader.new
    end    
        
  end
  
end