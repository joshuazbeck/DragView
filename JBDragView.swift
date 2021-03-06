//  DragView.swift
//  Josh Beck Studios
//  Originally created by Josh Beck on 1/29/19.
//  Copyright © 2021 Joshua Beck. All rights reserved.
//  Available under the MIT License.  Any modification and redistribution is allowed as long as it includes this header

import UIKit

enum Direction {
    case Up
    case Down
}

class DragView: UIView {

    ///A variable to hold the center of the view.  It should not be modified externally but is only used internally
    private var initialCenter = CGPoint()
    
    /// This function will snap the view to the top of the parent view while maintaining a distance from the top based on the cushion from top variable.
    ///
    ///The reachedTop() block code, if initialized, will run upon the method BEING called, not the view reaching a resting state after animation
    ///
    /// - Warning: Providing a different anchor point will still offset the distance from top.  See the x/y coordinates first if troubleshooting
    public func snapToTop() {
        
        let distanceFromTop = cushionFromTop
        let newUpperPosY = distanceFromTop + self.frame.size.height/2
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.84, initialSpringVelocity: 14, options: [.curveLinear, .allowUserInteraction], animations: {
        
            self.center.y = distanceFromTop + self.frame.size.height/2
            
        }, completion: nil)
        self.initialCenter = CGPoint(x: parentView.frame.size.width/2, y: newUpperPosY)
        
