/*
 * CPMenuItem.j
 * AppKit
 *
 * Created by Francisco Tolmasky.
 * Copyright 2008, 280 North, Inc.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 */

@import <Foundation/CPCoder.j>
@import <Foundation/CPObject.j>
@import <Foundation/CPString.j>

@import "CPImage.j"
@import "CPMenu.j"
@import "CPView.j"
@import "_CPMenuItemView.j"

/*! 
    @ingroup appkit
    @class CPMenuItem

    A CPMenuItem is added to a CPMenu.
    It has an action and a target for that action to be sent to
    whenever the item is 'activated'.
*/
@implementation CPMenuItem : CPObject
{
    BOOL            _isSeparator;

    CPString        _title;
    //CPAttributedString  _attributedTitle;
    
    CPFont          _font;
                  
    id              _target;
    SEL             _action;
                    
    BOOL            _isEnabled;
    BOOL            _isHidden;
                    
    int             _tag;
    int             _state;
                    
    CPImage         _image;
    CPImage         _alternateImage;
    CPImage         _onStateImage;
    CPImage         _offStateImage;
    CPImage         _mixedStateImage;
                    
    CPMenu          _submenu;
    CPMenu          _menu;
                    
    CPString        _keyEquivalent;
    unsigned        _keyEquivalentModifierMask;
                    
    int             _mnemonicLocation;
                    
    BOOL            _isAlternate;
    int             _indentationLevel;
                    
    CPString        _toolTip;
    id              _representedObject;
    CPView          _view;
    
    _CPMenuItemView _menuItemView;
}

- (id)init
{
    return [self initWithTitle:@"" action:nil keyEquivalent:nil];
}

/*!
    Initializes the menu item with a title, action, and keyboard equivalent.
    @param aTitle the menu item's title
    @param anAction the action that gets triggered when the item is selected
    @param aKeyEquivalent the keyboard shortcut for the item
    @return the initialized menu item
*/
- (id)initWithTitle:(CPString)aTitle action:(SEL)anAction keyEquivalent:(CPString)aKeyEquivalent
{
    self = [super init];
    
    if (self)
    {
        _isSeparator = NO;

        _title = aTitle;
        _action = anAction;
        
        _isEnabled = YES;
        
        _tag = 0;
        _state = CPOffState;
        
        _keyEquivalent = aKeyEquivalent || @"";
        _keyEquivalentModifierMask = CPPlatformActionKeyMask;

        _indentationLevel = 0;

        _mnemonicLocation = CPNotFound;
    }
    
    return self;
}

// Enabling a Menu Item
/*!
    Sets whether the menu item is enabled or not
    @param isEnabled \c YES enables the item. \c NO disables it.
*/
- (void)setEnabled:(BOOL)isEnabled
{
    if ([_menu autoenablesItems])
        return;

    _isEnabled = isEnabled;

    [_menuItemView setDirty];

    [_menu itemChanged:self];
}

/*!
    Returns \c YES if the item is enabled.
*/
- (BOOL)isEnabled
{
    return _isEnabled;
}

// Managing Hidden Status
/*!
    Sets whether the item should be hidden. A hidden item can not be triggered by keyboard shortcuts.
    @param isHidden \c YES hides the item. \c NO reveals it.
*/
- (void)setHidden:(BOOL)isHidden
{
    if (_isHidden == isHidden)
        return;
    
    _isHidden = isHidden;

    [_menu itemChanged:self];
}

/*!
    Returns \c YES if the item is hidden.
*/
- (BOOL)isHidden
{
    return _isHidden;
}

/*!
    Returns \c YES if the item is hidden or if one of it's supermenus is hidden.
*/
- (BOOL)isHiddenOrHasHiddenAncestor
{
    if (_isHidden)
        return YES;
    
    var supermenu = [_menu supermenu];
    
    if ([[supermenu itemAtIndex:[supermenu indexOfItemWithSubmenu:_menu]] isHiddenOrHasHiddenAncestor])
        return YES;

    return NO;
}

// Managing Target and Action
/*!
    Sets the menu item's action target.
    @param aTarget the target for the action
*/
- (void)setTarget:(id)aTarget
{
    _target = aTarget;
}

/*!
    Returns the item's action target
*/
- (id)target
{
    return _target;
}

/*!
    Sets the action that gets sent to the item's target when triggered.
    @param anAction the action to send
*/
- (void)setAction:(SEL)anAction
{
    _action = anAction;
}

