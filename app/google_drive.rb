require 'dotenv/load'

require "google/apis/drive_v3"
require "googleauth"
require "googleauth/stores/file_token_store"
require "fileutils"
require "pry"


OOB_URI = "urn:ietf:wg:oauth:2.0:oob".freeze
APPLICATION_NAME = "File Uploader/Downloader".freeze
CREDENTIALS_PATH = "token_store.yaml".freeze
SCOPE = Google::Apis::DriveV3::AUTH_DRIVE
CLIENT_ID = ENV["DRIVE_API_CLIENT_ID"]
CLIENT_SECRET = ENV["DRIVE_API_CLIENT_SECRET"]
TOKEN_STORE = {
  "default" => {
    client_id: ENV["DRIVE_API_CLIENT_ID"],
    access_token: ENV["DRIVE_API_ACCESS_TOKEN"],
    refresh_token: ENV["DRIVE_API_REFRESH_TOKEN"],
    scope: [SCOPE],
    expiration_time_millis: ENV["DRIVE_API_TOKEN_EXPIRATION_MS"].to_i
  }.to_json
}.freeze

# class that contains methods that apply to google drive
class GoogleDrive
  def initialize
    @drive_service = Google::Apis::DriveV3::DriveService.new
    @drive_service.client_options.application_name = APPLICATION_NAME
    FileUtils.mkdir_p(File.dirname(CREDENTIALS_PATH))
    File.write(CREDENTIALS_PATH, TOKEN_STORE.to_yaml)
  end

  def authorize
    client_id = Google::Auth::ClientId.new(CLIENT_ID, CLIENT_SECRET)
    token_store = Google::Auth::Stores::FileTokenStore.new(
      file: CREDENTIALS_PATH
    )
    authorizer = Google::Auth::UserAuthorizer.new(
      client_id, SCOPE, token_store
    )
    user_id = 'default'
    credentials = authorizer.get_credentials(user_id)

    @drive_service.authorization = credentials
  end

  def upload_file(file_name, file_type, file_path)
    authorize
    file_metadata = { name: file_name }
    @drive_service.create_file(file_metadata,
                               fields: 'id',
                               upload_source: file_path,
                               content_type: file_type)
  end
end
