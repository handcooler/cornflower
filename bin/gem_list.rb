#!/usr/bin/env ruby

require 'rubygems/spec_fetcher'
fetcher = Gem::SpecFetcher.fetcher
tuples = fetcher.detect(:released) { true }
byebug
