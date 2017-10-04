#!/usr/bin/env ruby
# Sinatra requirements
require 'sinatra'
require 'thin'
require 'sinatra/namespace'
require 'paint'

# Other useful stuff
require 'fileutils'

# Set sinatra settings here
# Consider:
# => Switching to +:production+ instead of +:development+ (which is default)
# => Switch the port
# => Starting a sinatra server to serve the files from this file (start a different script from this one)
set :environment, :development
set :server, 'thin'
set :port, 8080
set :show_exceptions, true if development?

FileUtils.mkdir(File.join(Dir.home, 'rise-server')) if !File.directory?(File.join(Dir.home, 'rise-server'))

namespace '/api/v1' do

  put '/:uuid/*' do |uuid, path|
    isdir = params[:dir]
    if File.directory?(File.join(Dir.home, 'rise-server', uuid))
      if isdir == "true"
        FileUtils.mkdir(File.join(Dir.home, 'rise-server', uuid, path))
        return
      end
      File.open(File.join(Dir.home, 'rise-server', uuid, path), 'w+') do |f|
        request_body = request.body.read
        f.puts(request_body)
      end
    else
      FileUtils.mkdir(File.join(Dir.home, 'rise-server', uuid))
      puts Paint["[#{Time.now}] Creating initial folder with uuid: #{uuid}", :blue]
      if isdir == "true"
        FileUtils.mkdir(File.join(Dir.home, 'rise-server', uuid, path))
        return
      end
      File.open(File.join(Dir.home, 'rise-server', uuid, path), 'w+') do |f|
        request_body = request.body.read
        f.puts(request_body)
      end
    end
  end
end