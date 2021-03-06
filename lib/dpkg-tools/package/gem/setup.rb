require 'stringio'
require 'zlib'
require 'rubygems/package'
require 'rubygems/specification'
require 'rubygems/remote_fetcher'
begin
  require 'rubygems/remote_installer'
rescue LoadError => e
  puts "Ignoring LoadError due to too-new Rubygems package :-("
end

require 'dpkg-tools/package/gem/gem_format'

module DpkgTools
  module Package
    module Gem
      class Setup < DpkgTools::Package::Setup
        class << self
          include DpkgTools::Package::Gem::GemFormat
          
          def write_gem_file(config, gem_byte_string)
            File.open(config.gem_path, 'wb') {|f| f.write(gem_byte_string)}
          end
          
          def most_recent_spec_n_source(specs_n_sources)
            specs_n_sources.select {|spec, source| spec.platform == ::Gem::Platform::RUBY || spec.platform.nil?}.first
          end
          
          def specs_n_sources_for_name(gem_name)
            ::Gem::RemoteInstaller.new.specs_n_sources_matching(gem_name, nil)
          end
        
          def spec_n_source_for_name(gem_name)
            most_recent_spec_n_source(specs_n_sources_for_name(gem_name))
          end
          
          def most_recent_spec_n_source_satisfying_requirement(requirement, specs_n_sources)
            okay_specs = specs_n_sources.select do |spec, source| 
              (spec.platform == ::Gem::Platform::RUBY || spec.platform.nil?) && requirement.satisfied_by?(spec.version)
            end
            okay_specs.first
          end
          
          def spec_n_source_for_name_and_requirement(gem_name, requirement)
            most_recent_spec_n_source_satisfying_requirement(requirement, specs_n_sources_for_name(gem_name))
          end
          
          def gem_file_from_uri(uri)
            ::Gem::RemoteFetcher.fetcher.fetch_path(uri)
          end
          
          def gem_uri_from_spec_n_source(spec, source_uri)
            source_uri + "/gems/#{spec.full_name}.gem"
          end
          
          def format_and_file_from_path(gem_path)
            gem_byte_string = File.read(gem_path)
            format = format_from_string(gem_byte_string)
            [format, gem_byte_string]
          end
          
          def cache_key_from_spec(spec)
            "#{spec.name}-#{spec.version}"
          end
          
          def from_spec_and_source(spec, source)
            gem_byte_string = gem_file_from_uri(gem_uri_from_spec_n_source(spec, source))
            self.new(DpkgTools::Package::Gem::Data.new(format_from_string(gem_byte_string), gem_byte_string))
          end
          
          def from_spec_and_source_via_cache(spec, source)
            cache_key = cache_key_from_spec(spec)
            return dependency_cache[cache_key] if dependency_cache.has_key?(cache_key)
            dependency_cache[cache_key] = from_spec_and_source(spec, source)
          end
          
          def from_name(gem_name)
            from_spec_and_source_via_cache(*spec_n_source_for_name(gem_name))
          end
          
          def from_name_and_requirement(gem_name, requirement)
            from_spec_and_source_via_cache(*spec_n_source_for_name_and_requirement(gem_name, requirement))
          end
          
          def from_path(gem_path)
            format, gem_byte_string = format_and_file_from_path(gem_path)
            self.new(DpkgTools::Package::Gem::Data.new(format, gem_byte_string))
          end
          
          def write_orig_tarball(config, gem_byte_string)
            output_io = StringIO.new
            gz_io = Zlib::GzipWriter.new(output_io)
            tar_io = StringIO.new
            ::Gem::Package::TarWriter.new(tar_io) do |tar_stream|
              tar_stream.mkdir(config.package_dir_name, 0755)
              tar_stream.add_file("#{config.package_dir_name}/#{config.gem_filename}", 0644) {|f| f.write(gem_byte_string) }
            end
            tar_io.flush
            tar_io.rewind
            gz_io.write(tar_io.read)
            gz_io.finish
            output_io.rewind
            File.open(File.join(config.orig_tarball_path), 'w') do |f| 
              f.write(output_io.read)
            end
          end
          
          def dependency_cache
            @dependency_cache ||= {}
          end
        end
        
        attr_reader :data, :config
        
        def control_file_classes
          DpkgTools::Package::Gem::ControlFiles.classes
        end
        
        def config_options
          {:suffix => 'rubygem'}
        end
        
        def fetch_gem_file
          self.class.fetch_gem_file(@source_uri + "/gems/#{@spec.full_name}.gem")
        end
        
        def write_orig_tarball
          self.class.write_orig_tarball(config, data.gem_byte_string)
        end
        
        def write_gem_file
          self.class.write_gem_file(config, data.gem_byte_string)
        end
        
        def prepare_package
          write_orig_tarball
          write_gem_file
        end
        
        def fetch_dependency(dependency)
          dep_setup = self.class.from_name_and_requirement(dependency.name, dependency.version_requirements)
          return dep_setup if dep_setup.fetched_dependencies?
          [dep_setup] + dep_setup.fetch_dependencies
        end
        
        def fetch_dependencies
          deps = data.spec.dependencies.collect do |dependency|
            fetch_dependency(dependency)
          end
          @fetched_dependencies = true
          deps.flatten
        end
        
        def fetched_dependencies?
          @fetched_dependencies ||= false
        end
        
        def dependency_cache
          self.class.dependency_cache
        end
      end
    end
  end
end