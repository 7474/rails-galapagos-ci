require 'rails'
require "active_support/ordered_options"

module RailsGalapagosCi
  class Railtie < ::Rails::Railtie
    rake_tasks do
      load "tasks/rails_galapagos_ci.rake"
    end
  end

  class << self
    attr_accessor :options

    def default_options
      ActiveSupport::OrderedOptions[
        :rogical_name, true
      ]
    end
  end

  self.options = default_options
end
