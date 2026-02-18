# Labamu Test

Labamu Take Home Test 
Flutter 3.41.1 
Clean Architecture
Bloc
Offline First with Hive
ai assistant : Augment Code Generation

## Architecture

This application follows Clean Architecture** principles, separating concerns into distinct layers:

### Layers

1. **Presentation Layer**
   - **BLoC (Business Logic Component)**: Manages state and handles user interactions
   - **UI Components**: Screens, widgets, and routing using Go Router
   - Located in `lib/features/product/presentation/`

2. **Domain Layer**
   - **Entities**: Core business objects (e.g., `Product`)
   - **Use Cases**: Application-specific business logic (e.g., `FetchProducts`, `AddProduct`, `SyncProduct`)
   - **Repository Interfaces**: Abstract contracts for data operations
   - Located in `lib/features/product/domain/`

3. **Data Layer**
   - **Repository Implementations**: Concrete implementations of repository interfaces
   - **Data Sources**: Local (Hive) and remote (HTTP) data sources
   - **Models**: Data transfer objects with serialization
   - Located in `lib/features/product/data/`

### Core Components

- **Dependency Injection**: GetIt for service locator pattern
- **State Management**: BLoC pattern with events and states
- **Error Handling**: Functional programming with `Either<Failure, Data>` using Dartz
- **Routing**: Go Router for declarative navigation
- **Local Storage**: Hive for NoSQL database with type adapters

## Offline Strategy

The application implements an **offline-first** approach to ensure functionality without internet connectivity:

### Key Features

- **Local Caching**: All data is stored locally using Hive database
- **Offline Operations**: Create, read, update operations work offline
- **Background Sync**: Automatic synchronization when network is available
- **Conflict Resolution**: Timestamp-based last-write-wins strategy
- **Network Monitoring**: Real-time connectivity detection using `connectivity_plus`

### Sync Mechanism

1. **Read Operations**: Always load from local cache first for instant UI response
2. **Write Operations**: Save to local storage immediately, mark as unsynced
3. **Background Sync**: When online, sync unsynced changes to remote server
4. **Conflict Handling**: Compare timestamps; remote wins on conflicts, local changes queued for retry

### Data Flow

```
User Action → BLoC → Use Case → Repository → Local Data Source (immediate)
                                      ↓
                           Remote Data Source (async when online)
```

## Trade-offs

### Advantages

- **Reliability**: App functions without internet connection
- **Performance**: Instant loading from local cache
- **User Experience**: No loading states for cached data
- **Scalability**: Clean separation of concerns allows easy feature additions

### Disadvantages

- **Storage**: Local database increases app size
- **Conflicts**: Potential data conflicts require resolution logic
- **Sync Issues**: Failed syncs may leave data in inconsistent states
- **Development Time**: More boilerplate code compared to simpler architectures

### Offline-First Trade-offs

- **Stale Data**: Users may see outdated information until sync completes
- **Sync Failures**: Network issues can prevent data reconciliation
- **Conflict Resolution**: Last-write-wins may not always be appropriate for all use cases
- **Battery/Performance**: Background sync consumes resources

## Getting Started

1. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

2. **Run Code Generation**:
   ```bash
   flutter pub run build_runner build
   ```

3. **Run the App**:
   ```bash
   flutter run
   ```

## Dependencies

- **State Management**: `flutter_bloc`, `bloc`
- **Networking**: `http`, `connectivity_plus`
- **Local Storage**: `hive_ce`, `hive_ce_flutter`
- **Dependency Injection**: `get_it`
- **Functional Programming**: `dartz`
- **Routing**: `go_router`
- **Utilities**: `equatable`, `uuid`, `intl`
