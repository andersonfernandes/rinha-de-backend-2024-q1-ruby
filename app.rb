require 'sinatra'
require './api/root'

class Application < Sinatra::Base
  before do
    content_type :json
  end

  register Api::Root
end