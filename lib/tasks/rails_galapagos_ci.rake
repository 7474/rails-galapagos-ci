
def say(message)
  puts message unless Rake.application.options.silent
end

namespace :gci do
  namespace :erd do
    require "rails_erd"

    # see rails_erd/tasks.task
    task :options do
      ENV.keys.each do |option|
        RailsERD.options[option.to_sym] = case ENV[option]
        when "true", "yes" then true
        when "false", "no" then false
        when /,/ then ENV[option].split(/\s*,\s*/)
        else ENV[option].to_sym
        end
      end
    end

    task :load_models do
      say "Loading application environment..."
      Rake::Task[:environment].invoke

      say "Loading code in search of Active Record models..."
      begin
        # XXX メタデータをリロードしたい
        Rails.application.eager_load!
      rescue Exception => err
        if Rake.application.options.trace
          raise
        else
          trace = Rails.backtrace_cleaner.clean(err.backtrace)
          error = (["Loading models failed!\nError occurred while loading application: #{err} (#{err.class})"] + trace).join("\n    ")
          raise error
        end
      end

      raise "Active Record was not loaded." unless defined? ActiveRecord
    end

    task :generate => [:options, :load_models] do
      say "Generating Entity-Relationship Diagram for #{ActiveRecord::Base.descendants.length} models..."

      require "rails_galapagos_ci/galapagos_diagram"
      file = RailsGalapagosCi::GarapagosDiagram.create

      say "Done! Saved diagram to #{file}."
    end
  end

  task :erd => "erd:generate"

  # XXX バージョンあげながらER図を出せばいい感じに変化が出ると思ったけれど、よく考えたらModel自体はファイルだったのでNGだ
  task :histories do
    filename = ENV['filename']? ENV['filename']: 'erd'
    migrate_files = Dir::glob("#{Rails.root}/db/migrate/*.rb").map { |path|
      { :path => path, :version => File::basename(path)[0, 14] }
    }

    ENV['VERSION'] = '0'
    Rake::Task['db:migrate'].reenable
    Rake::Task['db:migrate'].invoke

    migrate_files.sort { |x, y| x[:version] <=> y[:version] }.each do |f|
      puts f
      ENV['VERSION'] = f[:version]
      Rake::Task['db:migrate'].reenable
      Rake::Task['db:migrate'].invoke

      ENV['filename'] = "#{filename}-#{f[:version]}"
      Rake::Task['gci:erd:options'].reenable
      Rake::Task['gci:erd:load_models'].reenable
      Rake::Task['gci:erd:generate'].reenable
      Rake::Task['gci:erd'].reenable
      Rake::Task['gci:erd'].invoke
    end
  end
end
