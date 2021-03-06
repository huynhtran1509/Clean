//
//  Controls.swift
//  clean
//
//  Created by Gabriel O'Flaherty-Chan on 2016-01-03.
//  Copyright © 2016 Gabrieloc. All rights reserved.
//

import simd
import SceneKit
import GameController

enum ActionInput {
	case ButtonA
	case ButtonB
}

#if os(OSX)
	
protocol KeyboardAndMouseEventsDelegate {
	func keyDown(view: NSView, theEvent: NSEvent) -> Bool
	func keyUp(view: NSView, theEvent: NSEvent) -> Bool
}
	
private enum KeyboardInput : UInt16 {
	case Left   = 123
	case Right  = 124
	case Down   = 125
	case Up     = 126
	case Space  = 49
	case Z      = 6
	case X      = 7
	
	var vector : float2 {
		switch self {
		case .Up:    return float2( 0, -1)
		case .Down:  return float2( 0,  1)
		case .Left:  return float2(-1,  0)
		case .Right: return float2( 1,  0)
		default:     return float2()
		}
	}
	
	var isDirectional: Bool {
		return [.Left, .Right, .Down, .Up].contains(self)
	}
	
	var isActionInput: Bool {
		return [.Z, .X].contains(self)
	}
	
	var actionInput: ActionInput {
		if self == .Z {
			return .ButtonA
		}
		return .ButtonB
	}
}

extension RoomViewController: KeyboardAndMouseEventsDelegate {
}
	
#endif

extension RoomViewController {
	
	// MARK: Controller orientation
	
	private static let controllerAcceleration = Float(1.0 / 10.0)
	private static let controllerDirectionLimit = float2(1.0)
	
	internal func controllerDirection() -> float2 {
		if let dpad = controllerDPad {
			if dpad.xAxis.value == 0.0 && dpad.yAxis.value == 0.0 {
				controllerStoredDirection = float2(0.0)
			} else {
				let inputValue = float2(dpad.xAxis.value, -dpad.yAxis.value * RoomViewController.controllerAcceleration)
				controllerStoredDirection = clamp(controllerStoredDirection + inputValue,
					min: -RoomViewController.controllerDirectionLimit,
					max: RoomViewController.controllerDirectionLimit)
			}
		}
		return controllerStoredDirection
	}
	
	internal func setupGameControllers() {
		#if os(OSX)
			roomView.eventsDelegate = self
		#endif
	}

	
	// MARK: Events
	
	#if os(iOS)
	
	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		if panningTouch == nil {
			controllerStoredDirection = float2(0.0)
			panningTouch = touches.first
		}
	}
	
	override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
		if let touch = panningTouch {
			let newLocation = float2(touch.locationInView(view))
			let oldLocation = float2(touch.previousLocationInView(view))
			let displacement = newLocation - oldLocation
			controllerStoredDirection = clamp(mix(controllerStoredDirection, displacement, t: RoomViewController.controllerAcceleration), min: -RoomViewController.controllerDirectionLimit, max: RoomViewController.controllerDirectionLimit)
		}
	}
	
	func commonTouchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
		if let touch = panningTouch {
			if touches.contains(touch) {
				panningTouch = nil
				controllerStoredDirection = float2(0.0)
			}
		}
	}
	
	override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
		commonTouchesEnded(touches!, withEvent: event)
	}
	
	override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
		commonTouchesEnded(touches, withEvent: event)
	}
	
	#endif
	
	#if os(OSX)

	func keyDown(view: NSView, theEvent: NSEvent) -> Bool {
		if let key = KeyboardInput(rawValue: theEvent.keyCode) {
			if !theEvent.ARepeat {
				if key.isDirectional {
					controllerStoredDirection += key.vector
				}
				else if key.isActionInput {
					roomView.actionInputChanged(key.actionInput, selected: true)
				}
			}
			return true
		}
		return false
	}
	
	func keyUp(view: NSView, theEvent: NSEvent) -> Bool {
		if let key = KeyboardInput(rawValue: theEvent.keyCode) {
			if !theEvent.ARepeat {
				if key.isDirectional {
					controllerStoredDirection -= key.vector
				}
				else if key.isActionInput {
					roomView.actionInputChanged(key.actionInput, selected: false)
				}
			}
			return true
		}
		
		return false
	}
	
	#endif
}
