describe LovApi::ImageEndpoint do

  let(:app) { described_class }

  let(:test_file_path) { File.join(API_ROOT, 'spec', 'fixtures', 'test.jpg') }
  let(:user_folder) { File.join(API_ROOT, 'images', 'test_user') }
  let(:day_folder) do
    File.join(user_folder, Time.now.year.to_s, Time.now.month.to_s, Time.now.day.to_s)
  end

  after do
    FileUtils.rm_rf("#{user_folder}/.", secure: true)
  end

  describe 'POST /image' do
    it 'saves file the file' do
      post '/image',
        { file: Rack::Test::UploadedFile.new(test_file_path, "image/jpeg") },
        { 'REMOTE_USER' => 'test_user' }
      expect(last_response.status).to eq(201)
      expect(Dir["#{day_folder}/*.jpg"].length).to eq(1)
      expect(File.exists?(File.join(user_folder, 'latest.jpg'))).to be true
    end
    it 'saves even if MiniMagick fails' do
      expect(MiniMagick::Image).to receive(:open).and_raise('whoot')
      post '/image',
        { file: Rack::Test::UploadedFile.new(test_file_path, "image/jpeg") },
        { 'REMOTE_USER' => 'test_user' }

      expect(last_response.status).to eq(201)
      expect(Dir["#{day_folder}/*.jpg"].length).to eq(1)
      expect(File.exists?(File.join(user_folder, 'latest.jpg'))).to be true
    end
  end

  describe 'GET /image' do
    it 'gets the latest image for the user' do
      FileUtils.mkdir_p(user_folder)
      File.open(File.join(user_folder, 'latest.jpg'), 'w') {|f| f.write("I'm a picture") }
      get '/image/latest?user=test_user'
      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq("I'm a picture")
    end
  end
end
