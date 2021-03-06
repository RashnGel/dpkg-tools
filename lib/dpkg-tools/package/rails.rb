require 'dpkg-tools/package/rails/data'
require 'dpkg-tools/package/rails/setup'
require 'dpkg-tools/package/rails/builder'
require 'dpkg-tools/package/rails/control_files'
require 'dpkg-tools/package/rails/rake'
require 'dpkg-tools/package/rails/cap'

module DpkgTools
  module Package
    module Rails
      class << self
        def create_builder(path_to_app)
          Builder.from_path(path_to_app)
        end
        
        def create_setup(path_to_app)
          Setup.from_path(path_to_app)
        end
        
        def setup_from_path(path_to_app)
          create_setup(path_to_app).create_structure
        end
      end
    end
  end
end