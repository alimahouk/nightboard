# Nightboard

Create a directory of people you may know in the local communities you physically frequent using Bluetooth on your iPhone.

* Launch the app and leave it running in the background.
* The app automatically detects other Nightboard users around you who also have the app running.
* People who've been within close proximity of you will appear as suggestions, and you'll appear to them.

## Configuration

Before running the app, you need to configure the following:

1. Update the domain in `Constants.h`:
   * Replace `YOUR_DOMAIN` with your actual domain for the API endpoints

2. Set up your backend server with the following endpoints:
   * `/theboard/api/purgestaletoken`
   * `/theboard/api/getuserinfo`
   * `/theboard/api/getboardinfo`

3. Update the bundle identifier in `Info.plist`:
   * Replace `com.alimahouk.nightboard` with your desired bundle identifier

4. Authentication:
   * The app uses token-based authentication
   * Tokens are stored securely in the keychain
   * Implement your own token management system in the backend

5. Bluetooth Configuration:
   * The app uses Bluetooth for proximity detection
   * Configure the app's Bluetooth permissions in Info.plist
   * Set up appropriate privacy descriptions for Bluetooth usage

## Development

1. Clone the repository
2. Open `Nightboard.xcodeproj` in Xcode
3. Update the configuration as described above
4. Build and run the project

## License

This project is licensed under the terms specified in the LICENSE file.

## Author

Created by Ali Mahouk in 2015.
