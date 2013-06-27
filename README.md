# Localization Suite

All source code for the Localization Suite.

## Structure
Subfolders are structured as follows:

- **BlueLocalization**: Central framework for storage, import and export of files. Also implements process architecture, file formats, etc.
- **LocTools**: Framework with translation-related algorithms. Includes a difference engine, fuzzy match computation, auto-translation, localization checking, etc.
- **NibPreview**: Framework used to parse and preview Mac xib/nib interface files.
- **LocInterface**: Common interface components shared by all applications.
- **Manager**: The Localization Manager application. Logic lies in frameworks, mostly just interface.
- **Localizer**: The Localizer application. Logic lies in frameworks, mostly just interface.
- **Dictionary**: The Localization Dictionary application. Logic lies in frameworks, mostly just interface.
- **Shared**: Utility stuff like 3rd party frameworks and image resources shared by all the apps and frameworks.

## Branch management
This project is supposed to use git-flow branching structure. Read about [the concept](http://nvie.com/posts/a-successful-git-branching-model/), [the tool](http://jeffkreeftmeijer.com/2010/why-arent-you-using-git-flow/) and [the project](https://github.com/nvie/gitflow). Installing is as easy as typing:

    brew install git-flow

This project uses the default naming scheme suggested when initializing git flow on your checkout.