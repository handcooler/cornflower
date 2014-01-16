#!/usr/bin/env ruby

# http://stackoverflow.com/questions/21094095/how-to-get-all-gems-names-via-web
require 'rubygems/spec_fetcher'
fetcher = Gem::SpecFetcher.fetcher
tuples = fetcher.detect(:released) { true }
byebug
