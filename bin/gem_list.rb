#!/usr/bin/env ruby
require 'bundler/setup'
require 'pry'
require 'multi_json'

# http://stackoverflow.com/questions/21094095/how-to-get-all-gems-names-via-web
require 'rubygems/spec_fetcher'
fetcher = Gem::SpecFetcher.fetcher
tuples = fetcher.detect(:latest) { true }
holder = []
tuples.map do |tuple|
  gem = tuple.first
  holder << { name: gem.name, platform: gem.platform, version: gem.version.to_s }
end
puts MultiJson.dump(holder)
