# Contributing

> vStacklet is an open source project licensed using the The MIT License.
> This project has been forked and completely rewritten from [Quick LEMP](https://github.com/jbradach/quick-lemp/).
> Though the two are not the same and are entirely different, vStacklet has drawn inspiration from Quick LEMP and is grateful for the work that has been done.
> I appreciate pull requesets as well as other types of contributions. Any contributions, suggestions, or comments are welcome!

---

## Documentation

Documentation is available at: [/docs/](https://github.com/JMSDOnline/vstacklet/tree/main/docs)
 - :book: [vStacklet Documentation](https://github.com/JMSDOnline/vstacklet/blob/main/docs/setup/vstacklet.sh.md)
 - :book: [vStacklet Server Stack Documentation](https://github.com/JMSDOnline/vstacklet/blob/main/docs/setup/vstacklet-server-stack.sh.md)
 - :book: [vStacklet www-permissions.sh) Documentation](https://github.com/JMSDOnline/vstacklet/blob/main/docs/bin/www-permissions.sh.md)
   - :book: [vStacklet VS-Perms (www-permissions-standalone.sh) Documentation](https://github.com/JMSDOnline/vstacklet/blob/main/docs/bin/www-permissions-standalone.sh.md)
 - :book: [vStacklet VS-Backup (vs-backup) Documentation](https://github.com/JMSDOnline/vstacklet/blob/main/docs/bin/backup/vs-backup.md)
   - :book: [vStacklet VS-Backup (vstacklet-backup-standalone.sh) Documentation](https://github.com/JMSDOnline/vstacklet/blob/main/docs/bin/backup/vstacklet-backup-standalone.sh.md)

---

## How to Contribute to vStacklet - You want to contribute feedback, support, or general issue reporting

 - It's the most important step of all! [Grab the vStacklet script](https://github.com/JMSDOnline/vstacklet/tree/main#getting-started) and [run it on your system](https://github.com/JMSDOnline/vstacklet/tree/main#example).
 - Report script related issues or ideas for enhancements on the [issue tracker](https://github.com/JMSDOnline/vstacklet/issues).
 - Assist with testing on different distributions to help ensure compability.
 - Say thanks and/or spread the word. :heart:
 - "Do you accept donations?" Nope, but I do accept feedback and support. :smile:
   - "But I really want to donate!" Okay, you can donate to the [Electronic Frontier Foundation](https://www.eff.org/) or your favorite charity.

---

## How to Contribute to vStacklet - You want to contribute code

 - Fork, clone, and improve this repistory by sending a pull request when it's done. (preferrably to the `development` branch)
 - I use [VSCode](https://code.visualstudio.com/) for development, but you can use whatever you want. I have included a couple of extension settings in the project, as this makes my life easier. You can find more information about these extensions below.
 - Install the Trunk.io extension for VSCode. (See more on that below)
 - Setup for RunOnSave in VSCode (See below)
 - The project is coded with indentation of 4 spaces as tab. This is not required, but it is recommended. Worse case scenario, I will adjust the formatting when I merge your pull request. I certainly don't want to make it harder for you to contribute.

### Visual Studio Code Setup

#### Extensions

##### [Run on Save](https://marketplace.visualstudio.com/items?itemName=emeraldwalk.RunOnSave)

> Needed for the scripts in `developer_resources`
> - RunOnSave will run the scripts in `developer_resources` to ensure that the code is formatted correctly.
> - RunOnSave will additionally set the version numbers on files and the readme.
> - RunOnSave will also update the documentation in the `docs` folder. These are formatted in markdown and are used to generate the documentation site. `developer_resources/doc.awk` is used to generate the documentation site with the necessary formatting.

##### [Trunk](https://marketplace.visualstudio.com/items?itemName=trunk.io)

> Needed for the `.trunk/trunk.yaml` file in the root of the project. This is not required, but it is recommended. This will handle all linting/formatting/issue checking needs, it generally makes life easier.

<br />

#### Visual Studio Code Settings

##### Run on Save Settings

```json
  "emeraldwalk.runonsave": {
    "commands": [
      {
        "match": ".*",
        "isAsync": false,
        "cmd": "bash \"${workspaceFolder}/developer_resources/onSave\" \"${file}\" \"${workspaceFolder}\""
      }
    ],
  }
```

##### Trunk Settings

No big setup required, just install the extension and it will do the rest.

<br />

#### Windows compatibility

You'll need to add your Git folder (Normally located at `C:/Program Files/Git` to your system environments, then restart vscode). After that replace `bash` with `git-bash` in the above codeblock.

**This also might work:**
Windows users might need to enable BASH. To do this:
 1. Go to **Settings** > **Update & Security** > **For Developers**. Check the Developer Mode radio button.
 2. And search for “*Windows Features*”
 3. Choose “*Turn Windows features on or off*”
 4. Scroll to find ***WSL***, check the box, and then install it.
 5. Once done, one has to reboot to finish installing the requested changes.
 6. Press Restart now.

<br />

### Coding Practices

#### File Header

Files should follow this example header: <sup>(Aids in proper formatting for associated documentation. example: [the docs](https://github.com/JMSDOnline/vstacklet/blob/main/docs/setup/vstacklet-server-stack.sh.md))</sup>

```bash
#!/usr/bin/env bash
################################################################################
# <START METADATA>
# @file_name: example_file
# @version: 1.0.0
# @description: Short file description
#
# @project_name: vStacklet
#
# @path: /path/to/example_file
#
# @brief: Example file brief
#
# @save_tasks:
#  automated_versioning: true|false (default: true)
#  automated_documentation: true|false (default: true)
#
# @build_tasks:
#  automated_comment_strip: false
#  automated_encryption: false
#
# @author: Jason Matthews (JMSDOnline), ... <add_your_name_next>
# @author_contact: https://github.com/JMSDOnline/vstacklet
#
# @license: MIT License (Included in LICENSE)
# Copyright (C) 2016-2023, Jason Matthews :: vStacklet
# All rights reserved.
# <END METADATA>
################################################################################
```

This allows the post process scripts in `developer_resources` to process how each file needs to be handled.

#### Function Comments

Each function group should be preceded by the following header: <sup>(Aids in proper formatting for associated documentation. example: [function header in the docs](https://github.com/JMSDOnline/vstacklet/blob/main/docs/setup/vstacklet-server-stack.sh.md#vstackletcsfinstall))</sup>

```bash
################################################################################
# @name: Function::Name
# @description: Description of function
# Globals:
#   Any variables declared that are not local.
# Arguments:
#   Any arguments that are being passed to functions ("$@")
################################################################################
```

This allows us to quickly see what is being modified for debugging or review purposes.

#### Function Naming

Functions should be named with `function_group::function_name` syntax. This makes it easier to identify where the function is being called, and what it is responsible for doing. You'll see a lot of `function_group::function_name::function_task()` throughout the vStacklet code, again, this is to keep things transparent and easy to follow as per their intended function.

---