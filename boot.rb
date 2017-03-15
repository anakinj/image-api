require 'sinatra/base'
require 'fileutils'
require 'oj'

Oj.default_options = { mode: :compat }

API_ROOT = File.expand_path File.dirname(__FILE__)

def load_path(*paths)
  paths.each do |path|
    Dir[File.join(API_ROOT, path)].each do |file|
      require file
    end
  end
end

load_path('lib/lov_api/*.rb',
          'lib/*.rb')

FileUtils.mkdir_p(File.join(API_ROOT, 'log'))
