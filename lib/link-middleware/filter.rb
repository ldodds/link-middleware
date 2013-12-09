module LinkMiddleware
  
  class Filter
    
    def initialize(app, options={})
      @app = app       
      @options = options
      if options[:store]        
        @store = options[:store]
      elsif options[:store_impl]
        @store = options[:store].new(options)
      else
        @store = LinkMiddleware::MemoryStore.new(options)
      end
    end                
  
    def call(env)         
      request = Rack::Request.new( env )  
      if request.request_method == "LINK"
        return link( request.url, env )
      elsif request.request_method == "UNLINK"
        return unlink( request.url, env )
      end          
      @app.call(env)
    end
         
    def link(url, env)
      links = LinkHeader.parse( env["HTTP_LINK"] )
      success = @store.add(url,links)
      headers = {}
      if success
        headers["Link"] = links.to_s unless links.links.empty?
        return [200, headers, ["OK"]]
      else
        return [500, headers, ["Unable to add links"]]
      end      
    end    
    
    def unlink(url, env)
      links = LinkHeader.parse( env["HTTP_LINK"] )
      success = @store.remove(url,links)
      headers = {}
      if success
        headers["Link"] = links.to_s unless links.links.empty?
        return [200, headers, ["OK"]]
      else
        return [500, headers, ["Unable to add links"]]
      end      
    end
    
  end
  
end