require 'bundler/setup'
require 'rack'
require 'rack/rewrite'
require 'rack/cors'
require 'open-uri'
require 'octokit'
require 'multi_json'

use Rack::Rewrite do
  r302 '/gems-latest.json', 'https://s3.amazonaws.com/cornflower1/gems-latest.json'
end

use Rack::Cors do
  allow do
    origins '*'
    resource '/rubygems.org/api/v1/*', headers: :any, methods: :get
    resource '/gems-latest.json', headers: :any, methods: :get
    resource '/readme/github.com/*', headers: :any, methods: :get
    resource '/tags/github.com/*', headers: :any, methods: :get
  end
end

app = Proc.new do |env|
  if %r|\A/rubygems.org/api/v1/.*\Z| =~ env['PATH_INFO']
    request = 'https://rubygems.org/' + env['PATH_INFO'].split('/', 3).last
    request += '?' + env['QUERY_STRING'] if !env['QUERY_STRING'].empty?
    body = URI.parse(request).read
    Rack::Response.new(body)
  elsif %r|\A/readme/github.com/.*\Z| =~ env['PATH_INFO']
    repos_with_extension = env['PATH_INFO'].split('/', 4).last
    # FIXME: detect extension
    repos = repos_with_extension.chomp('.html')
    body = Octokit.readme repos, accept: 'application/vnd.github.html'
    Rack::Response.new(body)
  elsif %r|\A/tags/github.com/.*\Z| =~ env['PATH_INFO']
    repos_with_extension = env['PATH_INFO'].split('/', 4).last
    # FIXME: detect extension
    repos = repos_with_extension.chomp('.json')
    tags = Octokit.tags repos, accept: 'application/vnd.github.beta+json'
    # NOTE: ["v4.0.3", "v4.0.0.rc.1", "v2.1.0", "v2.0.0"]
    tag_values = tags.map(&:name)
    # NOTE: {"v4.0.3":"v4.0.3","v4.0.0.rc.1":"v4.0.0.rc.1","v2.1.0":"v2.1.0","v2.0.0":"v2.0.0"}
    Rack::Response.new(MultiJson.dump(Hash[tag_values.zip(tag_values)]))
  else
    Rack::Response.new('Not Found', 404)
  end
end
run app
