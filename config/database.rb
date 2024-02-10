require "sequel"
require "logger"

module Database
  def self.init
    @connection ||= Sequel.connect(ENV["DATABASE_URL"], logger: Logger.new(STDOUT))
    @connection.sql_log_level = :debug
    Sequel::Model.db = @connection
    Sequel::Model.plugin :json_serializer

    @connection
  end

  def self.connection
    init

    @connection
  end

  def self.with_advisory_lock(id, &block)
    self.connection.transaction do
      self.lock(id)
      result = block.call
      self.unlock(id)

      result
    end
  end

  def self.lock(id)
    self.connection["SELECT pg_advisory_lock(?)", id]
  end

  def self.unlock(id)
    self.connection["SELECT pg_advisory_unlock(?)", id]
  end
end
