require 'sinatra'
require './app/google_drive'

class App < Sinatra::Base

  def service
    @service = GoogleDrive.new
  end

  def view_upload(file_id)
    "https://drive.google.com/file/d/#{file_id}/view"
  end

  post '/upload' do
    service
    err = { "error": "parameters are required" }
    halt 400, err.to_json if params.empty?

    file_object = params.keys
    file_name = params[file_object.first]["filename"]
    file_type = params[file_object.first]["type"]
    file_path = params[file_object.first]["tempfile"].path
    # begin
    file = @service.upload_file(file_name, file_type, file_path)
    { message: "upload successful", preview_url: view_upload(file.id) }.to_json
    # rescue => ex
    #   halt 400, {error: ex}.to_json
    # end
  end
end
