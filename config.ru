require 'bundler/setup'
require 'rack'
require 'rack/rewrite'
require 'rack/cors'
require 'open-uri'
require 'octokit'
require 'multi_json'
require 'newrelic_rpm'
require 'new_relic/agent/instrumentation/rack'
require 'rubygems-code_finder'

#http://blog.udzura.jp/2011/10/12/new-relic-on-sinatra-or-rack-app-generic/
class AppMetric
  def initialize(app)
    @app = app
  end

  def call(env)
    @app.call(env)
  end
  # Do the include after the call method is defined:
  include NewRelic::Agent::Instrumentation::Rack
end

use AppMetric

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
    resource '/repository/*', headers: :any, methods: :get
  end
end

app = Proc.new do |env|
  if %r|\A/rubygems.org/api/v1/.*\Z| =~ env['PATH_INFO']
    _, _, path = env['PATH_INFO'].split('/', 3)
    request = 'https://rubygems.org/'
    request += path
    request += '?' + env['QUERY_STRING'] if !env['QUERY_STRING'].empty?
    body = URI.parse(request).read
    Rack::Response.new(body)
  elsif %r|\A/readme/github.com/.*\Z| =~ env['PATH_INFO']
    _, _, _, repos_with_extension = env['PATH_INFO'].split('/', 4)
    # FIXME: detect extension
    repos = repos_with_extension.chomp('.html')
    body = Octokit.readme repos, accept: 'application/vnd.github.html'
    Rack::Response.new(body)
  elsif %r|\A/tags/github.com/.*\Z| =~ env['PATH_INFO']
    _, _, _, repos_with_extension = env['PATH_INFO'].split('/', 4)
    # FIXME: detect extension
    repos = repos_with_extension.chomp('.json')
    tags = Octokit.tags repos, accept: 'application/vnd.github.beta+json'
    Rack::Response.new(MultiJson.dump(tags.map(&:name)))
  elsif %r|\A/repository/.*\Z| =~ env['PATH_INFO']
    _, _, gem_name, _ = env['PATH_INFO'].split('/',4)
    body = Rubygems::CodeFinder.url gem_name
    response = {name: gem_name, repository: body}
    Rack::Response.new(MultiJson.dump(response))
  elsif '/ping' == env['PATH_INFO']
    Rack::Response.new('It works.')
  else
    Rack::Response.new('Not Found', 404)
  end
end
run app
