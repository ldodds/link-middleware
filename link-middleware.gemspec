lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require "link-middleware/version"

Gem::Specification.new do |s|
  s.name        = "link-middleware"
  s.version     = LinkMiddleware::VERSION
  s.authors     = ["Leigh Dodds"]
  s.email       = ["leigh@ldodds.com"]
  s.homepage    = "http://github.com/ldidds/link-middleware"
  s.summary     = "Implementation of LINK/UNLINK using Rack middleware"
  s.files = Dir["{bin,etc,lib}/**/*"] + ["LICENSE.md", "README.md"]
 
  s.add_dependency "rack"  
  s.add_dependency "link_header"
  s.add_dependency "redis"
    
  s.add_development_dependency "rspec"
  s.add_development_dependency "simplecov-rcov"
  s.add_development_dependency "mock_redis"
  
end
