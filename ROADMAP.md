# VUI Critical Recovery Roadmap 2.0

## Overview
VUI (Version 1.0.0) is a comprehensive World of Warcraft addon suite for The WarWithin Season 2. This roadmap outlines the necessary steps to address critical functionality issues and improve user experience.

**Author:** VortexQ8

## Core Recovery Priorities

### Phase 1: Module Initialization Framework (Critical)
- [x] Implement dependency-based loading priority system
- [x] Fix namespace inconsistencies and initialization sequence
- [x] Create consistent module API for initialization
- [x] Add fallback protection for all core methods
- [ ] Implement startup error prevention system

### Phase 2: Default Configuration (High Priority)
- [ ] Create comprehensive default settings for all modules
- [ ] Implement first-time user setup wizard
- [ ] Create profile templates for different play styles (DPS, Tank, Healer)
- [ ] Add configuration validation to prevent settings corruption
- [ ] Build recovery system for damaged configuration data

### Phase 3: Module-Specific Fixes (Critical)
- [x] Fix BuffOverlay namespace and initialization issues 
- [x] Repair TrufiGCD initialization sequence
- [x] Correct Paperdoll RegisterCallback issues
- [x] Add fallback handling for EventManager in castbar module
- [x] Fix unit frame db initialization in module_api.lua
- [x] Implement event optimization Debug method fallback

### Phase 4: User Experience Improvements (High Priority)
- [ ] Create module enable/disable interface with dependency warnings
- [ ] Add configuration backup and restore functionality
- [ ] Create simplified "lite mode" for better performance
- [ ] Improve help system with tooltips and contextual guidance
- [ ] Add upgrade migration path for future versions

### Phase 5: Performance Optimization (Medium Priority)
- [ ] Implement selective module loading based on character class
- [ ] Add frame throttling during high-activity periods
- [ ] Optimize texture atlas usage for memory efficiency
- [ ] Add combat performance mode that reduces non-essential features
- [ ] Improve garbage collection during combat

## Module Status Overview

| Module | Current Status | Priority Fix |
|--------|---------------|--------------|
| BuffOverlay | ✓ Fixed | Standardized BuffOverlay and buffoverlay namespaces |
| TrufiGCD | ✓ Fixed | Repaired module reference and loading sequence |
| Paperdoll | ✓ Fixed | RegisterCallback method already implemented |
| Castbar | ✓ Fixed | Added EventManager fallback handling |
| UnitFrames | ✓ Fixed | Fixed db field access and initialization |
| Core Events | ✓ Fixed | Added Debug method with fallback |
| Theme System | ✓ Functional | N/A |
| Configuration | ✓ Functional | Improve defaults |

## Comprehensive Module Fix Plan

### Core Infrastructure
1. **Initialization System Update**
   - Create priority-based initialization queue
   - Add dependency check before module init
   - Implement recovery for circular dependencies
   - Add timeout detection for hung initialization

2. **Namespace Standardization**
   - Ensure consistent case for all module namespaces
   - Create accessor functions for cross-module references
   - Add validation for critical namespace paths
   - Implement global namespace recovery system

3. **Method Protection System**
   - Add pre-check handlers for all critical methods
   - Create method stubs for all optional functionality
   - Implement safe call wrapper for external libraries
   - Add callback verification before registration

### Module-Specific Solutions

1. **BuffOverlay Module**
   - Fix namespace inconsistency (BuffOverlay vs buffoverlay)
   - Implement proper unpack method fallback
   - Add initialization sequence validation
   - Create recovery system for category data

2. **TrufiGCD Module**
   - Fix initialization sequence and dependencies
   - Add fallback for missing TrufiGCD table
   - Correct timeline view initialization timing
   - Implement namespace standardization

3. **Paperdoll Module**
   - Add RegisterCallback method implementation
   - Fix initialization dependency chain
   - Create fallback for OnInitialized events
   - Add error handling for callback failure

4. **Castbar Module**
   - Implement EventManager or add fallback
   - Fix theme integration dependency path
   - Create error recovery for animation system
   - Add initialization retry logic

5. **Core Module API**
   - Fix db field access patterns
   - Add database initialization verification
   - Create default recovery values for missing settings
   - Implement module settings validation

## Implementation Timeline

### Week 1: Critical Infrastructure (COMPLETED)
- [x] Create enhanced module initialization system
- [x] Fix core namespace inconsistencies
- [x] Implement method protection wrappers
- [x] Add fallback handlers for critical methods

### Week 2: Module-Specific Fixes (COMPLETED)
- [x] Fix BuffOverlay module namespace and initialization
- [x] Repair TrufiGCD module loading sequence
- [x] Add missing methods to Paperdoll module
- [x] Implement EventManager system for Castbar
- [x] Fix database access in module API

### Week 3: User Experience & Defaults
- [ ] Create comprehensive default settings
- [ ] Implement first-time setup wizard
- [ ] Add profile templates for different roles
- [ ] Create configuration validation system
- [ ] Improve help system and documentation

### Week 4: Testing & Validation
- [ ] Comprehensive testing across all modules
- [ ] Configuration validation checks
- [ ] Performance optimization validation
- [ ] Lua error monitoring and prevention
- [ ] Final polish and release preparation

## Quality Standards
- Zero tolerance for initialization failures
- All modules must have fallback protection
- Every critical method needs safety wrapper
- Comprehensive default settings for first-time users
- Clear error messages for troubleshooting

## Final Deliverables
- Stable, error-free addon suite
- First-time user wizard with role templates
- Comprehensive default configuration
- Improved module dependency system
- Enhanced error prevention and recovery

