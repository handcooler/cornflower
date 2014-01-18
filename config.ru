require 'bundler/setup'
require 'rack'
require 'rack/rewrite'

use Rack::Rewrite do
  r302 '/gems-latest.json', 'https://s3.amazonaws.com/cornflower1/gems-latest.json'
end
app = Proc.new do |env|
  Rack::Response.new('Not Found', 404)
end
run app
