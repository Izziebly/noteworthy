

# Noteworthy

A full stack notes application built across three layers — a NestJS REST API,
a React web frontend, and a Flutter mobile app. Features JWT authentication,
slug-based URLs, infinite scroll, and a warm editorial design consistent
across both web and mobile.

## Project Structure
```
noteworthy/
├── backend/                  # NestJS REST API (current)
├── web/                      # React web frontend
├── mobile/                   # Flutter mobile app
└── express-backend/          # Legacy Express API (archived)
```

---

## Backend — NestJS (`/backend`)

A structured REST API built with NestJS, MongoDB and JWT authentication.
Migrated from Express to NestJS for better scalability and architecture.

### Features
- JWT authentication with access + refresh tokens
- Refresh tokens stored in httpOnly cookies
- Role-based route protection via Guards
- Input validation via DTOs and class-validator
- Slug generation for clean note URLs
- Paginated notes with search
- Custom decorators (`@CurrentUser`, `@Public`)
- Global exception filter
- MongoDB ID validation pipe

### Tech Stack
- NestJS + TypeScript
- MongoDB + Mongoose
- JWT (@nestjs/jwt)
- bcrypt
- class-validator + class-transformer

### Structure
```
backend/
├── src/
│   ├── auth/
│   │   ├── decorators/       # @CurrentUser, @Public
│   │   ├── dto/              # LoginDto, RegisterDto
│   │   ├── guards/           # AuthGuard
│   │   ├── schemas/          # User schema
│   │   ├── auth.controller.ts
│   │   ├── auth.module.ts
│   │   └── auth.service.ts
│   ├── notes/
│   │   ├── dto/              # CreateNoteDto, UpdateNoteDto, NoteQueryDto
│   │   ├── schemas/          # Note schema
│   │   ├── notes.controller.ts
│   │   ├── notes.module.ts
│   │   └── notes.service.ts
│   ├── common/
│   │   ├── filters/          # GlobalExceptionFilter
│   │   └── pipes/            # ParseMongoIdPipe
│   ├── utils/                # slugify
│   ├── app.module.ts
│   └── main.ts
└── .env.example
```

### Getting Started
```bash
cd backend
npm install
npm run start:dev
```

### Environment Variables
| Variable | Description |
|----------|-------------|
| MONGO_URI | MongoDB connection string |
| JWT_SECRET | Secret for signing access tokens |
| REFRESH_SECRET | Secret for signing refresh tokens |
| NODE_ENV | development or production |
| PORT | Server port (default 5000) |
| CLIENT_URL | Frontend URL for CORS |

### API Endpoints

#### Auth
| Method | Endpoint | Description | Protected |
|--------|----------|-------------|-----------|
| POST | /api/auth/register | Register new user | No |
| POST | /api/auth/login | Login user | No |
| POST | /api/auth/logout | Logout user | No |
| POST | /api/auth/refresh | Refresh access token | No |

#### Notes
| Method | Endpoint | Description | Protected |
|--------|----------|-------------|-----------|
| GET | /api/notes | Get all notes (paginated + search) | Yes |
| GET | /api/notes/:id | Get single note | Yes |
| POST | /api/notes | Create note | Yes |
| PUT | /api/notes/:id | Update note | Yes |
| DELETE | /api/notes/:id | Delete note | Yes |

---

## Web — React (`/web`)

A responsive web frontend built with React and TypeScript.
Features a warm editorial design consistent with the mobile app.

### Features
- JWT authentication with persistent login
- Create, edit and delete notes
- Slug-based URLs for clean navigation
- Hold to delete with 4 second undo
- Infinite scroll with back to top
- Real-time search and filter
- Word and character count on editor
- Auto-save on browser back button
- ⌘S / Ctrl+S keyboard shortcut to save
- Responsive design for mobile, tablet and desktop
- Toast notifications for all actions

### Tech Stack
- React 18 + TypeScript
- TanStack Query (data fetching, caching, infinite scroll)
- React Router v6
- Axios
- Vanilla CSS with CSS custom properties

