# flutter-github-api-example

[![Build Status](https://app.bitrise.io/app/1374261f7edd2854/status.svg?token=vvuQ1e27U7VQX7XgifZwDg&branch=main)](https://app.bitrise.io/app/1374261f7edd2854)

Using the GitHub API in Flutter. Sandbox/example project.

A minimal example showcasing how https://pub.dev/packages/github and https://pub.dev/packages/url_launcher can be used to provide a full GitHub OAuth2 login & repo listing flow.

## Tested platforms

- iOS
- macOS
- Windows
- Android

## Setup / development / usage notes

- Project has to have "internet permissions" to be able to communicate with the GitHub API:
    - Android: https://flutter.dev/docs/cookbook/networking/send-data#1-add-the-http-package
    - macOS: https://stackoverflow.com/a/61201109/974381 & https://flutter.dev/desktop#setting-up-entitlements
- Don't forget to set the right `scopes` in the `OAuth2Flow` call, based on the APIs you want to access: https://docs.github.com/en/developers/apps/building-oauth-apps/scopes-for-oauth-apps
