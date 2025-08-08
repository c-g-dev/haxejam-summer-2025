package ui;

import h2d.Object;
import hxd.Key;
import ludi.heaps.Node;

interface IArrowNavInputProvider {
	function isUpPressed():Bool;
	function isDownPressed():Bool;
	function isLeftPressed():Bool;
	function isRightPressed():Bool;
	function isEnterPressed():Bool;
}

class DefaultArrowNavInputProvider implements IArrowNavInputProvider {
	public function new() {}

	public function isUpPressed():Bool {
		return Key.isPressed(Key.UP);
	}

	public function isDownPressed():Bool {
		return Key.isPressed(Key.DOWN);
	}

	public function isLeftPressed():Bool {
		return Key.isPressed(Key.LEFT);
	}

	public function isRightPressed():Bool {
		return Key.isPressed(Key.RIGHT);
	}

	public function isEnterPressed():Bool {
		return Key.isPressed(Key.ENTER);
	}
}

enum ArrowNavEvent {
	Leave;
	Enter;
	Selected;
}

class ArrowNav {
	var nodes:Map<Object, ArrowNavNode<Dynamic>> = new Map();
	var currentSelection:Object = null;
	var inputProvider:IArrowNavInputProvider;

	public function new() {
		inputProvider = new DefaultArrowNavInputProvider();
	}

	public function bind<T>(obj:Object, onEvent:ArrowNavEvent->Void):ArrowNavNode<T> {
		var node = new ArrowNavNode<T>(obj, onEvent, obj);
		nodes.set(obj, node);

		if (currentSelection == null) {
			currentSelection = obj;
			node.onEvent(Enter);
		}
		return node;
	}

	function setSelection(newSelection:Object) {
		if (currentSelection == newSelection)
			return;
		if (currentSelection != null) {
			var prevNode = nodes.get(currentSelection);
			if (prevNode != null) {
				prevNode.onEvent(Leave);
			}
		}
		currentSelection = newSelection;
		if (newSelection != null) {
			var newNode = nodes.get(newSelection);
			if (newNode != null) {
				newNode.onEvent(Enter);
			}
		}
	}

	function selectCurrent() {
		if (currentSelection != null) {
			var node = nodes.get(currentSelection);
			if (node != null) {
				node.onEvent(Selected);
			}
		}
	}

	public function update() {
		if (inputProvider.isRightPressed()) {
			var next = getNextItem(Right);
			if (next != null)
				setSelection(next);
		} else if (inputProvider.isLeftPressed()) {
			var next = getNextItem(Left);
			if (next != null)
				setSelection(next);
		} else if (inputProvider.isDownPressed()) {
			var next = getNextItem(Down);
			if (next != null)
				setSelection(next);
		} else if (inputProvider.isUpPressed()) {
			var next = getNextItem(Up);
			if (next != null)
				setSelection(next);
		} else if (inputProvider.isEnterPressed()) {
			selectCurrent();
		}
	}

	function getNextItem(direction:Direction):Object {
		if (currentSelection == null)
			return null;
		var currentPos = currentSelection.getAbsPos();
		var cx = currentPos.x;
		var cy = currentPos.y;

		var best:Object = null;
		var bestScore1:Float = Math.POSITIVE_INFINITY;
		var bestScore2:Float = Math.POSITIVE_INFINITY;

		for (obj in nodes.keys()) {
			if (obj == currentSelection)
				continue;
			var pos = obj.getAbsPos();
			var x = pos.x;
			var y = pos.y;
			var score1:Float;
			var score2:Float;

			switch direction {
				case Right:
					if (x <= cx)
						continue;
					score1 = Math.abs(y - cy);
					score2 = x - cx;
				case Left:
					if (x >= cx)
						continue;
					score1 = Math.abs(y - cy);
					score2 = cx - x;
				case Down:
					if (y <= cy)
						continue;
					score1 = Math.abs(x - cx);
					score2 = y - cy;
				case Up:
					if (y >= cy)
						continue;
					score1 = Math.abs(x - cx);
					score2 = cy - y;
			}

			if (score1 < bestScore1 || (score1 == bestScore1 && score2 < bestScore2)) {
				best = obj;
				bestScore1 = score1;
				bestScore2 = score2;
			}
		}
		return best != null ? best : currentSelection;
	}
}

enum Direction {
	Up;
	Down;
	Left;
	Right;
}

class ArrowNavNode<T> extends Node {
	public var obj:Object;

	var onEventCallback:ArrowNavEvent->Void;

	public function new(obj:Object, onEvent:ArrowNavEvent->Void, ?parent:Object) {
		super(parent);
		this.obj = obj;
		this.onEventCallback = onEvent;
	}

	public function onEvent(e:ArrowNavEvent) {
		onEventCallback(e);
	}
}