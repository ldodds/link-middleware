require 'rack'
require 'link_header'

require 'link-middleware/annotator'
require 'link-middleware/filter'
require 'link-middleware/store'
require 'link-middleware/redis_store'

class LinkHeader::Link
  
  def eql?(other)
    return href == other.href && attr_pairs == other.attr_pairs
  end
  
  def hash
    return href.hash + attr_pairs.hash
  end
end