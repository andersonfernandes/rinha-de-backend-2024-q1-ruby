require "sinatra"
require "./api/root"
require "sinatra/reloader" if development?

class Application < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
  end

  before do
    content_type :json
  end

  register Api::Root
end
