module LinkMiddleware
  class RedisStore
    def initialize(options={})
      if options[:store]
        @redis = options[:store]
      else  
        @redis = Redis.new(options)        
      end
    end

    def add(context_uri, header)
      header.links.each do |link|
        @redis.sadd context_uri, link.to_s
      end
      true
    end

    def remove(context_uri, header)
      process = true
      header.links.each do |link|
        process = process && @redis.sismember(context_uri, link.to_s)
      end
      header.links.each do |link|
        @redis.srem context_uri, link.to_s
      end if process
      process
    end

    def read(context_uri)
      header = LinkHeader.new
      links = @redis.smembers context_uri
      links.each do |link|
        header << LinkHeader.parse(link).links.first
      end
      header
    end

  end

end