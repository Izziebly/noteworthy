import { useCreateNote } from "../hooks/useNotes";
import Navbar from "../components/Navbar";
import "../styles/editor.css";

export default function CreateNotePage() {
  const {
    title,
    setTitle,
    content,
    setContent,
    handleSubmit,
    handleKeyDown,
    wordCount,
    isReady,
    isCreating,
    isError,
    navigate,
    toast,
  } = useCreateNote();

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
              <span className="editor-breadcrumb-current">New Note</span>
            </div>

            <div className="editor-topbar-actions">
              <button
                className="btn btn-secondary"
                onClick={() => navigate("/notes")}
              >
                Discard
              </button>
              <button
                className="btn btn-primary"
                onClick={handleSubmit}
                disabled={!isReady || isCreating}
              >
                {isCreating ? "Saving..." : "Save Note"}
              </button>
            </div>
          </div>

          {/* ── Error ── */}
          {isError && (
            <div className="error-banner">
              Failed to save note. Please try again.
            </div>
          )}

          {/* ── Editor Card ── */}
          <div className="editor-card">

            {/* Title */}
            <textarea
              className="editor-title-input"
              placeholder="Note title..."
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
              placeholder="Start writing..."
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
              </div>

              <div className="editor-footer-actions">
                <button
                  className="btn btn-secondary btn-sm"
                  onClick={() => navigate("/notes")}
                >
                  Cancel
                </button>
                <button
                  className="btn btn-accent btn-sm"
                  onClick={handleSubmit}
                  disabled={!isReady || isCreating}
                >
                  {isCreating ? "Saving..." : "✓ Save Note"}
                </button>
              </div>
            </div>

          </div>
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