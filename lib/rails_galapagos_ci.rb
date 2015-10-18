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

  module Inspectable # @private :nodoc:
    def inspection_attributes(*attributes)
      attribute_inspection = attributes.collect { |attribute|
        " @#{attribute}=\#{[Symbol, String].include?(#{attribute}.class) ? #{attribute}.inspect : #{attribute}}"
      }.join
      class_eval <<-RUBY
        def inspect
          "#<\#{self.class}:0x%.14x#{attribute_inspection}>" % (object_id << 1)
        end
      RUBY
    end
  end

  self.options = default_options
end