/*!
    Returns the item's action.
*/
- (SEL)action
{
    return _action;
}

// Managing the Title
/*!
    Sets the item's title.
    @param aTitle the item's new title
*/
- (void)setTitle:(CPString)aTitle
{
    _mnemonicLocation = CPNotFound;

    if (_title == aTitle)
        return;
    
    _title = aTitle;
    
    [_menuItemView setDirty];
    
    [_menu itemChanged:self];
}

/*!
    Returns the menu item's title.
*/
- (CPString)title
{
    return _title;
}

/*!
    Set's the item's text color
*/
- (void)setTextColor:(CPString)aColor
{
    //FIXME IMPLEMENT
}

/*!
    Sets the font for the text of this menu item
    @param aFont the font for the menu item
*/
- (void)setFont:(CPFont)aFont
{
    if (_font == aFont)
        return;
        
    _font = aFont;

    [_menu itemChanged:self];
    
    [_menuItemView setDirty];
}

/*!
    Returns the menu item's font
*/
- (CPFont)font
{
    return _font;
}

/*
- (void)setAttributedTitle:(CPAttributedString)aTitle
{
}

- (CPAttributedString)attributedTitle
{
}
*/

// Managing the Tag
/*!
    Sets the menu item's tag
    @param aTag the tag for the item
*/
- (void)setTag:(int)aTag
{
    _tag = aTag;
}

/*!
    Returns the item's tag
*/
- (int)tag
{
    return _tag;
}

/*!
    Sets the state of the menu item. Possible states are:
<pre>
CPMixedState
CPOnState
CPOffState
</pre>
*/
- (void)setState:(int)aState
{
    if (_state == aState)
        return;
    
    _state = aState;
    
    [_menu itemChanged:self];

    [_menuItemView setDirty];
}

/*!
    Returns the menu item's current state. Possible states are:
<pre>
CPMixedState
CPOnState
CPOffState
</pre>
*/
- (int)state
{
    return _state;
}

// Managing the Image
/*!
    Sets the menu item's image
    @param anImage the menu item's image
*/
- (void)setImage:(CPImage)anImage
{
    if (_image == anImage)
        return;
    
    _image = anImage;

    [_menuItemView setDirty];
    
    [_menu itemChanged:self];
}

/*!
    Returns the menu item's image
*/
- (CPImage)image
{
    return _image;
}

/*!
    Sets the menu item's alternate image
    @param anImage the menu item's alternate image
*/
- (void)setAlternateImage:(CPImage)anImage
{
    _alternateImage = anImage;
}

/*!
    Returns the menu item's alternate image
*/
- (CPImage)alternateImage
{
    return _alternateImage;
}

/*!
    Sets the image that is shown when the
    menu item is in the 'on' state.
    @param anImage the image to show
*/
- (void)setOnStateImage:(CPImage)anImage
{
    if (_onStateImage == anImage)
        return;
    
    _onStateImage = anImage;
    [_menu itemChanged:self];
}

/*!
    Returns the image shown when the menu item is in the 'on' state.
*/
- (CPImage)onStateImage
{
    return _onStateImage;
}

/*!
    Sets the image that is shown when the menu item is in the 'off' state.
    @param anImage the image to show
*/
- (void)setOffStateImage:(CPImage)anImage
{
    if (_offStateImage == anImage)
        return;
    
    _offStateImage = anImage;
    [_menu itemChanged:self];
}

/*!
    Returns the image shown when the menu item is in the 'off' state.
*/
- (CPImage)offStateImage
{
    return _offStateImage;
}

/*!
    Sets the image that is shown when the menu item is in the 'mixed' state.
    @param anImage the image to show
*/
- (void)setMixedStateImage:(CPImage)anImage
{
    if (_mixedStateImage == anImage)
        return;
    
    _mixedStateImage = anImage;
    [_menu itemChanged:self];
}

/*!
    Returns the image shown when the menu item is
    in the 'mixed' state.
*/
- (CPImage)mixedStateImage
{
    return _mixedStateImage;
}

