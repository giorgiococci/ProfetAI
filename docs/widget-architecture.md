# Widget Architecture Documentation

This document provides an overview of the widget components created during the application refactoring.

## Common Widgets

### GradientContainer
**Purpose**: Provides consistent gradient backgrounds with optional image overlays.
**Goal**: Standardize background styling across different screens and components.

### CustomButton
**Purpose**: Implements primary and outlined button variants with consistent styling.
**Goal**: Ensure uniform button appearance and behavior throughout the application.

### LoadingIndicator
**Purpose**: Displays loading states with prophet-specific theming.
**Goal**: Provide consistent loading feedback to users during async operations.

### ErrorDisplay
**Purpose**: Shows error messages with appropriate styling and context.
**Goal**: Deliver clear error feedback with consistent visual presentation.

## Home Screen Widgets

### ProphetHeader
**Purpose**: Displays prophet temple information and descriptions with localization support.
**Goal**: Present prophet context clearly while supporting multiple languages.

### AnimatedProphetHeader
**Purpose**: Enhanced version of ProphetHeader with fade-in animations.
**Goal**: Improve user experience with smooth visual transitions.

### OracleAvatar
**Purpose**: Renders prophet avatars with hover effects and theming.
**Goal**: Create engaging visual representation of different prophet types.

### QuestionInputField
**Purpose**: Specialized text input for oracle questions with validation.
**Goal**: Provide intuitive question entry with appropriate validation feedback.

### ProphetSelector
**Purpose**: Interface for selecting between different prophet types.
**Goal**: Enable easy prophet switching with visual feedback.

## Dialog Widgets

### VisionDialog
**Purpose**: Displays oracle responses with feedback and action options.
**Goal**: Present oracle visions in an engaging, interactive format.

### ProphetLoadingDialog
**Purpose**: Shows loading state during AI response generation.
**Goal**: Provide visual feedback during potentially long AI operations.

### FeedbackDialog
**Purpose**: Collects user feedback on oracle responses.
**Goal**: Gather user satisfaction data to improve oracle responses.

### ConfirmationDialog
**Purpose**: Handles user confirmations for various actions.
**Goal**: Ensure user intent before performing important operations.

## Utility Classes

### ValidationUtils
**Purpose**: Centralized validation logic for forms and user input.
**Goal**: Ensure consistent validation behavior and error messaging.

### ThemeUtils
**Purpose**: Manages application theming, colors, and styling consistency.
**Goal**: Provide centralized theme management with prophet-specific variations.

### StateUtils
**Purpose**: Common state management patterns and utilities.
**Goal**: Reduce boilerplate code for common state management scenarios.

### ProphetUtils
**Purpose**: Business logic related to prophet management and localization.
**Goal**: Centralize prophet-specific operations and data handling.

### NotificationUtils
**Purpose**: Manages user notifications and feedback messages.
**Goal**: Provide consistent notification experience across the application.

### VisionUtils
**Purpose**: Handles oracle vision processing and feedback management.
**Goal**: Centralize vision-related business logic and user interaction handling.

## Design Principles Applied

### Single Responsibility
Each widget has a focused, well-defined purpose without overlapping concerns.

### Composition Over Inheritance
Widgets are designed to be composed together rather than extending complex hierarchies.

### Theming Consistency
All widgets support the application's theming system and prophet-specific styling.

### Accessibility
Widgets include proper semantic labels and support for accessibility features.

### Localization Support
Components are designed to work seamlessly with the application's localization system.

### Performance Optimization
Widgets are structured to minimize unnecessary rebuilds and optimize rendering performance.

### Error Resilience
Components include proper error handling and graceful degradation patterns.

### Testability
Widgets are designed with clear interfaces that facilitate unit and widget testing.
