# Flutter and Dart Installation Guide

Welcome to the Flutter and Dart installation guide! This guide will walk you through installing Flutter and Dart on your machine. We also provide an alternative method in case you'd prefer not to use the Flutter and Dart installers.

## Prerequisites

Before installing Flutter and Dart, ensure you have the following:
- **Operating System**: Windows 10+, macOS 10.14+, or Linux (64-bit).
- **Disk Space**: At least 2.8 GB for the Flutter SDK (not including IDE/tools).
- **Tools**: `git` command-line tool for Windows and Linux users.

### 1. Install Flutter and Dart via Installer

#### Step 1: Download Flutter SDK

- Visit [Flutter's official website](https://flutter.dev/docs/get-started/install) to download the Flutter SDK for your operating system.
- Extract the Flutter SDK to a suitable location, for example:
  - **Windows**: Extract to `C:\src\flutter`.
  - **macOS/Linux**: Extract to your home directory or `/usr/local/`.

#### Step 2: Update Path Variable

Add the Flutter SDK to your system's `PATH` to access the `flutter` command globally.

**Windows**:
- Search for **Environment Variables** in the Start Menu.
- Select **Path**, click **Edit**, and add the path to the `flutter/bin` directory (e.g., `C:\src\flutter\bin`).

**macOS/Linux**:
- Open terminal and edit your shell profile (e.g., `.bashrc`, `.zshrc`):
  ```sh
  export PATH="$PATH:/path-to-flutter/flutter/bin"
  ```
- Apply changes:
  ```sh
  source ~/.bashrc  # or ~/.zshrc
  ```

#### Step 3: Verify Installation

Run the following command to verify that Flutter is installed correctly:
```sh
flutter doctor
```
This command will check the setup and notify you of any dependencies that need to be installed.

### 2. Install Dart SDK

The Dart SDK is bundled with Flutter, so if you've installed Flutter, Dart should already be available. To verify, run:
```sh
dart --version
```
If Dart isn't found, you can manually install it by following these steps:

**macOS/Linux**:
- Use Homebrew:
  ```sh
  brew tap dart-lang/dart
  brew install dart
  ```

**Windows**:
- Use the [Dart Installer](https://dart.dev/get-dart).

### 3. Set Up Your Editor

Flutter and Dart work well with several IDEs and editors, including:
- **Visual Studio Code**: Install the [Flutter and Dart plugins](https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter) from the VS Code Extensions Marketplace.
- **Android Studio**: Install the [Flutter and Dart plugins](https://developer.android.com/studio).

### 4. Run a Flutter App

To ensure everything is working:
1. Open a terminal and run the following command to create a new Flutter project:
   ```sh
   flutter create my_app
   ```
2. Change to the project directory:
   ```sh
   cd my_app
   ```
3. Run the app:
   ```sh
   flutter run
   ```

You can use an Android/iOS simulator or connect a physical device to see the app running.

## Alternative Installation Method (Without Flutter and Dart Installers)

If you prefer not to use the standard installers, follow these steps to set up Flutter and Dart manually:

### Step 1: Install Git
- **Windows**: Download Git from [git-scm.com](https://git-scm.com/downloads) and install it.
- **macOS/Linux**: Use Homebrew or your package manager to install Git:
  ```sh
  brew install git
  ```

### Step 2: Clone Flutter SDK
Clone the Flutter repository from GitHub to your machine:
```sh
git clone https://github.com/flutter/flutter.git -b stable
```
Add the Flutter SDK to your `PATH` as mentioned in the first method.

### Step 3: Run Flutter Doctor
Navigate to the Flutter directory and run `flutter doctor` to identify any missing dependencies.

### Step 4: Install Dart
Dart can be installed separately by visiting [dart.dev](https://dart.dev/get-dart). Follow the installation instructions for your specific operating system.

---

Now you have everything set up! You can start building Flutter apps with Dart.

For more details, visit the [official Flutter documentation](https://flutter.dev/docs). Feel free to reach out for any issues or further clarifications.

