import { createContext } from "react";

export interface User {
  _id: string;
  username: string;
}

export interface AuthContextType {
  user: User | null;
  setUser: (user: User | null) => void;
  accessToken: string | null;
  setAccessToken: (token: string | null) => void;
  logoutUser: () => Promise<void>;
}

export const AuthContext = createContext<AuthContextType | null>(null);
