# Prosigliere Harry Potter Characters Coding Challenge

A modern iOS application showcasing Harry Potter characters using Kotlin Multiplatform (KMP) for shared business logic and SwiftUI for the user interface.

## Demo

### iPhone Demo
[Watch iPhone Demo Video](./iPhoneDemo.mp4)

### iPad Demo
[Watch iPad Demo Video](./iPadDemo.mp4)

## Features

### Core Features
- **Character Browsing**: View all Harry Potter characters with detailed information
- **Smart Filtering**: Filter by All, Students, or Staff members
- **Favorites**: Mark characters as favorites with segmented control filtering
- **Character Details**: Rich detail view with character information, wand details, and more, including caching for character images
- **House Selection**: Choose your Hogwarts house (Gryffindor, Slytherin, Ravenclaw, Hufflepuff)
- **Profile Photo**: Capture and set a profile picture using device camera

### Technical Highlights
- **Kotlin Multiplatform**: Shared networking, business logic, and data layer
- **SwiftUI**: Modern declarative UI with Swift 6 concurrency support
- **MVVM Architecture**: Clean separation of concerns
- **Type-Safe Networking**: Custom `NetworkResult` wrapper for robust error handling
- **Offline-First Ready**: Architecture supports caching (not implemented due to time)

## Architecture

### Project Structure

```
HpTest-KMP-iOS/
├── shared/                           # Kotlin Multiplatform Module
│   └── src/commonMain/kotlin/
│       ├── data/
│       │   ├── api/                  # Network layer (Ktor client)
│       │   └── repository/           # Repository pattern
│       ├── domain/
│       │   ├── models/               # DTOs (CharacterDTO, WandDTO)
│       │   └── filters/              # Business logic (CharacterFilter)
│       └── utils/                    # NetworkResult wrapper
│
└── iosApp/HpTest/                    # iOS Application
    ├── Core/
    │   ├── Managers/                 # Business logic managers
    │   │   ├── FavoritesManager      # Favorites state management
    │   │   ├── HouseManager          # House selection state
    │   │   └── ProfileImageStore     # Profile photo persistence
    │   └── Models/                   # iOS domain models
    │
    └── Features/
        ├── Characters/               # Characters feature
        │   ├── CharactersListView    # Master list view
        │   ├── CharactersViewModel   # ViewModel with KMP integration
        │   ├── CharacterRowView      # List row component
        │   └── CharacterDetailView   # Detail view
        └── CameraPicker              # Camera integration
```

### Technology Stack

**Shared (KMP)**
- **Language**: Kotlin 1.9.21
- **Networking**: Ktor 2.3.7 (with automatic retry, timeout handling)
- **Serialization**: kotlinx.serialization 1.6.2
- **Concurrency**: Kotlin Coroutines 1.7.3

**iOS**
- **Language**: Swift 6
- **UI Framework**: SwiftUI
- **Minimum iOS Version**: iOS 15+
- **Concurrency**: Swift Concurrency (async/await, @MainActor)

## Setup Instructions

### Prerequisites

- **macOS** with Xcode 15.0 or later
- **Java 17+** (for Gradle)
- **Xcode Command Line Tools**: `xcode-select --install`

### Building the Project

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd HpTest-KMP-iOS
   ```

2. **Build the KMP framework**
   ```bash
   ./gradlew :shared:linkDebugFrameworkIosSimulatorArm64
   ```
   
   For other architectures:
   ```bash
   # Intel Mac simulator
   ./gradlew :shared:linkDebugFrameworkIosX64
   
   # Physical device
   ./gradlew :shared:linkDebugFrameworkIosArm64
   ```

3. **Open in Xcode**
   ```bash
   open iosApp/HpTest.xcodeproj
   ```

4. **Run the app**
   - Select a simulator or device
   - Press `Cmd + R` to build and run

### Build Configuration

The Xcode project includes a Run Script Phase that automatically builds the KMP framework:

```bash
cd "$SRCROOT/.."
./gradlew :shared:embedAndSignAppleFrameworkForXcode
```

This runs automatically when building from Xcode and selects the correct framework for your target (simulator vs device).

## API Information

**Base URL**: `https://hp-api.onrender.com`

**Endpoint Used**: `/api/characters`

**Note**: This API can be slow on cold starts (free tier). The app includes:
- **No Pagination**: All characters loaded at once
- 30-second request timeout
- Automatic retry logic (3 attempts with exponential backoff)
- User-friendly error messages
- Decided to use Characters endpoint because it contains all data, and then filter data in session

## Design Decisions

### Kotlin Multiplatform Strategy

**Why KMP?**
- **Code Reuse**: Share networking, business logic, and data models
- **Type Safety**: Kotlin's type system prevents runtime errors
- **Platform Native**: iOS app uses 100% native SwiftUI

**What's Shared?**
- ✅ Network client (Ktor with retry/timeout)
- ✅ Repository pattern
- ✅ Data models (DTOs)
- ✅ Business logic (filtering)
- ✅ Error handling (NetworkResult)

**What's iOS-Specific?**
- ✅ UI layer (SwiftUI)
- ✅ Navigation
- ✅ State management (Managers)
- ✅ Camera integration
- ✅ User preferences

### Swift 6 Concurrency

The app is fully compatible with Swift 6's strict concurrency checking:
- `@MainActor` isolation for ViewModels and UI state
- No callback-based APIs (KMP uses property-based API)
- Sendable types across boundaries

### State Management

**Favorites & House Selection**: SwiftUI Environment + @Observable
```swift
@Environment(\.favoritesManager) private var favoritesManager
@Environment(\.houseManager) private var houseManager
```

