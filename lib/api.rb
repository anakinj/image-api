require 'rack/cors'

module LovApi
  class App < Sinatra::Base
    use Rack::Auth::Basic, 'Simple API protection' do |_username, password|
      password == ENV['API_PASSWORD'].to_s
    end

    use LovApi::ImageEndpoint
    use LovApi::TemperatureEndpoint
  end

  def self.app
    Rack::Builder.new do
      use Rack::Cors do
        allow do
          origins '*'
          resource '*', :headers => :any, :methods => :get
        end
      end
      run LovApi::App
    end
  end
end
