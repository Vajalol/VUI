# VUI Performance Optimization Guide
## Quick Reference for Optimal Settings

This guide provides recommended settings for the Spell Detection Logic Enhancement system based on your hardware specifications and gameplay scenarios.

### Hardware-Based Recommendations

#### Low-End Systems (Older CPU, <4GB VRAM)
| Setting | Recommended Value | Notes |
|---------|------------------|-------|
| Enable Optimization | Enabled | Essential for low-end systems |
| Predictive Spell Loading | Enabled | Improves responsiveness |
| Combat Event Throttling | Enabled | Critical for performance |
| Throttle Interval | 0.15s | More aggressive to save CPU |
| Adaptive FPS Throttling | Enabled | Helps maintain playable FPS |
| Low FPS Threshold | 30 | Higher threshold to engage earlier |
| Low FPS Throttle Multiplier | 4.0 | Aggressive throttling for stability |
| Cache Size | 1000 | Balanced for memory constraints |

#### Mid-Range Systems (Modern CPU, 4-8GB VRAM)
| Setting | Recommended Value | Notes |
|---------|------------------|-------|
| Enable Optimization | Enabled | Recommended for all systems |
| Predictive Spell Loading | Enabled | Improves responsiveness |
| Combat Event Throttling | Enabled | Beneficial for most systems |
| Throttle Interval | 0.10s | Balanced setting |
| Adaptive FPS Throttling | Enabled | Helps during intensive encounters |
| Low FPS Threshold | 20 | Default setting |
| Low FPS Throttle Multiplier | 2.0 | Default setting |
| Cache Size | 2000 | Good balance of performance |

#### High-End Systems (High-performance CPU, >8GB VRAM)
| Setting | Recommended Value | Notes |
|---------|------------------|-------|
| Enable Optimization | Enabled | Still beneficial |
| Predictive Spell Loading | Enabled | Maximum responsiveness |
| Combat Event Throttling | Optional | Less critical for high-end systems |
| Throttle Interval | 0.05s | Minimal throttling if enabled |
| Adaptive FPS Throttling | Optional | Less needed on powerful systems |
| Low FPS Threshold | 15 | Only engage in very demanding scenarios |
| Low FPS Throttle Multiplier | 1.5 | Subtle throttling is sufficient |
| Cache Size | 5000 | Maximum caching for best performance |

### Scenario-Based Recommendations

#### Solo Play / Questing
| Setting | Recommended Value | Notes |
|---------|------------------|-------|
| Combat Event Throttling | Optional | Less important in solo play |
| Throttle Interval | 0.05s | Minimal if enabled |
| Adaptive FPS Throttling | Disabled | Rarely needed for solo content |

#### 5-Player Dungeons / Mythic+
| Setting | Recommended Value | Notes |
|---------|------------------|-------|
| Combat Event Throttling | Enabled | Helps during intense combat |
| Throttle Interval | 0.10s | Balanced setting |
| Adaptive FPS Throttling | Enabled | Beneficial during large pulls |
| Low FPS Throttle Multiplier | 2.0 | Good balance for dungeon content |

#### 10-30 Player Raids
| Setting | Recommended Value | Notes |
|---------|------------------|-------|
| Combat Event Throttling | Enabled | Important for raid performance |
| Throttle Interval | 0.15s | More aggressive to handle raid events |
| Adaptive FPS Throttling | Enabled | Very beneficial in raids |
| Low FPS Throttle Multiplier | 3.0 | Increased for raid stability |

#### 40-Player Raids / World Bosses
| Setting | Recommended Value | Notes |
|---------|------------------|-------|
| Combat Event Throttling | Enabled | Critical for large group content |
| Throttle Interval | 0.20s | Aggressive throttling for stability |
| Adaptive FPS Throttling | Enabled | Essential for large groups |
| Low FPS Throttle Multiplier | 4.0 | Maximum value for extreme scenarios |
| Predictive Spell Loading | Enabled | Even more beneficial in large raids |

### Troubleshooting

If you experience performance issues despite using the recommended settings:

1. **Enable Debug Mode** to view detailed performance metrics
2. **Check the Cache Hit Rate** - should be above 85% for optimal performance
3. **Monitor Adaptive Throttling** - if constantly active, consider more aggressive settings
4. **Reset Cache** if you suspect any cache corruption or issues
5. **Try Different Throttle Intervals** - start with more aggressive settings and gradually reduce

For spell notification issues:
1. Ensure **Critical spells** like interrupts and defensive cooldowns are properly categorized
2. Check if **throttling is too aggressive** by temporarily disabling it

### Advanced Customization

Power users can further optimize by editing the following files:
- `core/spell_detection_optimization.lua`: Core optimization logic
- `modules/multinotification/init.lua`: Notification settings integration

To add more class-specific spells to the predictive caching system, locate the `GetGroupClassSpells` function and add important spell IDs to the appropriate class array.