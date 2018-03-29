describe LovApi::ImageEndpoint do
  let(:app) { LovApi.app }

  let(:test_file_path) { File.join(API_ROOT, 'spec', 'fixtures', 'test.jpg') }
  let(:user_folder) { File.join(API_ROOT, 'images', 'test_user') }
  let(:day_folder) do
    File.join(user_folder, Time.now.year.to_s, Time.now.month.to_s, Time.now.day.to_s)
  end

  after do
    FileUtils.rm_rf("#{user_folder}/.", secure: true)
  end

  before do
    basic_authorize 'test_user', ENV['API_PASSWORD']
  end

  describe 'POST /image' do
    subject(:response) { post '/image', file: Rack::Test::UploadedFile.new(test_file_path, 'image/jpeg') }

    it 'saves file the file' do
      expect(response.status).to eq(201)
      expect(Dir["#{day_folder}/*.jpg"].length).to eq(1)
      expect(File.exist?(File.join(user_folder, 'latest.jpg'))).to be true
    end

    it 'saves even if MiniMagick fails' do
      expect(MiniMagick::Image).to receive(:open).and_raise('whoot')
      expect(response.status).to eq(201)
      expect(Dir["#{day_folder}/*.jpg"].length).to eq(1)
      expect(File.exist?(File.join(user_folder, 'latest.jpg'))).to be true
    end
  end

  describe 'GET /image' do
    subject(:response) { get '/image/latest?user=test_user' }

    it 'gets the latest image for the user' do
      FileUtils.mkdir_p(user_folder)
      File.open(File.join(user_folder, 'latest.jpg'), 'w') { |f| f.write("I'm a picture") }

      expect(response.status).to eq(200)
      expect(response.body).to eq("I'm a picture")
    end
  end
end
