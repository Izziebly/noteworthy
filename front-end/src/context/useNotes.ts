import { useRef, useState, useEffect, useCallback } from "react";
import { useNavigate, useParams, useLocation } from "react-router-dom";
import {
  useInfiniteQuery,
  useQuery,
  useMutation,
  useQueryClient,
} from "@tanstack/react-query";
import {
  getNotes,
  getNoteById,
  createNote,
  updateNote,
  deleteNote,
  type Note,
} from "../services/noteService";

/* TOAST */

export function useToast() {
  const [toast, setToast] = useState<{
    message: string;
    type: "success" | "error";
  } | null>(null);

  const showToast = useCallback(
    (message: string, type: "success" | "error" = "success") => {
      setToast({ message, type });
      setTimeout(() => setToast(null), 8000);
    },
    [],
  );
  return { toast, showToast };
}

/* NOTES PAGE LOGIC */

export function useNotes() {
  const navigate = useNavigate();
  const location = useLocation();
  const queryClient = useQueryClient();
  const { showToast, toast } = useToast();

  const [search, setSearch] = useState("");
  const [activeNoteId, setActiveNoteId] = useState<string | null>(null);
  const holdTimer = useRef<ReturnType<typeof setTimeout> | null>(null);
  const deleteTimer = useRef<ReturnType<typeof setTimeout> | null>(null);
  const [pendingDeleteId, setPendingDeleteId] = useState<string | null>(null);

  /* ── Fetch all notes ── */
  const {
    data,
    isLoading,
    error,
    fetchNextPage,
    hasNextPage,
    isFetchingNextPage,
  } = useInfiniteQuery({
    queryKey: ["notes"],
    queryFn: ({ pageParam = 1 }) => getNotes(pageParam),
    initialPageParam: 1,
    getNextPageParam: (lastPage) =>
      lastPage.page < lastPage.pages ? lastPage.page + 1 : undefined,
  });

  const notes: Note[] = data?.pages.flatMap((p) => p.notes) ?? [];

  useEffect(() => {
    if (location.state?.toast) {
      showToast(location.state.toast);
      window.history.replaceState({}, "");
    }
  }, [location.state, showToast]);

  /* ── Delete mutation ── */
  const deleteMutation = useMutation({
    mutationFn: deleteNote,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["notes"] });
    },
    onError: () => {
      showToast("Failed to delete note", "error");
    },
  });

  const handleDeleteNote = (id: string) => {
    setPendingDeleteId(id);
    setActiveNoteId(null);

    queryClient.setQueryData<{ pages: { notes: Note[] }[] }>(
      ["notes"],
      (old) => {
        if (!old) return old;
        return {
          ...old,
          pages: old.pages.map((page) => ({
            ...page,
            notes: page.notes.filter((n) => n._id !== id),
          })),
        };
      },
    );

    showToast("Note deleted", "success");

    deleteTimer.current = setTimeout(() => {
      deleteMutation.mutate(id);
      setPendingDeleteId(null);
    }, 8000);
  };

  /* ── Undo delete ── */
  const handleUndoDelete = () => {
    if (deleteTimer.current) {
      clearTimeout(deleteTimer.current);
      deleteTimer.current = null;
    }
    queryClient.invalidateQueries({ queryKey: ["notes"] });
    setPendingDeleteId(null);
    showToast("Delete undone", "success");
  };

  /* ── Filtered notes ── */
  const filtered = notes.filter(
    (note) =>
      note.title.toLowerCase().includes(search.toLowerCase()) ||
      note.content.toLowerCase().includes(search.toLowerCase()),
  );

  const observerRef = useRef<IntersectionObserver | null>(null);
  const loadMoreRef = useCallback(
    (node: HTMLDivElement | null) => {
      if (isFetchingNextPage) return;
      if (observerRef.current) observerRef.current.disconnect();
      if (!node) return;

      observerRef.current = new IntersectionObserver((entries) => {
        if (entries[0].isIntersecting && hasNextPage) {
          fetchNextPage();
        }
      });

      observerRef.current.observe(node);
    },
    [isFetchingNextPage, hasNextPage, fetchNextPage],
  );

  /* ── Long press handlers ── */

    useEffect(() => {
    if (!activeNoteId) return;
 
    const handleOutside = (e: MouseEvent | TouchEvent) => {
      const target = e.target as HTMLElement;
      if (!target.closest(".note-card-popup")) {
        setActiveNoteId(null);
      }
    };
 
    const timer = setTimeout(() => {
      document.addEventListener("mousedown", handleOutside);
      document.addEventListener("touchstart", handleOutside);
    }, 300);
 
    return () => {
      clearTimeout(timer);
      document.removeEventListener("mousedown", handleOutside);
      document.removeEventListener("touchstart", handleOutside);
    };
  }, [activeNoteId]);
 
  /* ── Mouse handlers (desktop) ── */
  const handleMouseDown = (id: string) => {
    holdTimer.current = setTimeout(() => setActiveNoteId(id), 500);
  };
 
  const handleMouseUp = () => {
    if (holdTimer.current) {
      clearTimeout(holdTimer.current);
      holdTimer.current = null;
    }
  };
 
  /* ── Touch handlers (mobile) ── */
  const handleTouchStart = (id: string) => {
    holdTimer.current = setTimeout(() => setActiveNoteId(id), 500);
  };
 
  const handleTouchEnd = () => {
    if (holdTimer.current) {
      clearTimeout(holdTimer.current);
      holdTimer.current = null;
    }
  };
 
  /* ── Format date (short) ── */
  const formatDate = (dateStr?: string) => {
    if (!dateStr) return "";
    return new Date(dateStr).toLocaleDateString("en-US", {
      month: "short",
      day: "numeric",
      year: "numeric",
    });
  };
 
  return {
    notes,
    filtered,
    isLoading,
    error,
    search,
    setSearch,
    activeNoteId,
    setActiveNoteId,
    handleMouseDown,
    handleMouseUp,
    handleTouchStart,
    handleTouchEnd,
    formatDate,
    isDeleting: deleteMutation.isPending,
    navigateToNote: (slug: string) => navigate(`/notes/${slug}`),
    navigate,
    toast,
    deleteNote: handleDeleteNote,
    pendingDeleteId,
    handleUndoDelete,
    loadMoreRef,
    isFetchingNextPage,
    hasNextPage,
  };
}

