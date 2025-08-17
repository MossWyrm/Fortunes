# 👨‍💻 Developer Guide: Fortunes

A comprehensive guide for developers working on the Fortunes codebase.

## 🏗️ Architecture Overview

Fortunes uses a modern, modular architecture designed for maintainability and scalability. The codebase follows clean architecture principles with clear separation of concerns.

### Core Systems

#### 🎯 **GameManager** (Systems)
Central coordinator that initializes and manages all game systems.

```gdscript
# Access the game state
GameManager.game_state.stats.money
GameManager.game_state.deck_manager.draw_card()
```

#### 🔧 **Utility Classes**

- **ValidationUtils**: Null-safety validation helpers
- **SignalManager**: Safe signal connection/disconnection
- **GameConstants**: Centralized magic numbers
- **DescriptionFormatter**: Consistent string formatting

```gdscript
# Always validate before accessing
if ValidationUtils.has_event_bus():
    GameManager.game_state.event_bus.emit_something()

# Use constants instead of magic numbers
if card.rank == GameConstants.CARD_RANK_KING:
    # Handle king card

# Use formatter for consistent UI text
var text = DescriptionFormatter.format_deck_count(deck_size, max_size)
```

## 🎴 Card System

### Card Structure

Every card has:
- **ID**: Unique identifier
- **Suit**: CUPS, WANDS, PENTACLES, SWORDS, or MAJOR
- **Rank/Value**: 1-10 for numbered cards, 11-14 for face cards, 1-22 for majors

### Card ID System

```gdscript
# Suit offsets (defined in GameConstants)
SUIT_OFFSET_CUPS = 100      # 101-114
SUIT_OFFSET_WANDS = 200     # 201-214  
SUIT_OFFSET_PENTACLES = 300 # 301-314
SUIT_OFFSET_SWORDS = 400    # 401-414
MAJOR_CARD_THRESHOLD = 500  # 501-522
```

### Working with Cards

```gdscript
# Create cards through DeckManager
var deck_manager = GameManager.game_state.deck_manager
var card = deck_manager.draw_card()

# Check card properties
if card.suit == DataStructures.SuitType.MAJOR:
    # Special major arcana logic
    
# Calculate card values
var value = GameConstants.get_card_value_from_id(card.id)
```

## 💰 Currency & Economy

### Currency Types

```gdscript
# Access currency through GameStats
var stats = GameManager.game_state.stats
var money = stats.money  # Clairvoyance currency
var prestige_points = stats.prestige_points
```

### Economic Calculations

Card values contribute to money generation through suit-specific calculators:

```gdscript
# Each suit has its own calculator
Calculators/CupCalculator.gd      # Healing/restoration effects
Calculators/WandCalculator.gd     # Energy/action effects  
Calculators/PentacleCalculator.gd # Material/money effects
Calculators/SwordCalculator.gd    # Conflict/challenge effects
Calculators/MajorCalculator.gd    # Powerful arcana effects
```

## 🎨 UI Development

### Event System

Use the EventBus for all UI updates:

```gdscript
# Listen for events
SignalManager.safe_connect(
    GameManager.game_state.event_bus.money_updated,
    _on_money_changed,
    "MyComponent money update"
)

# Emit events
GameManager.game_state.event_bus.emit_money_updated(new_amount)
```

### Safe Component Development

Always follow these patterns:

```gdscript
extends Control
class_name MyUIComponent

func _ready():
    # Wait for GameManager initialization
    if not GameManager.is_initialized:
        await GameManager.initialization_signal
    _setup_component()

func _setup_component():
    # Validate before accessing
    if not ValidationUtils.has_event_bus():
        push_error("MyUIComponent: EventBus not available")
        return
        
    # Safe signal connections
    var event_bus = GameManager.game_state.event_bus
    SignalManager.safe_connect(event_bus.some_signal, _on_signal, "MyUIComponent")

func _exit_tree():
    _disconnect_signals()

func _disconnect_signals():
    # Always clean up signals
    if ValidationUtils.has_event_bus():
        var event_bus = GameManager.game_state.event_bus
        SignalManager.safe_disconnect(event_bus.some_signal, _on_signal, "MyUIComponent")
```

## 🧪 Testing Patterns

### Manual Testing Tools

