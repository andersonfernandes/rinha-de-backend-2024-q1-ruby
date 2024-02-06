require 'sequel'

module Database
  def self.init
    @database ||= Sequel.connect(ENV['DATABASE_URL'])
    Sequel::Model.db = @database
    Sequel::Model.plugin :json_serializer

    @database
  end

  def self.database
    init

    @database
  end
end