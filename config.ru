require 'bundler/setup'
require 'rack'
require 'rack/rewrite'
require 'rack/cors'
require 'open-uri'

use Rack::Rewrite do
  r302 '/gems-latest.json', 'https://s3.amazonaws.com/cornflower1/gems-latest.json'
end

use Rack::Cors do
  allow do
    origins '*'
    resource '/rubygems.org/api/v1/*', headers: :any, methods: :get
  end
end

app = Proc.new do |env|
  if %r|\A/rubygems.org/api/v1/.*\Z| =~ env['PATH_INFO']
    request = 'https://rubygems.org/' + env['PATH_INFO'].split('/', 3).last
    request += '?' + env['QUERY_STRING'] if !env['QUERY_STRING'].empty?
    body = URI.parse(request).read
    Rack::Response.new(body)
  else
    Rack::Response.new('Not Found', 404)
  end
end
run app
