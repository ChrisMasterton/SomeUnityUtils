require 'fileutils'

module Fastlane
  module Actions
    module SharedValues
      DELETE_DIR_CUSTOM_VALUE = :DELETE_DIR_CUSTOM_VALUE
    end

    class DeleteDirAction < Action
      def self.run(params)
        # fastlane will take care of reading in the parameter and fetching the environment variable:
        UI.message "Parameter dir_name: #{params[:dir_path]}"

		dir_path = params[:dir_path]
		
		if Dir.exist?(dir_path)
			# directory exists
			FileUtils.rm_rf(dir_path)
		
			if Dir.exist?(dir_path)
				puts "ERROR: the directory path still seems to exist"
			else
				puts "Success, the directory path no longer exists"		
			end
		else
			puts "The directory #{dir_path} was never found so nothing to delete"
		end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Deletes a directory"
      end

      def self.details
        # Optional:
        # this is your chance to provide a more detailed description of this action
        "Deletes a specified directory"
      end

      def self.available_options
        # Define all options your action supports.

        # Below a few examples
        [
           FastlaneCore::ConfigItem.new(key: :dir_path,
                                       env_name: "FL_DELETE_DIR_DIR_PATH", # The name of the environment variable
                                       description: "Directory to delete", # a short description of this parameter
                                       verify_block: proc do |value|
                                       UI.user_error!("No directory path for DeleteDirAction given, pass using `dir_path: 'path'`") unless (value and not value.empty?)
                                       end)
        ]
      end

      def self.output
        # Define the shared values you are going to provide
        # Example
        [
          
        ]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.authors
        # So no one will ever forget your contribution to fastlane :) You are awesome btw!
        ["ChrisMasterton"]
      end

      def self.is_supported?(platform)
        # you can do things like
        #
        #  true
        #
        #  platform == :ios
        #
        #  [:ios, :mac].include?(platform)
        #
        true
      end
    end
  end
end
