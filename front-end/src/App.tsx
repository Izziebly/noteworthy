import { BrowserRouter, Routes, Route, Navigate } from "react-router-dom";
import CreateNotePage from "./pages/CreateNotePage";
import NoteDetailPage from "./pages/NoteDetailPage";
import NotesPage from "./pages/NotesPage";
import Login from "./pages/LoginPage";
import Register from "./pages/Register";
import ProtectedRoute from "./components/ProtectedRoute";
import PublicRoute from "./components/PublicRoute";

function App() {
  return (
    <BrowserRouter>
      <Routes>

        <Route path="/" element={<Navigate to="/login" replace />} />
        
        <Route
          path="/login"
          element={
            <PublicRoute>
              <Login />
            </PublicRoute>
          }
        />

        <Route
          path="/register"
          element={
            <PublicRoute>
              <Register />
            </PublicRoute>
          }
        />

        <Route
          path="/notes"
          element={
            <ProtectedRoute>
              <NotesPage />
            </ProtectedRoute>
          }
        />

        <Route
          path="/notes/new"
          element={
            <ProtectedRoute>
              <CreateNotePage />
            </ProtectedRoute>
            
          }
        />

        <Route
          path="/notes/:slug"
          element={
            <ProtectedRoute>
              <NoteDetailPage />
            </ProtectedRoute>
            
          }
        />
        

      </Routes>
    </BrowserRouter>
  );
}

export default App;