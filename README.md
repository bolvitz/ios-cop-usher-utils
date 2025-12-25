# Event Monitor - iOS

An offline-first event management application for tracking attendance, managing lost & found items, and reporting incidents across multiple venues.

This is the iOS equivalent of the [android-cop-usher-utils](https://github.com/bolvitz/android-cop-usher-utils) Android app.

## Features

### Multi-Venue Support
- Manage multiple venues/locations
- Configure venue-specific details (name, location, code, contact info)
- Enable/disable features per venue
- Custom venue colors for easy identification

### Head Counting
- **Real-time attendance tracking** across multiple areas/zones
- **Undo/Redo functionality** for corrections
- **Visual progress bars** showing capacity utilization
- **Area-based counting** with customizable zones
- **Event history** with search and filtering
- **Capacity management** with percentage tracking
- **Haptic feedback** for count changes

### Lost & Found Management
- **180-day donation rule** - Items held for 6 months before donation
- **Status tracking** - Pending, Claimed, Donated, Disposed
- **Category classification** - Electronics, Clothing, Documents, etc.
- **Photo attachments** for item verification
- **Detailed item descriptions** - Color, brand, identifying marks
- **Claim verification** with contact information
- **Search and filter** by category and status

### Incident Reporting
- **Severity levels** - Low, Medium, High, Critical (color-coded)
- **Status tracking** - Reported, Investigating, In Progress, Resolved, Closed
- **Assignment management** - Track who's responsible
- **Photo evidence** support
- **Action logging** - Document steps taken
- **Location tracking** within venue
- **Search and filter** capabilities

### Reports & Analytics
- **Attendance summaries** by venue and date range
- **Statistical insights** - Total events, average attendance
- **CSV export** for external analysis
- **Event comparison** across venues
- **Visual statistics** with color-coded cards

## Architecture

### Technology Stack
- **SwiftUI** - Modern, declarative UI framework
- **SwiftData** - Apple's latest persistence framework
- **MVVM Pattern** - Clean separation of concerns
- **Combine** - Reactive programming for data flow

### Project Structure
```
EventMonitor/
├── EventMonitor/              # Main app module
│   ├── App/                   # App entry point
│   ├── Navigation/            # Navigation structure
│   ├── Screens/              # Main app screens
│   └── Resources/            # Assets, Info.plist
├── Core/
│   ├── Common/               # Shared UI, theme, extensions
│   ├── Data/
│   │   ├── Models/          # SwiftData models
│   │   ├── Persistence/     # Database configuration
│   │   └── Repositories/    # Data access layer
│   └── Domain/
│       ├── Models/          # Domain models
│       ├── Enums/           # Enumerations
│       └── Validation/      # Business logic validation
└── Features/
    ├── HeadCounter/         # Head counting feature
    ├── LostAndFound/        # Lost & found feature
    └── Incidents/           # Incident reporting feature
```

### Data Models

#### Core Entities
- **Venue** - Venue/location information
- **AreaTemplate** - Configured areas/zones for venues
- **Event** - Service/event instances
- **EventType** - Predefined event types (e.g., "Sunday Service")
- **AreaCount** - Attendance counts per area per event
- **LostItem** - Lost and found items
- **Incident** - Incident reports

All entities include:
- Unique IDs (UUID)
- Timestamps (created/updated)
- Cloud sync fields (for future use)
- Proper relationship management with cascade delete

### Key Design Patterns

#### Offline-First Architecture
- All data stored locally with SwiftData
- No network dependency for core functionality
- Cloud sync ready (future enhancement)

#### Material Design 3 Theme
- Consistent color scheme matching Android app
- Purple primary color (#6200EE)
- Material spacing and typography
- Card-based UI with elevation

#### State Management
- `@ObservableObject` ViewModels
- `@Published` properties for reactive updates
- SwiftData `@Query` for automatic data binding

## Requirements

- **iOS 17.0+**
- **Xcode 15.0+**
- **Swift 5.9+**
- **SwiftData** (iOS 17+)

## Installation

### Building from Source

1. Clone the repository:
```bash
git clone https://github.com/bolvitz/ios-cop-usher-utils.git
cd ios-cop-usher-utils
```

2. Open the project in Xcode:
```bash
open EventMonitor.xcodeproj
```

3. Select your target device or simulator

4. Build and run (⌘R)

### Project Setup

The project uses SwiftData for persistence, which requires:
- iOS 17.0 or later
- No additional dependencies or CocoaPods
- All code is native Swift and SwiftUI

## Usage

### First Launch

1. **Add a Venue**
   - Tap the menu (⋯) → Add Venue
   - Enter venue details (name, location, unique code)
   - Configure contact information
   - Select venue color
   - Enable desired features

2. **Configure Areas**
   - Edit the venue → Manage Areas
   - Add areas/zones (e.g., "Main Hall", "Balcony")
   - Set capacity for each area
   - Choose icons and colors
   - Reorder areas by drag-and-drop

3. **Set Up Event Types** (Optional)
   - Go to Settings
   - Add event types (e.g., "Sunday Service", "Wednesday Prayer")
   - Configure day and time

### Head Counting Workflow

1. From venue list, tap **Head Count**
2. Tap + to create new event
3. Select event type and enter counter name
4. Tap **Start Counting**
5. Use +/- buttons to count each area
6. View real-time totals and capacity percentages
7. Use undo/redo for corrections
8. Lock event when complete

### Lost & Found Workflow

1. From venue list, tap **Lost & Found**
2. Tap + to add new item
3. Fill in item details:
   - Description and category
   - Where and when found
   - Color, brand, identifying marks
   - Photo (optional)
4. Item automatically tracks 180-day countdown
5. Mark as Claimed when owner retrieves it
6. Can mark as Donated after 180 days

### Incident Reporting Workflow

1. From venue list, tap **Incident Reporting**
2. Tap + to report incident
3. Enter incident details:
   - Title and description
   - Severity level (color-coded)
   - Category and location
   - Assigned personnel
4. Update status as incident progresses
5. Document actions taken
6. Mark as Resolved/Closed when complete

## Key Features Comparison with Android

| Feature | Android | iOS | Status |
|---------|---------|-----|--------|
| Multi-venue support | ✓ | ✓ | ✅ Complete |
| Head counting | ✓ | ✓ | ✅ Complete |
| Undo/Redo | ✓ | ✓ | ✅ Complete |
| Lost & Found | ✓ | ✓ | ✅ Complete |
| 180-day rule | ✓ | ✓ | ✅ Complete |
| Incident reporting | ✓ | ✓ | ✅ Complete |
| Reports & Export | ✓ | ✓ | ✅ Complete |
| Event types | ✓ | ✓ | ✅ Complete |
| Material Design 3 | ✓ | ✓ | ✅ Complete |
| Offline-first | ✓ | ✓ | ✅ Complete |
| Cloud sync | Planned | Planned | ⏳ Future |
| Firebase integration | Planned | Planned | ⏳ Future |

## Business Logic

### Critical Rules Preserved

1. **180-Day Donation Rule**
   - Lost items must be held for 180 days before donation
   - Automatic countdown tracking
   - Visual indicators when donation is allowed

2. **Undo/Redo Stack**
   - Essential for head counting accuracy
   - Maintains count history per area
   - Supports unlimited undo/redo operations

3. **Capacity Calculations**
   - Color-coded progress bars:
     - Green: 0-60%
     - Orange: 60-80%
     - Deep Orange: 80-100%
     - Red: 100%+

4. **Severity Color Coding**
   - Low: Green
   - Medium: Orange
   - High: Deep Orange
   - Critical: Red

5. **Cascade Deletes**
   - Deleting venue removes all related areas, events, items, incidents
   - Deleting event removes all area counts
   - Maintains data integrity

6. **Unique Constraints**
   - Venue codes must be unique and uppercase
   - Event type names must be unique

## Future Enhancements

### Planned Features
- [ ] iCloud sync
- [ ] Firebase integration
- [ ] Photo storage and management
- [ ] Advanced analytics and charts
- [ ] Export to multiple formats (PDF, Excel)
- [ ] Multi-user support with authentication
- [ ] Push notifications
- [ ] iPad optimization with split views
- [ ] Apple Watch companion app
- [ ] Widgets for quick counting

### Under Consideration
- [ ] Barcode scanning for items
- [ ] QR code generation for venues
- [ ] Offline map integration
- [ ] Voice commands for counting
- [ ] Automated incident escalation
- [ ] Custom report templates

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines
- Follow Swift style guidelines
- Use SwiftUI best practices
- Maintain MVVM architecture
- Add unit tests for business logic
- Update documentation

## License

This project is part of the bolvitz organization event management suite.

## Related Projects

- [android-cop-usher-utils](https://github.com/bolvitz/android-cop-usher-utils) - Android version

## Support

For issues, questions, or suggestions:
- Open an issue on GitHub
- Contact: [Your contact information]

## Acknowledgments

- Designed to match the Android app feature-for-feature
- Built with SwiftUI and SwiftData
- Follows Material Design 3 principles
- Offline-first architecture for reliability

---

**Version:** 1.0.0
**Platform:** iOS 17.0+
**Last Updated:** December 2024
