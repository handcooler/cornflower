require 'rack'
app = proc do |env|
  [302, {'Content-Type' => 'text','Location' => 'cosmicvent.com'}, ['302 found'] ]
end
run app
