# Contributing
Thank you for your interrest in Contributing to the Project! Please follow the guide below before opening a Pull Request!

## Governance
- Pull Requests are reviewed by [Alexkist](https://github.com/Alexkist) or any other maintainer.
- Maintainers may edit PR titles, descriptions and labels for classification.
- Community Members are allowed and encouraged to leave comments below PR's for Feedback.

## Scope of Contributions
* **Permited Contributions:**
    * Additions or modifications to Quickchat features or systems
    * Bug fixes and stability improvements
    * Documentation and wiki improvements
* **Prohibited Contributions:**
    * Any form of obfuscated code
    * Features that could endanger Games using the Quickchat
    * Code or features that violate Roblox's Terms of Service or Community Standards
    * Contributions that add unnecessary complexity without clear benefit.

## Pull Request Standards
* **Titles:**
    * Must be concise and clearly describe what is being added
    * Examples
        * `Fix Feature`
        * `Add New Feature`
* **Descriptions**
    * Must clearly document the changes
    * Should explained the intend behind the change
* **Proof of Functionality:**
    * PR's should include evidence (e.g. Videos, Screenshots) showing that the contribution works in Roblox Studio.
        * It is also recommended to test features in live Servers.
        * **Exceptions:** Obvious fixes (like Typos).
* **Labels:**
    * PR's should include relevant labels.
    * Maintainers may add or adjust labels after submission.

## Code Quality and Style
* This Project uses Selene for linting and Aftman to manage tooling versions. Please make sure your code passes Selene checks (see `selene.toml`) before submitting.
* Follow the existing formatting and naming conventions used throughout the `MainModule` and `Loader`.
* Use clear, descriptive variable and function names instead of abbreviations.
* Comment non-obvious logic, especially around Plugin hooks, TopbarPlus/VRBottomBar integration, or VR compatibility.
* Avoid introducing new external dependencies.

## Version Control
* All PR's should be based on the latest version of the `master` branch.
* Outdated or conflicting code will not be merged.

## Tooling and Developer Environment
* We recommend using Rojo to sync with Roblox Studio.
    * Please install Rojo via the [official documentation](https://rojo.space/docs/v7/getting-started/installation/)
* Rojo can be run via `rojo serve` or the VS Code plugin.

### Building the Loader and MainModule with Rojo
You can start by forking the Repository and cloning it to your System locally.
```bash
git clone https://github.com/<your-username>/OspryOS-Quickchat.git
cd OspryOS-Quickchat
```

**Build the latest `Loader` and `MainModule` into a place file** using the provided `default.project.json`:
```bash
rojo build default.project.json --output OspryOS-Quickchat.rbxlx
```

**Or, sync live into Roblox Studio** while you work
```bash
rojo serve default.project.json
```
Then connect to the running session from the [Rojo Studio Plugin](https://create.roblox.com/store/asset/13916111004/Rojo). Any changes you make to files under `Loader/` or `MainModule/` will sync into Studio.

## Post-Merge Process
* Accepted contributions will be credited in the [README](https://github.com/Alex-Tech-Incorporated/OspryOS-Quickchat/blob/main/README.md) file.
* After merging, maintainers will conduct additional testing.

## Reporting Bugs & Requesting Features
* Please search existing [Issues](https://github.com/Alex-Tech-Incorporated/OspryOS-Quickchat/issues) before opening a new one to avoid duplicates.
* When reporting a bug, describe the bug, include steps to reproduce, Loader Version, Device and Version Channel
* Feature requests are welcome, but please explain the use case and why it fits the Scope of Contributions above.