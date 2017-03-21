module LovApi
  class TemperatureEndpoint < Sinatra::Base
    def logger
      @logger ||= Logger.new(File.join(API_ROOT, '/log/temperature_endpoint.log'))
    end

    set :show_exceptions, false
    error do |e|
      logger.error("#{e.message}: #{e.backtrace}")
    end

    get '/temperature' do
      halt 400 if params[:tag].nil?
      content_type :json
      status 200
      Oj.dump(LovApi::RRDStore.new(params[:tag], logger).get(indifferent_params(params)))
    end

    post '/temperature' do
      logger.info("Got #{params}")

      halt 400 if params[:tag].nil? || params[:value].nil?

      LovApi::RRDStore.new(params[:tag], logger).put(params[:value], params[:timestamp])
      status 201
    end
  end
end
