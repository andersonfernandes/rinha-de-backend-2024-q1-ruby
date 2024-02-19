if ENV["RACK_ENV"] != "development"
  require "./app"
  run Application
else
  require "auto_reloader"

  AutoReloader.activate reloadable_paths: [__dir__], delay: 1
  run ->(env) {
        AutoReloader.reload! do |unloaded|
          require "./app"
          Application.call env
        end
      }
end
