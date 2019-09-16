# Infinite Image Scroll

Hey there! This app serves as a simple visual client for the [Bing Image Search API](https://azure.microsoft.com/en-us/services/cognitive-services/bing-image-search-api/).

This README serves as a high-level guide to the app's codebase. Check out the bottom of this page for a video of the app in action!

![allimages](https://github.com/smolster/InfiniteImageScroll/raw/master/Screenshots/allimages.png)

### Dependency Note
This app uses a third-party dependency for rendering GIFs: [FLAnimatedImage](https://github.com/Flipboard/FLAnimatedImage). The project uses [Carthage](https://github.com/Carthage/Carthage) to manage this dependency. Running `carthage update` in the primary directory should set the project up to build.

## App Architecture Overview
The app's architecture can be broken down into Four primary components: **Models**, **Providers**, **ViewModels**, and **Views**.

### Models
Models in this app refer to the backing data/information around which logic is performed. Examples in this app: are `ImageMetadata` and `ImagePage` retrieved from the network and `UserSettings` retrieved from local storage.

### Providers
Providers are, essentially, ViewModel dependencies used for accessing Model information. They are responsible for retrieiving and/or editing backing model data on the network or local storage. In general, they are always declared as protocols, so that test providers can be swapped out when testing the ViewModels. In this app, they are organized into "Local" providers and "Networking" providers. A great example `PagingImageDataProvider` and implementation `BingImageDataProvider`, which are responsible for providing `ImagePage`s from the network.

### View Models
View Models serve as the bridge between the Models and the Views, and are the core logic handlers in the app. In general, every unique screen of the app should have its own ViewModel. ViewModels are responsible for loading data, and transforming communication from the Model -> View and View -> Model using Providers.

ViewModels are **not** responsible actually rendering the view--they communicate _what_ should be displayed, but not _how_ to display it (e.g. "Display a loading overlay with text telling the user images are loading", rather than "Render a LoadingOverlayView with an activity indicator at these coordinates"). It's up to the view to decide how to display to the user. For a good example of this distinction, a check out the difference between `AllImagesLoadingOverlayState` and `SingleImageCollectionViewCell.Configuration`.

Interactions with ViewModels fall strictly into either Inputs from the View (in the form of ViewModel object methods) or Outputs to the View (in the form of settable handler closures).

They are uniformly declared as in this example:

```swift
protocol SampleViewModelInputs: class {
    /// Call when the user taps the button.
    func userTappedButton()
}

protocol SampleViewModelOutputs: class {
    /// Outputs when the provided String should be displayed to the user.
    var displayMessage: ((String) -> Void)? { get set }
}

protocol SampleViewModelType: class {
    var inputs: SampleViewModelInputs { get }
    var outputs: SampleViewModelOutputs { get }
}

final class SampleViewModel: SampleViewModelInputs, SampleViewModelOutputs, SampleViewModelType {
    var inputs: SampleViewModelInputs { return self }
    var outputs: SampleViewModelOutputs { return self }

    // MARK: - Private Properties

    /// Example property that may change based on app conditions, Model information, etc.
    private var shouldDisplayMessage: Bool = false

    init(...) { }

    // MARK: - Outputs
    var displayMessage: ((String) -> Void)?

    // MARK: - Inputs
    func userTappedButton() {
        if shouldDisplayMessage {
            self.outputs.displayMessage?("Sample message!")
        }
    }
}
```

Initially, this code pattern may seem a bit repetitive. However, the clarity and ease of understanding it provides is worth the extra lines. At first glance, we can immediately see all of the ways in which the user can interact with the associated screen (in the form of Inputs), and all of the ways in which the View can change (in the form of Outputs).

As a rule, a View should set all of its ViewModel's outputs before the end of `viewDidLoad()`. Additionally, outputs should not be changed once set. However, outputs are (as a rule) declared as variable for testing reasons.

### Views
View objects in the app are, generally, `UIViewController` subclasses, like `AllImagesViewController`. A View has only two jobs:

1. Gather user input, and pass it along to its associated ViewModel's `inputs`.
2. Respond to its associated ViewModel's `outputs` by assigning closures to each before the end of `viewDidLoad`.

Example interaction from a View:

```swift
final class SampleViewController: UIViewController {

    let viewModel: SampleViewModelType

    init(viewModel: SampleViewModelType) {
        self.viewModel = viewModel
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.outputs.displayMessage = displayMessage
    }

    var displayMessage: (String) -> Void { 
        return { [weak self] message in 
            self?.label.text = message
        }
    }

    @IBAction func buttonTapped(_ sender: UIButton) {
        self.viewModel.inputs.userTappedButton()
    }
}
```
Note that no decisioning happens in the view controller--it's only responsibility is to respond to ViewModel outputs, and pass along inputs.

Good examples of Views are `AllImagesViewController` and `SettingsViewController`.

## Architecture Benefits
### Ease of Understanding
The clearly defined and consistently structured Input/Output protocols allow a developer to quickly understand "what actually happens" on a given screen, which can often be almost half the battle when working with new code.

### Testability
The decoupling between the ViewModel and the View objects allow both to be tested independently and rigourously.

While this project's unit tests are not as thorough as would be ideal (due to time constraints), I've included a handful of good ViewModel example tests to demonstrate the simplicity that comes from the Input/Output approach.

#### ViewModel Approach
ViewModels are highly testable. They aren't inherently connection to a `UIViewController`, and don't inherit from `NSObject`, which make them easy to work with in a test environment.

By passing in test versions of Provider dependencies, we can ensure that providers are called when necessary, easily simulate error scenarios, and verify that the correct values are sent to outputs at the correct times. Integration tests become a breeze!

See `TestImageDataProvider` for a good example of a test provider, and `AllImagesViewModelTests` for an example of how we can test view models!

#### View Approach
In this architecture, Views become testable as well! Thanks to the `XXXXViewModelType` protocols, we can pass in test versions of ViewModels that can be used to puppet changes their associated Views owners, and ensure that views respond correctly to the provided outputs. A fully realized testing suite could make use of screenshot testing with minimal effort.

## Conclusion
Thanks so much for reading through! I'd love any and all thoughts, critiques, or comments about my work. Thanks again for your time, and have a great day!
