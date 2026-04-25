# Sync UP Planning Manager

Flutter application for event planning and participant management with attendance tracking.

## Project Overview

The Planning Manager allows users to create, manage, and track events with participant attendance.

## Features

### 📅 Calendar Interface
- Visual event indicators with color-coded attendance status
- Day selection with event display
- Responsive design for both large and small screens

### 📝 Event Management
- Create new events with title, date, and time
- Add participants to events
- View event details in a popup dialog
- Edit participant attendance status
- Event list organized by selected date

### 👥 Participant Management
- Add participants to events
- Track attendance status (Present, Absent, No status)
- Visual status indicators with color coding (red and green)
- Participant list with status dropdown menus

### 🎨 User Interface
- Professional blue color scheme
- Gradient backgrounds and shadows
- Responsive layout that adapts to screen size
- Modern Material Design components

### 📊 Attendance Tracking
- Color-coded calendar days based on attendance:
  - **Green**: All participants present
  - **Red**: At least one participant absent
  - **Dark Gray**: Participants with undefined status

## How to Execute

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio or VS Code with Flutter extensions
- Android/iOS device or emulator

### Installation Steps

1. **Clone the repository:**
   ```bash
   git clone https://github.com/AlikBook/Flutter_planning.git
   cd planning
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the application:**
   ```bash
   flutter run
   ```

### Platform Support
- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

## Project Structure

```
lib/
├── main.dart              # Main application file with calendar and event UI
├── main_classes.dart      # Data models (Event, Person classes)
└── my_form.dart          # Event creation form widget
```

## Key Components

### Main Classes
- **Event**: Represents an event with title, date, time, and participants
- **Person**: Represents a participant with name and event participation history

### Main Widgets
- **TableCalendar**: Interactive calendar display
- **MyForm**: Event creation form
- **Event List**: Displays events for selected date
- **Attendance Dialog**: Manages participant attendance status

## Dependencies

- `flutter`: Flutter framework
- `table_calendar`: Calendar widget for event display
- `material_design_icons_flutter`: Additional icons

## Development

1. Event classes are defined in `main_classes.dart`
2. UI components are in `main.dart`
3. Form components are in `my_form.dart`
