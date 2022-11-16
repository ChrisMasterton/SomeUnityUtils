module Fastlane
  module Actions
    module SharedValues
      NO_MORE_BITCODE_CUSTOM_VALUE = :NO_MORE_BITCODE_CUSTOM_VALUE
    end

    class NoMoreBitcodeAction < Action
      def self.run(params)
        # fastlane will take care of reading in the parameter and fetching the environment variable:
        UI.message "Parameter xcode_project: #{params[:xcode_project]}"

		xcode_project = params[:xcode_project]
		
		# Its the pbxproj we want inside the xcodeproj
		pbx_path = xcode_project + "/project.pbxproj"
		
		# Read the entire project file
		text = File.read(pbx_path)
		
		# Replace it
		new_contents = text.gsub("BITCODE = YES", "BITCODE = NO")
		
		# Write it back
		File.open( pbx_path, "w") { |file| file.puts new_contents }

      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Sets BITCODE to NO for targets inside an xcode project"
      end

      def self.details
        # Optional:
        # this is your chance to provide a more detailed description of this action
        "Opens the pbxproj inside an xcodeproj and replaces all instances of BITCODE = YES with BITCODE = NO"
      end

      def self.available_options
        # Define all options your action supports.

        # Below a few examples
        [
           FastlaneCore::ConfigItem.new(key: :xcode_project,
                                       env_name: "FL_NO_MORE_BITCODE_XCODE_PROJECT", # The name of the environment variable
                                       description: "Local path to xcode project file", # a short description of this parameter
                                       verify_block: proc do |value|
                                       UI.user_error!("No xcodeproj path for NoMoreBitcode given, pass using `xcode_project: 'local file'`") unless (value and not value.empty?)
                                       UI.user_error!("Couldn't find file at path '#{xcode_project}'") unless File.exist?(value)
                                       end)
        ]
      end

      def self.output
        # Define the shared values you are going to provide
        # Example
        [
          ['NO_MORE_BITCODE_CUSTOM_VALUE', 'A description of what this value contains']
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