// Managing Subemenus
/*!
    Sets the submenu for this item
    @param aMenu the submenu
*/
- (void)setSubmenu:(CPMenu)aMenu
{
    if (_submenu === aMenu)
        return;

    var supermenu = [_submenu supermenu];

    if (supermenu)
        [CPException raise:CPInvalidArgumentException
		   reason: @"Can't add submenu \"" + [aMenu title] + "\" to item \"" + [self title] + "\", because it is already submenu of \"" + [[aMenu supermenu] title] + "\""];

    _submenu = aMenu;

    if (_submenu)
    {
        [_submenu setSupermenu:_menu];

        [self setTarget:_menu];
        [self setAction:@selector(submenuAction:)];
    }
    else
    {
        [self setTarget:nil];
        [self setAction:NULL];
    }

    [_menuItemView setDirty];

    [_menu itemChanged:self];
}

/*!
    Returns the submenu of the item. \c nil if there is no submenu.
*/
- (CPMenu)submenu
{
    return _submenu;
}

/*!
    Returns \c YES if the menu item has a submenu.
*/
- (BOOL)hasSubmenu
{
    return _submenu ? YES : NO;
}

// Getting a Separator Item

/*!
    Returns a new menu item separator.
*/
+ (CPMenuItem)separatorItem
{
    var separatorItem = [[self alloc] initWithTitle:@"" action:nil keyEquivalent:nil];

    separatorItem._isSeparator = YES;

    return separatorItem;
}

/*!
    Returns \c YES if the menu item is a separator.
*/
- (BOOL)isSeparatorItem
{
    return _isSeparator;
}

// Managing the Owning Menu
/*!
    Set the container menu of this item.
    @param aMenu the item's container menu
*/
- (void)setMenu:(CPMenu)aMenu
{
    _menu = aMenu;
}

/*!
    Returns the container menu of this item
*/
- (CPMenu)menu
{
    return _menu;
}

//

/*!
    Sets the keyboard shortcut for this menu item
    @param aString the keyboard shortcut
*/
- (void)setKeyEquivalent:(CPString)aString
{
    _keyEquivalent = aString || @"";
}

/*!
    Returns the keyboard shortcut for this menu item
*/
- (CPString)keyEquivalent
{
    return _keyEquivalent;
}

/*!
    Sets the modifier mask used for the item's keyboard shortcut.
    Can be a combination of:
<pre>
CPShiftKeyMask
CPAlternateKeyMask
CPCommandKeyMask
CPControlKeyMask
</pre>
*/
- (void)setKeyEquivalentModifierMask:(unsigned)aMask
{
    _keyEquivalentModifierMask = aMask;
}

/*!
    Returns the item's keyboard shortcut modifier mask.
    Can be a combination of:
<pre>
CPShiftKeyMask
CPAlternateKeyMask
CPCommandKeyMask
CPControlKeyMask
</pre>
*/
- (unsigned)keyEquivalentModifierMask
{
    return _keyEquivalentModifierMask;
}

- (CPString)keyEquivalentStringRepresentation
{
    if (![_keyEquivalent length])
        return @"";

    var string = _keyEquivalent.toUpperCase();

    if (_keyEquivalentModifierMask & CPCommandKeyMask)
        string = "⌘" + string;

    if (_keyEquivalentModifierMask & CPShiftKeyMask)
        string = "⇧" + string;

    if (_keyEquivalentModifierMask & CPControlKeyMask)
        string = "^" + string;

    return string;
}

// Managing Mnemonics
/*!
    Sets the index of the mnemonic character in the title. The character
    will be underlined and is used as a shortcut for navigation.
    @param aLocation the index of the character in the title
*/
- (void)setMnemonicLocation:(unsigned)aLocation
{
    _mnemonicLocation = aLocation;
}

/*!
    Returns the index of the mnemonic character in the title.
*/
- (unsigned)mnemonicLocation
{
    return _mnemonicLocation;
}

/*!
    Sets the title of the menu item and the mnemonic character. The mnemonic chracter should be preceded by an '&'.
    @param aTitle the title string with a denoted mnemonic
*/
- (void)setTitleWithMnemonicLocation:(CPString)aTitle
{
    var location = [aTitle rangeOfString:@"&"].location;
    
    if (location == CPNotFound)
        [self setTitle:aTitle];
    else
    {
        [self setTitle:[aTitle substringToIndex:location] + [aTitle substringFromIndex:location + 1]];
        [self setMnemonicLocation:location];
    }    
}

/*!
    Returns the menu items mnemonic character
*/
- (CPString)mnemonic
{
    return _mnemonicLocation == CPNotFound ? @"" : [_title characterAtIndex:_mnemonicLocation];
}

// Managing Alternates

/*!
    Sets whether this item is an alternate for the previous menu item.
    @param isAlternate \c YES denotes that this menu item is an alternate
*/
- (void)setAlternate:(BOOL)isAlternate
{
    _isAlternate = isAlternate;
}

