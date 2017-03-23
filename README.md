# Deploy To SharePoint VSTS Build Step #

### What is this repository for? ###

When developing SharePoint add-ins you typically need to deploy the add-in to a SharePoint online tenant upon successful build. This is 
a Visual Studio Team Services (VSTS) Custom build step enabling just that.

Simply configure the build step with details about the SharePoint tenant and your add-in will be deployed automatically

### Contribution guidelines ###

* Never commit without comments

### Who do I talk to? ###

* Repo owner is "Projectum Aps" - world leader of Project Server/Online implementations

### Prerequisites ###

In order to either make changes or deploy the extension, your environment must meet the following requriements:

* [NodeJS runtime](https://nodejs.org/en/)
* [TFX CLI](https://github.com/Microsoft/tfs-cli)

### Deploying the build task to specific VSTS ###

Below are the steps to deploy the build task to specific VSTS passing marketplace:

1. Achieve [VSTS personal access token](https://www.visualstudio.com/en-us/docs/integrate/get-started/auth/overview#create-personal-access-tokens-to-authenticate-access) from target VSTS tenant.
2. Open command line and navigate to extension folder (where extension.json is located).
3. Execute the following commands (replace `{tenant}` and `{access_token}` with your values):

```
    tfx login --service-url https://{tenant}.visualstudio.com/DefaultCollection --token {access_token}
    tfx build tasks upload --task-path ./UploadFilesToSPDocLib
```

Run the following command to delete already deployed task:

```
    tfx build tasks delete --task-id 78e95edd-975c-46cd-bfcc-4f4b22c1f792
```

### Publishing VSTS extension with the build task to VSTS marketplace ###

Follow steps below to publish VSTS extension with the build task to VSTS marketplace:

1. Create your [VSTS publisher](https://www.visualstudio.com/en-us/docs/integrate/extensions/develop/add-build-task#step-4-publish-your-extension).
2. Open command line and navigate to extension folder (where extension.json is located).
3. Execute the following command to package your extension into a .vsix file (it will appear in Builds folder):

```
    tfx extension create --manifest-globs extension.json
```
4. Upload your generated extension to [Marketplace Publishing Portal](http://aka.ms/vsmarketplace-manage)
5. Right click your extension and select Share..., and enter your account information.

Now that your extension is in the marketplace and shared, anyone who wants to use it will have to install it.

Check the following article for detailed description of publishing process of VSTS extension to marketplace and specific tenant: https://www.visualstudio.com/en-us/docs/integrate/extensions/publish/overview 