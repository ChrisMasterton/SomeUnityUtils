# no_more_bitcode

Replaces the BITCODE = YES from xcode project files with BITCODE = NO. As of XCode 14 Apple doesn't want anything to do with bitcode. Lucky us, I say. This fastlane action is a no-frills way to force BITCODE = NO in your xcode project. I tried setting it from Unity, no dice. I tried setting it with gym, no dice.

If you have multiple xcodeproj files in your workspace (hello cocoapods!) then call it twice. Here's an example lane that I use to cRuSh ThA bItCoDeZ.

`	desc "Set bitcode to no in the project files"
	private_lane :disable_bitcode do
		no_more_bitcode( xcode_project: "./YourProject/Unity-iPhone.xcodeproj" )
        no_more_bitcode( xcode_project: "./YourProject/Pods/Pods.xcodeproj" )
	end`

---	

# delete_dir

During a broken build a frameworks folder was created and - somehow - was never cleaned up. This caused xcode to barf. As many things cause xcode to barf this is merely another tool reduce barfage.

`	desc "Sometimes empty directories are left arounds"
	private_lane :delete_empty_frameworks do |options|
         delete_dir( dir_path: @xcode_output + "/Pods/Frameworks" )
	end`

---	

# fs_xcode.rb

When you have had enough and just want to ship the build, I use the fs_xcode action as the hammer to nail.ipa.
1. It forces swift embedded frameworks to yes for the correct unity project.
2. It sets the correct path for adding frameworks.
3. It adds the Photos and PhotosUI frameworks I need for my game. 

Feel free to use this file as the hammer to whatever issue you need to fix in your xcode projects. I run some version of this right before calling fastlane to build the ipa.

---	

	
# upload_to_ucb

Had enough of Unity Cloud Build random crashes and opaqueness but still really like the distribution capabilities?
In the example below ENV['BUILD_NUMBER'] is the build number set by jenkins. If you use jenkins then great, otherwise set whatever build number you want.

From unitys website https://build-artifact-api.cloud.unity3d.com/docs/1.0.0/index.html: "You can find your API key in the Unity Cloud Services portal by clicking on 'Cloud Build Preferences' in the sidebar. Copy the API Key and paste it into the upper left corner of this website. It will be used in all subsequent requests."
		
`	desc "uploads a built app to unity cloud build"
	private_lane :upload_to_unity_cloud_build do		
		upload_to_ucb(		
			api_key: "this-is-your-api-key",
			org_id: "your-unity-dashboard-org-id",
			project_id: "from-the-settings-page-of-your-project",
			artifact_name: "I dont remember what this is",
			path: "./YourProject/Build/YourApp.ipa",
			build_number: ENV['BUILD_NUMBER'],
			filename: "filename-in-ucb.ipa"
        )
	end`