### Structure
```
web/
├── src/
│   ├── context/              # Auth context
│   ├── hooks/                # useNotes, useAuth, useAuthForms
│   ├── pages/                # NotesPage, CreateNotePage, NoteDetailPage
│   │                         # LoginPage, RegisterPage
│   ├── components/           # Navbar
│   ├── services/             # noteService, authService, axios
│   └── styles/               # CSS files per page/component
└── index.html
```

### Getting Started
```bash
cd web
npm install
npm run dev
```

### Environment Variables
| Variable | Description |
|----------|-------------|
| VITE_API_URL | Backend API base URL |

---

## Mobile — Flutter (`/mobile`)

A cross-platform mobile app for iOS and Android built with Flutter.
Shares the same backend API as the web frontend.

### Features
- JWT authentication with persistent login via SecureStorage
- Create, edit and delete notes
- Long press to delete with 4 second undo
- Infinite scroll with back to top
- Real-time search with debounce
- Pull to refresh
- Word and character count on editor
- Toast notifications for all actions
- Warm editorial design matching the web app

### Tech Stack
- Flutter + Dart
- Riverpod (state management)
- GoRouter (navigation)
- Dio (HTTP client)
- flutter_secure_storage (token storage)
- Google Fonts (Playfair Display + DM Sans)

### Structure
```
mobile/
└── lib/
    ├── core/
    │   ├── network/          # Dio client + interceptors
    │   ├── storage/          # SecureStorage
    │   ├── theme/            # AppColors, AppSpacing, AppTheme
    │   └── widgets/          # Toast
    ├── features/
    │   ├── auth/
    │   │   ├── data/         # AuthService
    │   │   ├── models/       # User
    │   │   ├── presentation/ # LoginScreen, RegisterScreen
    │   │   └── providers/    # AuthProvider, AuthState
    │   └── notes/
    │       ├── data/         # NoteService
    │       ├── models/       # Note, PaginatedNotes
    │       ├── presentation/ # NotesScreen, CreateNoteScreen, NoteDetailScreen
    │       ├── providers/    # NotesProvider, NotesState
    │       └── widgets/      # NoteCard
    ├── router/               # GoRouter with auth redirect
    └── main.dart
```

### Getting Started
```bash
cd mobile
flutter pub get

# Android emulator
flutter run

# Physical device
flutter run --dart-define=API_URL=http://YOUR_MACHINE_IP:5000/api
```

---

## Legacy Backend — Express (`/express-backend`)

The original Express backend this project was built on before migrating
to NestJS. Kept for reference to show architectural progression.

### Tech Stack
- Node.js + Express
- MongoDB + Mongoose
- JWT
- bcrypt

### Structure
```
express-backend/
├── middleware/               # authMiddleware
├── models/                   # User, Note
├── routes/                   # auth, notes
├── utils/                    # slugify
└── server.js
```

---

## Design System

All interfaces follow the **Warm Ink** editorial aesthetic:

| Token | Value | Usage |
|-------|-------|-------|
| `--cream` | `#F7F3ED` | Page backgrounds |
| `--ink` | `#1C1917` | Primary text, buttons |
| `--amber` | `#D97706` | Accents, highlights |
| `--paper` | `#FDFAF6` | Card backgrounds |
| Heading font | Playfair Display | Titles, display text |
| Body font | DM Sans | Body text, UI labels |

---

## Getting Started (All Projects)

**Prerequisites:**
- Node.js 18+
- MongoDB (local or Atlas)
- Flutter SDK
- Android Studio or Xcode

**1. Clone the repo:**
```bash
git clone https://github.com/Izziebly/noteworthy.git
cd noteworthy
```

**2. Set up backend:**
```bash
cd backend
npm install
cp .env.example .env   # fill in your values
npm run start:dev
```

**3. Set up web:**
```bash
cd web
npm install
cp .env.example .env   # fill in your values
npm run dev
```

**4. Set up mobile:**
```bash
cd mobile
flutter pub get
flutter run
```

---

## License

MIT