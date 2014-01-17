require 'rack'
app = Proc.new do |env|
  request = Rack::Request.new(env)
  case request.path
  when '/gems-latest.json'
    Rack::Response.new { |r| r.redirect('https://s3.amazonaws.com/cornflower1/gems-latest.json') }
  else
    Rack::Response.new('Not Found', 404)
  end
end
run app
