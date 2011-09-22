#!/usr/bin/env rackup

require 'rubygems'
require 'bundler'

Bundler.require

require './ame.rb'
run Sinatra::Application
