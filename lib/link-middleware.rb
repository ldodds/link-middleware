require 'rack'
require 'redis'
require 'json'
require 'link_header'

require 'link-middleware/annotator'
require 'link-middleware/filter'
require 'link-middleware/store'
require 'link-middleware/redis_store'
require 'link-middleware/simple_rdf_store'

class LinkHeader::Link
  
  def eql?(other)
    return href == other.href && attr_pairs == other.attr_pairs
  end
  
  def hash
    return href.hash + attr_pairs.hash
  end
end