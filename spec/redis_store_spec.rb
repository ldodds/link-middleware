require 'spec_helper'
require 'mock_redis'

describe LinkMiddleware::RedisStore do
  
  before(:each) do
    @redis = MockRedis.new
    @store = LinkMiddleware::RedisStore.new( :client => @redis )
  end
  
  it_should_behave_like "a valid Link Store"    
  
end