package objects;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxSort;

typedef Choice =
{
	var choices:Array<{name:String, callback:String->Void}>;
	var curSelected:Int;
}

class SelectionList extends FlxTypedGroup<Text>
{
	public var options:Array<String> = [];
	public var curSelected:Int = 0;
	public var choiceSelected(get, never):Int;
	public var topBound:Float;
	public var bottomBound:Float;
	public var parentMenu:SelectionList;
	public var focusedMenu:SelectionList;
	public var targetX:Float = 0;
	public var name:String;

	var callbacks:Map<String, Null<Float>->Void> = [];
	var choiceCallbacks:Map<String, Choice> = [];
	var submenus:Map<String, SelectionList> = [];
	var nextQ:Map<String, Array<String>> = [];
	var lists:Map<String, Bool> = [];
	var _defY:Float;
	var _spacing:Float;
	var topMenu(get, never):SelectionList;
	var scrollSelected:Int = 0;
	var scrollAmount:Int = 0;
	var fontSize:Int = 64;

	function get_topMenu():SelectionList
	{
		var menu = this;
		while (menu.parentMenu != null)
			menu = menu.parentMenu;
		return menu;
	}

	function get_choiceSelected():Int
	{
		if (choiceCallbacks.exists(options[curSelected]))
			return choiceCallbacks.get(options[curSelected]).curSelected;
		else
			return -1;
	}

	public function addChoices(option:String, choices:Array<{name:String, callback:String->Void}>, defaultIndex:Int = 0, mustSelect:Bool = false,
			hasLabel:Bool = false)
	{
		if (options.contains(option))
		{
			var myCallback:Null<Float>->Void = myFloat ->
			{
				choiceCallbacks.get(option)
					.curSelected = Std.int(FlxMath.bound(choiceCallbacks.get(option)
						.curSelected + myFloat, 0, choiceCallbacks.get(option).choices.length - 1));
				members[options.indexOf(option)].text = choiceCallbacks.get(option).choices[choiceCallbacks.get(option).curSelected].name;

				members[options.indexOf(option)].text = '${choiceCallbacks.get(option).curSelected > 0 ? '< ' : ''}${members[options.indexOf(option)].text}${choiceCallbacks.get(option).curSelected < choiceCallbacks.get(option).choices.length - 1 ? ' >' : ''}';

				if (!mustSelect || myFloat == 0 || myFloat == null)
					choiceCallbacks.get(option)
						.choices[choiceCallbacks.get(option)
							.curSelected].callback(choiceCallbacks.get(option).choices[choiceCallbacks.get(option).curSelected].name);
			};
			callbacks.set(option, myCallback);
			return this;
		}
		else
		{
			if (options.contains('Back'))
				options.insert(options.lastIndexOf('Back'), option);
			else
				options.push(option);

			choiceCallbacks.set(option, {curSelected: defaultIndex, choices: choices});
			updateText(hasLabel, true, null, null, null);
			members[options.indexOf(option)].text = '${choiceCallbacks.get(option).curSelected > 0 ? '< ' : ''}${choiceCallbacks.get(option).choices[choiceCallbacks.get(option).curSelected].name}${choiceCallbacks.get(option).curSelected < choiceCallbacks.get(option).choices.length - 1 ? ' >' : ''}';
			return addChoices(option, choices, defaultIndex, mustSelect, hasLabel);
		}
	}

