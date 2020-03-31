# Developer onboarding

The audience for this document is a developer who is being onboarded onto the
project, either for the service team or first-line support.

## How to set up Azure two-factor auth without giving a phone number or downloading a proprietary app

To use DfE’s Cloud Infrastructure Platform on Azure, you need to set up
two-factor authentication.

It’s possible to use a TOTP app like 1Password, but the Azure UI doesn’t make it
clear.

These steps are correct for DfE Azure’s UI as of 2020-03-31, but things might
change.

1. In “Step 1: How should we contact you?”, choose “Mobile app”.
2. In “How do you want to use the mobile app?”, choose “Use verification code”.
3. Click the “Set up” button.
4. The “Configure mobile app” screen that appears will show a QR code that can
   only be used by the Microsoft authenticator app. To switch it to display a
   TOTP code, click “Configure app without notifications”. You can then copy and
   paste the “Secret Key” into a one-time password field in 1Password.
5. Click “Next”.
6. Enter the 6-digit verification code displayed in 1Password.
7. Click “Verify”.

Two-factor auth is now set up. Azure may prompt you to add a backup phone
number, but at the time of writing it was not necessary to fill this in. You can
close this tab and then log in to Azure using the code from 1Password.
