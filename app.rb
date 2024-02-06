require 'sinatra'
require './api/root'

class Application < Sinatra::Base
  register Api::Root
end