require "sequel"
require "logger"

module Database
  def self.init!
    return if @connection

    @connection ||= Sequel.connect(
      ENV["DATABASE_URL"],
      logger: Logger.new(STDOUT),
    )
    @connection.sql_log_level = ENV["RACK_ENV"] == "development" ? :debug : :info
    Sequel::Model.db = @connection
    Sequel::Model.plugin :json_serializer

    @connection
  end

  def self.connection
    init!

    @connection
  end

  def self.with_advisory_lock(id, &block)
    self.connection.transaction do
      self.lock(id)
      block.call
    end
  end

  def self.lock(id)
    self.connection["SELECT pg_advisory_xact_lock(?)", id]
  end
end
