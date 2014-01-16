#!/usr/bin/env ruby
require 'bundler/setup'
require 'byebug'
require 'pry'

# http://stackoverflow.com/questions/21094095/how-to-get-all-gems-names-via-web
require 'rubygems/spec_fetcher'
fetcher = Gem::SpecFetcher.fetcher
tuples = fetcher.detect(:latest) { true }
tuples.map{ |tuple| tuple.first }

binding.pry
