require File.join(File.dirname(__FILE__), 'gem/data')
require File.join(File.dirname(__FILE__), 'gem/setup')
require File.join(File.dirname(__FILE__), 'gem/builder')
require File.join(File.dirname(__FILE__), 'gem/rake')

module DpkgTools
  module Package
    module Gem
      class << self
        def setup_from_path(gem_path, options = {})
          Setup.from_path(gem_path).create_structure
        end
        
        def setup_from_name(gem_name, options = {})
          setup = Setup.from_name(gem_name)
          unless options[:ignore_dependencies]
            setup.fetch_dependencies.each do |dependency|
              dependency.create_structure
            end
          end
          setup.create_structure
        end
        
        def create_builder(path_to_gem_file)
          Builder.from_file_path(path_to_gem_file)
        end
      end
    end
  end
end