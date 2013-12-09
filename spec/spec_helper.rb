require 'simplecov'
require 'simplecov-rcov'
require 'rack/test'
require 'link-middleware'
SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
SimpleCov.start

RSpec.configure do |config|
  config.order = "random"
  config.color_enabled = true
  config.tty = true
end


#The following bit of monkey patching won't be necessary when 
#a pending PR is merged into rack-test. 
class Rack::Test::Session
  def link(uri, params = {}, env = {}, &block)
    env = env_for(uri, env.merge(:method => "LINK", :params => params))
    process_request(uri, env, &block)
  end

  def unlink(uri, params = {}, env = {}, &block)
    env = env_for(uri, env.merge(:method => "UNLINK", :params => params))
    process_request(uri, env, &block)
  end  
end

module Rack::Test::Methods
  def_delegators :current_session, *[:link, :unlink] 
end
