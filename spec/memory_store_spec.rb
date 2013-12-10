require 'spec_helper'

describe LinkMiddleware::MemoryStore do
  
  before(:each) do
    @store = LinkMiddleware::MemoryStore.new
  end
  
  it_should_behave_like "a valid Link Store"    
 
end