	public function addCallback(option:String, callback:Null<Float>->Void, silent:Bool = false, usesFloat:Bool = false, ?subtext:String,
			?subtextTop:Bool = true, ?topBound:Int, ?bottomBound:Int, ?child:FlxSprite, ?childoffsets:FlxPoint):SelectionList
	{
		if (options.contains(option) && callback != null)
		{
			if (usesFloat)
				lists.set(option, true);
			if (nextQ.exists(option))
			{
				var myCallback:Null<Float>->Void = myFloat ->
				{
					if (!usesFloat && myFloat != 0 && myFloat != null)
						return;

					nextQ.get(option).push(members[options.indexOf(option)].text);
					members[options.indexOf(option)].text = nextQ.get(option).shift();
					if (nextQ.get(option)[0] == option)
						callbacks.set(option, callback);
					else
						addCallback(option, callback);
				};
				callbacks.set(option, myCallback);
				return this;
			}
			if (!silent)
			{
				var myCallback:Null<Float>->Void = myFloat ->
				{
					if (!usesFloat && myFloat != 0 && myFloat != null)
						return;
					Sound.play('menuSelect');
					callback(myFloat);
				};
				callbacks.set(option, myCallback);
			}
			else
			{
				var myCallback:Null<Float>->Void = myFloat ->
				{
					if (!usesFloat && myFloat != 0 && myFloat != null)
						return;

					callback(myFloat);
				};
				callbacks.set(option, myCallback);
			}
			return this;
		}
		else
		{
			var split = option.split('>');
			option = split.shift();
			if (split.length >= 1)
				nextQ.set(option, split);
			if (options.contains('Back'))
				options.insert(options.lastIndexOf('Back'), option);
			else
				options.push(option);
			updateText(subtext != null, subtextTop, subtext, child, childoffsets, null, topBound, bottomBound);
			return addCallback(option, callback, silent, usesFloat, subtext, subtextTop, topBound, bottomBound, child, childoffsets);
		}
	}

	public function addText(text:String, ?subtext:String, ?labelTop:Bool = true, ?child:FlxSprite, ?childoffsets:FlxPoint, ?topBound:Int,
			?bottomBound:Int):SelectionList
	{
		if (options.contains(text))
		{
			return this;
		}
		else
		{
			if (options.contains('Back'))
				options.insert(options.lastIndexOf('Back'), text);
			else
				options.push(text);
			updateText(subtext != null, labelTop, subtext, child, childoffsets, Std.int((48 * FlxG.height) / 720), topBound, bottomBound);
			return addText(text, subtext, labelTop, child, childoffsets, topBound, bottomBound);
		}
	}

	public function addSubmenu(option:String, submenu:SelectionList, ?onSelect:() -> Void, ?onBack:() -> Void):SelectionList
	{
		if (options.contains(option) && submenu != null)
		{
			submenu.parentMenu = this;
			submenu.addCallback('Back', myFloat ->
			{
				submenu.curSelected = 0;
				submenu.scrollSelected = 0;
				submenu.scrollAmount = 0;
				topMenu.focusedMenu = submenu.parentMenu;
				if (onBack != null)
					onBack();
			});
			submenus.set(option, submenu);
			addCallback(option, myFloat ->
			{
				topMenu.focusedMenu = submenu;
				if (onSelect != null)
					onSelect();
			});
		}
		else
		{
			var split = option.split('>');
			option = split.shift();
			if (split.length >= 1)
				nextQ.set(option, split);
			if (options.contains('Back'))
				options.insert(options.lastIndexOf('Back'), option);
			else
				options.push(option);
			updateText(false, true, null, null, null);
			return addSubmenu(option, submenu, onSelect, onBack);
		}
		return this;
	}

	public function select(amount:Float = 0, option:String = '')
	{
		if (option == 'Back')
		{
			if (callbacks.exists('Back'))
				callbacks.get('Back')(null);
			if (topMenu.focusedMenu != this)
			{
				tweenTexts(-100, true, .25, 0, .15);
				topMenu.focusedMenu.tweenTexts(20, false, .25, 1, .15);
			}
			return;
		}
		if (callbacks.get(options[curSelected]) == null)
			return;

		callbacks.get(options[curSelected])(amount != 0 ? amount : null);

		// if (topMenu.focusedMenu != this)
		// {
		// 	tweenTexts(-100, true, .25, 0, .15);
		// 	topMenu.focusedMenu.tweenTexts(20, false, .25, 1, .15);
		// }
	}

	public function updateText(newTextsHaveLabels:Bool = false, newTextsLabelTop:Bool = true, ?customLabel, ?child:FlxSprite, ?childoffsets:FlxPoint,
			?textSize:Int, ?topBound:Float, ?bottomBound:Float)
	{
		for (i in 0...options.length)
		{
			var textExists:Bool = false;
			forEach(text -> if (text.originalText == options[i])
			{
				textExists = true;
				text.ID = i; // reset the ID in case the index was changed.
			});
			if (textExists)
				continue;
			var newText:Text = new Text(0, 0, FlxG.width, options[i], textSize != null ? textSize : fontSize);
			newText.y = _defY + (_spacing * i);
			newText.alignment = CENTER;
			if (newTextsHaveLabels)
				newText.addLabel(customLabel != null ? customLabel : options[i], Std.int((32 * FlxG.height) / 720), newTextsLabelTop, true);

			if (child != null)
			{
				newText.child = child;
				newText.childOffset = childoffsets;
			}
			if (topBound != null)
				newText.bound = FlxPoint.get(topBound, bottomBound);
			newText.ID = i;
			add(newText);
		}

		members.sort((t1, t2) -> FlxSort.byValues(FlxSort.ASCENDING, t1.ID, t2.ID));
	}