/* CREATE NOTE PAGE LOGIC */

export function useCreateNote() {
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const { showToast, toast } = useToast();

  const [title, setTitle] = useState("");
  const [content, setContent] = useState("");

  /* ── Create mutation ── */
  const createMutation = useMutation({
    mutationFn: createNote,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["notes"] });
      navigate("/notes", { state: { toast: "Note saved successfully" } });
    },
    onError: () => {
      showToast("Failed to save note", "error");
    },
  });

  /* ── Submit ── */
  const handleSubmit = () => {
    if (!title.trim() || !content.trim()) return;
    createMutation.mutate({ title: title.trim(), content: content.trim() });
  };

  /* ── Cmd/Ctrl + S to save ── */
  const handleKeyDown = (e: React.KeyboardEvent) => {
    if ((e.metaKey || e.ctrlKey) && e.key === "s") {
      e.preventDefault();
      handleSubmit();
    }
  };

  const wordCount = content.trim() ? content.trim().split(/\s+/).length : 0;
  const isReady = title.trim().length > 0 && content.trim().length > 0;

  return {
    title,
    setTitle,
    content,
    setContent,
    handleSubmit,
    handleKeyDown,
    wordCount,
    isReady,
    isCreating: createMutation.isPending,
    isError: createMutation.isError,
    navigate,
    toast,
  };
}

/* NOTE DETAIL / EDIT PAGE LOGIC */

export function useNoteDetail() {
  const { slug } = useParams<{ slug: string }>();
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const { showToast, toast } = useToast();

  const cachedData = queryClient.getQueryData<{
    pages: { notes: Note[] }[];
  }>(["notes"]);
  const cachedNotes = cachedData?.pages.flatMap((p) => p.notes) ?? [];
  const matched = cachedNotes.find((n) => n.slug === slug);

  const [isEditing, setIsEditing] = useState(false);
  const [title, setTitle] = useState("");
  const [content, setContent] = useState("");

  /* ── Fetch single note ── */
  const {
    data: note,
    isLoading,
    error,
  } = useQuery({
    queryKey: ["notes", matched?._id],
    queryFn: () => getNoteById(matched!._id),
    enabled: !!matched?._id,
  });

  /* ── Update mutation ── */
  const updateMutation = useMutation({
    mutationFn: ({
      id,
      data,
    }: {
      id: string;
      data: { title: string; content: string };
    }) => updateNote(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["notes"] });
      queryClient.invalidateQueries({ queryKey: ["notes", matched?._id] });
      setIsEditing(false);
      showToast("Changes saved successfully");
    },
    onError: () => {
      showToast("Failed to save changes", "error");
    },
  });

  /* ── Enter edit mode ── */
  const handleStartEditing = () => {
    if (!note) return;
    setTitle(note.title);
    setContent(note.content);
    setIsEditing(true);
  };

  /* ── Save ── */
  const handleSave = () => {
    if (!title.trim() || !content.trim() || !note?._id) return;
    updateMutation.mutate({
      id: note._id,
      data: { title: title.trim(), content: content.trim() },
    });
  };

  /* ── Discard edits ── */
  const handleDiscard = () => {
    setTitle("");
    setContent("");
    setIsEditing(false);
  };

  /* ── Cmd/Ctrl + S to save, Escape to discard ── */
  const handleKeyDown = (e: React.KeyboardEvent) => {
    if ((e.metaKey || e.ctrlKey) && e.key === "s") {
      e.preventDefault();
      handleSave();
    }
    if (e.key === "Escape") {
      handleDiscard();
    }
  };

  /* ── Format date (long) ── */
  const formatDate = (dateStr?: string) => {
    if (!dateStr) return "";
    return new Date(dateStr).toLocaleDateString("en-US", {
      weekday: "long",
      month: "long",
      day: "numeric",
      year: "numeric",
    });
  };

  const wordCount = content.trim() ? content.trim().split(/\s+/).length : 0;
  const isReady = title.trim().length > 0 && content.trim().length > 0;

  return {
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
    isUpdating: updateMutation.isPending,
    isError: updateMutation.isError,
    notFound: !matched && !isLoading,
    navigate,
    toast, // ← expose toast so page can render it
  };
}
