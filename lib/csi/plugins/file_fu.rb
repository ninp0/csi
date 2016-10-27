require 'shellwords'
require 'rubygems/package'
require 'zlib'


module CSI
  module Plugins
    # This plugin is primarily used for interacting with files and directories 
    # in addition to the capabilities already built within the File and FileUtils 
    # built-in ruby classes (e.g. contains an easy to use recursion method that 
    # uses yield to interact with each entry on the fly).
    module FileFu
      # Supported Method Parameters::
      # CSI::Plugins::FileFu.recurse_dir(
      #   :dir_path => 'optional path to dir defaults to .'
      # )
      public
      def self.recurse_dir(opts={})
        if opts[:dir_path].nil?
          dir_path = '.'
        else
          dir_path = opts[:dir_path].to_s.scrub if File.directory?(opts[:dir_path].to_s.scrub)
          raise "CSI Error: Invalid Directory #{dir_path}" if dir_path.nil?
        end 
        # Execute this like this:
        # recurse_dir(:dir_path => 'path to dir') {|entry| puts entry}
        Dir.glob("#{dir_path}/**/*").each {|entry| yield Shellwords.escape(entry) }
      end

      # Supported Method Parameters::
      # CSI::Plugins::FileFu.untar_gz_file(
      #   :tar_gz_file => 'required - path to .tar.gz file',
      #   :destination => 'required - destination folder to save extracted contents'
      # )
      public
      def self.untar_gz_file(opts={})
        tar_gz_file = opts[:tar_gz_file].to_s.scrub if File.exists?(opts[:tar_gz_file].to_s.scrub)
        destination = opts[:destination].to_s.scrub if Dir.exists?(File.dirname(tar_gz_file))
        puts `tar -xzvf #{tar_gz_file} -C #{destination}`

        return
      end

      # Author(s):: Jacob Hoopes <jake.hoopes@gmail.com>
      public
      def self.authors
        authors = %Q{AUTHOR(S):
          Jacob Hoopes <jake.hoopes@gmail.com>
        }

        return authors
      end

      # Display Usage for this Module
      public
      def self.help
        puts %Q{USAGE:
          #{self}.recurse_dir(:dir_path => 'optional path to dir defaults to .') {|entry| puts entry}

          #{self}.untar_gz_file(
            :tar_gz_file => 'required - path to .tar.gz file',
            :destination => 'required - destination folder to save extracted contents'
          )

          #{self}.authors
        }
      end
    end
  end
end
