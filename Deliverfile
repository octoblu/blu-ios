# For more information about each property, visit the GitHub documentation: https://github.com/krausefx/deliver
# Everything next to a # is a comment and will be ignored

email 'd@octoblu.com'

########################################
# App Metadata
########################################

# The app identifier is required
app_identifier "com.octoblu.blu"
apple_id "938900017"


# This folder has to include one folder for each language
# More information about automatic screenshot upload:
screenshots_path "./deliver/screenshots/"


# version '1.2' # you can pass this if you want to verify the version number with the ipa file

config_json_folder './deliver'


########################################
# Building and Testing
########################################

# Dynamic generation of the ipa file
# I'm using Shenzhen by Mattt, but you can use any build tool you want
# Remove the whole block if you do not want to upload an ipa file
ipa do
    # Add any code you want, like incrementing the build
    # number or changing the app identifier

    system("ipa build") # build your project using Shenzhen
    "./Blu.ipa" # Tell 'Deliver' where it can find the finished ipa file
end

# ipa "./latest.ipa" # this can be used, if you prefer manually building the ipa file

# unit_tests do
#   system("xctool test")
# end

success do
  system("say 'Successfully deployed a new version.'")
end