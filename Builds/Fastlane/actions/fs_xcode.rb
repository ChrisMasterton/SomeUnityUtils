module Fastlane
  module Actions

    class FsXcodeAction < Action
      def self.run(params)
		require 'xcodeproj'
      
        # fastlane will take care of reading in the parameter and fetching the environment variable:
        UI.message "Parameter build_folder: #{params[:build_folder]}"

		build_folder = params[:build_folder]
		
		project_path = "#{build_folder}/Unity-iPhone.xcodeproj"
		
		project = Xcodeproj::Project.open(project_path)
		
		puts "going through all targets"
		project.targets.each do|target|
			target.build_configurations.each do |config|
				if target.name == "Unity-iPhone"
					config.build_settings['ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES'] = 'YES'
				else
					config.build_settings['ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES'] = 'NO'
				end
				#runtime search paths
				config.build_settings['LD_RUNPATH_SEARCH_PATHS'] = "/usr/lib/swift $(inherited) @executable_path/Frameworks @loader_path/Frameworks"
			end				
		end
		
		# add the photos UI framework
		add_framework( project, "PhotosUI.framework" )
		add_framework( project, "Photos.framework" )

		project.save

		##### Go through the pods
		pods_path = "#{build_folder}/Pods/Pods.xcodeproj"
		
		pods_project = Xcodeproj::Project.open(pods_path)		
		pods_project.targets.each do|target|
			target.build_configurations.each do |config|
				config.build_settings['ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES'] = 'NO'
			end				
		end
		pods_project.save
		
	  end
	  
	  def self.add_framework( project, framework_path )
		lib_path = "/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS16.0.sdk/System/Library/Frameworks/#{framework_path}"
		lib_ref = project['Frameworks'].new_file(lib_path)
		framework_buildphase = project.objects.select{|x| x.class == Xcodeproj::Project::Object::PBXFrameworksBuildPhase}[1]
		framework_buildphase.add_file_reference(lib_ref)
	  end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Replaces values in a pbx project"
      end

      def self.details
        # Optional:
        # this is your chance to provide a more detailed description of this action
        "Pbx project find and replace"
      end

      def self.available_options
        # Define all options your action supports.

        # Below a few examples
        [
           FastlaneCore::ConfigItem.new(key: :build_folder,
                                       env_name: "FL_FS_CODE_BUILD_FOLDER", # The name of the environment variable
                                       description: "Local path to build folder containing the main project file", # a short description of this parameter
                                       verify_block: proc do |value|
                                       UI.user_error!("No xcodeproj path for FSXCode given, pass using `build_folder: 'path'`") unless (value and not value.empty?)
                                       UI.user_error!("Couldn't find directory at path '#{build_folder}'") unless Dir.exist?(value)
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
