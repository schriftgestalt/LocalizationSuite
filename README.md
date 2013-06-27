# Localization Suite

All source code for the Localization Suite. Subfolders are structured as follows:

- **BlueLocalization**: Central framework for storage, import and export of files. Also implements process architecture, file formats, etc.
- **LocTools**: Framework with translation-related algorithms. Includes a difference engine, fuzzy match computation, auto-translation, localization checking, etc.
- **NibPreview**: Framework used to parse and preview Mac xib/nib interface files.
- **LocInterface**: Common interface components shared by all applications.
- **Manager**: The Localization Manager application. Logic lies in frameworks, mostly just interface.
- **Localizer**: The Localizer application. Logic lies in frameworks, mostly just interface.
- **Dictionary**: The Localization Dictionary application. Logic lies in frameworks, mostly just interface.
- **Shared**: Utility stuff like 3rd party frameworks and image resources shared by all the apps and frameworks.