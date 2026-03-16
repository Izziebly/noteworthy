# Noteworthy

A very clean, full-stack, high level notes application built with the MERN stack and TypeScript.
Features JWT authentication, slug-based URLs, infinite scroll, and a 
warm editorial design.


## Features

- JWT authentication with refresh tokens stored in httpOnly cookies
- Persistent login via token refresh on page load
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

## Tech Stack

**Frontend**
- React 18 + TypeScript
- TanStack Query (data fetching, caching, infinite scroll)
- React Router v6
- Axios
- Vanilla CSS with CSS custom properties

**Backend**
- Node.js + Express
- MongoDB + Mongoose
- JWT (access + refresh tokens)
- bcrypt

## Project Structure
```
├── client/                   # React frontend
│   ├── src/
│   │   ├── context/          # Auth context useNotes, useAuth
│   │   ├── pages/            # NotesPage, CreateNotePage, NoteDetailPage, Register, Login
│   │   ├── components/       # Navbar
│   │   ├── services/         # API calls (noteService, authService, axios)
│   │   ├── styles/           # CSS files per page/component
│   └── index.html
│
└── server/                   # Express backend
    ├── middleware/            # authMiddleware
    ├── models/               # User, Note
    ├── routes/               # auth, notes
    ├── utils/                # slugify
    └── server.js
```

## Environment Variables

### Server
| Variable | Description |
|----------|-------------|
| MONGO_URI | MongoDB connection string |
| JWT_SECRET | Secret for signing access tokens |
| REFRESH_SECRET | Secret for signing refresh tokens |
| NODE_ENV | development or production |
| PORT | Server port (default 5000) |

### Client
| Variable | Description |
|----------|-------------|
| VITE_API_URL | Backend API base URL |

## API Endpoints

### Auth
| Method | Endpoint | Description | Protected |
|--------|----------|-------------|-----------|
| POST | /api/auth/register | Register new user | No |
| POST | /api/auth/login | Login user | No |
| POST | /api/auth/logout | Logout user | No |
| POST | /api/auth/refresh | Refresh access token | No |

### Notes
| Method | Endpoint | Description | Protected |
|--------|----------|-------------|-----------|
| GET | /api/notes | Get all notes (paginated) | Yes |
| GET | /api/notes/:id | Get single note | Yes |
| POST | /api/notes | Create note | Yes |
| PUT | /api/notes/:id | Update note | Yes |
| DELETE | /api/notes/:id | Delete note | Yes |

## Design

The UI follows a **Warm Ink** editorial aesthetic:
- **Fonts:** Playfair Display (headings) + DM Sans (body)
- **Palette:** Cream backgrounds, deep ink text, amber gold accents
- **Components:** Custom vanilla CSS with CSS custom properties

## License

MIT