require "sinatra"
# require "sinatra/reloader" if development?
require "sinatra/custom_logger"
require "logger"
require "./lib/api/root"

class Application < Sinatra::Base
  # configure :development do
  #   register Sinatra::Reloader
  #   also_reload "./lib/models/client"
  #   also_reload "./lib/models/transaction"
  #   also_reload "./lib/api/root"
  #   also_reload "./lib/api/transactions"
  #   also_reload "./lib/api/statements"
  # end

  configure :development, :production do
    logger = Logger.new(STDOUT)
    logger.level = Logger::DEBUG if development?
    set :logger, logger
  end

  before do
    content_type :json
  end

  helpers Sinatra::CustomLogger

  register Api::Root
end
