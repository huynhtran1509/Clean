//
//  RoomView.swift
//  clean
//
//  Created by Gabriel O'Flaherty-Chan on 2016-01-03.
//  Copyright © 2016 Gabrieloc. All rights reserved.
//

import SceneKit

class RoomView : SCNView {

	var character : Character = Character()
	var cameraNode : SCNNode {
		return scene!.rootNode.childNodeWithName("PlayerCamera", recursively: true)!
	}
	
	override init(frame: CGRect) {
		super.init(frame:frame)
		commonInit()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
	}
	
	func commonInit() {
		self.scene = Playground.init(character: character)
		
		playing = true
		loops = true
		showsStatistics = true
	}

	var eventsDelegate: KeyboardAndMouseEventsDelegate?
	
	#if os(OSX)
	
	override func keyDown(theEvent: NSEvent) {
		guard let eventsDelegate = eventsDelegate where eventsDelegate.keyDown(self, theEvent: theEvent) else {
			super.keyDown(theEvent)
			return
		}
	}
	
	override func keyUp(theEvent: NSEvent) {
		guard let eventsDelegate = eventsDelegate where eventsDelegate.keyUp(self, theEvent: theEvent) else {
			super.keyUp(theEvent)
			return
		}
	}

	#endif
}
