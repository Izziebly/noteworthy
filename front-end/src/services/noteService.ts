import { request } from "../api/request";

export interface Note {
  _id: string;
  title: string;
  content: string;
  slug: string;
  createdAt?: string;
  updatedAt?: string;
}

interface NoteInput {
  title: string;
  content: string;
}

export interface PaginatedNotes {
  total: number;
  page: number;
  pages: number;
  notes: Note[];
}

export const getNotes = (page: number = 1): Promise<PaginatedNotes> =>
  request<PaginatedNotes>("get", `/notes?page=${page}&limit=10`);

export const getNoteById = (id: string) => request<Note>("get", `/notes/${id}`);

export const createNote = (data: NoteInput) =>
  request<Note>("post", "/notes", data);

export const updateNote = (id: string, data: NoteInput) =>
  request<Note>("put", `/notes/${id}`, data);

export const deleteNote = (id: string) =>
  request<void>("delete", `/notes/${id}`);
