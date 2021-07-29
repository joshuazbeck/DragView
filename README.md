# JBDragView
##### _Simulate iOS's many draggable, collapsable views 🤩_


JBDragView is a customizable UIView which mimics Apple's draggable and collapsable views.  What do you mean by autocollapsable views, you might wonder?  Here's a lovely example of one of the many draggable views by Apple and a sample usage of a JBView which we will build in this guide:

![Alt Text](https://media.giphy.com/media/9G5K3YQRKu24HDl5af/giphy.gif)   ![Alt Text](https://media.giphy.com/media/bnnmS9F2BPIZ8XftT2/giphy.gif)

See how this deliciously delightful view slides up and down with the simple slide of a finger yet snaps to oh-so convenient positions depending on the needs of design.  This is what the JBDragView attempts to simulate!

##### JBDragView is:

- Lighweight 🪶
- Quick and buttery smooth 🧈
- ✨Customizable ✨

# Set Up

Set up for the JBDragView is incredibly simple.  Instead of worrying about complicated frameworks and troublesome Maven builds that don't work even though it works for your brother and mother. 

_JBDragView is a simple file.
It needs no imports or exports.
All code lies at your fingertips._

Let's get right into it!
To start:

- Download the GitHub repository into project
- Add the JBDragView to a UIViewController
- Customize to fit needs

Let's break this down step by step

#### Download the GitHub repository into project

Run these commands in your terminal upon navigating to your existing project's path

To download the entire GIT repo (license, README.md, JBDragView) 
> Recommended
```sh
cd {project_path}
git fetch https://github.com/joshuazbeck/DragView.git
git checkout HEAD
```
To download only the JBDragView.swift file:
> Not recommended but smaller download size
```sh
cd {project_path}
git fetch https://github.com/joshuazbeck/DragView.git
git checkout FETCH_HEAD -- JBDragView.swift
```
After dowloading the file(s), move them to the desired folder within your Xcode project
#
#
#### Add the JBDragView to a UIViewController
Now that we have that crucial JBDragView in our project, the next step is to integrate it.  A JBDragView is incredibly simply to integrate.  No need for troublesome imports and dependency checks.  Instead, assuming it is in the same package as the rest of the project, it can merely be referenced and quickly initialized.

##### Try it out
Go ahead and add a view to the view controller.  There are a few different parameters to keep in mind when creating your first Drag View.  Setting the frame is pretty self explanatory (do note that x:0, y:0 will result in a non-offset but centered view.  Changing these values will offset the view from the CENTER not the origin)
```
 override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let draggableView = DragView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height), parentView: self.view, cushionFromBottom: 100, cushionFromTop: 100)
        self.view.addSubview(draggableView)
    }
```
Whenever you do this, however, you will notice that the screen is left unchanged:
#

![Alt Text](https://i.postimg.cc/sDjZ0mDx/Simulator-Screen-Shot-i-Phone-12-mini-2021-07-28-at-21-49-12.png)

_There is nothing on the screen after adding the view_
#
It is important to note that a JBDragView is only a VEHICLE for the behavior.  In of itself, it is a transparent view.  Therefore, we could spice things up by adding a colored view on top of the JBDragView.
```
let coloredView = UIView(frame: self.view.frame)
coloredView.backgroundColor = .purple
draggableView.addSubview(coloredView)
```
Doing this results in having a draggable, pullable view that we can see!

![Alt Text](https://media.giphy.com/media/glOo8Hnl5u7WGcH21p/giphy.gif)

#
However, this isn't necessarily too exciting.  Things really start to look Apple _ish_ whenever we pair this effect with a blur view layered on top.  Go ahead and delete the previous code to add the purple view:

~~let coloredView = UIView(frame: self.view.frame)
coloredView.backgroundColor = .purple
draggableView.addSubview(coloredView)~~

Add in this code:
```
//Set up effect view
let blur = UIBlurEffect(style: .extraLight)
let blurView = UIVisualEffectView(frame: self.view.frame)
blurView.effect = blur;
        
//Change corner radius
blurView.layer.cornerRadius = 20
blurView.clipsToBounds = true
draggableView.addSubview(blurView)
```

 ![Alt Text](https://media.giphy.com/media/SeoyL383F7IKRMXgfu/giphy.gif)

And now we have a nice, pretty, smooth view that behaves very similar to the draggable view's throughout Apple's UI.  Turning now to further customization!!

##### Customization

We've already explored some customization in setting up a basic draggable view that simulates the draggable views within Apple's interface.  However, such a basic implementation does not necessarily fit every implementation.  A large amount of customization is possible through modification of direct JBDragView properties.  Propterties such as 
- **cushionFromBottom** - A greater value means more of the view will be exposed whenever the drag view is anchored to the bottom
- **cushionFromTop** - A smaller value means that more of the view will be exposed whenever the drag view is anchored to the top and the gap between the top of the drag view and the phone screen will be smaller
- **allowedDragDistance** - This is a variable that can be changed to determine how far a user must "drag/pull" the view before it automatically snaps to the top or the bottom.  Modifying this to a lesser value will mean a user will have to drag longer before the view autosnaps
- **currentAnchorSide** - This holds whether the view is starting in the .Up or .Down position

Additionally, there are a few more complex customizations that can be added.  For example, let one theorize that one would like to snap the drag view to the top of the view whenever a button is pressed.  One must simply call the code:

```
dragView.snapToTop()
```
And this will handle all the behind the scenes work of animating the drag view upwards.
```
dragView.snapToBottom()
```
Will snap the drag view to the bottom
#
#
One final functionality that deserves mention is the ability to run custom code whenever reaching the top and the bottom of the "snap" positions.  This is done by setting a void handler for either the top or the bottom which is run at the end of the animation (whenever the drag view settles after doing it's short spring animation action)
#
These void handlers can be accessed through the **reachedTop** and **reachedBottom** properties.  Here is an example of how they can be used.  Simply add the following code after the previous code for adding an optional blur view:

```
 draggableView.reachedTop = {
    UIView.animate(withDuration: 0.2) {
        blurView.effect = UIBlurEffect(style: .dark)
    }
}
        
draggableView.reachedBottom = {
    UIView.animate(withDuration: 0.2) {
        blurView.effect = UIBlurEffect(style: .extraLight)
    }
}
```
This will produce the following animations upon reaching the top and the bottom "snap" positions:

 ![Alt Text](https://media.giphy.com/media/bnnmS9F2BPIZ8XftT2/giphy.gif)
 
 These are a few of the customizations you can add to the JBDragView.  
 
 ### Conclusion
 Any component can be added on top of the JBDragView such as buttons, horizontal scroll views, and text.  Thank you for taking the time to explore this little component.  I hope you find it as helpful to you as it was to me.  
All improvements are also welcome and if you have any questions, I would be happy to do my best to answer them.  
#
**🎉 If you do anything special or boring with this, please let me know!  I would absolutely love to hear about all the creative ways you have used this!!! 🪅**
