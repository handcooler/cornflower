require 'bundler/setup'
require 'rack'
require 'rack/rewrite'
require 'rack/cors'

use Rack::Rewrite do
  r302 '/gems-latest.json', 'https://s3.amazonaws.com/cornflower1/gems-latest.json'
  r302 %r|\A/rubygems.org/(api/v1/.*)\Z|, 'https://rubygems.org/$1'
end

#use Rack::Cors do
#  allow do
#    origins '*'
#    resource '/rubygems.org/api/v1/*', headers: :any, methods: :get
#  end
#end

app = Proc.new do |env|
  Rack::Response.new('Not Found', 404)
end
run app
