describe LovApi::TemperatureEndpoint do
  let(:app) { described_class }
  describe 'GET /temperatrue' do
    it 'returns current avg' do
      FileUtils.rm(LovApi::RRDStore.rrd_db_path('gettest'))
      now = (Time.now.to_i - (300*10))
      10.times do
        post '/temperature', { tag: '../get_test', value: 8, timestamp: now }, 'REMOTE_USER' => 'test_user'
        now += 300
      end
      get '/temperature?tag=get_test'
      expect(last_response.status).to eq(200)
      json = Oj.load(last_response.body)

      expect(json.size).to eq(1)
      expect(json.first['value']).to eq(8.0)
    end
  end
  describe 'POST /temperature' do
    it 'requires value and tag' do
      post '/temperature', { tag: 'room' }, 'REMOTE_USER' => 'test_user'
      expect(last_response.status).to eq(400)
      post '/temperature', { value: 10.03 }, 'REMOTE_USER' => 'test_user'
      expect(last_response.status).to eq(400)
    end
    it 'stores the given value' do
      post '/temperature', { tag: 'room', value: 10.03 }, 'REMOTE_USER' => 'test_user'
      expect(last_response.status).to eq(201)
    end
  end
end
