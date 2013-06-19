package  {
	import com.as3nui.nativeExtensions.air.kinect.Kinect;
	import com.as3nui.nativeExtensions.air.kinect.KinectSettings;
	import com.as3nui.nativeExtensions.air.kinect.data.User;
	import com.as3nui.nativeExtensions.air.kinect.events.CameraImageEvent;
	
	import flash.display.Stage;
	import flash.display.StageDisplayState;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import com.as3nui.nativeExtensions.air.kinect.data.SkeletonJoint;
	import flash.display.MovieClip;
	import flash.utils.Timer;
	import flash.geom.Point;
	
public class Scales extends MovieClip {
	private var kinect:Kinect;
	private var bmp:Bitmap;
	private var skeletonContainer:Sprite;
	private var isFullScreen:Boolean;
	private var prevLocation:Number;

	public function Scales() {
		stage.stageHeight = 768;
		stage.stageWidth = 2048;
		stage.align = StageAlign.TOP_LEFT;
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.nativeWindow.visible = true;
		//Listener for the key presses
		stage.addEventListener(KeyboardEvent.KEY_DOWN, downKey);
		//Make sure the "clip" doesnt immediately start playing through
		stop();
		//Check to see if a kinect is connected to the PC
		if(Kinect.isSupported())
		{
			trace("Found the kinect!");
			//Bitmap for printing out camera data (not necessary, testing purposes only)
			bmp = new Bitmap();
			addChild(bmp);
			
			skeletonContainer = new Sprite();
			addChild(skeletonContainer);
			
			kinect = Kinect.getDevice();
			
			//Add the event listener for users entering/leaving camera (this gives us the DEPTH data, no colors or any of that other crap)
			kinect.addEventListener(CameraImageEvent.DEPTH_IMAGE_UPDATE, depthImageHandler);
			
			//Create the kinect settings that get passed when the kinect is started, make sure all settings are changed PRIOR to sending it to kinect.start
			var settings:KinectSettings = new KinectSettings();
			settings.userEnabled = true;
			settings.depthEnabled = true;
			settings.skeletonEnabled = true;
			settings.rgbEnabled = true;
			
			kinect.start(settings);
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		} else { //Oh noes, no kinect!
			trace("No kinect found");
		}
	}
	
	// What to do when a key is pressed down
	protected function downKey(event:KeyboardEvent){
		// Up
		if(event.keyCode==38){
			// Increment one frame
			gotoAndStop(this.currentFrame - 1);
		}
		// Down
		if(event.keyCode==40){
			// Decrement one frame
			gotoAndStop(this.currentFrame + 1);
		}
		
		// F
		if(event.keyCode==70){
			if(isFullScreen == true){
				stage.displayState = StageDisplayState.NORMAL;
				isFullScreen = false;
			} else {
				stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
				isFullScreen = true;
			}
		}
	}
		
	protected function enterFrameHandler(event:Event):void
	{
		skeletonContainer.graphics.clear();
		var currLocation:Number;
		//This loop only goes through the users with skeletons
		for each(var user:User in kinect.users)
		{
			if(user.hasSkeleton){
				currLocation = user.position.rgb.x;
				//Insert if block managing chest movement here
				//if(prevLocation != NaN && (currLocation - prevLocation > 3)){
					//gotoAndStop(this.currentFrame + 1);
				//} else if (prevLocation != NaN && (currLocation - prevLocation < -3))
				//{
					//gotoAndStop(this.currentFrame - 1);
				//}
				
				//if((user.rightHand.position.rgb.y < user.head.position.rgb.y) && (user.rightHand.position.rgb.x > user.rightHip.position.rgb.x))
				//{
					//trace("Command gesture recognized");
					//if((user.leftHand.position.rgb.x < user.leftHip.position.rgb.x) && (user.leftHand.position.rgb.y < user.head.position.rgb.y))
					//{
						//trace("Zooming to the farthest point");
						//gotoAndStop(this.framesLoaded);
					//} else if ((user.leftHand.position.rgb.x < user.leftHip.position.rgb.x) && (user.leftHand.position.rgb.y > user.leftHip.position.rgb.y))
					//{
						//trace("Zooming to smallest point");
						//gotoAndStop(1);
					//}
					//Testing kinect data return values to ensure proper gesture control (for gesture testing purposes, keep commented)
					//trace("User returns " + user.rightHand.position.rgb.x + " for x and " + user.rightHand.position.rgb.y + " for y");
					//trace("Depth returns " + user.rightHand.position.depth.x + " for x and " + user.rightHand.position.depth.y + " for y");
				//} else 
				if((user.rightHand.position.rgb.y < user.rightHip.position.rgb.y) && (user.leftHand.position.rgb.y < user.leftHip.position.rgb.y)) {
					if((user.leftHand.position.rgb.x < user.leftHip.position.rgb.x) && (user.rightHand.position.rgb.x > user.rightHip.position.rgb.x))
					{
						//trace("zoom out recognized");
						gotoAndStop(this.currentFrame + 1);
					} else if ((user.leftHand.position.rgb.x > user.leftHip.position.rgb.x) && (user.rightHand.position.rgb.x < user.rightHip.position.rgb.x))
					{
						//trace("zoom in recognized");
						gotoAndStop(this.currentFrame - 1);
					}
				}
				//Shows each joint on an overlaid skeleton (for gesture testing purposes, keep commented)
				//for each(var joint:SkeletonJoint in user.skeletonJoints)
				//{
				//	skeletonContainer.graphics.beginFill(0xFF0000);
				//	skeletonContainer.graphics.drawCircle(joint.position.depth.x, joint.position.depth.y, 3);
				//	skeletonContainer.graphics.endFill();
				//}
				prevLocation = currLocation;
			} else {
				//If no user with a skeleton was detected...
				trace("User with no skeleton detected at distance X: " + user.position.depth.x + ", Y: " + user.position.depth.y + ".");
			}
		}
		
	}
	
	protected function depthImageHandler(event:CameraImageEvent):void
	{
		//Prints the image to the screen
		//bmp.bitmapData = event.imageData;
	}
}
}//end package