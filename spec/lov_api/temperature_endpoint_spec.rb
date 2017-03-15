describe LovApi::TemperatureEndpoint do
  let(:app) { described_class }
  describe 'GET /temperatrue' do
    it 'returns current avg' do
      post '/temperature', { tag: 'get_test', value: 8 }, 'REMOTE_USER' => 'test_user'
      get '/temperature?tag=get_test'
      expect(last_response.status).to eq(200)
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
