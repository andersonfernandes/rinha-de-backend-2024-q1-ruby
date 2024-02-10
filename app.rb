require "sinatra"
require "sinatra/custom_logger"
require "logger"
require "./lib/api/root"

class Application < Sinatra::Base
  configure :development, :production do
    logger = Logger.new(STDOUT)
    logger.level = Logger::DEBUG if !production?
    set :logger, logger
  end

  before do
    content_type :json
  end

  helpers Sinatra::CustomLogger

  register Api::Root

  get "/" do
    "ok"
  end
end
