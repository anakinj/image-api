module LovApi
  class TemperatureEndpoint < Sinatra::Base
    def logger
      @logger ||= Logger.new(File.join(API_ROOT, '/log/temperature_endpoint.log'))
    end
  end
end