**Data Loading**: MVVM pattern with ViewModel calling KMP repository
```swift
@MainActor
@Observable
class CharactersViewModel {
    private let repository = CharacterRepository()
    // ...
}
```

## UI/UX Features

- **Master-Detail Navigation**: NavigationSplitView for iPad-optimized layout
- **Segmented Control**: Quick switching between All/Students/Staff/Favorites
- **Pull-to-Refresh**: Refresh character list
- **Empty States**: ContentUnavailableView for no selection / no favorites
- **Loading States**: ProgressView during data fetch
- **Error Handling**: User-friendly error messages with retry option

## Possible Improvements

### Not Implemented (Time Constraints)

#### 1. **Unit & UI Tests**
   - **Missing**: Test coverage for ViewModels, Managers, and KMP code
   - **Priority**: High
   - **Effort**: 2-3 hours
   - **Implementation**:
     ```swift
     // ViewModel tests
     @Test func testFetchCharactersSuccess() async {
         let viewModel = CharactersViewModel()
         await viewModel.loadCharacters()
         #expect(viewModel.characters.isEmpty == false)
     }
     
     // KMP tests
     class CharacterRepositoryTest {
         @Test
         suspend fun `fetchCharacters returns success`() {
             val repository = CharacterRepository()
             val result = repository.fetchCharacters()
             assertTrue(result is NetworkResult.Success)
         }
     }
     ```

#### 2. **Coordinator Pattern for Navigation**
   - **Current**: NavigationSplitView handles navigation
   - **Improvement**: Coordinator pattern for complex navigation flows
   - **Priority**: Medium
   - **Effort**: 3-4 hours
   - **Benefits**:
     - Centralized navigation logic
     - Easier to test navigation flows
     - Deep linking support

#### 3. **Offline Caching**
   - **Current**: Network-only data fetching
   - **Improvement**: Cache characters locally
   - **Priority**: High
   - **Effort**: 4-5 hours
   - **Implementation**:
     - SwiftData or CoreData for iOS
     - SQLDelight in KMP for shared DB
     - Cache invalidation strategy

#### 4. **Search Functionality**
   - **Current**: Filter by role only
   - **Improvement**: Full-text search by name, house, actor
   - **Priority**: Medium
   - **Effort**: 2 hours
   - **Implementation**:
     ```swift
     .searchable(text: $searchText, prompt: "Search characters...")
     var filteredCharacters: [Character] {
         characters.filter { 
             searchText.isEmpty || 
             $0.name.localizedCaseInsensitiveContains(searchText)
         }
     }
     ```

#### 5. **Profile View**
   - **Current**: Camera picker exists, but no dedicated profile screen
   - **Improvement**: Standalone profile view with:
     - Profile photo display
     - House selection UI
     - User preferences
   - **Priority**: Medium
   - **Effort**: 2 hours

#### 6. **Spells Feature**
   - **API Available**: `/api/spells` endpoint exists
   - **Improvement**: Add spells browsing section
   - **Priority**: Low
   - **Effort**: 3-4 hours

#### 7. **Accessibility**
   - **Current**: Basic SwiftUI accessibility
   - **Improvement**: 
     - VoiceOver labels
     - Dynamic Type support
     - Accessibility identifiers for UI testing
   - **Priority**: High
   - **Effort**: 2-3 hours

#### 8. **Animations & Polish**
   - **Current**: Default SwiftUI transitions
   - **Improvement**:
     - Custom transitions for navigation
     - Loading shimmer effects
     - Favorite button animation
   - **Priority**: Low
   - **Effort**: 2-3 hours

#### 9. **Error Recovery**
   - **Current**: Error message with manual retry
   - **Improvement**: 
     - Automatic retry with exponential backoff UI feedback
     - Offline mode detection
     - Network reachability monitoring
   - **Priority**: Medium
   - **Effort**: 2 hours

### Code Quality Improvements

#### 1. **DTO to Domain Model Mapping**
   - **Current**: iOS uses KMP DTOs directly
   - **Issue**: Tight coupling to API structure
   - **Fix**: Create iOS domain models
   ```swift
   // iOS Domain Model
   struct Character {
       let id: String
       let name: String
       // ... iOS-specific computed properties
       
       init(from dto: CharacterDTO) {
           self.id = dto.id
           self.name = dto.name
           // ...
       }
   }
   ```

#### 2. **Dependency Injection**
   - **Current**: Direct instantiation of repositories
   - **Improvement**: Protocol-based DI for testability
   ```swift
   protocol CharacterRepositoryProtocol {
       func fetchCharacters() async -> NetworkResult<[CharacterDTO]>
   }
   
   class CharactersViewModel {
       private let repository: CharacterRepositoryProtocol
       init(repository: CharacterRepositoryProtocol = CharacterRepository()) {
           self.repository = repository
       }
   }
   ```

#### 3. **Logging & Analytics**
   - **Missing**: Structured logging, crash reporting
   - **Tools**: OSLog, Firebase Crashlytics, Sentry
   - **Priority**: Medium
   - **Effort**: 1-2 hours

## Notes

- **Development Time**: Approximately 4 hours (as per challenge guidelines)
- **Focus Areas**: Clean architecture, KMP integration, Swift 6 compatibility
- **Tradeoffs**: Features vs code quality vs time - prioritized architecture and core features

## License

This is a coding challenge project. All Harry Potter content is owned by Warner Bros. Entertainment Inc.

## Acknowledgments

- **API**: [Harry Potter API](https://hp-api.onrender.com/) by @maael
- **Framework**: Kotlin Multiplatform by JetBrains
- **UI**: SwiftUI by Apple