/*!
    Returns \c YES if the menu item is an alternate for the previous item.
*/
- (BOOL)isAlternate
{
    return _isAlternate;
}

// Managing Indentation Levels

/*!
    Sets the indentation level of the menu item. Must be a value between 0 and 15 (inclusive).
    @param aLevel the item's new indentation level
    @throws CPInvalidArgumentException if aLevel is less than 0
*/
- (void)setIndentationLevel:(unsigned)aLevel
{
    if (aLevel < 0)
        [CPException raise:CPInvalidArgumentException reason:"setIndentationLevel: argument must be greater than or equal to 0."];
        
    _indentationLevel = MIN(15, aLevel);
}

/*!
    Returns the menu item's indentation level. This is a value between 0 and 15 (inclusive).
*/
- (unsigned)indentationLevel
{
    return _indentationLevel;
}

// Managing Tool Tips
/*!
    Sets the tooltip for the menu item.
    @param aToolTip the tool tip for the item
*/
- (void)setToolTip:(CPString)aToolTip
{
    _toolTip = aToolTip;
}

/*!
    Returns the item's tooltip
*/
- (CPString)toolTip
{
    return _toolTip;
}

// Representing an Object

/*!
    Sets the menu item's represented object. This is a kind of tag for the developer. Not a UI feature.
    @param anObject the represented object
*/
- (void)setRepresentedObject:(id)anObject
{
    _representedObject = anObject;
}

/*!
    Returns the item's represented object.
*/
- (id)representedObject
{
    return _representedObject;
}

// Managing the View

/*!
    Sets the view for the menu item
    @param aView the menu's item's view
*/
- (void)setView:(CPView)aView
{
    if (_view === aView)
        return;
    
    _view = aView;
    
    [_menuItemView setDirty];
    
    [_menu itemChanged:self];
}

/*!
    Returns the menu item's view
*/
- (CPView)view
{
    return _view;
}

// Getting Highlighted Status

/*!
    Returns \c YES if the menu item is highlighted.
*/
- (BOOL)isHighlighted
{
    return [[self menu] highlightedItem] == self;
}

//

/*
    @ignore
*/
- (id)_menuItemView
{
    if (!_menuItemView)
        _menuItemView = [[_CPMenuItemView alloc] initWithFrame:CGRectMakeZero() forMenuItem:self];
    
    return _menuItemView;
}

- (BOOL)_isSelectable
{
    return ![self submenu] || [self action] !== @selector(submenuAction:) || [self target] !== [self menu];
}

@end

var CPMenuItemIsSeparatorKey                = @"CPMenuItemIsSeparatorKey",

    CPMenuItemTitleKey                      = @"CPMenuItemTitleKey",
    CPMenuItemTargetKey                     = @"CPMenuItemTargetKey",
    CPMenuItemActionKey                     = @"CPMenuItemActionKey",

    CPMenuItemIsEnabledKey                  = @"CPMenuItemIsEnabledKey",
    CPMenuItemIsHiddenKey                   = @"CPMenuItemIsHiddenKey",

    CPMenuItemTagKey                        = @"CPMenuItemTagKey",
    CPMenuItemStateKey                      = @"CPMenuItemStateKey",

    CPMenuItemImageKey                      = @"CPMenuItemImageKey",
    CPMenuItemAlternateImageKey             = @"CPMenuItemAlternateImageKey",

    CPMenuItemSubmenuKey                    = @"CPMenuItemSubmenuKey",
    CPMenuItemMenuKey                       = @"CPMenuItemMenuKey",

    CPMenuItemKeyEquivalentKey              = @"CPMenuItemKeyEquivalentKey",
    CPMenuItemKeyEquivalentModifierMaskKey  = @"CPMenuItemKeyEquivalentModifierMaskKey",

    CPMenuItemIndentationLevelKey           = @"CPMenuItemIndentationLevelKey",

    CPMenuItemRepresentedObjectKey          = @"CPMenuItemRepresentedObjectKey",
    CPMenuItemViewKey                       = @"CPMenuItemViewKey";

#define DEFAULT_VALUE(aKey, aDefaultValue) [aCoder containsValueForKey:(aKey)] ? [aCoder decodeObjectForKey:(aKey)] : (aDefaultValue)
#define ENCODE_IFNOT(aKey, aValue, aDefaultValue) if ((aValue) !== (aDefaultValue)) [aCoder encodeObject:(aValue) forKey:(aKey)];

