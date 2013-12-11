module LinkMiddleware

  require 'rdf'
  require 'sparql/client'

  LINK_RELATIONS = "http://www.iana.org/assignments/link-relations/link-relations.xhtml"
      
  #A Link Store implementation used to store RDF predicates
  #
  #This implementation isn't completely compliant with the draft RFC
  #as it doesn't store link attributes.
  #
  #The assumption here is that LINK/UNLINK requests are intended to provide
  #links to related resources. The link relation specifies the predicate. All
  #other attributes are ignored.
  #
  #Link relations that aren't absolute URIs are assumed to be registered types and 
  #will be stored with a base URL of:
  #
  # http://www.iana.org/assignments/link-relations/link-relations.xhtml#type
  #
  #The store uses the following patterns:
  #
  # * Graph Per Resource -- one Named Graph per URL
  # * Rebased URI -- to create Named Graph URI from a supplied prefix
  #
  #The backend must be a SPARQL 1.1 compliant endpoint as the store uses
  #SPARQL 1.1 Query and SPARQL 1.1 Update to interact with the store.
  #
  #The store can be configured using the +:endpoint+ option in the constructor. 
  #Separate query and update endpoints (e.g. as with Fuseki) can be specified
  #with the +:query_endpont+ and +:update_endpoint+ options
  class SimpleRDFStore
    
    def initialize(options={})
      if options[:query_client]
        @qry = options[:query_client]
      else
        @qry = SPARQL::Client.new( options[:query_endpoint] || options[:endpoint] )
      end        
      if options[:update_client]
        @upd = options[:update_client]
      else
        @upd = SPARQL::Client.new( options[:update_endpoint] || options[:endpoint] )
      end
      @graph_base = URI.parse( options[:graph_base ] ).normalize.to_s
    end

    def graph_uri(context_uri)
      return "#{@graph_base};#{context_uri}"
    end
    
    def header_to_graph(context_uri, header)
      graph = RDF::Graph.new
      header.links.each do |link|
          graph << RDF::Statement.new( 
            RDF::URI.new( context_uri ), 
            predicate(link), 
            RDF::URI.new( link.href ) )
      end
      graph      
    end
    
    def predicate(link)
      rel = link["rel"]
      rel.start_with?("http") ? RDF::URI.new(rel) : RDF::URI.new( "#{LINK_RELATIONS}##{rel}")
    end
    
    def add(context_uri, header)
        begin
            @upd.insert_data( header_to_graph(context_uri, header), :graph=>graph_uri(context_uri) )      
        rescue => e
          puts e.inspect
          return false
        end
        true
    end

    def remove(context_uri, header)
      graph = header_to_graph(context_uri, header)      
      pattern = []
      graph.statements.each do |s| pattern << s.to_s end
                
      process = @qry.query( "ASK WHERE { GRAPH <#{graph_uri(context_uri)}> { #{ pattern.join("\n") }" )
      if process
        begin
          @upd.delete_data( header_to_graph(context_uri, header), :graph=>graph_uri(context_uri) )        
          return true
        rescue => e
          return false
        end              
      end
      return false
    end

    def read(context_uri)
      header = LinkHeader.new
      select = "SELECT ?p ?o WHERE { GRAPH <#{graph_uri(context_uri)}> { <#{context_uri}> ?p ?o. } }"
      result = @qry.query( select )
      result.each_solution do |solution|
        header << LinkHeader::Link.new( solution[:o].to_s, [["type",  solution[:p].to_s ]] )
      end
      header
    end

  end

end