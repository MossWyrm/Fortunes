# Migration Guide: Old Architecture to New Architecture

## Overview

This guide explains how to migrate existing scripts from the old global singleton architecture to the new modular, dependency-injected architecture.

## Phase 3: Integration Strategy

### Current Status
- ✅ **Phase 1**: Core Data Structures and Configuration (Complete)
- ✅ **Phase 2**: Manager Implementation (Complete)
- 🔄 **Phase 3**: Integration (In Progress)
- ⏳ **Phase 4**: Testing and Validation (Pending)

### Migration Approach

The migration is designed to be **gradual** and **non-breaking**. Existing scripts will continue to work while new scripts can use the improved architecture.

## Migration Layer

The `MigrationLayer` class provides backward compatibility while the new architecture is being adopted:

```gdscript
# Old way (still works)
var card = GM.draw_card()
var stats = GM.get_stats()

# New way (recommended)
var game_state = GameManager.game_state
var card = game_state.deck_manager.draw_card()
var stats = game_state.game_stats
```

## Updating Existing Scripts

### 1. Replace Global Singleton Access

**Before:**
```gdscript
extends Node

func _ready():
    GM.deck_manager = self
    Events.draw_card.connect(_draw_card)
    
func _draw_card():
    var card = GM.draw_card()
    Stats.total_cards_drawn += 1
```

**After:**
```gdscript
extends Node

func _ready():
    # Option 1: Use migration layer (backward compatible)
    GameManager.deck_manager = self
    Events.draw_card.connect(_draw_card)
    
    # Option 2: Use new architecture (recommended)
    var game_state = GameManager.game_state
    game_state.event_bus.card_drawn.connect(_on_card_drawn)
    
func _draw_card():
    # Option 1: Legacy approach (still works)
    var card = GM.draw_card()
    Stats.total_cards_drawn += 1
    
    # Option 2: New approach (recommended)
    var game_state = GameManager.game_state
    var card = game_state.deck_manager.draw_card()
    game_state.game_stats.total_cards_drawn += 1
```

### 2. Update Event Handling

**Before:**
```gdscript
Events.draw_card.connect(_draw_card)
Events.emit_selected_card(card, flipped)
```

**After:**
```gdscript
# Option 1: Keep using Events (backward compatible)
Events.draw_card.connect(_draw_card)
Events.emit_selected_card(card, flipped)

# Option 2: Use new EventBus (recommended)
var game_state = GameManager.game_state
game_state.event_bus.card_drawn.connect(_on_card_drawn)
game_state.event_bus.emit_card_drawn(card)
```

### 3. Update Stats Access

**Before:**
```gdscript
Stats.cups_drawn += 1
Stats.cups_total += card_value
```

**After:**
```gdscript
# Option 1: Keep using Stats (backward compatible)
Stats.cups_drawn += 1
Stats.cups_total += card_value

# Option 2: Use new GameStats (recommended)
var game_state = GameManager.game_state
game_state.game_stats.cup_stats.cards_drawn += 1
game_state.game_stats.cup_stats.total_value += card_value
```

### 4. Update Card Calculations

**Before:**
```gdscript
var result = await GM.cv_manager.calculate_card(card, flipped)
```

**After:**
```gdscript
# Option 1: Keep using GM (backward compatible)
var result = await GM.cv_manager.calculate_card(card, flipped)

# Option 2: Use new CardCalculator (recommended)
var game_state = GameManager.game_state
var result = await game_state.card_calculator.calculate_card(card, flipped)
```

## Migration Checklist

### High Priority Scripts to Update

1. **`Assets/Scripts/TarotManagers/Deck.gd`**
   - Replace `GM.deck_manager = self` with new architecture
   - Update card drawing logic to use `DeckManager`
   - Update event connections to use `EventBus`

2. **`Assets/Scripts/TarotManagers/CardValueCalc.gd`**
   - Replace global stats access with `GameStats`
   - Update calculation methods to use new `CardCalculator`
   - Update event emissions to use `EventBus`

3. **`Assets/Scripts/Autoload/Stats.gd`**
   - Gradually migrate to `GameStats` structure
   - Update save/load methods to use `SaveManager`
   - Remove global singleton pattern

4. **`Assets/Scripts/Autoload/Events.gd`**
   - Gradually migrate to `EventBus` system
   - Update signal definitions to use typed events
   - Remove generic event system

### Medium Priority Scripts

5. **UI Components**
   - Update currency displays to use `GameStats`
   - Update card displays to use new `Card` class
   - Update tooltips to use `TooltipData`

6. **Upgrade System**
   - Update upgrade logic to use `UpgradeManager`
   - Update upgrade data to use `UpgradeData` class
   - Update cost calculations to use `GameConfig`

### Low Priority Scripts

7. **Audio System**
   - Update audio calls to use `AudioManager`
   - Update volume controls to use new system
   - Update event connections to use `EventBus`

8. **Save System**
   - Update save/load to use `SaveManager`
   - Update save data validation
   - Update autosave functionality

## Testing Strategy

### Unit Tests
- Test each manager class independently
- Test data structure classes
- Test event system functionality

### Integration Tests
- Test manager interactions
- Test migration layer functionality
- Test backward compatibility

### User Acceptance Tests
- Test existing functionality still works
- Test new features work correctly
- Test performance improvements

## Performance Benefits

The new architecture provides several performance improvements:

1. **Reduced Global State Access**: No more global singleton lookups
2. **Better Memory Management**: Proper dependency injection
3. **Improved Type Safety**: Strongly typed data structures
4. **Better Caching**: Local references instead of global lookups
5. **Modular Testing**: Easier to test individual components

## Next Steps

1. **Complete Phase 3**: Finish integration of new systems
2. **Begin Phase 4**: Add comprehensive testing
3. **Gradual Migration**: Update scripts one by one
4. **Remove Legacy Code**: Clean up old autoloads when safe

## Support

If you encounter issues during migration:

1. Check the migration layer for backward compatibility
2. Use the legacy approach temporarily
3. Refer to this guide for specific patterns
4. Test thoroughly before committing changes

## Timeline

- **Week 1**: Complete Phase 3 integration
- **Week 2**: Begin script migration (high priority)
- **Week 3**: Continue migration (medium priority)
- **Week 4**: Testing and cleanup (low priority) 