	override public function new(defaultTextY:Float = 0, defaultSpacing:Float = 50, topBound:Float = 368, bottomBound:Float = 650, ?name:String,
			fontSize:Int = 64)
	{
		super();
		_defY = defaultTextY;
		_spacing = defaultSpacing;
		updateText();
		focusedMenu = this;
		this.topBound = topBound;
		this.bottomBound = bottomBound;
		this.name = name;
		this.fontSize = fontSize;
	}

	public function tweenTexts(newX:Float, subtractWidth:Bool = false, duration:Float, startDelay:Float, delay:Float)
	{
		forEach(text ->
		{
			FlxTween.tween(text, {x: newX - (subtractWidth ? text.width : 0)}, duration,
				{startDelay: startDelay + (delay * text.ID), ease: FlxEase.smootherStepInOut});
		});
	}

	public function setTexts(newX:Float, subtractWidth:Bool = false)
	{
		forEach(text ->
		{
			text.x = newX;
			if (subtractWidth)
				text.x -= text.width;
		});
	}

	override public function update(elapsed:Float)
	{
		var focused = topMenu.focusedMenu == this;
		forEach(text ->
		{
			var targetY = _defY + (_spacing * text.ID) - (_spacing * scrollAmount);
			text.y = FlxMath.lerp(text.y, targetY, 0.2);
			text.x = FlxMath.lerp(text.x, targetX, .3);
			text.alpha = FlxMath.lerp(text.alpha, focused ? 1 : 0, 1);
			var index = members.indexOf(text);
			if (lists.exists(options[index]))
				text.text = '< ${options[index]} >';
			if (nextQ.exists(options[text.ID]) && text.ID != curSelected)
				if (nextQ.get(options[text.ID]).contains(options[text.ID]))
				{
					nextQ.get(options[text.ID]).push(text.text);
					while (nextQ.get(options[text.ID])[0] != options[text.ID])
						nextQ.get(options[text.ID]).push(text.text = nextQ.get(options[text.ID]).shift());
					text.text = nextQ.get(options[text.ID]).shift();
					addCallback(options[text.ID], callbacks.get(options[text.ID]));
				}
			if (text.clipRect != null)
			{
				text.clipRect.put();
				text.clipRect = null;
			}
			if (text.y < topBound)
			{
				var yDiff = topBound - text.y;
				text.clipRect = FlxRect.get(0, yDiff, text.width, text.height - yDiff);
			}
			else if (text.y + text.height > bottomBound)
			{
				var yDiff = text.y + text.height - bottomBound;
				text.clipRect = FlxRect.get(0, 0, text.width, text.height - yDiff);
			}
		});
		for (menu in submenus)
			menu.update(elapsed);
		super.update(elapsed);
	}

	override public function draw()
	{
		super.draw();
		for (menu in submenus)
			menu.draw();
	}

	public function setAllRight()
	{
		for (menu in submenus)
			menu.setAllRight();
		targetX = FlxG.width;
	}

	public var maxScroll:Int = 3;

	public function scroll(amount:Int, boundOffs:Int = 0)
	{
		var bound = FlxPoint.get(0,
			options.length > (_spacing > 70 ? maxScroll - 1 + boundOffs : maxScroll + boundOffs) ? (_spacing > 70 ? maxScroll - 1 + boundOffs : maxScroll
				+ boundOffs) : options.length - 1);
		scrollSelected += amount;
		if (scrollSelected < bound.x || scrollSelected > bound.y)
			scrollAmount = Std.int(FlxMath.bound(scrollAmount + amount, 0, options.length - scrollSelected));
		scrollSelected = Std.int(FlxMath.bound(scrollSelected, bound.x, bound.y));
		bound.put();
	}
}
