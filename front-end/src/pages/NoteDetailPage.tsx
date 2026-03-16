import { useNoteDetail } from "../hooks/useNotes";
import Navbar from "../components/Navbar";
import "../styles/editor.css";

export default function NoteDetailPage() {
  const {
    note,
    isLoading,
    error,
    isEditing,
    title,
    setTitle,
    content,
    setContent,
    handleStartEditing,
    handleSave,
    handleDiscard,
    handleKeyDown,
    formatDate,
    wordCount,
    isReady,
    isUpdating,
    isError,
    navigate,
    notFound,
    toast,
  } = useNoteDetail();

  /* ── Loading ── */
  if (isLoading) {
    return (
      <>
        <Navbar />
        <div className="loading-wrapper">
          <div className="loading-spinner" />
          <p className="loading-text">Loading note...</p>
        </div>
      </>
    );
  }

  if (notFound) {
    return (
      <>
        <Navbar />
        <div className="page-wrapper">
          <div style={{ paddingTop: 40 }}>
            <div className="error-banner">
              ⚠️ Note not found. It may have been deleted.
            </div>
            <button
              className="btn btn-secondary"
              style={{ marginTop: 16 }}
              onClick={() => navigate("/notes")}
            >
              ← Back to Notes
            </button>
          </div>
        </div>
      </>
    );
  }

  /* ── Error / Not found ── */
  if (error || !note) {
    return (
      <>
        <Navbar />
        <div className="page-wrapper">
          <div style={{ paddingTop: 40 }}>
            <div className="error-banner">
              Note not found or failed to load.
            </div>
            <button
              className="btn btn-secondary"
              style={{ marginTop: 16 }}
              onClick={() => navigate("/notes")}
            >
              ← Back to Notes
            </button>
          </div>
        </div>
      </>
    );
  }

  /* EDIT MODE */
  if (isEditing) {
    return (
      <>
        <Navbar />
        <div className="page-wrapper" onKeyDown={handleKeyDown}>
          <div className="note-editor-page">

            {/* ── Topbar ── */}
            <div className="editor-topbar">
              <div className="editor-breadcrumb">
                <button
                  className="btn btn-ghost btn-sm"
                  onClick={() => navigate("/notes")}
                >
                  ← Notes
                </button>
                <span className="editor-breadcrumb-sep">›</span>
                <span
                  className="editor-breadcrumb-current"
                  style={{
                    maxWidth: 180,
                    overflow: "hidden",
                    textOverflow: "ellipsis",
                    whiteSpace: "nowrap",
                    display: "inline-block",
                  }}
                >
                  {note.title}
                </span>
                <span className="editor-breadcrumb-sep">›</span>
                <span className="editor-breadcrumb-current">Editing</span>
              </div>

              <div className="editor-topbar-actions">
                <button
                  className="btn btn-secondary"
                  onClick={handleDiscard}
                >
                  Discard
                </button>
                <button
                  className="btn btn-primary"
                  onClick={handleSave}
                  disabled={!isReady || isUpdating}
                >
                  {isUpdating ? "Saving..." : "Save Changes"}
                </button>
              </div>
            </div>

            {/* ── Error ── */}
            {isError && (
              <div className="error-banner">
                Failed to save changes. Please try again.
              </div>
            )}

            {/* ── Editor Card ── */}
            <div className="editor-card">

              {/* Title */}
              <textarea
                className="editor-title-input"
                rows={1}
                value={title}
                maxLength={120}
                autoFocus
                onChange={(e) => {
                  e.target.style.height = "auto";
                  e.target.style.height = e.target.scrollHeight + "px";
                  setTitle(e.target.value);
                }}
              />

              <div className="editor-divider" />

              {/* Content */}
              <textarea
                className="editor-content-input"
                value={content}
                onChange={(e) => setContent(e.target.value)}
              />

              {/* ── Footer ── */}
              <div className="editor-footer">
                <div className="editor-meta">
                  <span className="editor-char-count">
                    {wordCount} {wordCount === 1 ? "word" : "words"}
                  </span>
                  <span className="editor-char-count">·</span>
                  <span className="editor-char-count">
                    {content.length} characters
                  </span>
                  <span className="editor-char-count">·</span>
                  <span className="editor-char-count">Esc to discard</span>
                </div>

                <div className="editor-footer-actions">
                  <button
                    className="btn btn-secondary btn-sm"
                    onClick={handleDiscard}
                  >
                    Cancel
                  </button>
                  <button
                    className="btn btn-accent btn-sm"
                    onClick={handleSave}
                    disabled={!isReady || isUpdating}
                  >
                    {isUpdating ? "Saving..." : "✓ Save Changes"}
                  </button>
                </div>
              </div>

            </div>
          </div>
        </div>
      </>
    );
  }

  /* READ MODE */
  return (
    <>
      <Navbar />
      <div className="page-wrapper">
        <div className="note-detail-page">

          {/* ── Topbar ── */}
          <div className="note-detail-topbar">
            <button
              className="btn btn-ghost btn-sm"
              onClick={() => navigate("/notes")}
            >
              ← Back to Notes
            </button>

            <div className="note-detail-actions-bar">
              <button
                className="btn btn-secondary btn-sm"
                onClick={handleStartEditing}
              >
                ✏️ Edit
              </button>
            </div>
          </div>

          {/* ── Meta ── */}
          <div className="note-detail-meta">
            <span className="note-detail-date">{formatDate(note.createdAt)}</span>
            <span className="note-detail-badge">Note</span>
          </div>

          {/* ── Title ── */}
          <h1 className="note-detail-title">{note.title}</h1>

          {/* ── Amber accent line ── */}
          <div className="note-detail-divider" />

          {/* ── Body ── */}
          <p className="note-detail-body">{note.content}</p>

        </div>
      </div>
      {toast && (
        <div className={`toast ${toast.type}`}>
          {toast.message}
        </div>
      )}
    </>
  );
}