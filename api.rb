require 'sinatra/base'
require 'fileutils'

class Api < Sinatra::Base
  use Rack::Auth::Basic, "Simple API protection" do |username, password|
    password == ENV['API_PASSWORD'].to_s
  end

  IMAGE_ROOT = './images'

  post '/image' do
    halt 400 unless params.key?(:file) || params[:file].is_a?(Hash) || params[:file].key?(:filename)

    now = Time.now
    user_folder = File.join(IMAGE_ROOT, env['REMOTE_USER'])
    year_path = File.join(now.year.to_s, now.month.to_s, now.day.to_s)
    image_folder = File.join(user_folder, year_path)
    image_name = "#{now.to_i}_#{params[:file][:filename]}"

    FileUtils::mkdir_p(image_folder)
    image_file = File.join(image_folder, image_name)

    File.open(image_file, 'wb') do |f|
      f.write(params[:file][:tempfile].read)
    end

    FileUtils::ln_s(File.join(year_path, image_name), "#{user_folder}/latest.jpg", :force => true)

    status 201
  end
end
