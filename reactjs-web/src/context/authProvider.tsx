import { useEffect, useState, type ReactNode } from "react";
import { getCurrentUser, logout } from "../services/authService";
import { AuthContext } from "./authContext";
import { setAccessToken as setTokenHelper } from "./accessTokenHelper";

interface AuthProviderProps {
  children: ReactNode;
}
interface User {
  _id: string;
  username: string;
}

export const AuthProvider = ({ children }: AuthProviderProps) => {
  const [user, setUser] = useState<User | null>(null);
  const [accessToken, setAccessTokenState] = useState<string | null>(null);
  const setAccessToken = (token: string | null) => {
    setAccessTokenState(token);
    setTokenHelper(token ?? "");
  };

  useEffect(() => {
    const loadUser = async () => {
      try {
        const data = await getCurrentUser();
        setUser(data);
      } catch {
        setUser(null);
      }
    };
    loadUser();
  }, []);

  const logoutUser = async () => {
    await logout();
    setUser(null);
    setAccessToken(null);
  };

  return (
    <AuthContext.Provider
      value={{ user, setUser, accessToken, setAccessToken, logoutUser }}
    >
      {children}
    </AuthContext.Provider>
  );
};