@implementation CPMenuItem (CPCoding)
/*!
    Initializes the menu item from a coder.
    @param aCoder the coder from which to initialize
    @return the initialized menu item
*/
- (id)initWithCoder:(CPCoder)aCoder
{
    self = [super init];
    
    if (self)
    {
        _isSeparator = [aCoder containsValueForKey:CPMenuItemIsSeparatorKey] && [aCoder decodeBoolForKey:CPMenuItemIsSeparatorKey];

        _title = [aCoder decodeObjectForKey:CPMenuItemTitleKey];
        
//        _font;
                  
        _target = [aCoder decodeObjectForKey:CPMenuItemTargetKey];
        _action = [aCoder decodeObjectForKey:CPMenuItemActionKey];

        _isEnabled = DEFAULT_VALUE(CPMenuItemIsEnabledKey, YES);
        _isHidden = DEFAULT_VALUE(CPMenuItemIsHiddenKey, NO);
        _tag = DEFAULT_VALUE(CPMenuItemTagKey, 0);
        _state = DEFAULT_VALUE(CPMenuItemStateKey, CPOffState);
//    int             _state;

        _image = DEFAULT_VALUE(CPMenuItemImageKey, nil);
        _alternateImage = DEFAULT_VALUE(CPMenuItemAlternateImageKey, nil);
//    CPImage         _onStateImage;
//    CPImage         _offStateImage;
//    CPImage         _mixedStateImage;

        // This order matters because setSubmenu: needs _menu to be around.
        _menu = DEFAULT_VALUE(CPMenuItemMenuKey, nil);
        [self setSubmenu:DEFAULT_VALUE(CPMenuItemSubmenuKey, nil)];

        _keyEquivalent = [aCoder decodeObjectForKey:CPMenuItemKeyEquivalentKey] || @"";
        _keyEquivalentModifierMask = [aCoder decodeObjectForKey:CPMenuItemKeyEquivalentModifierMaskKey] || 0;

//    int             _mnemonicLocation;

//    BOOL            _isAlternate;

        // Default is 0.
        [self setIndentationLevel:[aCoder decodeIntForKey:CPMenuItemIndentationLevelKey] || 0];

//    CPString        _toolTip;

        _representedObject = DEFAULT_VALUE(CPMenuItemRepresentedObjectKey, nil);
        _view = DEFAULT_VALUE(CPMenuItemViewKey, nil);
    }
    
    return self;
}

/*!
    Writes the menu item out to a coder.
    @param aCoder the coder to write the menu item out to
*/
- (void)encodeWithCoder:(CPCoder)aCoder
{
    if (_isSeparator)
        [aCoder encodeBool:_isSeparator forKey:CPMenuItemIsSeparatorKey];

    [aCoder encodeObject:_title forKey:CPMenuItemTitleKey];
        
    [aCoder encodeObject:_target forKey:CPMenuItemTargetKey];
    [aCoder encodeObject:_action forKey:CPMenuItemActionKey];

    ENCODE_IFNOT(CPMenuItemIsEnabledKey, _isEnabled, YES); 
    ENCODE_IFNOT(CPMenuItemIsHiddenKey, _isHidden, NO);

    ENCODE_IFNOT(CPMenuItemTagKey, _tag, 0);
    ENCODE_IFNOT(CPMenuItemStateKey, _state, CPOffState);

    ENCODE_IFNOT(CPMenuItemImageKey, _image, nil);
    ENCODE_IFNOT(CPMenuItemAlternateImageKey, _alternateImage, nil);
    
    ENCODE_IFNOT(CPMenuItemSubmenuKey, _submenu, nil);
    ENCODE_IFNOT(CPMenuItemMenuKey, _menu, nil);

    if (_keyEquivalent && _keyEquivalent.length)
        [aCoder encodeObject:_keyEquivalent forKey:CPMenuItemKeyEquivalentKey];

    if (_keyEquivalentModifierMask)
        [aCoder encodeObject:_keyEquivalentModifierMask forKey:CPMenuItemKeyEquivalentModifierMaskKey];

    if (_indentationLevel > 0)
        [aCoder encodeInt:_indentationLevel forKey:CPMenuItemIndentationLevelKey];

    ENCODE_IFNOT(CPMenuItemRepresentedObjectKey, _representedObject, nil);
    ENCODE_IFNOT(CPMenuItemViewKey, _view, nil);
}

@end