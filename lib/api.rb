module LovApi
  class App < Sinatra::Base
    use Rack::Auth::Basic, 'Simple API protection' do |_username, password|
      password == ENV['API_PASSWORD'].to_s
    end

    use LovApi::ImageEndpoint
  end
end
