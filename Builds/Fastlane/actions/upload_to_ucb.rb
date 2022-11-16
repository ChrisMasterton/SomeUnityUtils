module Fastlane
  module Actions
    module SharedValues

    end

    class UploadToUcbAction < Action
      def self.run(params)
		require 'net/http'
		require 'json'
		require 'digest/md5'
		
        # fastlane will take care of reading in the parameter and fetching the environment variable:
        UI.message "Parameter API Token: #{params[:api_key]}"
        UI.message "Parameter project id: #{params[:project_id]}"
		UI.message "Parameter org id: #{params[:org_id]}"
        UI.message "Parameter local_path: #{params[:local_path]}"
        UI.message "Parameter build_number: #{params[:build_number]}"
        UI.message "Parameter filename: #{params[:filename]}"
        UI.message "Parameter artifact_name: #{params[:artifact_name]}"

		api_key = params[:api_key]
		project_id = params[:project_id]
		local_path = params[:local_path]
		incoming_build_number = params[:build_number]
		filename = params[:filename]
		artifact_name = params[:artifact_name]
		org_id = params[:org_id]
		
		file_size = File.size( local_path )
		
		# create a new local build
		puts "Creating new local build..."
		build_uri_string = "https://build-api.cloud.unity3d.com/api/v1/orgs/#{org_id}/projects/#{project_id}/buildtargets/_local/builds"
		build_uri = URI(build_uri_string)
		build_req = Net::HTTP::Post.new(build_uri)
		build_req.content_type = 'application/json'
		build_req['Authorization'] = "Basic #{api_key}"

		build_req.body = {
		  "clean" => false,
		  "delay" => 0,
		  "commit" => "",
		  "headless" => false,
		  "label" => "adhoc",
		  "platform" => "ios"
		}.to_json

		build_req_options = {
		  use_ssl: build_uri.scheme == "https"
		}
		build_res = Net::HTTP.start(build_uri.hostname, build_uri.port, build_req_options) do |http|
		  http.request(build_req)
		end
				
		if build_res.is_a?(Net::HTTPSuccess)
			puts build_res.body
			body_object = JSON[build_res.body]
			build_number = body_object[0]["build"]
			puts "OK created local build #{build_number}"
		else
			puts "Failed to create local build on UCB"
			exit(1)
		end

 		
 		# create an artifact 
 		puts "Creating artifact..."
 		create_artifact_uri_string = "https://build-artifact-api.cloud.unity3d.com/api/v1/projects/#{project_id}/buildtargets/_local/builds/#{build_number}/artifacts"
		create_artifact_uri = URI( create_artifact_uri_string )
		create_artifact_req = Net::HTTP::Post.new(create_artifact_uri)
		create_artifact_req.content_type = "application/json"
		create_artifact_req['Authorization'] = "Basic #{api_key}"
		
		puts "loading file ...."
		local_file_data = File.read(local_path)
		puts "loaded file ok"
		
		md5sum = Digest::MD5.hexdigest(local_file_data)
		puts "Generated md5 #{md5sum}"
		
		create_artifact_req.body = "{\"name\":\"#{artifact_name}\",\"primary\":true,\"public\":false,\"files\":[{\"filename\":\"#{filename}\",\"size\":#{file_size},\"md5sum\":\"#{md5sum}\"}]}"
		
		puts "url: #{create_artifact_uri_string}"
		puts "body: #{create_artifact_req.body}"

		create_artifact_req_options = { use_ssl: create_artifact_uri.scheme == "https" }
		create_artifact_res = Net::HTTP.start(create_artifact_uri.hostname, create_artifact_uri.port, create_artifact_req_options) do |http|
			http.request(create_artifact_req)
		end
		if create_artifact_res.is_a?(Net::HTTPSuccess)
			puts "OK created the artifact for the #{artifact_name} artifact"
		else
			puts "Failed to create artifact for the main file on UCB"
			puts create_artifact_res
			exit(1)
		end
		
		
		# Get the artifact status because it has info on the offsets we need.
		puts "Getting artifact status..."
		get_status_uri_string = "https://build-artifact-api.cloud.unity3d.com/api/v1/projects/#{project_id}/buildtargets/_local/builds/#{build_number}/artifacts/#{artifact_name}/upload/#{filename}"
		get_status_uri = URI(get_status_uri_string)
		get_status_req = Net::HTTP::Head.new(get_status_uri)
		get_status_req.content_type = "application/json"
		get_status_req['Tus-Resumable'] = "1.0.0"
		get_status_req['Authorization'] = "Basic #{api_key}"

		get_status_req_options = {		  use_ssl: get_status_uri.scheme == "https"		}
		get_status_res = Net::HTTP.start(get_status_uri.hostname, get_status_uri.port, get_status_req_options) do |http|
		  http.request(get_status_req)
		end
		if get_status_res.is_a?(Net::HTTPSuccess)
			puts "OK got the status for the artifact #{artifact_name}"
			#puts get_status_res			
			#get_status_body_object = JSON[get_status_res.body]
			upload_length = get_status_res["Upload-Length"]
			upload_offset = get_status_res["Upload-Offset"]
			puts "Upload length is #{upload_length}"
			puts "Upload offset is #{upload_offset}"
		else
			puts "Failed to get artifact status"
			exit(1)
		end
		
		# for each file in the artifact
		# create the file entry? did we do that already when getting status url?
		# nope, we need to create the remote file.
		puts "creating the remote file..."
		create_remote_uri_string = "https://build-artifact-api.cloud.unity3d.com/api/v1/projects/#{project_id}/buildtargets/_local/builds/#{build_number}/artifacts/#{artifact_name}/upload/#{filename}"
		create_remote_uri = URI( create_remote_uri_string )
		create_remote_req = Net::HTTP::Post.new(create_remote_uri)
		create_remote_req.content_type = "application/offset+octet-stream"
		create_remote_req['Upload-Offset'] = "#{upload_offset}"
		create_remote_req['Upload-Length'] = "#{upload_length}"
		create_remote_req['Tus-Resumable'] = "1.0.0"
		create_remote_req['Authorization'] = "Basic #{api_key}"

		create_remote_req_options = {  use_ssl: create_remote_uri.scheme == "https" }
		create_remote_res = Net::HTTP.start(create_remote_uri.hostname, create_remote_uri.port, create_remote_req_options) do |http|
			http.request(create_remote_req)
		end
		if create_remote_res.is_a?(Net::HTTPSuccess)
			puts "Created remote OK"
		else
			puts "Failed to create remote"
			puts create_remote_res
			exit(1)
		end
 		
 		# upload the file entry.
 		puts "uploading the file entry..."
 		upload_file_uri_string = "https://build-artifact-api.cloud.unity3d.com/api/v1/projects/#{project_id}/buildtargets/_local/builds/#{build_number}/artifacts/#{artifact_name}/upload/#{filename}"
		upload_file_uri = URI( upload_file_uri_string )
		upload_file_req = Net::HTTP::Patch.new(upload_file_uri)
		upload_file_req.content_type = "application/offset+octet-stream"
		upload_file_req['Upload-Offset'] = "#{upload_offset}"
		upload_file_req['Upload-Length'] = "#{upload_length}"
		upload_file_req['Tus-Resumable'] = "1.0.0"
		upload_file_req['Authorization'] = "Basic #{api_key}"

		upload_file_req.body = local_file_data
	
		upload_file_req_options = { use_ssl: upload_file_uri.scheme == "https" }
		upload_file_res = Net::HTTP.start(upload_file_uri.hostname, upload_file_uri.port, upload_file_req_options) do |http|
		  upload_file_response = http.request(upload_file_req)
		end
		if upload_file_res.is_a?(Net::HTTPSuccess)
			puts "OK uploaded"
		else
			puts "Failed to upload"
			puts upload_file_res
			exit(1)
		end
		
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Uses the Unity Cloud Build artifact api to upload a build. Will upload a single file (probably an APK or IPA)"
      end

      def self.details
        # Optional:
        # this is your chance to provide a more detailed description of this action
        "Upload to cloud build"
      end

      def self.available_options
        # Define all options your action supports.

        # Below a few examples
        [
          FastlaneCore::ConfigItem.new(key: :api_key,
                                       env_name: "FL_UPLOAD_TO_UCB_API_KEY", # The name of the environment variable
                                       description: "API Key for UploadToUcbAction", # a short description of this parameter
                                       verify_block: proc do |value|
                                       UI.user_error!("No API token for UploadToUcbAction given, pass using `api_key: 'token'`") unless (value and not value.empty?)
                                       end),
          FastlaneCore::ConfigItem.new(key: :artifact_name,
                                       env_name: "FL_UPLOAD_TO_UCB_ARTIFACT_NAME", # The name of the environment variable
                                       description: "Artifact name", # a short description of this parameter
                                       verify_block: proc do |value|
                                       UI.user_error!("No artifact name for UploadToUcbAction given, pass using `artifact_name: 'name'`") unless (value and not value.empty?)
                                       end),
           FastlaneCore::ConfigItem.new(key: :local_path,
                                       env_name: "FL_UPLOAD_TO_UCB_LOCAL_PATH", # The name of the environment variable
                                       description: "Local path of build to upload", # a short description of this parameter
                                       verify_block: proc do |value|
                                       UI.user_error!("No local path for UploadToUcbAction given, pass using `local_path: 'local file'`") unless (value and not value.empty?)
                                       UI.user_error!("Couldn't find file at path '#{local_path}'") unless File.exist?(value)
                                       end),
			FastlaneCore::ConfigItem.new(key: :project_id,
                                       env_name: "FL_UPLOAD_TO_UCB_PROJECT_ID", # The name of the environment variable
                                       description: "Unity dashboards project id", # a short description of this parameter
                                       verify_block: proc do |value|
                                       UI.user_error!("No project id for UploadToUcbAction given, pass using `project_id: 'id'`") unless (value and not value.empty?)
                                       end),
			FastlaneCore::ConfigItem.new(key: :project_id,
                                       env_name: "FL_UPLOAD_TO_UCB_ORG_ID", # The name of the environment variable
                                       description: "Unity dashboards org id", # a short description of this parameter
                                       verify_block: proc do |value|
                                       UI.user_error!("No org id for UploadToUcbAction given, pass using `org_id: 'id'`") unless (value and not value.empty?)
                                       end),
             FastlaneCore::ConfigItem.new(key: :build_number,
                                       env_name: "FL_UPLOAD_TO_UCB_BUILD_NUMBER", # The name of the environment variable
                                       description: "Current build number", # a short description of this parameter
                                       verify_block: proc do |value|
                                       UI.user_error!("No build number for UploadToUcbAction given, pass using `build_number: 'number'`") unless (value and not value.empty?)
                                       end),
			FastlaneCore::ConfigItem.new(key: :filename,
                                       env_name: "FL_UPLOAD_TO_UCB_FILENAME", # The name of the environment variable
                                       description: "Filename when its uploaded to UCB", # a short description of this parameter
                                       verify_block: proc do |value|
                                       UI.user_error!("No destination file name for UploadToUcbAction given, pass using `filename: 'blah.ipa'`") unless (value and not value.empty?)
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