        reachedTop()
        //Set anchor afterwards so we can access the previous anchor point
        currentAnchorSide = .Up
       
    }
    /// This function will snap the view to the bottom of the parent view while maintaining a distance from the bottom that was intially set in visibleHeight initiation (contained in visibleHeight variable).
    ///
    ///The reachedBottom() block code, if initialized, will run upon the method BEING called, not the view reaching a resting state after animation
    ///
    /// - Warning: Providing a different anchor point will still offset the distance from bottom.  See the x/y coordinates first if troubleshooting
    public func snapToBottom(){
        
        //New position to animate too
        let newBottomPosY = parentView.frame.size.height - (self.frame.size.height/2) + offsetY
        
        //Animate the view
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.73, initialSpringVelocity: 14, options: [.curveLinear, .allowUserInteraction], animations: {
            self.center.y = newBottomPosY
        }, completion: nil)
        
        //Set the initial center for reference to honor any x/y modification of the view
        self.initialCenter = CGPoint(x: parentView.frame.size.width/2, y: newBottomPosY)

        //Run any code upon reaching the bottom
        reachedBottom()
        
        //Set anchor afterwards so we can access the previous anchor point
        currentAnchorSide = .Down
    }
    ///Setup the DragView
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        //Set the default drag distance
        allowedDragDistance = parentView.frame.size.height/5.5
        //Set the view to the corrosponding anchor side
        if currentAnchorSide == .Up{
            snapToTop()
        } else {
            snapToBottom()
        }

    }
    ///This variable holds the previous position of the pan gesture to calculate a substantial movement
    private var prevP = CGPoint()
    
    ///Holds a boolean containing whether the view should continue to track the pan.  Will be set to FALSE while is being animated upon a "snap" to the top or bottom
    private var continueMonitoringPan = Bool()
   
    ///Holds the reference view (parent view) that will be used to calculate the size to modify the animations and the distances from the top and the bottom.  Can be overiden in a subclass if desired
    internal var parentView = UIView()
    
    ///The amount of the view that should be visible from the bottom of the reference view (parent view).  Think of this amount pertaining to how much of the view should "peak up" from the bottom
    /// - Warning: Modifying the x/y values of the view from (0,0) will offset the bottom cushion by said amount
    public var cushionFromBottom = CGFloat()
    
    ///The current offset in the y axis of the view
    private var offsetY = CGFloat()
    
    ///The amount of the space that should be between the view from the top of the reference view (parent view).  Think of this amount pertaining to how much of the view should "peak up" from the bottom
    /// - Warning: Modifying the x/y values of the view from (0,0) will offset the top cushion by said amount
    public var cushionFromTop = CGFloat()
    init(frame: CGRect, parentView: UIView, cushionFromBottom: CGFloat, cushionFromTop: CGFloat) {
        super.init(frame: frame)
        self.cushionFromBottom = cushionFromBottom
        self.cushionFromTop = cushionFromTop
        self.parentView = parentView
        
        //Calculates the initial center of the view from the bottom
        initialCenter.y = parentView.frame.size.height + (self.frame.size.height/2 - cushionFromBottom)
        
        //Calculates the initial offset that moving the view to the bottom has caused
        let bottomCenterY = (parentView.frame.size.height - self.frame.size.height/2)
        //Set the offset to the said value
        offsetY = initialCenter.y - bottomCenterY
        
        //Set the initial center to middle of the view.  It is used for reference to offset any x/y changes external callers may make to the view
        initialCenter.x = self.frame.size.width/2
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    ///This function changes the position of a view only if the view / location is within desired sensitivity (threshold)[returning false] and also returns true if it is time to snap view to new position
     ///
     ///The greater the pull, the faster the view is draged to a stop
     ///Only adjust view's position if the position is within the desired threshold
     ///The greater the snapSensitivity the slower the function will return true indicating to snap to upper position.  The snap sensitivity is the pixels from the top y coord. of view for which to return true indicating a snap is needed to top

    ///- parameter position: The location of the touch (pan gesture recognizer)
    ///- parameter pull: The speed of the touch (pan gesture recognizer).  A faster pull (speed), the more sensitive and likely the view will snap to tthe top or bottom
    ///- parameter snapSensitivity: A higher snap sensitivity means the user will need to drag less to snap the view to the top or the bottom
    ///- parameter direction: .Up or .Down
    private func calculatePosition(position locOfTouch: CGPoint, pull: CGFloat, snapSensitivity: CGFloat, direction: Direction) -> Bool{
       
        //Handle the down direction
            if direction == .Down{
                
                //Calculate the target distance for the bottom of the view
                let yTop = self.parentView.frame.size.height - cushionFromBottom
                //Calculate the distance between the location of the touch and the target potion
                let diffY =  locOfTouch.y - yTop
                
                //Calculate the dampening value to apply to the movements.  The numbers are arbitrary and based on preference
                let dampening = ((diffY*diffY)/(1000*(self.parentView.frame.height/569)))*pull
                
                //Add the dampening to the actual difference in the y dimension
                let diffYScaled = -((diffY) + dampening)
                //If the diffY scaled is bigger than 0 (should be negative), flatline at 0
                let diffYScaledSafe = (diffYScaled >= 0) ? diffYScaled : 0
                
                /**
                 What's going on? :
                 diffYScaled is negative because of the anchor point of the view.  What we would assume would be compared upwardly is in reality translated as a lesser value because the y-dimension starts at 0 and moves down the screen to +self.view.frame.size.width.
                 If the snapSensitivity is greater than the difference in the y dimension, the we return true to completed.  The snapSensitivity determines how sensitive the view should be before it snaps to the upper position.  The larger the value, the earlier it will snap because the difference between the y-distance btw touch and view upper bound and the calculated dampening will be greater.
                */
                
                //Compare to see if the diffYScaled(for the snap sensitivity)Safe is big enough to warrent a snap downward?
                if snapSensitivity <= diffYScaledSafe{
                    return true
                } else {
                    //The snap does not warrent a snap downward; offset the actual position of the drag by the diffYScaledSafe to provide a more natural decelleration before the SNAP!!
                    let posY = initialCenter.y - diffYScaledSafe
                    
                    if posY < initialCenter.y {
                        //PosY is closer to top of the view
                        self.center.y = posY
                    }
                    
                    //No snap warrented
                    return false
                }
            } else if direction == .Up{

                //Calculate the target distance for the top of the view
                let yTop = initialCenter.y - self.frame.size.height/2
                //Calculate the distance between the location of the touch and the target potion
                let diffY =  locOfTouch.y - yTop
                //Calculate the dampening value to apply to the movements.  The numbers are arbitrary and based on preference
                let dampening = ((diffY*diffY)/(1000*(self.parentView.frame.height/569)))*pull
                
                //Add the dampening to the actual difference in the y dimension
                let diffYScaled = (diffY) - dampening
                //If the diffY scaled is bigger than 0 (should be negative), flatline at 0
                let diffYScaledSafe = (diffYScaled >= 0) ? diffYScaled : 0
               
                //Compare to see if the diffYScaled(for the snap sensitivity)Safe is big enough to warrent a snap downward?
                if snapSensitivity <= diffYScaledSafe{
                    return true
                } else {
                    
                    //The snap does not warrent a snap downward; offset the actual position of the drag by the diffYScaledSafe to provide a more natural decelleration before the SNAP!!
                    let posY = initialCenter.y + diffYScaledSafe

                    if posY > initialCenter.y {
                        self.center.y = posY
                    }
                    
                    //No snap warrented
                    return false
                }
            } else {
                //Provided a response other than .Up or .Down
                return false
            }
        
       
        
    }
    ///Set current anchor side to either up or down [default = .Down]
    public var currentAnchorSide = Direction.Down
    
    ///This property holds  the distance required to drag the view before it snaps to the bottom or top of view.  This is set defaultly and only needs to be overriden if a custom value is required
    /// - Warning: Only set this property after the view has moved to the superview.  Otherwise, the custom value will be overwritten
    public var allowedDragDistance = CGFloat()
    
    ///This property holds the current offset from top as set from the touches moved/began method
    private var offsetFromTop: CGFloat = 0
    ///This property holds the current offset from bottom as set from the touches moved/began method
    private var offsetFromBottom: CGFloat = 0
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       
        //Set the initial position
        touchBeginWPosition(location: touches.first!.location(in: parentView))
    }
    
    ///This method handles setting the appropriate values upon a first touch
    func touchBeginWPosition(location: CGPoint){
        //Reset offset from top to a 0
         offsetFromTop = 0
        
        //If the touch is within the frame
        if self.frame.contains(location){
            
            //Set offset so that view will not instantaneously snap to new position.  It sets it so that the touchesMoved location.y is reduced by offset virtually setting the touch as starting at the top of the view.
            let topOfView = self.center.y - self.frame.size.height/2
            offsetFromTop = location.y - topOfView
            
            continueMonitoringPan = true
        } else {
            //The touch is not within the DragView so stop monitoring pan.  It doesn't matter
            continueMonitoringPan = false
        }
    }
    
    ///This property can be set to a non-default value to run code upon reaching the end of the upward snap animation (aka. whenever the drag view is settled at the top)
    public var reachedTop: (() -> Void) = {
        
    }
    
    ///This property can be set to a non-default value to run code upon reaching the end of the downward snap animation (aka. whenever the drag view is settled at the bottom)
    public var reachedBottom: (() -> Void) = {
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
       super.touchesMoved(touches, with: event)
        let locOfTouch = touches.first!.location(in: parentView)
        touchMovedWPosition(loc: locOfTouch)
    }
    
    ///This method modifies all necessary values whenever a touch is being dragged across the screen
    private func touchMovedWPosition(loc locOfTouch: CGPoint){
        
        //If we should continue to monitor the pan (it is within the bounds of the drag view
        if continueMonitoringPan == true {
            
            //Find the y location offset by the distance necessary from the top
            let transposedPosition = CGPoint(x: locOfTouch.x, y: locOfTouch.y - offsetFromTop)
            
            //Store whether the view should snap down/up
            var needToSnap = false
            
           //If the current anchor side is down
            if currentAnchorSide == .Down{
                
                //Determine if a snap downwards is warrented
                //MARK: Customize the pull here to make the snap downward more sensitive appart from the snap upwards (change the 1.7)
                needToSnap = calculatePosition(position: transposedPosition, pull: 1.7, snapSensitivity: allowedDragDistance, direction: .Down)
                
                //Also runs the calculate position block so the view is moved whether or not the timeToSnap variable is accessed
                if needToSnap {
                    continueMonitoringPan = false
                    snapToTop()
                    currentAnchorSide = .Up
                }
            } else {
                
                //Determine if a snap upwards is warrented
                //MARK: Customize the pull here to make the snap upwards more sensitive appart from the snap downwards (change the 1.7)
                needToSnap = calculatePosition(position: transposedPosition, pull: 1.7, snapSensitivity: allowedDragDistance, direction: .Up)
                
                //Also runs the calculate position block so the view is moved whether or not the timeToSnap variable is accessed
                if needToSnap {
                    continueMonitoringPan = false
                    snapToBottom()
                    currentAnchorSide = .Down
                    
                }
            }
            
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        let locOfTouch = touches.first!.location(in: parentView)
         touchEndWPosition(locOfTouch: locOfTouch)
    }
    
    ///Private method handle resetting all values at the end of a drag/tap sequence
    private func touchEndWPosition(locOfTouch: CGPoint){
        if continueMonitoringPan == true {
            //Find the transposed position to determine if a snap is necessary
            let transposedPosition = CGPoint(x: locOfTouch.x, y: locOfTouch.y - offsetFromTop)
            
            //Determine if a snap is necessary
            let needToSnap = calculatePosition(position: transposedPosition, pull: 1.7, snapSensitivity: allowedDragDistance, direction: currentAnchorSide)
            
            if currentAnchorSide == .Down {
                
                if needToSnap {
                    
                    //Snap to up position
                    snapToTop()
                    
                    //Toggle anchor side
                    currentAnchorSide = .Up
                } else {
                    
                    //Snap back to initial start position
                    snapToBottom()
                    
                    //Toggle anchor side
                    currentAnchorSide = .Down
                }
                
            } else if currentAnchorSide == .Up{
                
                if needToSnap {
                    
                    //Snap to up position
                    snapToBottom()
                    
                    //Toggle anchor side
                    currentAnchorSide = .Down
                   
                } else {
                    
                    //Snap back to initial start position
                    snapToTop()
                    
                    //Toggle anchor side
                    currentAnchorSide = .Up
                  
                }
                
            }
        }
    }
}