Debug tools are available in the `DEBUG_*` files:

- `DEBUG_MoneyButton.gd` - Add currency for testing
- `DEBUG_reset_game.gd` - Reset game state
- `DEBUG_major_draw.gd` - Force major arcana draws

### Validation Testing

```gdscript
# Test validation utilities
assert(ValidationUtils.has_stats())
assert(ValidationUtils.has_deck_manager())
assert(ValidationUtils.has_event_bus())
```

## 🔧 Common Development Tasks

### Adding New Card Effects

1. Identify the appropriate calculator (Cups/Wands/Pentacles/Swords/Major)
2. Add effect logic to the calculator
3. Update UI to reflect new mechanics
4. Add constants for any magic numbers

### Creating New UI Components

1. Extend from appropriate base class (Control, Button, etc.)
2. Implement validation patterns
3. Use EventBus for communication
4. Add proper signal cleanup in `_exit_tree()`
5. Use DescriptionFormatter for text

### Adding New Game Mechanics

1. Create manager class in `Assets/Scripts/Managers/`
2. Register with GameState
3. Add EventBus signals for communication
4. Implement save/load functionality
5. Add validation utilities if needed

## 🚨 Code Quality Guidelines

### Must-Do Patterns

✅ **Always validate before accessing GameManager state**
✅ **Use SignalManager for all signal operations**  
✅ **Implement _exit_tree() cleanup in all components**
✅ **Use GameConstants instead of magic numbers**
✅ **Use DescriptionFormatter for UI text**

### Never-Do Patterns

❌ **Never access GameManager.game_state without validation**
❌ **Never connect signals without SignalManager**
❌ **Never leave signals connected in _exit_tree()**
❌ **Never use magic numbers**
❌ **Never duplicate string formatting logic**

## 🐛 Debugging Tips

### Common Issues

**"Null reference to GameManager.game_state"**
- Use `ValidationUtils.has_stats()` before accessing
- Ensure GameManager is initialized before component setup

**"Memory leaks from signals"**
- Check `_exit_tree()` implementation
- Use SignalManager for all connections

**"UI not updating"**
- Verify EventBus signal connections
- Check if signals are being emitted correctly

### Debug Output

```gdscript
# Use validation for debug safety
if ValidationUtils.has_stats():
    print("Money: ", GameManager.game_state.stats.money)
else:
    print("Stats not available")
```

## 📁 File Organization

```
Assets/Scripts/
├── Core/                # Core utilities and foundation systems
├── Managers/           # Game logic and state managers
├── Systems/            # Global singletons and coordinators
├── Data/               # Game data and statistics
├── GUI/                # User interface components
├── Models/             # Data structures and type definitions
├── Utils/              # Utility functions and helpers
└── CardDescriptions/   # Card-specific content
```

## 🎯 Performance Considerations

- ValidationUtils checks are lightweight but avoid in tight loops
- Use object pooling for frequently created/destroyed objects
- Cache manager references when possible
- Disconnect unused signals promptly

## 🔮 Advanced Topics

### Custom Calculators

Each suit calculator extends BaseCalculator and implements:

```gdscript
extends BaseCalculator
class_name CustomCalculator

func calculate_value(card: Card) -> float:
    # Your calculation logic
    return base_value * multiplier
```

### Event Bus Extensions

Add new events to EventBus.gd:

```gdscript
signal my_custom_event(data: CustomData)

func emit_my_custom_event(data: CustomData):
    my_custom_event.emit(data)
```

---

## 📚 Quick Reference

### Essential Imports
```gdscript
extends Control  # or appropriate base class

# Core systems automatically available via Systems/ autoloads:
# - GameManager
# - ValidationUtils  
# - SignalManager
# - GameConstants
# - DescriptionFormatter
```

### Common Code Snippets

```gdscript
# Safe game state access
if ValidationUtils.has_stats():
    var money = GameManager.game_state.stats.money

# Safe signal connection
SignalManager.safe_connect(signal, method, "ComponentName description")

# Using constants
if card.rank >= GameConstants.CARD_RANK_PAGE:
    # Handle face cards

# Formatting text
var text = DescriptionFormatter.format_deck_count(current, maximum)
```

Happy coding! May your code be bug-free and your fortunes ever in your favor! 🎴✨
