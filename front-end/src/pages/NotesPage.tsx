import { useNotes } from "../context/useNotes";
import { useEffect, useState } from "react";
import Navbar from "../components/Navbar";
import "../styles/notes.css";

export default function NotesPage() {
  const {
    notes,
    filtered,
    isLoading,
    error,
    search,
    setSearch,
    activeNoteId,
    setActiveNoteId,
    formatDate,
    deleteNote,
    isDeleting,
    navigateToNote,
    navigate,
    toast,
    pendingDeleteId,
    handleUndoDelete,
    loadMoreRef,
    isFetchingNextPage,
    hasNextPage,
    handleMouseDown,
    handleMouseUp,
    handleTouchStart,
    handleTouchEnd,
  } = useNotes();

  const [showBackToTop, setShowBackToTop] = useState(false);

  useEffect(() => {
    const handleScroll = () => setShowBackToTop(window.scrollY > 400);
    window.addEventListener("scroll", handleScroll);
    return () => window.removeEventListener("scroll", handleScroll);
  }, []);

  const scrollToTop = () => window.scrollTo({ top: 0, behavior: "smooth" });

  /* ── Loading ── */
  if (isLoading) {
    return (
      <>
        <Navbar />
        <div className="loading-wrapper">
          <div className="loading-spinner" />
          <p className="loading-text">Loading your notes...</p>
        </div>
      </>
    );
  }

  /* ── Error ── */
  if (error) {
    return (
      <>
        <Navbar />
        <div className="page-wrapper">
          <div className="error-banner" style={{ marginTop: 32 }}>
            Failed to load notes. Please refresh and try again.
          </div>
        </div>
      </>
    );
  }

  return (
    <>
      <Navbar />

      <div className="page-wrapper">
        <div className="home-page">

          {/* ── Header ── */}
          <div className="home-header">
            <div className="home-header-text">
              <p className="home-greeting">Your workspace</p>
              <h1 className="home-title"><em>All Notes</em></h1>
              <p className="home-subtitle">
                {notes.length} {notes.length === 1 ? "note" : "notes"} saved
              </p>
            </div>
          </div>

          {/* ── Search ── */}
          <div className="search-bar-wrapper">
            <span className="search-icon">🔍</span>
            <input
              className="search-bar"
              placeholder="Search notes..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
            />
          </div>

          {/* ── Stats ── */}
          <div className="stats-row">
            <div className="stat-pill">
              <div className="stat-pill-dot" />
              <span className="stat-pill-label">Total</span>
              <span className="stat-pill-value">{notes.length}</span>
            </div>
            <div className="stat-pill">
              <div className="stat-pill-dot green" />
              <span className="stat-pill-label">Showing</span>
              <span className="stat-pill-value">{filtered.length}</span>
            </div>
          </div>

          {/* ── Notes Grid ── */}
          <div className="notes-grid">
            {filtered.length === 0 ? (
              <div className="empty-state">
                <div className="empty-state-icon">📝</div>
                <h3 className="empty-state-title">
                  {search ? "No results found" : "No notes yet"}
                </h3>
                <p className="empty-state-text">
                  {search
                    ? `Nothing matched "${search}". Try a different search.`
                    : "Tap the + button below to write your first note."}
                </p>
              </div>
            ) : (
              filtered.map((note) => (
                <div
                  key={note._id}
                  className="note-card"
                  onClick={() => {
                    if (activeNoteId === note._id) return;
                    navigateToNote(note.slug);
                  }}
                  onMouseDown={() => handleMouseDown(note._id)}
                  onMouseUp={handleMouseUp}
                  onMouseLeave={handleTouchEnd}
                  onTouchStart={() => handleTouchStart(note._id)}
                  onTouchMove={handleTouchEnd}
                  onTouchEnd={(e) => {
                    e.stopPropagation();
                    handleTouchEnd();
                  }}

                >
                  <div className="note-card-header">
                    <h3 className="note-card-title">{note.title}</h3>
                  </div>

                  <p className="note-card-content">{note.content}</p>
                  <div className="note-card-footer">
                    <span className="note-card-date">
                      {formatDate(note.createdAt)}
                    </span>
                    <span className="note-card-hold-hint">Hold to delete</span>
                  </div>

                  {/* ── Delete popup ── */}
                  {activeNoteId === note._id && (
                    <div
                      className="note-card-popup"
                      onClick={(e) => e.stopPropagation()}
                      onTouchStart={(e) => e.stopPropagation()}
                      onTouchEnd={(e) => e.stopPropagation()}
                    >
                      <p className="note-card-popup-label">Delete this note?</p>
                      <div className="note-card-popup-actions">
                        <button
                          className="btn btn-danger btn-sm"
                          disabled={isDeleting}
                          onClick={() => {
                            deleteNote(note._id);
                          }}
                        >
                          {isDeleting ? "..." : "🗑️ Delete"}
                        </button>
                        <button
                          className="btn btn-secondary btn-sm"
                          onClick={() => {
                            setActiveNoteId(null);
                          }}
                        >
                          Cancel
                        </button>
                      </div>
                    </div>
                  )}
                </div>
              ))
            )}
          </div>
          {/* ── Load more sentinel ── */}
          <div ref={loadMoreRef} style={{ height: 1 }} />

          {/* ── Fetching next page indicator ── */}
          {isFetchingNextPage && (
            <div className="loading-wrapper" style={{ minHeight: 80 }}>
              <div className="loading-spinner" />
            </div>
          )}

          {/* ── End of notes ── */}
          {!hasNextPage && notes.length > 0 && (
            <p className="notes-end-label">You've reached the end</p>
          )}

        </div>
      </div>

      {/* ── Floating Action Button ── */}
      <button
        className="fab"
        onClick={() => navigate("/notes/new")}
        title="New note"
      >
        +
      </button>

      {showBackToTop && (
        <button className="back-to-top" onClick={scrollToTop} title="Back to top">
          ↑
        </button>
      )}

      {toast && (
        <div className={`toast ${toast.type}`}>
          <span>{toast.message}</span>
          {pendingDeleteId && (
            <button
              className="toast-undo-btn"
              onClick={handleUndoDelete}
            >
              Undo
            </button>
          )}
        </div>
      )}
    </>
  );
}