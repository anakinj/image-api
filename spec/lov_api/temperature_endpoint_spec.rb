describe LovApi::TemperatureEndpoint do
  let(:app) { LovApi.app }

  before do
    basic_authorize 'test_user', ENV['API_PASSWORD']
  end

  describe 'GET /temperatrue' do
    before do
      begin
        FileUtils.rm(LovApi::RRDStore.rrd_db_path('gettest'))
      rescue StandardError
        nil
      end
    end

    it 'returns current avg' do
      start_now = now = (Time.now.to_i - (300 * 10))
      val = 0
      10.times do
        val += 1
        post '/temperature', tag: '../get_test', value: val, timestamp: now
        now += 300
      end
      get '/temperature?tag=get_test&func=AVERAGE'
      expect(last_response.status).to eq(200)
      json = Oj.load(last_response.body)

      expect(json.size).to eq(1)
      expect(json.first['value']).to be > 9.0

      get "/temperature?tag=get_test&func=MIN&start=#{start_now}"
      expect(last_response.status).to eq(200)
      json = Oj.load(last_response.body)

      expect(json.size).to be >= 8
      expect(json.first['value']).to be < 3.0
    end
  end

  describe 'POST /temperature' do
    it 'requires value and tag' do
      post '/temperature', tag: 'room'
      expect(last_response.status).to eq(400)
      post '/temperature', value: 10.03
      expect(last_response.status).to eq(400)
    end
    it 'stores the given value' do
      post '/temperature', tag: 'room', value: 10.03
      expect(last_response.status).to eq(201)
    end
  end
end
