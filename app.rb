require "sinatra"
require "logger"
require "./lib/api/root"

class Application < Sinatra::Base
  Logger.class_eval { alias :write :'<<' }
  logger = ::Logger.new(STDOUT)

  configure do
    use Rack::CommonLogger, logger
  end

  before do
    content_type :json
  end

  register Api::Root
end
