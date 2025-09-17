
# �️ Fortunes Developer Guide

A modern, modular codebase for a tarot-inspired idle-strategy game. This guide is for contributors, maintainers, and anyone interested in the architecture and best practices behind Fortunes.

---

## 🏗️ Architecture Overview

Fortunes is built for extensibility and maintainability. The project uses:
- **Modular managers** for deck, upgrades, stats, and calculators
- **Signal/event-driven** communication (EventBus)
- **Strict validation** and null-safety patterns
- **Separation of UI, logic, and data**

### Key Systems

- **GameManager**: Central coordinator, holds game state and references to all managers
- **DeckManager**: Handles all card/deck logic, including creation, shuffling, and drawing
- **UpgradeManager**: Manages upgrades, stat boosts, and synergy effects
- **Stats (GameStats, SuitStats)**: Tracks all player stats, currencies, and multipliers
- **Calculators**: Suit-specific and major arcana calculators for value/effect computation
- **EventBus**: Global event system for decoupled communication
- **ValidationUtils**: Null-safety and validation helpers
- **DescriptionFormatter**: Consistent UI text formatting
- **PreloadedResources**: Access the most important resources in instances
- **Tools**: This is a script for accessing important invormation in a static way

---

## 🎴 Card & Deck System

- **Card**: Has ID, suit (CUPS, WANDS, PENTACLES, SWORDS, MAJOR), rank/value, and effect logic
- **Card IDs**: Offset by suit, e.g. 101–114 (Cups), 501–522 (Majors)
- **DeckManager**: Creates, unlocks, and manages all cards and decks
- **Calculators**: Each suit/major has a dedicated calculator for value/effect computation

```gdscript
# Example: Drawing a card
var card = GameManager.game_state.deck_manager.draw_card()
if card.suit == DataStructures.SuitType.MAJOR:
    # Handle major arcana logic
```

---

## 💰 Currency & Progression

- **Clairvoyance**: Main currency, earned via card effects
- **Packs**: Meta-progression, earned via resets
- **Upgrades**: Flat and percentage boosts, synergy multipliers, and late-game scaling

```gdscript
# Accessing currencies
var stats = GameManager.game_state.stats
var clairvoyance / packs = stats.clairvoyance / stats.packs
```

---

## 🎨 UI & Event System

- **EventBus**: All UI updates and cross-system communication use signals/events
- **Safe UI Patterns**: Always validate GameManager state before accessing
- **Component Setup**: Wait for GameManager initialization before setup

```gdscript
# Safe UI component example
extends Control
func _ready():
    if not GameManager.is_initialized:
        await GameManager.initialization_signal
    # Now safe to access game state
```

---

## 🧪 Testing & Debugging

- **DebugManager**: Use this script for all debug logging, using the scene to change functionality
- **Validation**: Use `ValidationUtils` for all state checks
- **Dev Tools**: In-game debug overlays and logging for rapid iteration

```gdscript
# Example: Debug Money Changed:
var clairvoyance:
    set(value):
        if value != clairvoyance:
            clairvoyance = value
            DebugManager.print_card_effects("Clairvoyance updated", DebugManager.DebugLevel.VERBOSE)
```

---

## 🔧 Common Tasks & Patterns

### Adding Card Effects
1. Add logic to the appropriate calculator (Cups/Wands/Pentacles/Swords/Major)
2. Update UI and constants as needed
3. Add/adjust upgrades in UpgradesList.gd

### Creating UI Components
1. Use EventBus for all communication
2. Use DescriptionFormatter for text

### Adding Game Mechanics
1. Create a new manager in `Assets/Scripts/Managers/`
2. Register with GameState
3. Add EventBus signals
4. Implement save/load and validation
5. if needed, ensure shuffle integration

---

## 🚨 Code Quality & Best Practices

**Must-Do:**
- Always validate before accessing GameManager/game_state
- Use GameConstants for all magic numbers
- Use DescriptionFormatter for UI text

**Never-Do:**
- Never use magic numbers directly
- Never duplicate string formatting logic

---

## 📁 File Organization

```
Assets/Scripts/
├── Statics/             # Core utilities and foundation systems, mostly in static form
├── Managers/            # Game logic, deck, upgrade, and calculator managers
│   └── Calculators/     # Suit/major-specific calculators
├── Autoload/            # Global singletons and coordinators
├── Data/                # Game data, stats, and constants
├── GUI/                 # User interface and HUD
├── Models/              # Data structures and type definitions
├── Utils/               # Utility functions and helpers
└── CardDescriptions/    # Card-specific content and lore
```

---

## 🎯 Performance & Advanced Topics

- ValidationUtils is lightweight but avoid in tight loops
- Use object pooling for frequently created/destroyed objects
- Cache manager references when possible
- Each calculator extends BaseCalculator and implements custom logic

```gdscript
# Custom calculator example
extends BaseCalculator
class_name CustomCalculator
func calculate_value(card: Card) -> float:
    return base_value * multiplier
```

---

## 📚 Quick Reference

```gdscript
# Safe game state access
if ValidationUtils.has_stats():
    var money = GameManager.game_state.stats.money

# Using constants
if card.rank >= GameConstants.CARD_RANK_PAGE:
    # Handle face cards

# Formatting text
var text = DescriptionFormatter.format_deck_count(current, maximum)
```

---

Happy coding! May your code be bug-free and your fortunes ever in your favor! 🎴✨
