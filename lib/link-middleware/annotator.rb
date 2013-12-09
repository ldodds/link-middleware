module LinkMiddleware
  
  class Annotator
    
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
      status, headers, response = @app.call(env)            
      request = Rack::Request.new( env ) 
      stored_links = @store.read( request.url )
      if !stored_links.links.empty?
        link_header = stored_links.to_s
        if headers["Link"]         
          link_header = env["Link"] + ";" + link_header
        end
        headers["Link"] = link_header
      end          
      [status, headers, response]
    end
             
  end
  
end